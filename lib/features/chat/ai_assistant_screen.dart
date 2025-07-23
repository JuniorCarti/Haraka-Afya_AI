import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  String _selectedLanguage = 'English';

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        language: _selectedLanguage,
      ));
      _isProcessing = true;
    });

    try {
      final response = await _sendToN8n(
        message: message,
        language: _selectedLanguage,
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          language: _selectedLanguage,
        ));
      });
    } catch (_) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          language: 'English',
        ));
      });
    } finally {
      setState(() => _isProcessing = false);
      _textController.clear();
    }
  }

  Future<String> _sendToN8n({
    required String message,
    required String language,
  }) async {
    const String n8nWebhookUrl = 'YOUR_N8N_WEBHOOK_URL';

    final response = await http.post(
      Uri.parse(n8nWebhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'language': language,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      throw Exception('Failed to get AI response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haraka Afya AI Assistant'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.language, color: Colors.white),
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Swahili', child: Text('Swahili')),
              DropdownMenuItem(value: 'Sheng', child: Text('Sheng')),
              DropdownMenuItem(value: 'Luo', child: Text('Luo')),
              DropdownMenuItem(value: 'Kikuyu', child: Text('Kikuyu')),
              DropdownMenuItem(value: 'Luhya', child: Text('Luhya')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  message: _messages.reversed.toList()[index],
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message in $_selectedLanguage...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _sendMessage(_textController.text),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String language;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.language,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.language,
              style: TextStyle(
                color: message.isUser ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
