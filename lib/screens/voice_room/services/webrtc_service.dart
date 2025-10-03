import 'dart:async';
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
  // Server configuration for local development
  static const String _signalingServer = 'http://localhost:3000';

  Future<void> initialize() async {
    try {
      print('🔄 Initializing WebRTC service...');
      
      // Initialize socket connection
      _socket = IO.io(_signalingServer, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      _setupSocketListeners();
      
      // Wait for connection
      await _waitForConnection();
      print('✅ WebRTC service initialized');
      
    } catch (e) {
      print('❌ Error initializing WebRTC: $e');
      _onError('Failed to initialize WebRTC: $e');
    }
  }

  Future<void> _waitForConnection() async {
    final completer = Completer();
    
    _socket.once('connect', (_) {
      print('🔗 Connected to signaling server');
      completer.complete();
    });

    _socket.once('connect_error', (error) {
      print('❌ Connection error: $error');
      completer.completeError(error);
    });
    // Timeout after 10 seconds
    return completer.future.timeout(const Duration(seconds: 10));
  }

  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      print('✅ Connected to signaling server');
    });

    _socket.on('disconnect', (_) {
      print('❌ Disconnected from signaling server');
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
      print('📊 Room users: $users');
      // Handle existing users in room
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
    _socket.on('pong', (data) {
      print('🏓 Server pong: ${data['timestamp']}');
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
    } catch (e) {
      print('❌ Error joining room: $e');
      rethrow;
    }
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    print('🚪 Leaving room: $roomId');
    _socket.emit('leave-room', {'roomId': roomId, 'userId': userId});
    await _cleanup();
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
    if (_localStream == null) return;

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
