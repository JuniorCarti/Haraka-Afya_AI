import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class MetabolicMonitor extends StatefulWidget {
  const MetabolicMonitor({super.key});

  @override
  State<MetabolicMonitor> createState() => _MetabolicMonitorState();
}

class _MetabolicMonitorState extends State<MetabolicMonitor> {
  bool _isMonitoring = false;
  double _metabolicScore = 0.85;
  List<GlucoseReading> _recentReadings = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock data - replace with actual CGM API integration
    _recentReadings = [
      GlucoseReading(DateTime.now().subtract(const Duration(hours: 2)), 95),
      GlucoseReading(DateTime.now().subtract(const Duration(hours: 1)), 102),
      GlucoseReading(DateTime.now(), 98),
    ];
    _calculateMetabolicScore();
  }

  void _calculateMetabolicScore() {
    // Simple algorithm to detect anomalies
    double volatility = _calculateGlucoseVolatility();
    setState(() {
      _metabolicScore = (1.0 - volatility.clamp(0.0, 0.3)) * 0.85;
    });
  }

  double _calculateGlucoseVolatility() {
    if (_recentReadings.length < 3) return 0.0;
    
    double sum = 0;
    for (var reading in _recentReadings) {
      sum += reading.value;
    }
    double mean = sum / _recentReadings.length;
    
    double variance = 0;
    for (var reading in _recentReadings) {
      variance += (reading.value - mean) * (reading.value - mean);
    }
    
    return (variance / _recentReadings.length) / 100; // Normalized volatility
  }

  void _startMonitoring() {
    setState(() {
      _isMonitoring = true;
    });
    // In real implementation, start listening to CGM data stream
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
        ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
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
            _showMetabolicInsights(context);
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
                      child: const Icon(Iconsax.activity,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metabolic Monitor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Continuous glucose monitoring & pattern analysis',
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
                
                // Metabolic Score Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metabolic Stability',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _metabolicScore,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _metabolicScore > 0.7 ? Colors.green : 
                                _metabolicScore > 0.4 ? Colors.orange : Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_metabolicScore * 100).toStringAsFixed(0)}% Stable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatusIndicator(),
                    ],
                  ),
                ),
                
                if (_isMonitoring) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Active monitoring - No anomalies detected',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;
    
    if (_metabolicScore > 0.7) {
      statusColor = Colors.green;
      statusText = 'Normal';
    } else if (_metabolicScore > 0.4) {
      statusColor = Colors.orange;
      statusText = 'Monitor';
    } else {
      statusColor = Colors.red;
      statusText = 'Alert';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMetabolicInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: const MetabolicInsightsScreen(),
      ),
    );
  }
}

class MetabolicInsightsScreen extends StatelessWidget {
  const MetabolicInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Metabolic Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // Add detailed metabolic charts and insights here
          Expanded(
            child: Center(
              child: Text(
                'Detailed metabolic analysis coming soon...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlucoseReading {
  final DateTime timestamp;
  final double value;

  GlucoseReading(this.timestamp, this.value);
}