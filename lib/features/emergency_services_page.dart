// features/emergency_services_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyServicesPage extends StatelessWidget {
  const EmergencyServicesPage({super.key});

  Future<void> _callEmergency() async {
    const url = 'tel:911';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEmergencyCard(
              title: 'General Emergency',
              location: 'Citywide',
              available: 5,
              inUse: 3,
              waitTime: '8-12 min',
              onCallPressed: _callEmergency,
            ),
            const SizedBox(height: 16),
            _buildEmergencyCard(
              title: 'Aga Khan Hospital',
              location: 'Parklands',
              available: 3,
              inUse: 1,
              waitTime: '5-8 min',
              onCallPressed: _callEmergency,
            ),
            const SizedBox(height: 16),
            _buildEmergencyCard(
              title: 'Nairobi Hospital',
              location: 'Upper Hill',
              available: 4,
              inUse: 2,
              waitTime: '4 Available',
              status: 'En Route',
              onCallPressed: _callEmergency,
            ),
            const SizedBox(height: 16),
            _buildEmergencyCard(
              title: 'Kenyatta National Hospital',
              location: 'Dagoretti',
              available: 8,
              inUse: 0,
              waitTime: '10-15 min',
              onCallPressed: _callEmergency,
            ),
            const SizedBox(height: 16),
            _buildEmergencyCard(
              title: 'MP Shah Hospital',
              location: 'Parklands',
              available: 2,
              inUse: 0,
              waitTime: '7-12 min',
              onCallPressed: _callEmergency,
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emergency Tip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "If you're experiencing chest pain, difficulty breathing, or severe bleeding, call immediately. Don't wait!",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: _callEmergency,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency, size: 24, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'CALL EMERGENCY (911)',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String location,
    required int available,
    required int inUse,
    required String waitTime,
    String? status,
    required VoidCallback onCallPressed,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusIndicator('Available', available),
                const SizedBox(width: 16),
                _buildStatusIndicator('In Use', inUse),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Est. Wait:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      waitTime,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (status != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12), // Reduced padding
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: onCallPressed,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Fix overflow
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 8),
                      Text('Call Now'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}