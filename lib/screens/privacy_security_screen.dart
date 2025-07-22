import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F7F8),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6F6EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Row(
          children: const [
            CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE7F6EB),
              child: Icon(Icons.shield, size: 18, color: Color(0xFF16A249)),
            ),
            SizedBox(width: 8),
            Text(
              'Privacy & Security',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecurityStatusRow(),
            const SizedBox(height: 24),
            const Text('Authentication', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSwitchTile(Icons.phone_iphone, 'Two-Factor Authentication', 'Add extra security with SMS verification', false),
            _buildSwitchTile(Icons.fingerprint, 'Biometric Authentication', 'Use fingerprint or face ID', false),
            _buildSwitchTile(Icons.lock_outline, 'Auto-Lock', 'Lock app when inactive', true),
            const SizedBox(height: 24),
            const Text('Privacy Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSwitchTile(Icons.visibility, 'Data Sharing', 'Share anonymized health data for research', false),
            _buildSwitchTile(Icons.location_on, 'Location Tracking', 'Find nearby healthcare facilities', false),
            _buildSwitchTile(Icons.notifications, 'Push Notifications', 'Medication reminders and health tips', true),
            const SizedBox(height: 24),
            _buildSupportCard(),
            const SizedBox(height: 24),
            const Text('Legal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildLegalItem('Privacy Policy'),
            _buildLegalItem('Terms of Service'),
            _buildLegalItem('Data Protection Notice'),
            _buildLegalItem('Cookie Policy'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                Icon(Icons.shield, color: Color(0xFF16A249), size: 28),
                SizedBox(height: 6),
                Text('Protected', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A249)))
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                Icon(Icons.lock, color: Color(0xFF3B82F6), size: 28),
                SizedBox(height: 6),
                Text('Encrypted', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: enabled,
            onChanged: (val) {},
            activeColor: const Color(0xFF16A249),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.email, color: Color(0xFF16A249)),
              SizedBox(width: 8),
              Text('Need Help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact our support team for any privacy or security concerns.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: implement email support logic
            },
            icon: const Icon(Icons.mail),
            label: const Text('Email Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A249),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: navigate to legal page
      },
    );
  }
}
