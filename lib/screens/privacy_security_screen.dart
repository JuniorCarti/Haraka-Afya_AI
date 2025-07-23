import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:haraka_afya_ai/widgets/LegalDocumentsScreen.dart';
import 'package:haraka_afya_ai/widgets/legal_documents.dart';
import 'package:haraka_afya_ai/features/profile_page.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to profile page when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F7F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE6F6EC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Navigate to profile page when back arrow is pressed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
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
              _buildSupportCard(context),
              const SizedBox(height: 24),
              const Text('Legal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToDocumentScreen(context, 'Privacy Policy', LegalDocuments.privacyPolicy),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToDocumentScreen(context, 'Terms of Service', LegalDocuments.termsOfService),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data Protection Notice'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToDocumentScreen(context, 'Data Protection Notice', LegalDocuments.dataProtectionNotice),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cookie Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToDocumentScreen(context, 'Cookie Policy', LegalDocuments.cookiePolicy),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
            activeTrackColor: const Color(0xFF16A249),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
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
              _launchEmailSupport(context);
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

  void _navigateToDocumentScreen(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalDocumentsScreen(
          documentType: title,
          content: content,
        ),
      ),
    );
  }

  void _launchEmailSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening email support...')),
    );
  }
}