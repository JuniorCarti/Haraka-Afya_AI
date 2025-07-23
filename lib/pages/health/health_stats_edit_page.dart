import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haraka_afya_ai/models/health_stats.dart';
import 'package:haraka_afya_ai/services/health_service.dart';

class HealthStatsEditPage extends StatefulWidget {
  final HealthStats initialStats;
  
  const HealthStatsEditPage({
    super.key,
    required this.initialStats,
  });

  @override
  State<HealthStatsEditPage> createState() => _HealthStatsEditPageState();
}

class _HealthStatsEditPageState extends State<HealthStatsEditPage> {
  final _formKey = GlobalKey<FormState>();
  final HealthService _healthService = HealthService();
  late final Map<HealthField, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      HealthField.height: TextEditingController(text: widget.initialStats.height?.toString() ?? ''),
      HealthField.weight: TextEditingController(text: widget.initialStats.weight?.toString() ?? ''),
      HealthField.bloodPressure: TextEditingController(text: widget.initialStats.bloodPressure),
      HealthField.bloodSugar: TextEditingController(text: widget.initialStats.bloodSugar?.toString() ?? ''),
      HealthField.heartRate: TextEditingController(text: widget.initialStats.heartRate?.toString() ?? ''),
      HealthField.bloodType: TextEditingController(text: widget.initialStats.bloodType),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Health Stats'),
        backgroundColor: const Color(0xFF16A249),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStatField(
                'Height (cm)',
                _controllers[HealthField.height]!,
                Icons.height,
                isRequired: true,
              ),
              _buildStatField(
                'Weight (kg)',
                _controllers[HealthField.weight]!,
                Icons.monitor_weight,
                isRequired: true,
              ),
              _buildStatField(
                'Blood Pressure (mmHg)',
                _controllers[HealthField.bloodPressure]!,
                Icons.favorite,
                isRequired: true,
              ),
              _buildStatField(
                'Blood Sugar (mg/dL)',
                _controllers[HealthField.bloodSugar]!,
                Icons.bloodtype,
                isRequired: true,
              ),
              _buildStatField(
                'Heart Rate (BPM)',
                _controllers[HealthField.heartRate]!,
                Icons.favorite_border,
                isRequired: true,
              ),
              _buildStatField(
                'Blood Type',
                _controllers[HealthField.bloodType]!,
                Icons.bloodtype,
                isRequired: true,
              ),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF16A249)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: _getKeyboardType(label),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  TextInputType _getKeyboardType(String label) {
    if (label.contains('Type')) {
      return TextInputType.text;
    }
    return TextInputType.number;
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF16A249),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: _saveHealthStats,
      child: const Text(
        'Save Health Stats',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _saveHealthStats() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final updatedStats = HealthStats(
        height: double.tryParse(_controllers[HealthField.height]!.text),
        weight: double.tryParse(_controllers[HealthField.weight]!.text),
        bloodPressure: _controllers[HealthField.bloodPressure]!.text,
        bloodSugar: double.tryParse(_controllers[HealthField.bloodSugar]!.text),
        heartRate: int.tryParse(_controllers[HealthField.heartRate]!.text),
        bloodType: _controllers[HealthField.bloodType]!.text,
      );

      await _healthService.updateHealthStats(user.uid, updatedStats);

      if (!mounted) return;
      Navigator.pop(context, updatedStats);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

enum HealthField {
  height,
  weight,
  bloodPressure,
  bloodSugar,
  heartRate,
  bloodType,
}