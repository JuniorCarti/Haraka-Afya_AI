const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*", // Allow all origins for development
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json());

// Store active rooms and users
const rooms = new Map();

io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join-room', (data) => {
    const { roomId, userId } = data;
    
    console.log(`User ${userId} joining room ${roomId}`);
    
    // Leave any previous room
    if (socket.roomId) {
      socket.leave(socket.roomId);
    }
    
    // Join new room
    socket.join(roomId);
    socket.userId = userId;
    socket.roomId = roomId;
    
    // Initialize room if needed
    if (!rooms.has(roomId)) {
      rooms.set(roomId, new Set());
    }
    
    // Add user to room
    rooms.get(roomId).add(userId);
    
    // Notify others in the room
    socket.to(roomId).emit('user-joined', { userId });
    
    console.log(`User ${userId} joined room ${roomId}. Room users:`, Array.from(rooms.get(roomId)));
  });

  socket.on('offer', (data) => {
    const { offer, targetUserId } = data;
    console.log(`Offer from ${socket.userId} to ${targetUserId}`);
    socket.to(socket.roomId).emit('offer', {
      offer,
      userId: socket.userId
    });
  });

  socket.on('answer', (data) => {
    const { answer, targetUserId } = data;
    console.log(`Answer from ${socket.userId} to ${targetUserId}`);
    socket.to(socket.roomId).emit('answer', {
      answer,
      userId: socket.userId
    });
  });

  socket.on('ice-candidate', (data) => {
    const { candidate, targetUserId } = data;
    socket.to(socket.roomId).emit('ice-candidate', {
      candidate,
      userId: socket.userId
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
        socket.to(socket.roomId).emit('user-left', { userId: socket.userId });
        
        console.log(`User ${socket.userId} left room ${socket.roomId}`);
        
        // Clean up empty rooms
        if (room.size === 0) {
          rooms.delete(socket.roomId);
          console.log(`Room ${socket.roomId} deleted (empty)`);
        }
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Haraka Afya Voice Server running on port ${PORT}`);
  console.log(`Local: http://localhost:${PORT}`);
  console.log(`Network: http://YOUR_IP:${PORT}`);
});