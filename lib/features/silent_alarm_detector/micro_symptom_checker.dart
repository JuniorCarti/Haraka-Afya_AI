import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:camera/camera.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class MicroSymptomChecker extends StatefulWidget {
  const MicroSymptomChecker({super.key});

  @override
  State<MicroSymptomChecker> createState() => _MicroSymptomCheckerState();
}

class _MicroSymptomCheckerState extends State<MicroSymptomChecker> {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _analysisResult = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFEE5A24),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEE5A24).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _startWeeklyCheckin(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Iconsax.eye,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Micro-Symptom Checker',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'AI-powered voice & visual symptom detection',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Iconsax.arrow_right_3, 
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildCheckinFeature(
                            icon: Iconsax.microphone,
                            label: 'Voice Analysis',
                            description: 'Detect vocal fatigue & changes',
                          ),
                          const SizedBox(width: 16),
                          _buildCheckinFeature(
                            icon: Iconsax.camera,
                            label: 'Visual Check',
                            description: 'Analyze facial indicators',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '2-minute weekly check-in recommended',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_analysisResult.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.info_circle, 
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _analysisResult,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckinFeature({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _startWeeklyCheckin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: const WeeklyCheckinScreen(),
      ),
    );
  }
}

class WeeklyCheckinScreen extends StatefulWidget {
  const WeeklyCheckinScreen({super.key});

  @override
  State<WeeklyCheckinScreen> createState() => _WeeklyCheckinScreenState();
}

class _WeeklyCheckinScreenState extends State<WeeklyCheckinScreen> {
  int _currentStep = 0;
  bool _isRecording = false;
  String _recordedAudioPath = '';

  final List<CheckinStep> _steps = [
    CheckinStep(
      title: 'Voice Recording',
      description: 'Please read the sentence below in your normal voice',
      instruction: 'Read: "The quick brown fox jumps over the lazy dog"',
      type: CheckinType.voice,
    ),
    CheckinStep(
      title: 'Visual Check',
      description: 'Position your face in the frame for analysis',
      instruction: 'Look straight at the camera with natural lighting',
      type: CheckinType.visual,
    ),
    CheckinStep(
      title: 'Symptom Report',
      description: 'Briefly describe how you\'ve been feeling',
      instruction: 'Mention any unusual symptoms or changes',
      type: CheckinType.symptoms,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStepData = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Weekly Health Check-in',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF259450)),
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            
            // Step content
            Expanded(
              child: _buildStepContent(currentStepData),
            ),
            
            // Navigation buttons
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF259450),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1 ? 'Complete' : 'Next',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(CheckinStep step) {
    switch (step.type) {
      case CheckinType.voice:
        return _buildVoiceStep(step);
      case CheckinType.visual:
        return _buildVisualStep(step);
      case CheckinType.symptoms:
        return _buildSymptomsStep(step);
    }
  }

  Widget _buildVoiceStep(CheckinStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Iconsax.microphone_2, size: 40, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                step.instruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              if (_isRecording)
                AudioWaveforms(
                  size: Size(MediaQuery.of(context).size.width - 80, 50),
                  recorderController: RecorderController(), // You'll need to set this up
                  waveStyle: const WaveStyle(
                    waveColor: Color(0xFF259450),
                    showDurationLabel: false,
                    spacing: 8,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : const Color(0xFF259450),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: Icon(
                  _isRecording ? Iconsax.stop : Iconsax.microphone,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualStep(CheckinStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.camera, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  step.instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement camera functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF259450),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Start Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsStep(CheckinStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: step.instruction,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your symptoms are analyzed for patterns that might indicate early health changes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // Implement actual recording logic
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeCheckin();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeCheckin() {
    // Implement analysis logic
    Navigator.of(context).pop();
    // Show results
  }
}

enum CheckinType { voice, visual, symptoms }

class CheckinStep {
  final String title;
  final String description;
  final String instruction;
  final CheckinType type;

  CheckinStep({
    required this.title,
    required this.description,
    required this.instruction,
    required this.type,
  });
}