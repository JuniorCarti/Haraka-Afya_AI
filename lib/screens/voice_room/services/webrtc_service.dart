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
