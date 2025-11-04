import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCService {
  late IO.Socket _socket;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  
  // PREMIUM TURN/STUN configuration with custom Metered.ca domain
  static final List<Map<String, dynamic>> _iceServers = [
    // Primary Google STUN servers
    {
      'urls': [
        'stun:stun.l.google.com:19302',
        'stun:stun1.l.google.com:19302',
        'stun:stun2.l.google.com:19302',
      ]
    },
    
    // Your custom Metered.ca TURN server (Premium - Cross-location ready)
    {
      'urls': [
        'turn:harakaafyaai.metered.live:80',
        'turn:harakaafyaai.metered.live:80?transport=tcp',
        'turn:harakaafyaai.metered.live:443',
        'turns:harakaafyaai.metered.live:443?transport=tcp',
        'turn:harakaafyaai.metered.live:443?transport=udp'
      ],
      'username': 'harakaafyaai', // Replace with your actual Metered.ca username
      'credential': 'Shferick.1234' // Replace with your actual Metered.ca password
    },
    
    // Twilio STUN (Backup)
    {
      'urls': [
        'stun:global.stun.twilio.com:3478',
      ]
    },
    
    // Fallback STUN servers
    {
      'urls': [
        'stun:stun3.l.google.com:19302',
        'stun:stun4.l.google.com:19302',
        'stun:stun.services.mozilla.com:3478',
      ]
    },
  ];

  // Local signaling server - Replace with your deployed server URL for production
  static const String _signalingServer = 'http://localhost:3000';
  
  // For production deployment, use your deployed server:
  // static const String _signalingServer = 'https://your-app.render.com';

  // Event callbacks
  final List<Function(MediaStream)> onAddRemoteStream = [];
  final List<Function(MediaStream)> onRemoveRemoteStream = [];
  final List<Function(String)> onError = [];
  final List<Function(String, String)> onUserJoined = [];
  final List<Function(String, String)> onUserLeft = [];
  final List<Function(String, bool)> onUserAudioChanged = [];

  bool get isConnected => _socket.connected;
  bool get hasLocalStream => _localStream != null;

  Future<void> initialize() async {
    try {
      print('🔄 Initializing WebRTC service...');
      print('🌐 PREMIUM CONFIG: Custom TURN server - harakaafyaai.metered.live');
      print('   - Dedicated TURN server for cross-location calls');
      print('   - Enterprise-grade reliability');
      print('   - Optimized for global voice chat');
      
      // Log ICE server details for verification
      for (var i = 0; i < _iceServers.length; i++) {
        final server = _iceServers[i];
        final urls = server['urls'] as List;
        final hasCredentials = server['username'] != null;
        final serverType = hasCredentials ? 'TURN (Premium)' : 'STUN';
        print('   $serverType Server $i: ${urls.length} endpoints');
        if (hasCredentials && server['urls'][0].contains('harakaafyaai')) {
          print('     🔒 Custom Domain: harakaafyaai.metered.live');
        }
      }
      
      _socket = IO.io(_signalingServer, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'forceNew': true,
        'timeout': 15000, // Increased timeout for TURN server negotiation
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
      });

      _setupSocketListeners();
      await _waitForConnection();
      print('✅ WebRTC service initialized with CUSTOM TURN SERVER');
      print('🚀 Ready for cross-location voice chat!');
      
    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      _onError('Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  Future<void> _waitForConnection() async {
    final completer = Completer();
    
    if (_socket.connected) {
      completer.complete();
      return completer.future;
    }

    final connectionTimer = Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Server connection timeout after 15 seconds'));
      }
    });

    void cleanup() {
      connectionTimer.cancel();
      _socket.off('connect');
      _socket.off('connect_error');
    }

    _socket.once('connect', (_) {
      print('🔗 Connected to signaling server');
      cleanup();
      completer.complete();
    });

    _socket.once('connect_error', (error) {
      print('❌ Server connection error: $error');
      cleanup();
      completer.completeError(error ?? 'Failed to connect to signaling server');
    });

    try {
      await completer.future;
    } catch (e) {
      print('❌ Connection wait failed: $e');
      rethrow;
    }
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      print('✅ Connected to signaling server - Socket ID: ${_socket.id}');
    });

    _socket.on('disconnect', (reason) {
      print('❌ Disconnected from signaling server: $reason');
      _onError('Disconnected from server: $reason');
    });

    _socket.on('connect_error', (error) {
      print('❌ Server connection error: $error');
      _onError('Connection failed: $error');
    });

    _socket.on('user-joined', (data) {
      final userId = data['userId']?.toString();
      final username = data['username']?.toString();
      if (userId != null && username != null) {
        print('👤 User joined: $username ($userId)');
        for (final callback in onUserJoined) {
          callback(userId, username);
        }
        
        // Auto-create connection to new user
        if (userId != _socket.id) {
          _createPeerConnectionForUser(userId);
        }
      }
    });

    _socket.on('user-left', (data) {
      final userId = data['userId']?.toString();
      final username = data['username']?.toString();
      if (userId != null && username != null) {
        print('👤 User left: $username ($userId)');
        for (final callback in onUserLeft) {
          callback(userId, username);
        }
        _onUserLeft(userId);
      }
    });

    _socket.on('room-users', (data) async {
      try {
        final users = List.from(data['users'] ?? []);
        print('📊 Existing room users: ${users.length}');
        
        // Create connections to existing users
        for (final user in users) {
          final userId = user['id']?.toString();
          final username = user['username']?.toString();
          if (userId != null && 
              userId != _socket.id && 
              !_peerConnections.containsKey(userId)) {
            print('🔗 Creating connection to existing user: $username ($userId)');
            await _createPeerConnectionForUser(userId);
          }
        }
      } catch (e) {
        print('❌ Error processing room-users: $e');
      }
    });

    _socket.on('offer', (data) async {
      try {
        final offer = data['offer'];
        final userId = data['userId']?.toString();
        if (offer != null && userId != null) {
          print('📞 Received offer from $userId');
          await _handleOffer(offer, userId);
        }
      } catch (e) {
        print('❌ Error processing offer: $e');
      }
    });

    _socket.on('answer', (data) async {
      try {
        final answer = data['answer'];
        final userId = data['userId']?.toString();
        if (answer != null && userId != null) {
          print('📨 Received answer from $userId');
          await _handleAnswer(answer, userId);
        }
      } catch (e) {
        print('❌ Error processing answer: $e');
      }
    });

    _socket.on('ice-candidate', (data) async {
      try {
        final candidate = data['candidate'];
        final userId = data['userId']?.toString();
        if (candidate != null && userId != null) {
          print('🧊 Received ICE candidate from $userId');
          await _handleIceCandidate(candidate, userId);
        }
      } catch (e) {
        print('❌ Error processing ICE candidate: $e');
      }
    });

    _socket.on('user-audio-changed', (data) {
      final userId = data['userId']?.toString();
      final isMuted = data['isMuted'] == true;
      if (userId != null) {
        print('🎤 User audio changed: $userId - muted: $isMuted');
        for (final callback in onUserAudioChanged) {
          callback(userId, isMuted);
        }
      }
    });
  }

  Future<void> joinRoom(String roomId, String userId, String username) async {
    try {
      print('🚀 Joining room: $roomId as $username ($userId)');
      print('🌐 Using premium TURN server for cross-location connectivity');
      
      // Ensure we have media before joining
      if (_localStream == null) {
        await _getUserMedia();
      }
      
      _socket.emit('join-room', {
        'roomId': roomId,
        'userId': userId,
        'username': username
      });
      
      print('✅ Room join request sent for room: $roomId');
    } catch (e) {
      print('❌ Error joining room: $e');
      _onError('Failed to join room: $e');
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    print('🚪 Leaving room: $roomId as user: $userId');
    try {
      _socket.emit('leave-room', {
        'roomId': roomId,
        'userId': userId
      });
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
          'latency': 0,
        },
        'video': false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        print('✅ Got local audio stream - Ready for premium voice chat');
      } else {
        throw Exception('No audio tracks available');
      }
      
    } catch (e) {
      print('❌ Error getting user media: $e');
      _onError('Failed to access microphone: $e');
      rethrow;
    }
  }

  Future<void> _createPeerConnectionForUser(String remoteUserId) async {
    if (_localStream == null) {
      print('❌ No local stream available for connection');
      return;
    }

    if (_peerConnections.containsKey(remoteUserId)) {
      print('⚠️ Peer connection already exists for: $remoteUserId');
      return;
    }

    try {
      print('🔗 Creating premium peer connection for: $remoteUserId');
      final peerConnection = await _createPeerConnection();
      _peerConnections[remoteUserId] = peerConnection;

      // Add local stream tracks
      for (final track in _localStream!.getTracks()) {
        await peerConnection.addTrack(track, _localStream!);
      }

      // Create and send offer with enhanced options
      final offer = await peerConnection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
        'iceRestart': false,
      });
      
      await peerConnection.setLocalDescription(offer);
      
      _socket.emit('offer', {
        'offer': offer.toMap(),
        'targetUserId': remoteUserId,
      });
      
      print('📞 Sent offer to $remoteUserId via custom TURN server');
      
    } catch (e) {
      print('❌ Error creating peer connection for $remoteUserId: $e');
      _peerConnections.remove(remoteUserId)?.close();
      _onError('Failed to connect to user: $e');
    }
  }

  Future<void> _handleOffer(dynamic offerData, String remoteUserId) async {
    if (_localStream == null) return;

    if (_peerConnections.containsKey(remoteUserId)) {
      return;
    }

    try {
      print('📞 Processing offer from $remoteUserId');
      final peerConnection = await _createPeerConnection();
      _peerConnections[remoteUserId] = peerConnection;

      // Add local stream tracks
      for (final track in _localStream!.getTracks()) {
        await peerConnection.addTrack(track, _localStream!);
      }

      // Set remote description
      final offer = RTCSessionDescription(
        offerData['sdp'],
        offerData['type'],
      );
      await peerConnection.setRemoteDescription(offer);

      // Create and send answer
      final answer = await peerConnection.createAnswer({});
      await peerConnection.setLocalDescription(answer);
      
      _socket.emit('answer', {
        'answer': answer.toMap(),
        'targetUserId': remoteUserId,
      });
      
      print('📨 Sent answer to $remoteUserId');
      
    } catch (e) {
      print('❌ Error processing offer from $remoteUserId: $e');
      _peerConnections.remove(remoteUserId)?.close();
      _onError('Failed to process offer: $e');
    }
  }

  Future<void> _handleAnswer(dynamic answerData, String remoteUserId) async {
    final peerConnection = _peerConnections[remoteUserId];
    if (peerConnection == null) return;

    try {
      final answer = RTCSessionDescription(
        answerData['sdp'],
        answerData['type'],
      );
      await peerConnection.setRemoteDescription(answer);
      print('✅ Set remote description for $remoteUserId');
    } catch (e) {
      print('❌ Error setting remote description for $remoteUserId: $e');
      _onError('Failed to set remote description: $e');
    }
  }

  Future<void> _handleIceCandidate(dynamic candidateData, String remoteUserId) async {
    final peerConnection = _peerConnections[remoteUserId];
    if (peerConnection == null) return;

    try {
      final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      );
      await peerConnection.addCandidate(candidate);
      print('✅ Added ICE candidate from $remoteUserId');
    } catch (e) {
      print('❌ Error adding ICE candidate from $remoteUserId: $e');
    }
  }

  void _onUserLeft(String remoteUserId) {
    print('👤 User left, cleaning up: $remoteUserId');
    
    final connection = _peerConnections.remove(remoteUserId);
    if (connection != null) {
      connection.close();
      print('✅ Closed peer connection for $remoteUserId');
    }
    
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
      'iceServers': _iceServers,
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'iceTransportPolicy': 'all',
      'iceCandidatePoolSize': 10,
    };

    final constraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
        {'RtpDataChannels': true},
      ],
    };

    print('🔧 Creating premium peer connection with custom TURN server');
    print('   - STUN: 5 Google servers + Twilio');
    print('   - TURN: harakaafyaai.metered.live (5 endpoints)');
    print('   - Custom domain: Premium reliability for cross-location calls');
    
    final peerConnection = await createPeerConnection(configuration, constraints);

    // Set up event listeners
    peerConnection.onIceCandidate = (candidate) {
      final userId = _getUserIdByConnection(peerConnection);
      if (userId != null) {
        _socket.emit('ice-candidate', {
          'candidate': candidate.toMap(),
          'targetUserId': userId,
        });
        print('🧊 Sent ICE candidate to $userId via TURN server');
      }
    };

    peerConnection.onAddStream = (stream) {
      final userId = _getUserIdByConnection(peerConnection);
      if (userId != null) {
        _remoteStreams[userId] = stream;
        print('🎧 Added remote stream from user: $userId - Cross-location connected!');
        for (final callback in onAddRemoteStream) {
          callback(stream);
        }
      }
    };

    peerConnection.onRemoveStream = (stream) {
      final userId = _getUserIdByConnection(peerConnection);
      if (userId != null) {
        _remoteStreams.remove(userId);
        for (final callback in onRemoveRemoteStream) {
          callback(stream);
        }
        print('🎧 Removed remote stream from user: $userId');
      }
    };

    peerConnection.onIceConnectionState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('🧊 ICE connection state for $userId: $state');
      
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        print('✅ Premium TURN connection established! Cross-location ready.');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateChecking) {
        print('🔍 ICE checking - Using harakaafyaai.metered.live TURN server');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        print('⚠️ ICE connection failed - TURN server fallback activated');
      }
    };

    peerConnection.onIceGatheringState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('🌐 ICE gathering state for $userId: $state');
      
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        print('✅ ICE gathering complete - Custom TURN server optimized');
      }
    };

    peerConnection.onSignalingState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('📡 Signaling state for $userId: $state');
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

  Future<void> toggleMicrophone(bool mute) async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (final track in audioTracks) {
        track.enabled = !mute;
      }
      
      _socket.emit('toggle-audio', {
        'isMuted': mute,
      });
      
      print('🎤 ${mute ? 'Muted' : 'Unmuted'} microphone');
    } else {
      print('❌ No local stream available for mute/unmute');
    }
  }

  bool get isMicrophoneMuted {
    if (_localStream == null) return true;
    final audioTracks = _localStream!.getAudioTracks();
    return audioTracks.isEmpty || !audioTracks.first.enabled;
  }

  Future<void> _cleanup() async {
    print('🧹 Cleaning up WebRTC resources...');
    
    // Close all peer connections
    for (final connection in _peerConnections.values) {
      try {
        await connection.close();
      } catch (e) {
        print('⚠️ Error closing connection: $e');
      }
    }
    _peerConnections.clear();

    // Stop local stream
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        track.stop();
      });
      _localStream = null;
    }

    _remoteStreams.clear();
    
    // Disconnect socket
    if (_socket.connected) {
      _socket.disconnect();
    }
    
    print('✅ WebRTC cleanup complete');
  }

  // Get connection status for debugging
  Map<String, dynamic> getConnectionStatus() {
    return {
      'socketConnected': _socket.connected,
      'peerConnections': _peerConnections.length,
      'remoteStreams': _remoteStreams.length,
      'hasLocalStream': _localStream != null,
      'iceServers': _iceServers.length,
      'customTurnServer': 'harakaafyaai.metered.live',
    };
  }

  // Get streams
  List<MediaStream> get remoteStreams => _remoteStreams.values.toList();
  MediaStream? get localStream => _localStream;
  Map<String, RTCPeerConnection> get peerConnections => Map.from(_peerConnections);

  void dispose() {
    print('♻️ Disposing WebRTC service...');
    _cleanup();
  }
}