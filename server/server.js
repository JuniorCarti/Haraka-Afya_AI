const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// Configure CORS for Flutter web development
const io = socketIo(server, {
  cors: {
    origin: "http://localhost:36236", // 
    methods: ["GET", "POST"],
    credentials: true
  }
});

app.use(cors({
  origin: "http://localhost:36236",
  credentials: true
}));

app.use(express.json());

// Store active rooms and users
const rooms = new Map();

io.on('connection', (socket) => {
  console.log('🔗 User connected:', socket.id);

  socket.on('join-room', (data) => {
    const { roomId, userId, username } = data;
    
    console.log(`User ${username} (${userId}) joining room ${roomId}`);
    
    // Leave any previous room
    if (socket.roomId) {
      socket.leave(socket.roomId);
    }
    
    // Join new room
    socket.join(roomId);
    socket.userId = userId;
    socket.username = username;
    socket.roomId = roomId;
    
    // Initialize room if needed
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
    
    // Get all users in room (excluding current user)
    const otherUsers = Array.from(rooms.get(roomId).values())
      .filter(user => user.id !== userId);
    
    // Send current user list to the new user
    socket.emit('room-users', { users: otherUsers });
    
    // Notify others in the room about new user
    socket.to(roomId).emit('user-joined', { 
      userId: userId,
      username: username 
    });
    
    console.log(`User ${username} joined room ${roomId}. Room now has ${rooms.get(roomId).size} users`);
  });

  socket.on('offer', (data) => {
    const { offer, targetUserId } = data;
    console.log(`Offer from ${socket.username} to ${targetUserId}`);
    socket.to(socket.roomId).emit('offer', {
      offer,
      userId: socket.userId
    });
  });

  socket.on('answer', (data) => {
    const { answer, targetUserId } = data;
    console.log(`Answer from ${socket.username} to ${targetUserId}`);
    socket.to(socket.roomId).emit('answer', {
      answer,
      userId: socket.userId
    });
  });

  socket.on('ice-candidate', (data) => {
    const { candidate, targetUserId } = data;
    console.log(`ICE candidate from ${socket.username}`);
    socket.to(socket.roomId).emit('ice-candidate', {
      candidate,
      userId: socket.userId
    });
  });

  socket.on('toggle-audio', (data) => {
    const { isMuted, userId } = data;
    console.log(`${socket.username} ${isMuted ? 'muted' : 'unmuted'} microphone`);
    socket.to(socket.roomId).emit('user-audio-changed', {
      userId: userId,
      isMuted: isMuted,
      username: socket.username
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    
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
        }
      }
    }
  });

  // Health check
  socket.on('ping', (data) => {
    socket.emit('pong', { timestamp: new Date().toISOString() });
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    activeRooms: rooms.size,
    totalUsers: Array.from(rooms.values()).reduce((acc, room) => acc + room.size, 0)
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Haraka Afya Voice Server running on port ${PORT}`);
  console.log(`Local: http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Connected to Flutter: http://localhost:36236`);
});