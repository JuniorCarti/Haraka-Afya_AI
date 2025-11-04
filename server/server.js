const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// Production CORS - allow all origins
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  },
  pingTimeout: 60000,
  pingInterval: 25000
});

app.use(cors({
  origin: "*",
  credentials: true
}));

app.use(express.json());

// Store active rooms and users
const rooms = new Map();

io.on('connection', (socket) => {
  console.log('🔗 User connected:', socket.id);

  socket.on('join-room', (data) => {
    const { roomId, userId, username } = data;
    console.log(`🎯 User ${username} (${userId}) joining room ${roomId}`);
    
    // Join room logic (your existing code)
    socket.join(roomId);
    socket.userId = userId;
    socket.username = username;
    socket.roomId = roomId;
    
    // Initialize room
    if (!rooms.has(roomId)) {
      rooms.set(roomId, new Map());
    }
    
    // Add user to room
    rooms.get(roomId).set(userId, {
      id: userId,
      username: username,
      socketId: socket.id,
      joinedAt: new Date()
    });
    
    // Notify others
    socket.to(roomId).emit('user-joined', { 
      userId: userId,
      username: username 
    });
    
    // Send existing users to new user
    const otherUsers = Array.from(rooms.get(roomId).values())
      .filter(user => user.id !== userId);
    
    socket.emit('room-users', { users: otherUsers });
  });

  // WebRTC signaling events
  socket.on('offer', (data) => {
    const { offer, targetUserId } = data;
    socket.to(targetUserId).emit('offer', {
      offer,
      userId: socket.userId
    });
  });

  socket.on('answer', (data) => {
    const { answer, targetUserId } = data;
    socket.to(targetUserId).emit('answer', {
      answer,
      userId: socket.userId
    });
  });

  socket.on('ice-candidate', (data) => {
    const { candidate, targetUserId } = data;
    socket.to(targetUserId).emit('ice-candidate', {
      candidate,
      userId: socket.userId
    });
  });

  socket.on('toggle-audio', (data) => {
    const { isMuted } = data;
    socket.to(socket.roomId).emit('user-audio-changed', {
      userId: socket.userId,
      isMuted: isMuted,
      username: socket.username
    });
  });

  socket.on('disconnect', () => {
    console.log('❌ User disconnected:', socket.id);
    if (socket.roomId && socket.userId) {
      const room = rooms.get(socket.roomId);
      if (room) {
        room.delete(socket.userId);
        socket.to(socket.roomId).emit('user-left', { 
          userId: socket.userId,
          username: socket.username 
        });
        if (room.size === 0) {
          rooms.delete(socket.roomId);
        }
      }
    }
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    server: 'Haraka Afya Voice Server',
    environment: 'production',
    timestamp: new Date().toISOString(),
    activeRooms: rooms.size,
    totalUsers: Array.from(rooms.values()).reduce((acc, room) => acc + room.size, 0)
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Haraka Afya Voice Server - Production',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      websocket: 'ws://' + req.get('host') + '/socket.io/'
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Production Server running on port ${PORT}`);
  console.log(`🌐 Ready for cross-location voice chat!`);
});