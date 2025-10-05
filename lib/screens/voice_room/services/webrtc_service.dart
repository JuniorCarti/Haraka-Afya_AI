import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCService {
  late IO.Socket _socket;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  
  // XirSys configuration - Using your provided credentials
  static final List<Map<String, dynamic>> _iceServers = [
    // STUN server
    {
      'urls': ['stun:bn-turn1.xirsys.com']
    },
    // TURN servers with credentials
    {
      'username': 'dM0opvP29AePbdrWHk7QpcBUX5lXSbDOmRgjbDyC2Lw6nq85XhCWrk5YZjAe-RjDAAAAAGjihjpKdW5pb3JDYXJ0aQ==',
      'credential': 'f1dd1230-a1fa-11f0-aefa-0242ac140004',
      'urls': [
        'turn:bn-turn1.xirsys.com:80?transport=udp',
        'turn:bn-turn1.xirsys.com:3478?transport=udp',
        'turn:bn-turn1.xirsys.com:80?transport=tcp',
        'turn:bn-turn1.xirsys.com:3478?transport=tcp',
        'turns:bn-turn1.xirsys.com:443?transport=tcp',
        'turns:bn-turn1.xirsys.com:5349?transport=tcp',
      ],
    },
  ];

  // Event callbacks
  final List<Function(MediaStream)> onAddRemoteStream = [];
  final List<Function(MediaStream)> onRemoveRemoteStream = [];
  final List<Function(String)> onError = [];
  final List<Function(String, String)> onUserJoined = [];
  final List<Function(String, String)> onUserLeft = [];
  final List<Function(String, bool)> onUserAudioChanged = [];

  // Server configuration
  static const String _signalingServer = 'https://haraka-afya-voice-production.up.railway.app';

  bool get isConnected => _socket.connected;
  bool get hasLocalStream => _localStream != null;

  Future<void> initialize() async {
    try {
      print('🔄 Initializing WebRTC service...');
      print('🌐 Using XirSys TURN servers with ${_iceServers.length} ICE server configurations');
      
      // Log ICE server details for verification
      for (var i = 0; i < _iceServers.length; i++) {
        final server = _iceServers[i];
        final urls = server['urls'] as List;
        final hasCredentials = server['username'] != null;
        print('   Server $i: ${urls.length} URLs, Has credentials: $hasCredentials');
      }
      
      _socket = IO.io(_signalingServer, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'forceNew': true,
        'timeout': 30000,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
      });

      _setupSocketListeners();
      await _waitForConnection();
      print('✅ WebRTC service initialized successfully with XirSys TURN servers');
      
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

    final connectionTimer = Timer(const Duration(seconds: 20), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Connection timeout after 20 seconds'));
      }
    });

    void cleanup() {
      connectionTimer.cancel();
      _socket.off('connect');
      _socket.off('connect_error');
      _socket.off('connect_timeout');
    }

    _socket.once('connect', (_) {
      print('🔗 Connected to signaling server');
      cleanup();
      completer.complete();
    });

    _socket.once('connect_error', (error) {
      print('❌ Connection error: $error');
      cleanup();
      completer.completeError(error ?? 'Connection error');
    });

    _socket.once('connect_timeout', (_) {
      print('⏰ Connection timeout');
      cleanup();
      completer.completeError(TimeoutException('Connection timeout'));
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
      print('❌ Connection error: $error');
      _onError('Connection failed: $error');
    });

    _socket.on('error', (error) {
      print('❌ Socket error: $error');
      _onError('Socket error: $error');
    });

    _socket.on('user-joined', (data) {
      final userId = data['userId']?.toString();
      final username = data['username']?.toString();
      if (userId != null && username != null) {
        print('👤 User joined: $username ($userId)');
        for (final callback in onUserJoined) {
          callback(userId, username);
        }
      } else {
        print('⚠️ Invalid user-joined data: $data');
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
      } else {
        print('⚠️ Invalid user-left data: $data');
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
        } else {
          print('⚠️ Invalid offer data: $data');
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
        } else {
          print('⚠️ Invalid answer data: $data');
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
        } else {
          print('⚠️ Invalid ICE candidate data: $data');
        }
      } catch (e) {
        print('❌ Error processing ICE candidate: $e');
      }
    });

    _socket.on('user-audio-changed', (data) {
      final userId = data['userId']?.toString();
      final isMuted = data['isMuted'] == true;
      final username = data['username']?.toString();
      if (userId != null && username != null) {
        print('🎤 User audio changed: $username - muted: $isMuted');
        for (final callback in onUserAudioChanged) {
          callback(userId, isMuted);
        }
      } else {
        print('⚠️ Invalid user-audio-changed data: $data');
      }
    });

    // Connection health monitoring
    _socket.on('pong', (data) {
      print('🏓 Server pong received');
    });
  }

  Future<void> joinRoom(String roomId, String userId, String username) async {
    try {
      print('🚀 Joining room: $roomId as $username ($userId)');
      print('🌐 Using XirSys TURN servers for cross-network connectivity');
      
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
        print('✅ Got local audio stream - Track enabled: ${audioTracks.first.enabled}');
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
      print('🔗 Creating peer connection for: $remoteUserId');
      final peerConnection = await _createPeerConnection();
      _peerConnections[remoteUserId] = peerConnection;

      // Add local stream tracks
      for (final track in _localStream!.getTracks()) {
        await peerConnection.addTrack(track, _localStream!);
      }

      // Create and send offer without RTCOfferOptions
      final offer = await peerConnection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      
      await peerConnection.setLocalDescription(offer);
      
      _socket.emit('offer', {
        'offer': offer.toMap(),
        'targetUserId': remoteUserId,
      });
      
      print('📞 Sent offer to $remoteUserId');
      
    } catch (e) {
      print('❌ Error creating peer connection for $remoteUserId: $e');
      _peerConnections.remove(remoteUserId)?.close();
      _onError('Failed to connect to user: $e');
    }
  }

  Future<void> _handleOffer(dynamic offerData, String remoteUserId) async {
    if (_localStream == null) {
      print('❌ No local stream available for answering offer');
      return;
    }

    if (_peerConnections.containsKey(remoteUserId)) {
      print('⚠️ Peer connection already exists for offer from: $remoteUserId');
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

      // Create and send answer without RTCAnswerOptions
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
    if (peerConnection == null) {
      print('❌ No peer connection for answer from: $remoteUserId');
      return;
    }

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
    if (peerConnection == null) {
      print('❌ No peer connection for ICE candidate from: $remoteUserId');
      return;
    }

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

    print('🔧 Creating peer connection with XirSys TURN servers');
    print('   - STUN: bn-turn1.xirsys.com');
    print('   - TURN: 6 endpoints with credentials');
    
    final peerConnection = await createPeerConnection(configuration, constraints);

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
      
      // Use string comparison since the enum values might be different
      if (state.toString().contains('connected') || state.toString().contains('Connected')) {
        print('✅ Peer connection established with $userId using XirSys');
      } else if (state.toString().contains('failed') || 
                 state.toString().contains('disconnected') ||
                 state.toString().contains('Failed') ||
                 state.toString().contains('Disconnected')) {
        print('⚠️ Peer connection issue with $userId: $state');
        
        // Attempt to restart ICE if connection fails
        if (state.toString().contains('failed') || state.toString().contains('Failed')) {
          _restartIceForConnection(peerConnection, userId);
        }
      } else if (state.toString().contains('checking') || state.toString().contains('Checking')) {
        print('🔍 ICE checking in progress for $userId');
      }
    };

    peerConnection.onIceGatheringState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('🌐 ICE gathering state for $userId: $state');
    };

    peerConnection.onSignalingState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('📡 Signaling state for $userId: $state');
    };

    peerConnection.onConnectionState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('🔗 Connection state for $userId: $state');
    };

    return peerConnection;
  }

  Future<void> _restartIceForConnection(RTCPeerConnection peerConnection, String? userId) async {
    if (userId == null) return;
    
    print('🔄 Restarting ICE for connection: $userId');
    
    try {
      // Create new offer with iceRestart
      final offer = await peerConnection.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
        'iceRestart': true,
      });
      
      await peerConnection.setLocalDescription(offer);
      
      _socket.emit('offer', {
        'offer': offer.toMap(),
        'targetUserId': userId,
        'iceRestart': true,
      });
      
      print('📞 Sent ICE restart offer to $userId');
    } catch (e) {
      print('❌ Error restarting ICE for $userId: $e');
    }
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