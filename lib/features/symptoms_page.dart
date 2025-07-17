import 'package:flutter/material.dart';

class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Emergency: If you're experiencing chest pain, difficulty breathing, or other severe symptoms, call 911 immediately.",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 40, thickness: 1),

            // Language Selection
            const Text(
              'English',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Hujambo! I'm your AI health assistant. Please describe your symptoms in detail. I can help in English, Swahili, Sheng, Luo, Kikuyu, and Luhya.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '15:35:17',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 40, thickness: 1),

            // Quick Symptoms Grid
            const Text(
              'Quick symptoms:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: const [
                _SymptomButton('Headache'),
                _SymptomButton('Fever'),
                _SymptomButton('Cough'),
                _SymptomButton('Stomach pain'),
                _SymptomButton('Fatigue'),
                _SymptomButton('Nausea'),
                _SymptomButton('Dizziness'),
                _SymptomButton('Sore throat'),
                _SymptomButton('Back pain'),
                _SymptomButton('Joint pain'),
              ],
            ),
            const Divider(height: 40, thickness: 1),

            // Language Options
            const Center(
              child: Text(
                'Describe your symptoms in',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Available in English, Swahili, Sheng, Luo, Kikuyu & Luhya',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
      // Removed the bottomNavigationBar from here
    );
  }
}

class _SymptomButton extends StatelessWidget {
  final String symptom;
  const _SymptomButton(this.symptom);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Handle symptom selection
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C6D5B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF0C6D5B)),
        ),
        elevation: 0,
      ),
      child: Text(
        symptom,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}