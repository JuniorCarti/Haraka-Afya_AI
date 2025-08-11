// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'dart:convert';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({super.key});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _pickedImage;
  String? _aiResponse;
  bool _isLoading = false;
  Map<String, List<String>> cancerCategories = {};

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirestore();
    _controller.addListener(() => setState(() {}));
  }

  Future<void> _loadCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('cancer_categories').get();
      final Map<String, List<String>> loadedCategories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = doc.id;
        final List<String> symptoms = List<String>.from(data['symptoms'] ?? []);
        loadedCategories[category] = symptoms;
      }
      setState(() => cancerCategories = loadedCategories);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

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
        setState(() => _aiResponse = data['response'] ?? 'No response received.');
      } else {
        setState(() => _aiResponse = 'Error: Unable to process your request.');
      }
    } catch (e) {
      setState(() => _aiResponse = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _makeCall() async {
    final Uri url = Uri.parse('tel:911');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200, width: 1.5),
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration.collapsed(hintText: 'Describe your symptoms...'),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () => _pickImage(),
              ),
              if (_controller.text.trim().isEmpty)
                IconButton(icon: const Icon(Icons.camera_alt), onPressed: () => _takePhoto()),
              IconButton(
                icon: Icon(_controller.text.trim().isEmpty ? Icons.mic : Icons.send),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    _sendSymptom(_controller.text.trim());
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Card(
      color: const Color(0xFFD8FBE5), // Changed to #D8FBE5
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Lottie.asset(
                'assets/animations/chatbot.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Premium Plan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black, // Changed to black
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Harness the full power of AI with a Premium Plan",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black, // Changed to black
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // action for upgrading
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF269A51), // Changed to #269A51
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Upgrade Now",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white, // Changed to white
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('AI Health Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumBanner(),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFEFF5F1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text('Emergency? Call 911', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(icon: const Icon(Icons.call, color: Colors.red), onPressed: _makeCall),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputArea(),
            const SizedBox(height: 24),
            const Text('Quick Cancer Symptoms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (cancerCategories.isEmpty)
              const Center(child: Text('No categories found.'))
            else
              ...cancerCategories.entries.map((entry) {
                return ExpansionTile(
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  children: entry.value
                      .map((symptom) => ListTile(
                            title: Text('• $symptom'),
                            dense: true,
                            onTap: () {
                              _controller.text = symptom;
                              _sendSymptom(symptom);
                            },
                          ))
                      .toList(),
                );
              }),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_aiResponse != null)
              Card(
                color: const Color(0xFFEFF5F1),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_aiResponse!, style: const TextStyle(fontSize: 14)),
                ),
              ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Available in English, Swahili, Sheng, Luo, Kikuyu & Luhya',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}