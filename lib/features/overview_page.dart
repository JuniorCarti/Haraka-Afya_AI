import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haraka_afya_ai/pages/health/health_stats_edit_page.dart';
import 'package:haraka_afya_ai/models/health_stats.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic> _userData = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isEditing = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _loadProfileData();
      await _loadRecentActivities();
    }
  }

  Future<void> _loadProfileData() async {
    final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
    if (userDoc.exists) {
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>;
        _phoneController.text = _userData['phoneNumber'] ?? '';
        _ageController.text = _userData['age']?.toString() ?? '';
      });
    }
  }

  Future<void> _loadRecentActivities() async {
    final activities = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    setState(() {
      _recentActivities =
          activities.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'phoneNumber': _phoneController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
      });

      setState(() => _isEditing = false);
      await _loadProfileData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Future<void> _navigateToHealthStatsEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthStatsEditPage(
          initialStats: HealthStats.fromMap(_userData['healthStats']),
        ),
      ),
    );

    if (result == true) {
      await _loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F6EC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildHealthStatsSection(),
            const SizedBox(height: 24),
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _userData['subscriptionType'] == 'premium'
              ? const Color(0xFFFEF5D6)
              : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              child: _userData['firstName'] != null
                  ? Text(
                      _userData['firstName'][0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, color: Color(0xFF16A249)),
                    )
                  : const Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_user?.email ?? ''),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _userData['subscriptionType'] == 'premium'
                    ? const Color(0xFF16A249)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _userData['subscriptionType'] == 'premium' ? 'PREMIUM' : 'FREE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_isEditing)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A249),
                ),
                onPressed: () => setState(() => _isEditing = true),
                child: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF16A249))),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A249),
                    ),
                    onPressed: _updateProfile,
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF16A249).withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Statistics',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A249)),
                ),
                if (_isEditing)
                  TextButton(
                    onPressed: _navigateToHealthStatsEdit,
                    child: const Text('Edit',
                        style: TextStyle(color: Color(0xFF16A249))),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_userData['healthStats'] == null || _userData['healthStats'].isEmpty)
              const Center(
                child: Text(
                  'No health data available\nTap Edit to add your health stats',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard('Height', '${_userData['healthStats']['height']} cm', Icons.height),
                  _buildStatCard('Weight', '${_userData['healthStats']['weight']} kg', Icons.monitor_weight),
                  _buildStatCard('Blood Pressure', _userData['healthStats']['bloodPressure'], Icons.favorite),
                  _buildStatCard('Blood Sugar', '${_userData['healthStats']['bloodSugar']} mg/dL', Icons.bloodtype),
                  _buildStatCard('Heart Rate', '${_userData['healthStats']['heartRate']} BPM', Icons.favorite_border),
                  _buildStatCard('Blood Type', _userData['healthStats']['bloodType'], Icons.bloodtype),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF16A249)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF16A249))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF16A249).withOpacity(0.1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A249)),
            ),
            const SizedBox(height: 12),
            if (_recentActivities.isEmpty)
              const Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: _recentActivities
                    .map((activity) => _buildActivityItem(activity))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF16A249),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['title'] ?? 'Activity',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF16A249))),
                if (activity['timestamp'] != null)
                  Text(_formatTimestamp(activity['timestamp']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
