import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';

class VoiceRoomScreen extends StatefulWidget {
  const VoiceRoomScreen({super.key});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  final List<RoomMember> _members = [];
  final List<RoomGame> _availableGames = [
    RoomGame('Pool', Icons.sports, Colors.green),
    RoomGame('Sudoku', Icons.grid_4x4, Colors.blue),
    RoomGame('Dice', Icons.casino, Colors.orange),
    RoomGame('Chess', Icons.extension, Colors.brown),
    RoomGame('Cards', Icons.style, Colors.red),
    RoomGame('Words', Icons.text_fields, Colors.purple),
  ];

  final List<Gift> _availableGifts = [
    Gift('Rose', '🌹', 10, Colors.red),
    Gift('Crown', '👑', 100, Colors.yellow),
    Gift('Star', '⭐', 50, Colors.blue),
    Gift('Heart', '💖', 20, Colors.pink),
    Gift('Trophy', '🏆', 200, Colors.orange),
    Gift('Diamond', '💎', 500, Colors.cyan),
  ];

  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
    _initializeSampleChat();
  }

  void _initializeRoom() {
    // Add admin
    _members.add(RoomMember(
      name: 'You',
      role: 'Host',
      isSpeaking: true,
      avatar: '👑',
      points: 1200,
      isHost: true,
    ));
    
    // Add some sample members
    _members.addAll([
      RoomMember(name: 'Alex', role: 'Speaker', isSpeaking: true, avatar: '😊', points: 800, isHost: false),
      RoomMember(name: 'Sam', role: 'Speaker', isSpeaking: true, avatar: '🎤', points: 650, isHost: false),
      RoomMember(name: 'Jordan', role: 'Listener', isSpeaking: false, avatar: '👂', points: 450, isHost: false),
      RoomMember(name: 'Taylor', role: 'Listener', isSpeaking: false, avatar: '🌟', points: 300, isHost: false),
      RoomMember(name: 'Casey', role: 'Listener', isSpeaking: false, avatar: '🎧', points: 200, isHost: false),
    ]);
  }

  void _initializeSampleChat() {
    _chatMessages.addAll([
      ChatMessage(user: 'Alex', message: 'Hello everyone! 👋', time: '2 min ago'),
      ChatMessage(user: 'Sam', message: 'Great to be here!', time: '1 min ago'),
      ChatMessage(user: 'Jordan', message: 'Thanks for the support 💚', time: 'Just now'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text(
            'Support Room',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.people_alt_rounded, color: Colors.white54, size: 22),
              onPressed: _showRoomInfo,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white54, size: 22),
              onPressed: _showRoomOptions,
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Room header
          _buildRoomHeader(),
          
          // Main room layout
          Expanded(
            child: _buildRoomLayout(),
          ),
          
          // Chat section for listeners
          _buildChatSection(),
          
          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Members count
          Icon(Icons.people_alt_rounded, color: Colors.white54, size: 16),
          const SizedBox(width: 4),
          Text(
            '${_members.length}/9',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 12),
          // Room topic
          Expanded(
            child: Text(
              'Mental Health Support • Games • Chat',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Host seat at top (centered)
          _buildHostSeat(),
          
          const SizedBox(height: 24),
          
          // Member seats grid (3x3)
          Expanded(
            child: _buildMemberSeatsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHostSeat() {
    final host = _members.firstWhere((member) => member.isHost);
    return Container(
      width: 100,
      height: 120,
      child: Column(
        children: [
          // Seat design with glow effect
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFEC8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Seat icon
                const Icon(Icons.chair_rounded, color: Colors.white, size: 30),
                
                // User avatar
                Positioned.fill(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Text(
                      host.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                // Host crown
                Positioned(
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            host.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            host.role,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSeatsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        if (index < _members.length - 1) {
          final member = _members[index + 1];
          return _buildMemberSeat(member);
        } else {
          return _buildEmptySeat(index - _members.length + 2);
        }
      },
    );
  }

  Widget _buildMemberSeat(RoomMember member) {
    return GestureDetector(
      onTap: () => _showMemberOptions(member),
      child: Container(
        child: Column(
          children: [
            // Seat with user
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: member.isSpeaking
                      ? [const Color(0xFF4CAF50), const Color(0xFF45a049)]
                      : [Colors.grey.shade800, Colors.grey.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: member.isSpeaking
                        ? Colors.green.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Seat icon
                  Icon(
                    Icons.chair_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 28,
                  ),
                  
                  // User avatar
                  Positioned.fill(
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Text(
                        member.avatar,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  
                  // Speaking indicator
                  if (member.isSpeaking)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, size: 8, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              member.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              member.role,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySeat(int seatNumber) {
    return GestureDetector(
      onTap: _joinSeat,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Seat #$seatNumber',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
          Text(
            'Join',
            style: TextStyle(
              color: Colors.green.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Chat header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Room Chat',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_chatMessages.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              reverse: false,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return _buildChatMessage(message);
              },
            ),
          ),
          
          // Chat input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendChatMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                message.user[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      message.time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                Text(
                  message.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Games button
          _buildControlButton(
            icon: Icons.sports_esports_rounded,
            label: 'Games',
            onPressed: _showGamesMenu,
          ),
          const SizedBox(width: 12),
          
          // Gift button
          _buildControlButton(
            icon: Icons.card_giftcard_rounded,
            label: 'Gifts',
            onPressed: _showGiftMenu,
          ),
          const Spacer(),
          
          // Mic control
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: _isMuted 
                  ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                  : const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF45a049)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isMuted ? Colors.grey : Colors.green).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _toggleMicrophone,
            ),
          ),
          const Spacer(),
          
          // Leave room
          _buildControlButton(
            icon: Icons.logout_rounded,
            label: 'Leave',
            onPressed: _leaveRoom,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDanger = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDanger ? Colors.red : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDanger ? Colors.red : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDanger ? Colors.red : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGamesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose a Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _availableGames.length,
                  itemBuilder: (context, index) {
                    final game = _availableGames[index];
                    return _buildGameCard(game);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameCard(RoomGame game) {
    return GestureDetector(
      onTap: () => _startGame(game),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              game.color.withOpacity(0.2),
              game.color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: game.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(game.icon, color: game.color, size: 32),
            const SizedBox(height: 8),
            Text(
              game.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Send a Gift',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // User points
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.yellow, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Points: ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '1200',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _availableGifts.length,
                  itemBuilder: (context, index) {
                    final gift = _availableGifts[index];
                    return _buildGiftCard(gift);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftCard(Gift gift) {
    return GestureDetector(
      onTap: () => _sendGiftToRoom(gift),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gift.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gift.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              gift.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: gift.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${gift.cost} pts',
                style: TextStyle(
                  color: gift.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptions(RoomMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Member info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: Text(member.avatar, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            member.role,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${member.points} pts',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Action buttons
                _buildMemberActionButton(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Send Gift',
                  onTap: () {
                    Navigator.pop(context);
                    _showGiftMenuForUser(member);
                  },
                ),
                _buildMemberActionButton(
                  icon: Icons.person_remove_rounded,
                  label: 'Remove from Room',
                  onTap: () {
                    Navigator.pop(context);
                    _removeMember(member);
                  },
                  isDanger: true,
                ),
                _buildMemberActionButton(
                  icon: Icons.volume_off_rounded,
                  label: 'Mute User',
                  onTap: () {
                    Navigator.pop(context);
                    _muteMember(member);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? Colors.red : Colors.white,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  // Updated functionality methods
  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add(ChatMessage(
          user: 'You',
          message: _chatController.text.trim(),
          time: 'Just now',
        ));
        _chatController.clear();
      });
    }
  }

  void _toggleMicrophone() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _showGiftMenuForUser(RoomMember member) {
    // This would show a specialized gift menu for the specific user
    _showGiftMenu(); // For now, use the same gift menu
  }

  void _removeMember(RoomMember member) {
    // TODO: Implement remove member functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${member.name} from room'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _muteMember(RoomMember member) {
    // TODO: Implement mute member functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.name} has been muted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Placeholder methods
  void _showRoomInfo() {
    // TODO: Implement room info dialog
  }

  void _showRoomOptions() {
    // TODO: Implement room options menu
  }

  void _joinSeat() {
    // TODO: Implement join seat functionality
  }

  void _leaveRoom() {
    // TODO: Implement leave room functionality
  }

  void _startGame(RoomGame game) {
    // TODO: Implement game start functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${game.name}...'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _sendGiftToRoom(Gift gift) {
    // TODO: Implement gift sending functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${gift.emoji} ${gift.name} to the room!'),
        backgroundColor: Colors.pink,
      ),
    );
    Navigator.pop(context);
  }
}

// Data models
class RoomMember {
  final String name;
  final String role;
  final bool isSpeaking;
  final String avatar;
  final int points;
  final bool isHost;

  RoomMember({
    required this.name,
    required this.role,
    required this.isSpeaking,
    required this.avatar,
    required this.points,
    required this.isHost,
  });
}

class RoomGame {
  final String name;
  final IconData icon;
  final Color color;

  RoomGame(this.name, this.icon, this.color);
}

class Gift {
  final String name;
  final String emoji;
  final int cost;
  final Color color;

  Gift(this.name, this.emoji, this.cost, this.color);
}

class ChatMessage {
  final String user;
  final String message;
  final String time;

  ChatMessage({
    required this.user,
    required this.message,
    required this.time,
  });
}