import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<String> _favoriteHospitals = {};

  final List<String> cancerTypes = [
    'All',
    'Breast',
    'Lung',
    'Prostate',
    'Leukemia',
    'Skin',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _toggleFavorite(String hospitalId) {
    setState(() {
      if (_favoriteHospitals.contains(hospitalId)) {
        _favoriteHospitals.remove(hospitalId);
      } else {
        _favoriteHospitals.add(hospitalId);
      }
    });
  }

  Future<void> _shareHospital(Map<String, dynamic> facility) async {
    final String shareText = 
        'Check out ${facility['name']} located at ${facility['location']}. '
        'Specializes in: ${(facility['cancerTypes'] as List<dynamic>).join(', ')}. '
        'Rating: ${facility['rating']}';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        title: const Text(
          'Browse Cancer Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
            // Cancer Types Section with proper spacing
            const Padding(
              padding: EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
              child: Text(
                'Cancer Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 60, // Increased height to prevent cutting
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: cancerTypes.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedCategory == cancerTypes[index];
                  bool isAll = cancerTypes[index] == 'All';
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 12.0), // Increased right margin
                    child: ChoiceChip(
                      label: Text(
                        cancerTypes[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? const Color(0xFF0C6D5B) : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cancerTypes[index];
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFA4D3A5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: const Color(0xFF0C6D5B),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Updated Search Bar with new background color and no filter icon
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F4), // Updated background color
                  hintText: 'Search by hospital name or location...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Facilities List with proper spacing
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No hospitals found',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }

                var hospitals = snapshot.data!.docs.where((hospital) {
                  if (_selectedCategory != 'All') {
                    final cancerTypes = hospital['cancerTypes'] as List<dynamic>;
                    if (!cancerTypes.any((type) => type.toString().contains(_selectedCategory))) {
                      return false;
                    }
                  }

                  if (_searchQuery.isNotEmpty) {
                    final name = hospital['name'].toString().toLowerCase();
                    final location = hospital['location'].toString().toLowerCase();
                    if (!name.contains(_searchQuery) && !location.contains(_searchQuery)) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (hospitals.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No matching hospitals found',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildFacilityCard(hospitals[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(DocumentSnapshot hospitalDoc) {
    final facility = hospitalDoc.data() as Map<String, dynamic>;
    final isFavorite = _favoriteHospitals.contains(hospitalDoc.id);
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
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
                  facility['image'] ?? '',
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
                        facility['rating']?.toString() ?? '0.0',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _toggleFavorite(hospitalDoc.id),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facility['name'] ?? 'Unknown Hospital',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareHospital(facility),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        facility['location'] ?? 'Unknown Location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      facility['distance'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cancer Types Treated
                const Text(
                  'Cancer Types Treated:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (facility['cancerTypes'] as List<dynamic>?)?.map((type) => Chip(
                    label: Text(
                      type.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFFE8F5E9),
                    labelStyle: const TextStyle(fontSize: 12),
                  )).toList() ?? [const Chip(label: Text('No data available'))],
                ),
                const SizedBox(height: 16),

                // Specialists Section
                Row(
                  children: [
                    const Text(
                      'Specialists',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF259450),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(facility['specialists'] as List<dynamic>?)?.map((specialist) {
                  final specData = specialist as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color(0xFFD7FBE5),
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
                                  backgroundImage: NetworkImage(specData['image'] ?? ''),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        specData['name'] ?? 'Unknown Specialist',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        specData['specialty'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          Text(
                                            ' ${specData['rating'] ?? '0.0'}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${specData['experience'] ?? ''} exp',
                                            style: const TextStyle(fontSize: 14),
                                          ),
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
                                  backgroundColor: const Color(0xFF269A51),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Schedule an appointment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList() ?? [const Text(
                  'No specialists available',
                  style: TextStyle(fontSize: 14),
                )],

                // Equipment Section
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Equipments Available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF259450),
                        ),
                      ),
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
                                  children: (facility['equipment'] as List<dynamic>?)?.map((equip) => Chip(
                                    label: Text(
                                      equip.toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: const Color(0xFFE3F2FD),
                                    labelStyle: const TextStyle(fontSize: 12),
                                  )).toList() ?? [const Chip(label: Text('No data available'))],
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