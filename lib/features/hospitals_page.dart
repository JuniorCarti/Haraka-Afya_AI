import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> cancerTypes = [
    'All',
    'Breast',
    'Lung',
    'Prostate',
    'Leukemia',
    'Skin',
  ];

  final List<Map<String, dynamic>> facilities = [
    {
      'name': 'Hope Cancer Center',
      'location': 'New York, NY',
      'image': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'distance': '2.5 miles away',
      'rating': 4.8,
      'cancerTypes': ['Breast Cancer', 'Lung Cancer', 'Leukemia'],
      'specialists': [
        {
          'name': 'Dr. Sarah Johnson',
          'specialty': 'Medical Oncology',
          'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
          'experience': '12 years',
          'rating': 4.9,
        },
        {
          'name': 'Dr. Michael Chen',
          'specialty': 'Radiation Oncology',
          'image': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1064&q=80',
          'experience': '8 years',
          'rating': 4.7,
        },
      ],
      'equipment': ['MRI', 'CT Scan', 'PET Scan', 'Radiation Therapy'],
    },
    {
      'name': 'Kenya Cancer Institute',
      'location': 'Nairobi, Kenya',
      'image': 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'distance': '5.2 miles away',
      'rating': 4.5,
      'cancerTypes': ['Breast Cancer', 'Cervical Cancer', 'Prostate Cancer'],
      'specialists': [
        {
          'name': 'Dr. Emily Roberts',
          'specialty': 'Surgical Oncology',
          'image': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80',
          'experience': '10 years',
          'rating': 4.8,
        },
        {
          'name': 'Dr. James Wilson',
          'specialty': 'Hematology',
          'image': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1064&q=80',
          'experience': '15 years',
          'rating': 5.0,
        },
      ],
      'equipment': ['CT Scan', 'PET Scan', 'Mammography', 'Radiation Therapy'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        title: const Text(
          'Browse Cancer Facilities',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEDF3F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cancer Types Section with Green Outline Selection
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: Text(
                'Cancer Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: cancerTypes.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedCategory == cancerTypes[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cancerTypes[index];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0C6D5B) : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cancerTypes[index],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF0C6D5B) : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search by hospital name or location...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_alt_outlined),
                    onPressed: () {},
                  ),
                ),
              ),
            ),

            // Facilities List
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: facilities.length,
              itemBuilder: (context, index) => _buildFacilityCard(facilities[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital Image and Basic Info
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  facility['image'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        facility['rating'].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facility['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      facility['location'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      facility['distance'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cancer Types Treated
                const Text(
                  'Cancer Types Treated:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (facility['cancerTypes'] as List<String>).map((type) => Chip(
                    label: Text(type),
                    backgroundColor: const Color(0xFFE8F5E9),
                    labelStyle: const TextStyle(fontSize: 12),
                  )).toList(),
                ),
                const SizedBox(height: 16),

                // Specialists Section
                Row(
                  children: [
                    const Text(
                      'Specialists',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(facility['specialists'] as List<Map<String, dynamic>>).map((specialist) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(specialist['image']),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      specialist['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(specialist['specialty']),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(' ${specialist['rating']}'),
                                        const SizedBox(width: 8),
                                        Text('${specialist['experience']} exp'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C6D5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {},
                              child: const Text('Schedule an appointment'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),

                // Equipment Section
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Equipment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (facility['equipment'] as List<String>).map((equip) => Chip(
                                    label: Text(equip),
                                    backgroundColor: const Color(0xFFE3F2FD),
                                    labelStyle: const TextStyle(fontSize: 12),
                                  )).toList(),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}