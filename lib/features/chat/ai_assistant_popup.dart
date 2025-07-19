// features/chat/ai_assistant_popup.dart
import 'package:flutter/material.dart';

class AIAssistantPopup extends StatefulWidget {
  const AIAssistantPopup({super.key});

  @override
  State<AIAssistantPopup> createState() => _AIAssistantPopupState();
}

class _AIAssistantPopupState extends State<AIAssistantPopup> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your Haraka-Afya AI assistant. How can I help you today?",
      isUser: false,
      time: "Now",
    ),
  ];
  bool _isMinimized = false;
  final Color _whatsappGreen = const Color(0xFF25D366);
  final Color _whatsappLightGreen = const Color(0xFFDCF8C6);
  final Color _whatsappLightGray = const Color(0xFFECECEC);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isMinimized)
          Positioned(
            right: 20,
            bottom: 80,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              child: Container(
                width: 350,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _whatsappGreen, width: 1),
                ),
                child: Column(
                  children: [
                    // Header with WhatsApp-like styling
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _whatsappGreen,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.chat, color: _whatsappGreen),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Haraka-Afya AI Support',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.minimize, color: Colors.white),
                            onPressed: () => setState(() => _isMinimized = true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Chat messages with WhatsApp-like bubbles
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        reverse: false,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildWhatsAppMessage(_messages[index]);
                        },
                      ),
                    ),
                    
                    // Input area with WhatsApp-like styling
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _whatsappLightGray,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: _whatsappGreen,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Minimized state with WhatsApp-like floating button
        if (_isMinimized)
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () => setState(() => _isMinimized = false),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _whatsappGreen,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 30),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWhatsAppMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _whatsappGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? _whatsappLightGreen
                    : _whatsappLightGray,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(message.isUser ? 12 : 0),
                  bottomRight: Radius.circular(message.isUser ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
        time: "Just now",
      ));
      
      // Simulate AI response after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(ChatMessage(
            text: _getAIResponse(_messageController.text),
            isUser: false,
            time: "Now",
          ));
        });
      });
      
      _messageController.clear();
    });
  }

  String _getAIResponse(String message) {
    message = message.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return "Hello! How can I assist you with your health today?";
    } else if (message.contains('malaria')) {
      return "Malaria is a serious disease. Common symptoms include fever, chills, and headache. Have you been experiencing any of these?";
    } else if (message.contains('hospital') || message.contains('doctor')) {
      return "I can help you find nearby hospitals. Would you like me to show hospitals in your area?";
    } else if (message.contains('symptom')) {
      return "Please describe your symptoms and I'll try to help. Remember, I'm not a substitute for professional medical advice.";
    } else {
      return "Thank you for your message. I'm here to help with health-related questions. Could you please provide more details?";
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}