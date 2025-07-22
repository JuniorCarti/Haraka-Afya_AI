import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/features/learn_page.dart';
import 'package:haraka_afya_ai/features/symptoms_page.dart';
import 'package:haraka_afya_ai/features/hospitals_page.dart';

class GlovoStyleQuickActions extends StatelessWidget {
  final Function(int) onItemSelected;

  const GlovoStyleQuickActions({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Quick Services',
            style: TextStyle(
              fontSize: 16, // Reduced from 20
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100, // Reduced from 140
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(width: 4),
              _buildActionItem(
                context,
                icon: Icons.medical_services,
                label: 'Pharmacy',
                image: 'assets/images/pharmacy.png',
                color: const Color(0xFF6AC5F1),
                onTap: () => onItemSelected(0),
              ),
              _buildActionItem(
                context,
                icon: Icons.local_hospital,
                label: 'Hospitals',
                image: 'assets/images/hospital.png',
                color: const Color(0xFFF16A6A),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HospitalsPage()),
                ),
              ),
              _buildActionItem(
                context,
                icon: Icons.health_and_safety,
                label: 'Symptoms',
                image: 'assets/images/symptoms.png',
                color: const Color(0xFF6AF1B2),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SymptomsPage()),
                ),
              ),
              _buildActionItem(
                context,
                icon: Icons.school,
                label: 'Learn',
                image: 'assets/images/learn.png',
                color: const Color(0xFFF1E66A),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LearnPage()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Reduced padding
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        elevation: 1, // Reduced elevation
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 80, // Reduced from 100
            padding: const EdgeInsets.all(8), // Reduced padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40, // Reduced from 56
                  height: 40, // Reduced from 56
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8), // Reduced radius
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 20, // Reduced from 28
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Reduced spacing
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10, // Reduced from 12
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}