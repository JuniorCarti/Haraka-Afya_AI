import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/models/health_stats.dart';

class HealthStatsViewPage extends StatelessWidget {
  final HealthStats stats;

  const HealthStatsViewPage({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Health Statistics',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[700]!, Colors.purple[700]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.health_and_safety,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Health Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your complete health profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic Information Section
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  title: 'Height',
                  value: stats.height != null ? '${stats.height} cm' : 'Not set',
                  icon: Icons.height,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Weight',
                  value: stats.weight != null ? '${stats.weight} kg' : 'Not set',
                  icon: Icons.monitor_weight,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Blood Type',
                  value: stats.bloodType.isNotEmpty ? stats.bloodType : 'Not set',
                  icon: Icons.bloodtype,
                  color: Colors.red,
                ),
                _buildStatCard(
                  title: 'Heart Rate',
                  value: stats.heartRate != null ? '${stats.heartRate} bpm' : 'Not set',
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Medical Metrics Section
            const Text(
              'Medical Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildMetricTile(
                  title: 'Blood Pressure',
                  value: stats.bloodPressure.isNotEmpty ? stats.bloodPressure : 'Not measured',
                  icon: Icons.monitor_heart,
                  color: Colors.deepPurple,
                ),
                _buildMetricTile(
                  title: 'Blood Sugar',
                  value: stats.bloodSugar != null ? '${stats.bloodSugar} mg/dL' : 'Not measured',
                  icon: Icons.water_drop,
                  color: Colors.teal,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assessment, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getSummaryText(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String _getSummaryText() {
    int filledFields = 0;
    int totalFields = 6;
    
    if (stats.height != null) filledFields++;
    if (stats.weight != null) filledFields++;
    if (stats.bloodPressure.isNotEmpty) filledFields++;
    if (stats.bloodSugar != null) filledFields++;
    if (stats.heartRate != null) filledFields++;
    if (stats.bloodType.isNotEmpty) filledFields++;
    
    if (filledFields == 0) {
      return 'Start by adding your health information to get a complete overview of your health status.';
    } else if (filledFields < totalFields) {
      return 'You have provided $filledFields out of $totalFields health metrics. Consider adding more information for a comprehensive health profile.';
    } else {
      return 'Great! You have a complete health profile. All $totalFields metrics are recorded and available for review.';
    }
  }
}