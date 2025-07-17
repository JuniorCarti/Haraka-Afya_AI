import 'package:flutter/material.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  String _selectedView = 'Map View'; // 'Map View' or 'List View'
  String _selectedCategory = 'General'; // Selected category filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals & Facilities'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View Toggle and Search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildViewToggle('Map View'),
                _buildViewToggle('List View'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search hospitals, clinics...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Category Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryFilter('General'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Maternity'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Dental'),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 1),

            // Emergency Services
            const Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Need immediate assistance? Call 911',
              style: TextStyle(fontSize: 16),
            ),
            const Divider(height: 40, thickness: 1),

            // Specialist Doctors
            const Text(
              'Specialist Doctors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDoctorCard(
              name: 'Dr. Sarah Wanjiku',
              specialty: 'Oncologist (Cancer Specialist)',
              hospital: 'Kenyatta National Hospital',
              availability: 'Available Today 2:00 PM - 6:00 PM',
              rating: 4.8,
              experience: '15 years',
              specialties: ['Lung Cancer', 'Breast Cancer', 'Prostate Cancer'],
            ),
          ],
        ),
      ),
      // Removed the bottomNavigationBar from here
    );
  }

  Widget _buildViewToggle(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedView = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedView == title ? const Color(0xFF0C6D5B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0C6D5B),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedView == title ? Colors.white : const Color(0xFF0C6D5B),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(String category) {
    return FilterChip(
      label: Text(category),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : 'General';
        });
      },
      selectedColor: const Color(0xFF0C6D5B),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: _selectedCategory == category ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String hospital,
    required String availability,
    required double rating,
    required String experience,
    required List<String> specialties,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(specialty),
            Text(hospital),
            const SizedBox(height: 8),
            Text(
              availability,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rating.toString(),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(experience),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: specialties.map((spec) => Chip(
                label: Text(spec),
                backgroundColor: Colors.grey[200],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}