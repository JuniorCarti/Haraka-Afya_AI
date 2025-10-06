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
          activities.docs.map((doc) => doc.data()).toList();
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
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: const Color(0xFF259450),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToHealthStatsEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthStatsEditPage(
          initialStats: HealthStats.fromMap(_userData['healthStats'] ?? {}),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
    final isPremium = _userData['subscriptionType'] == 'premium';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isPremium
            ? const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFA000),
                ],
              )
            : const LinearGradient(
                colors: [
                  Color(0xFF259450),
                  Color(0xFF1976D2),
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF259450).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: _userData['photoURL'] != null
                        ? DecorationImage(
                            image: NetworkImage(_userData['photoURL']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _userData['photoURL'] == null
                      ? Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              _userData['firstName'] != null && _userData['firstName'].isNotEmpty
                                  ? _userData['firstName'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF259450),
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                if (isPremium)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Color(0xFFFFA000),
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}'.trim(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPremium ? 'PREMIUM MEMBER' : 'FREE PLAN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isEditing)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
          child: Material(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(12),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => setState(() => _isEditing = true), // ✅ changed onPressed → onTap
    child: const Center(
      child: Text(
        'Edit Profile',
        style: TextStyle(
          color: Color(0xFF259450),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
),

              )
            else
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                child: Material(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(12),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => setState(() => _isEditing = false), // ✅ changed onPressed → onTap
    child: const Center(
      child: Text(
        'Cancel',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
),

                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                   child: Material(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(12),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: _updateProfile, // ✅ changed from onPressed → onTap
    child: const Center(
      child: Text(
        'Save',
        style: TextStyle(
          color: Color(0xFF259450),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
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

  Widget _buildHealthStatsSection() {
    final hasHealthData = _userData['healthStats'] != null && _userData['healthStats'].isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(8),
  child: InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: _navigateToHealthStatsEdit, // ✅ changed from onPressed → onTap
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.edit, size: 14, color: Color(0xFF259450)),
          SizedBox(width: 4),
          Text(
            'Edit',
            style: TextStyle(
              color: Color(0xFF259450),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasHealthData)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Health Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your health statistics to track your wellness journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard('Height', '${_userData['healthStats']['height']} cm', Icons.height, const Color(0xFF259450)),
                  _buildStatCard('Weight', '${_userData['healthStats']['weight']} kg', Icons.monitor_weight, const Color(0xFF1976D2)),
                  _buildStatCard('Blood Pressure', _userData['healthStats']['bloodPressure'], Icons.monitor_heart, const Color(0xFFD32F2F)),
                  _buildStatCard('Blood Sugar', '${_userData['healthStats']['bloodSugar']} mg/dL', Icons.water_drop, const Color(0xFFE91E63)),
                  _buildStatCard('Heart Rate', '${_userData['healthStats']['heartRate']} BPM', Icons.favorite, const Color(0xFF7B1FA2)),
                  _buildStatCard('Blood Type', _userData['healthStats']['bloodType'], Icons.bloodtype, const Color(0xFF0097A7)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            if (_recentActivities.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your recent activities will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF259450),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] ?? 'Activity',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (activity['timestamp'] != null)
                    Text(
                      _formatTimestamp(activity['timestamp']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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