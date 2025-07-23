import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/models/health_stats.dart';


class HealthStatsViewPage extends StatelessWidget {
  final HealthStats stats;

  const HealthStatsViewPage({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HealthStatCard(
            title: 'Height',
            value: '${stats.height} cm',
            icon: Icons.height,
          ),
          // Add other stat cards similarly
        ],
      ),
    );
  }
  
  HealthStatCard({required String title, required String value, required IconData icon}) {}
}