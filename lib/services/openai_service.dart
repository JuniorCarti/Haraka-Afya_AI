import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String? _apiKey = dotenv.env['OPENAI_API_KEY']; // Changed to use proper env key name
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  List<Map<String, String>> _conversationHistory = [
    {
      "role": "system",
      "content": "You are Haraka-Afya AI Assistant. You help users with health tips, "
          "symptom checks, and finding clinics. Keep responses helpful, accurate, and "
          "concise (under 200 words). Respond in the same language as the user's question. "
          "For serious symptoms, always recommend consulting a doctor."
    }
  ];

  Future<String> sendMessage(String message) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      return "Error: OpenAI API key not configured";
    }

    _conversationHistory.add({"role": "user", "content": message});

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": _conversationHistory,
          "temperature": 0.7,
          "max_tokens": 500,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['choices'][0]['message']['content'].trim();
        _conversationHistory.add({"role": "assistant", "content": aiResponse});
        return aiResponse;
      } else {
        return _handleError(response.statusCode, response.body);
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  String _handleError(int statusCode, String responseBody) {
    try {
      final errorData = json.decode(responseBody);
      final errorMessage = errorData['error']['message'] ?? 'Unknown error';
      
      switch (statusCode) {
        case 400:
          return "Invalid request: $errorMessage";
        case 401:
          return "Authentication failed: $errorMessage";
        case 429:
          return "Too many requests: $errorMessage";
        case 500:
          return "Server error: $errorMessage";
        default:
          return "Error ($statusCode): $errorMessage";
      }
    } catch (e) {
      return "Error: Failed to parse error response";
    }
  }

  void clearConversation() {
    _conversationHistory = [
      {
        "role": "system",
        "content": "You are Haraka-Afya AI Assistant..."
      }
    ];
  }
}