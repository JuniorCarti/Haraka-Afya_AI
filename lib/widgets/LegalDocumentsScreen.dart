import 'package:flutter/material.dart';

class LegalDocumentsScreen extends StatelessWidget {
  final String documentType;
  final String content;

  const LegalDocumentsScreen({
    super.key,
    required this.documentType,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documentType),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}