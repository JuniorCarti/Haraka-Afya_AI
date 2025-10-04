import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCService {
  late IO.Socket _socket;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  
  // Event callbacks
  List<Function(MediaStream)> onAddRemoteStream = [];
  List<Function(MediaStream)> onRemoveRemoteStream = [];
  List<Function(String)> onError = [];
  List<Function(String, String)> onUserJoined = [];
  List<Function(String, String)> onUserLeft = [];
  List<Function(String, bool)> onUserAudioChanged = [];

  // Server configuration - Use Railway URL for production
  static const String _signalingServer = 'https://haraka-afya-voice-production.up.railway.app';

  // For development, you can switch between local and production:
  // static const String _signalingServer = kDebugMode 
  //   ? 'http://localhost:3000'
  //   : 'https://haraka-afya-voice-production.up.railway.app';

  bool get isConnected => _socket.connected;

  Future<void> initialize() async {
    try {
      print('🔄 Initializing WebRTC service...');
      print('🌐 Connecting to: $_signalingServer');
      
      _socket = IO.io(_signalingServer, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'forceNew': true,
        'timeout': 10000,
      });

      _setupSocketListeners();
      await _waitForConnection();
      print('✅ WebRTC service initialized successfully');
      
    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      _onError('Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  Future<void> _waitForConnection() async {
    final completer = Completer();
    
    _socket.once('connect', (_) {
      print('🔗 Connected to signaling server: $_signalingServer');
      completer.complete();
    });

    _socket.once('connect_error', (error) {
      print('❌ Connection error: $error');
      completer.completeError(error);
    });

    _socket.once('connect_timeout', (_) {
      print('⏰ Connection timeout');
      completer.completeError(TimeoutException('Connection timeout'));
    });

    return completer.future.timeout(const Duration(seconds: 15));
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      print('✅ Connected to signaling server');
    });

    _socket.on('disconnect', (reason) {
      print('❌ Disconnected from signaling server: $reason');
      _onError('Disconnected from server: $reason');
    });

    _socket.on('connect_error', (error) {
      print('❌ Connection error: $error');
      _onError('Connection failed: $error');
    });

    _socket.on('user-joined', (data) {
      final userId = data['userId'];
      final username = data['username'];
      print('👤 User joined: $username ($userId)');
      for (final callback in onUserJoined) {
        callback(userId, username);
      }
      _onUserJoined(userId);
    });

    _socket.on('user-left', (data) {
      final userId = data['userId'];
      final username = data['username'];
      print('👤 User left: $username ($userId)');
      for (final callback in onUserLeft) {
        callback(userId, username);
      }
      _onUserLeft(userId);
    });

    _socket.on('room-users', (data) {
      final users = List.from(data['users']);
      print('📊 Existing room users: ${users.length}');
      for (final user in users) {
        _onUserJoined(user['id']);
      }
    });

    _socket.on('offer', (data) async {
      final offer = data['offer'];
      final userId = data['userId'];
      print('📞 Received offer from $userId');
      await _onOffer(offer, userId);
    });

    _socket.on('answer', (data) async {
      final answer = data['answer'];
      final userId = data['userId'];
      print('📨 Received answer from $userId');
      await _onAnswer(answer, userId);
    });

    _socket.on('ice-candidate', (data) async {
      final candidate = data['candidate'];
      final userId = data['userId'];
      print('🧊 Received ICE candidate from $userId');
      await _onIceCandidate(candidate, userId);
    });

    _socket.on('user-audio-changed', (data) {
      final userId = data['userId'];
      final isMuted = data['isMuted'];
      final username = data['username'];
      print('🎤 User audio changed: $username - muted: $isMuted');
      for (final callback in onUserAudioChanged) {
        callback(userId, isMuted);
      }
    });

    // Ping-pong for connection health
    _socket.on('pong', (data) {
      print('🏓 Server pong received');
    });
  }

  Future<void> joinRoom(String roomId, String userId, String username) async {
    try {
      print('🚀 Joining room: $roomId as $username ($userId)');
      await _getUserMedia();
      _socket.emit('join-room', {
        'roomId': roomId,
        'userId': userId,
        'username': username
      });
      print('✅ Room join request sent');
    } catch (e) {
      print('❌ Error joining room: $e');
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    print('🚪 Leaving room: $roomId');
    try {
      _socket.emit('leave-room', {'roomId': roomId, 'userId': userId});
      await _cleanup();
      print('✅ Left room successfully');
    } catch (e) {
      print('❌ Error leaving room: $e');
      rethrow;
    }
  }

  Future<void> _getUserMedia() async {
    try {
      print('🎤 Requesting microphone access...');
      
      final mediaConstraints = <String, dynamic>{
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'channelCount': 1,
          'sampleRate': 48000,
          'sampleSize': 16,
        },
        'video': false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      print('✅ Got local audio stream');
      
      // Log stream information
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        print('🎵 Audio track enabled: ${audioTracks.first.enabled}');
        print('🎵 Audio track enabled: ${audioTracks.first.enabled}');
      }
      
    } catch (e) {
      print('❌ Error getting user media: $e');
      _onError('Failed to access microphone: $e');
      rethrow;
    }
  }

  Future<void> _onUserJoined(String remoteUserId) async {
    if (_localStream == null) {
      print('❌ No local stream available for connection');
      return;
    }

    try {
      print('🔗 Connecting to user: $remoteUserId');
      final peerConnection = await _createPeerConnection();
      _peerConnections[remoteUserId] = peerConnection;

      // Add local stream to connection
      _localStream!.getTracks().forEach((track) {
        peerConnection.addTrack(track, _localStream!);
      });

      // Create and send offer
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);
      
      _socket.emit('offer', {
        'offer': offer.toMap(),
        'targetUserId': remoteUserId,
      });
      
      print('📞 Sent offer to $remoteUserId');
      
    } catch (e) {
      print('❌ Error creating peer connection: $e');
      _onError('Failed to connect to user: $e');
    }
  }

  Future<void> _onOffer(dynamic offerData, String remoteUserId) async {
    if (_localStream == null) {
      print('❌ No local stream available for answering offer');
      return;
    }

    try {
      print('📞 Processing offer from $remoteUserId');
      final peerConnection = await _createPeerConnection();
      _peerConnections[remoteUserId] = peerConnection;

      // Add local stream to connection
      _localStream!.getTracks().forEach((track) {
        peerConnection.addTrack(track, _localStream!);
      });

      await peerConnection.setRemoteDescription(
        RTCSessionDescription(offerData['sdp'], offerData['type']),
      );

      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);
      
      _socket.emit('answer', {
        'answer': answer.toMap(),
        'targetUserId': remoteUserId,
      });
      
      print('📨 Sent answer to $remoteUserId');
      
    } catch (e) {
      print('❌ Error processing offer: $e');
      _onError('Failed to process offer: $e');
    }
  }

  Future<void> _onAnswer(dynamic answerData, String remoteUserId) async {
    final peerConnection = _peerConnections[remoteUserId];
    if (peerConnection == null) {
      print('❌ No peer connection for user: $remoteUserId');
      return;
    }

    try {
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(answerData['sdp'], answerData['type']),
      );
      print('✅ Set remote description for $remoteUserId');
    } catch (e) {
      print('❌ Error setting remote description: $e');
      _onError('Failed to set remote description: $e');
    }
  }

  Future<void> _onIceCandidate(dynamic candidateData, String remoteUserId) async {
    final peerConnection = _peerConnections[remoteUserId];
    if (peerConnection == null) {
      print('❌ No peer connection for ICE candidate from: $remoteUserId');
      return;
    }

    try {
      await peerConnection.addCandidate(RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      ));
      print('✅ Added ICE candidate from $remoteUserId');
    } catch (e) {
      print('❌ Error adding ICE candidate: $e');
    }
  }

  void _onUserLeft(String remoteUserId) {
    print('👤 User left, cleaning up: $remoteUserId');
    _peerConnections.remove(remoteUserId)?.close();
    
    final stream = _remoteStreams.remove(remoteUserId);
    if (stream != null) {
      for (final callback in onRemoveRemoteStream) {
        callback(stream);
      }
      print('✅ Cleaned up remote stream for $remoteUserId');
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
        {'urls': 'stun:stun3.l.google.com:19302'},
        {'urls': 'stun:stun4.l.google.com:19302'},
      ],
    };

    final peerConnection = await createPeerConnection(configuration);

    // Set up event listeners
    peerConnection.onIceCandidate = (candidate) {
      final userId = _getUserIdByConnection(peerConnection);
      if (userId != null) {
        _socket.emit('ice-candidate', {
          'candidate': candidate.toMap(),
          'targetUserId': userId,
        });
        print('🧊 Sent ICE candidate to $userId');
      }
    };

    peerConnection.onAddStream = (stream) {
      final userId = _getUserIdByConnection(peerConnection);
      if (userId != null) {
        _remoteStreams[userId] = stream;
        print('🎧 Added remote stream from user: $userId');
        for (final callback in onAddRemoteStream) {
          callback(stream);
        }
      }
    };

    peerConnection.onRemoveStream = (stream) {
      final userId = _getUserIdByConnection(peerConnection);
      if (userId != null) {
        _onUserLeft(userId);
      }
    };

    peerConnection.onIceConnectionState = (state) {
      print('🧊 ICE connection state: $state');
    };

    peerConnection.onSignalingState = (state) {
      print('📡 Signaling state: $state');
    };

    return peerConnection;
  }

  String? _getUserIdByConnection(RTCPeerConnection connection) {
    try {
      return _peerConnections.entries
          .firstWhere((entry) => entry.value == connection)
          .key;
    } catch (e) {
      return null;
    }
  }

  void _onError(String message) {
    print('❌ WebRTC Error: $message');
    for (final callback in onError) {
      callback(message);
    }
  }

  // Audio control methods
  Future<void> toggleMicrophone(bool mute) async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (final track in audioTracks) {
        track.enabled = !mute;
      }
      
      // Notify other users
      _socket.emit('toggle-audio', {
        'isMuted': mute,
        'userId': _socket.id,
      });
      
      print('🎤 ${mute ? 'Muted' : 'Unmuted'} microphone');
    } else {
      print('❌ No local stream available for mute/unmute');
    }
  }

  bool get isMicrophoneMuted {
    if (_localStream == null) return true;
    final audioTracks = _localStream!.getAudioTracks();
    return audioTracks.isEmpty || !audioTracks.first.enabled!;
  }

  Future<void> _cleanup() async {
    print('🧹 Cleaning up WebRTC resources...');
    
    for (final connection in _peerConnections.values) {
      await connection.close();
    }
    _peerConnections.clear();

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
      _localStream = null;
    }

    _remoteStreams.clear();
    
    if (_socket.connected) {
      _socket.disconnect();
    }
    
    print('✅ WebRTC cleanup complete');
  }

  // Send ping to check connection health
  void sendPing() {
    if (_socket.connected) {
      _socket.emit('ping', {'timestamp': DateTime.now().millisecondsSinceEpoch});
    }
  }

  List<MediaStream> get remoteStreams => _remoteStreams.values.toList();
  MediaStream? get localStream => _localStream;

  void dispose() {
    _cleanup();
  }
}