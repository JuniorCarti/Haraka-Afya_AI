import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({super.key});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  final TextEditingController _controller = TextEditingController();
  String? _aiResponse;
  bool _isLoading = false;

  final List<String> cancerSymptoms = [
    'Unexplained Weight Loss',
    'Lump or Swelling',
    'Persistent Fatigue',
    'Unusual Bleeding',
    'Skin Changes',
    'Chronic Pain',
  ];

  Future<void> _sendSymptom(String input) async {
    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    final url = Uri.parse('https://hooks.zapier.com/hooks/catch/23929090/uu5tpj8/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptom': input}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['response'] ?? 'No response received.';
        });
      } else {
        setState(() {
          _aiResponse = 'Error: Unable to process your request.';
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI Health Assistant',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Card
            Card(
              color: const Color(0xFFEFF5F1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  "🚨 Emergency: If you're experiencing chest pain, difficulty breathing, or severe symptoms, call 911 immediately.",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Assistant Greeting
            Card(
              color: const Color(0xFFEFF5F1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('English', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      "Hujambo! I'm your AI health assistant. Please describe your symptoms. I understand English, Swahili, Sheng, Luo, Kikuyu & Luhya.",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 6),
                    Text('15:35:17', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Quick Cancer Symptoms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cancerSymptoms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _SymptomChip(
                    label: cancerSymptoms[index],
                    onTap: () {
                      _controller.text = cancerSymptoms[index];
                      _sendSymptom(cancerSymptoms[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Input Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms...',
                fillColor: Colors.white,
                filled: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendSymptom(_controller.text.trim());
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: null,
            ),

            const SizedBox(height: 24),

            if (_isLoading) const Center(child: CircularProgressIndicator()),

            if (_aiResponse != null)
              Card(
                color: const Color(0xFFEFF5F1),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _aiResponse!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            const Center(
              child: Text('Available in English, Swahili, Sheng, Luo, Kikuyu & Luhya',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SymptomChip({required this.label, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C6D5B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF0C6D5B)),
        ),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
