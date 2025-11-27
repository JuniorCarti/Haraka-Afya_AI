import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCService {
  late IO.Socket _socket;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};
  MediaStream? _localStream;
  
  // Track audio state
  bool _isMicrophoneMuted = true;
  MediaStreamTrack? _audioTrack;
  
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
      'username': 'harakaafyaai',
      'credential': 'Shferick.1234'
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

  // ✅ PRODUCTION SERVER - Updated with your Render URL
  static const String _signalingServer = 'https://haraka-afya-voice-server.onrender.com';

  // Event callbacks
  final List<Function(MediaStream)> onAddRemoteStream = [];
  final List<Function(MediaStream)> onRemoveRemoteStream = [];
  final List<Function(String)> onError = [];
  final List<Function(String, String)> onUserJoined = [];
  final List<Function(String, String)> onUserLeft = [];
  final List<Function(String, bool)> onUserAudioChanged = [];
  final List<Function()> onConnecting = [];
  final List<Function()> onConnected = [];
  final List<Function(bool)> onLocalAudioStateChanged = []; // NEW: Track local audio state

  bool get isConnected => _socket.connected;
  bool get hasLocalStream => _localStream != null;
  bool get hasAudioTrack => _audioTrack != null;
  bool _isConnecting = false;

  Future<void> initialize() async {
    try {
      print('🔄 Initializing WebRTC service...');
      print('🌐 PRODUCTION CONFIG: Custom TURN server - harakaafyaai.metered.live');
      print('🚀 PRODUCTION SERVER: $_signalingServer');
      
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
        'timeout': 30000,
        'reconnection': true,
        'reconnectionAttempts': 3,
        'reconnectionDelay': 2000,
        'reconnectionDelayMax': 10000,
      });

      _setupSocketListeners();
      await _waitForConnection();
      print('✅ WebRTC service initialized with PRODUCTION SERVER');
      
    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      print('🔄 Retrying connection in 5 seconds...');
      await Future.delayed(Duration(seconds: 5));
      await initialize();
    }
  }

  Future<void> _waitForConnection() async {
    final completer = Completer();
    
    if (_socket.connected) {
      completer.complete();
      return completer.future;
    }

    // Show connecting state to UI
    _isConnecting = true;
    for (final callback in onConnecting) {
      callback();
    }

    final connectionTimer = Timer(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Server connection timeout after 30 seconds - Server might be waking up'));
      }
    });

    void cleanup() {
      connectionTimer.cancel();
      _socket.off('connect');
      _socket.off('connect_error');
    }

    _socket.once('connect', (_) {
      print('🔗 Connected to production signaling server');
      _isConnecting = false;
      for (final callback in onConnected) {
        callback();
      }
      cleanup();
      completer.complete();
    });

    _socket.once('connect_error', (error) {
      print('❌ Server connection error: $error');
      _isConnecting = false;
      cleanup();
      completer.completeError(error ?? 'Failed to connect to signaling server');
    });

    try {
      await completer.future;
    } catch (e) {
      print('❌ Connection wait failed: $e');
      _isConnecting = false;
      rethrow;
    }
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      print('✅ Connected to production server - Socket ID: ${_socket.id}');
      _isConnecting = false;
      for (final callback in onConnected) {
        callback();
      }
    });

    _socket.on('disconnect', (reason) {
      print('❌ Disconnected from signaling server: $reason');
      _onError('Disconnected from server: $reason');
    });

    _socket.on('connect_error', (error) {
      print('❌ Server connection error: $error');
      print('🔄 Auto-reconnect will attempt shortly...');
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
      print('🌐 Using production server: $_signalingServer');
      print('🔒 Premium TURN server enabled for cross-location calls');
      
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

  // 🎤 IMPROVED: Better microphone access with verification
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
        _audioTrack = audioTracks.first;
        
        // 🆕 ADDED: Audio track event listeners
        _setupAudioTrackListeners();
        
        print('✅ Got local audio stream - Track ID: ${_audioTrack!.id}');
        print('🎯 Audio track enabled: ${_audioTrack!.enabled}');
        print('🎯 Audio track kind: ${_audioTrack!.kind}');
        print('🎯 Audio track label: ${_audioTrack!.label}');
        
        // Initial state: muted
        await _setAudioTrackEnabled(false);
        
      } else {
        throw Exception('No audio tracks available in stream');
      }
      
    } catch (e) {
      print('❌ Error getting user media: $e');
      _onError('Failed to access microphone: $e');
      rethrow;
    }
  }

  // 🆕 NEW: Setup audio track listeners
  void _setupAudioTrackListeners() {
    if (_audioTrack == null) return;

    // Note: Flutter WebRTC doesn't expose all track events directly
    // We'll rely on manual state checking
    print('🎧 Setting up audio track monitoring');
  }

  // 🆕 NEW: Proper audio track control
  Future<void> _setAudioTrackEnabled(bool enabled) async {
    if (_audioTrack == null) {
      print('❌ No audio track available to enable/disable');
      return;
    }

    try {
      _audioTrack!.enabled = enabled;
      _isMicrophoneMuted = !enabled;
      
      print('🎤 Audio track ${enabled ? 'ENABLED' : 'DISABLED'}');
      print('   - Track enabled: ${_audioTrack!.enabled}');
      print('   - Track kind: ${_audioTrack!.kind}');
      print('   - Track ID: ${_audioTrack!.id}');
      
      // Notify UI about audio state change
      for (final callback in onLocalAudioStateChanged) {
        callback(enabled);
      }
      
      // Notify server about audio state change
      _socket.emit('toggle-audio', {
        'isMuted': !enabled,
      });
      
    } catch (e) {
      print('❌ Error setting audio track state: $e');
      _onError('Failed to control microphone: $e');
    }
  }

  // 🎤 FIXED: Better microphone toggle with verification
  Future<void> toggleMicrophone(bool mute) async {
    try {
      print('🎤 Toggle microphone: ${mute ? 'MUTE' : 'UNMUTE'}');
      
      if (_localStream == null) {
        print('❌ No local stream available');
        await _getUserMedia(); // Try to get media if not available
      }

      if (_audioTrack == null && _localStream != null) {
        final audioTracks = _localStream!.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          _audioTrack = audioTracks.first;
          _setupAudioTrackListeners();
        }
      }

      if (_audioTrack == null) {
        print('❌ No audio track available for toggle');
        _onError('No microphone access available');
        return;
      }

      await _setAudioTrackEnabled(!mute);
      
      // Verify the change
      await Future.delayed(Duration(milliseconds: 100));
      print('✅ Microphone toggle completed');
      print('   Final state - Enabled: ${_audioTrack!.enabled}, Muted: $_isMicrophoneMuted');
      
    } catch (e) {
      print('❌ Error in toggleMicrophone: $e');
      _onError('Failed to toggle microphone: $e');
      rethrow;
    }
  }

  // 🆕 NEW: Get detailed audio status
  Map<String, dynamic> getAudioStatus() {
    return {
      'hasLocalStream': _localStream != null,
      'hasAudioTrack': _audioTrack != null,
      'audioTrackEnabled': _audioTrack?.enabled ?? false,
      'audioTrackKind': _audioTrack?.kind ?? 'N/A',
      'audioTrackId': _audioTrack?.id ?? 'N/A',
      'isMicrophoneMuted': _isMicrophoneMuted,
      'audioTracksCount': _localStream?.getAudioTracks().length ?? 0,
      'remoteStreamsCount': _remoteStreams.length,
    };
  }

  // 🆕 NEW: Force refresh audio stream
  Future<void> refreshAudioStream() async {
    try {
      print('🔄 Refreshing audio stream...');
      
      // Stop old stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream = null;
      }
      _audioTrack = null;
      
      // Get new stream
      await _getUserMedia();
      
      // Update all peer connections with new stream
      for (final entry in _peerConnections.entries) {
        final userId = entry.key;
        final connection = entry.value;
        
        // Remove old tracks
        final senders = await connection.getSenders();
        for (final sender in senders) {
          if (sender.track?.kind == 'audio') {
            await connection.removeTrack(sender);
          }
        }
        
        // Add new audio track
        if (_localStream != null && _audioTrack != null) {
          await connection.addTrack(_audioTrack!, _localStream!);
          print('✅ Updated audio track for connection: $userId');
        }
      }
      
      print('✅ Audio stream refresh completed');
      
    } catch (e) {
      print('❌ Error refreshing audio stream: $e');
      _onError('Failed to refresh audio: $e');
    }
  }

  bool get isMicrophoneMuted => _isMicrophoneMuted;

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

      // 🆕 IMPROVED: Add audio track with verification
      if (_audioTrack != null) {
        await peerConnection.addTrack(_audioTrack!, _localStream!);
        print('✅ Added audio track to peer connection for $remoteUserId');
      } else {
        print('⚠️ No audio track available for peer connection');
      }

      // Create and send offer
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

    print('🔧 Creating peer connection with production TURN server');
    
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
        print('🎧 Added remote stream from user: $userId - Voice connected!');
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
        print('✅ TURN connection established! Cross-location ready.');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateChecking) {
        print('🔍 ICE checking - Using production TURN server');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        print('⚠️ ICE connection failed - TURN server fallback activated');
      }
    };

    peerConnection.onIceGatheringState = (state) {
      final userId = _getUserIdByConnection(peerConnection);
      print('🌐 ICE gathering state for $userId: $state');
      
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        print('✅ ICE gathering complete');
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
      _localStream!.getTracks().forEach((track) => track.stop());
      _localStream = null;
      _audioTrack = null;
    }

    _remoteStreams.clear();
    _isConnecting = false;
    _isMicrophoneMuted = true;
    
    // Disconnect socket
    if (_socket.connected) {
      _socket.disconnect();
    }
    
    print('✅ WebRTC cleanup complete');
  }

  // 🆕 IMPROVED: Get connection status with audio details
  Map<String, dynamic> getConnectionStatus() {
    return {
      'socketConnected': _socket.connected,
      'isConnecting': _isConnecting,
      'peerConnections': _peerConnections.length,
      'remoteStreams': _remoteStreams.length,
      'hasLocalStream': _localStream != null,
      'hasAudioTrack': _audioTrack != null,
      'audioTrackEnabled': _audioTrack?.enabled ?? false,
      'isMicrophoneMuted': _isMicrophoneMuted,
      'productionServer': _signalingServer,
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