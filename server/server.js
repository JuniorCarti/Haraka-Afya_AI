const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// Configure CORS for both local development and production
const allowedOrigins = [
  'http://localhost:36236', // Local Flutter development
  'https://haraka-afya-voice-production.up.railway.app', // Your Railway server
  'https://*.up.railway.app', // All Railway subdomains
  'http://localhost:3000', // Local server for testing
  'http://localhost:8080' // Railway internal port
];

const io = socketIo(server, {
  cors: {
    origin: function (origin, callback) {
      // Allow requests with no origin (like mobile apps or Postman)
      if (!origin) return callback(null, true);
      
      if (allowedOrigins.some(allowedOrigin => {
        // Exact match
        if (origin === allowedOrigin) return true;
        // Wildcard match for Railway domains
        if (allowedOrigin.includes('*') && origin.endsWith(allowedOrigin.replace('*.', ''))) return true;
        // Local development variations
        if (origin.includes('localhost') && allowedOrigin.includes('localhost')) return true;
        return false;
      })) {
        callback(null, true);
      } else {
        console.log('CORS blocked for origin:', origin);
        callback(new Error('Not allowed by CORS'));
      }
    },
    methods: ["GET", "POST"],
    credentials: true
  }
});

app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.some(allowedOrigin => {
      if (origin === allowedOrigin) return true;
      if (allowedOrigin.includes('*') && origin.endsWith(allowedOrigin.replace('*.', ''))) return true;
      if (origin.includes('localhost') && allowedOrigin.includes('localhost')) return true;
      return false;
    })) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

app.use(express.json());

// Store active rooms and users
const rooms = new Map();

io.on('connection', (socket) => {
  console.log('🔗 User connected:', socket.id);
  console.log('📡 Origin:', socket.handshake.headers.origin);

  socket.on('join-room', (data) => {
    const { roomId, userId, username } = data;
    
    console.log(`🎯 User ${username} (${userId}) joining room ${roomId}`);
    
    // Leave any previous room
    if (socket.roomId) {
      socket.leave(socket.roomId);
      console.log(`🔄 User left previous room: ${socket.roomId}`);
    }
    
    // Join new room
    socket.join(roomId);
    socket.userId = userId;
    socket.username = username;
    socket.roomId = roomId;
    
    // Initialize room if needed
    if (!rooms.has(roomId)) {
      rooms.set(roomId, new Map());
      console.log(`🏠 Created new room: ${roomId}`);
    }
    
    // Add user to room
    rooms.get(roomId).set(userId, {
      id: userId,
      username: username,
      socketId: socket.id,
      joinedAt: new Date()
    });
    
    // Get all users in room (excluding current user)
    const otherUsers = Array.from(rooms.get(roomId).values())
      .filter(user => user.id !== userId);
    
    // Send current user list to the new user
    socket.emit('room-users', { users: otherUsers });
    console.log(`📋 Sent ${otherUsers.length} existing users to ${username}`);
    
    // Notify others in the room about new user
    socket.to(roomId).emit('user-joined', { 
      userId: userId,
      username: username 
    });
    
    console.log(`✅ User ${username} joined room ${roomId}. Room now has ${rooms.get(roomId).size} users`);
  });

  socket.on('offer', (data) => {
    const { offer, targetUserId } = data;
    console.log(`📞 Offer from ${socket.username} to ${targetUserId}`);
    socket.to(socket.roomId).emit('offer', {
      offer,
      userId: socket.userId
    });
  });

  socket.on('answer', (data) => {
    const { answer, targetUserId } = data;
    console.log(`📨 Answer from ${socket.username} to ${targetUserId}`);
    socket.to(socket.roomId).emit('answer', {
      answer,
      userId: socket.userId
    });
  });

  socket.on('ice-candidate', (data) => {
    const { candidate, targetUserId } = data;
    console.log(`🧊 ICE candidate from ${socket.username}`);
    socket.to(socket.roomId).emit('ice-candidate', {
      candidate,
      userId: socket.userId
    });
  });

  socket.on('toggle-audio', (data) => {
    const { isMuted, userId } = data;
    console.log(`🎤 ${socket.username} ${isMuted ? 'muted' : 'unmuted'} microphone`);
    socket.to(socket.roomId).emit('user-audio-changed', {
      userId: userId,
      isMuted: isMuted,
      username: socket.username
    });
  });

  socket.on('disconnect', (reason) => {
    console.log('❌ User disconnected:', socket.id, 'Reason:', reason);
    
    if (socket.roomId && socket.userId) {
      // Remove user from room
      const room = rooms.get(socket.roomId);
      if (room) {
        room.delete(socket.userId);
        
        // Notify other users
        socket.to(socket.roomId).emit('user-left', { 
          userId: socket.userId,
          username: socket.username 
        });
        
        console.log(`🚪 User ${socket.username} left room ${socket.roomId}`);
        
        // Clean up empty rooms
        if (room.size === 0) {
          rooms.delete(socket.roomId);
          console.log(`🗑️ Room ${socket.roomId} deleted (empty)`);
        } else {
          console.log(`👥 Room ${socket.roomId} still has ${room.size} users`);
        }
      }
    }
  });

  // Health check
  socket.on('ping', (data) => {
    socket.emit('pong', { 
      timestamp: new Date().toISOString(),
      server: 'Haraka Afya Voice Server',
      version: '1.0.0'
    });
  });

  // Error handling
  socket.on('error', (error) => {
    console.error('❌ Socket error:', error);
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  const healthInfo = { 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    server: 'Haraka Afya Voice Server',
    version: '1.0.0',
    activeRooms: rooms.size,
    totalUsers: Array.from(rooms.values()).reduce((acc, room) => acc + room.size, 0),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    allowedOrigins: allowedOrigins
  };
  
  console.log('🏥 Health check requested');
  res.json(healthInfo);
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Haraka Afya Voice Server',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      websocket: '/socket.io/'
    },
    documentation: 'WebSocket signaling server for voice chat'
  });
});

// Handle 404
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    availableEndpoints: ['/', '/health']
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('🚨 Server error:', error);
  res.status(500).json({
    error: 'Internal server error',
    message: error.message
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🎯 Haraka Afya Voice Server running on port ${PORT}`);
  console.log(`📍 Local: http://localhost:${PORT}`);
  console.log(`🌐 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 Allowed origins:`, allowedOrigins);
  console.log(`🚀 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💻 Platform: ${process.platform}`);
});