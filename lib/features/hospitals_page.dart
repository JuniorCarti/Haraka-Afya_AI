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

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF259450),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF259450).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cancer Care Facilities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find specialized cancer treatment centers near you',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCategories() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cancerTypes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = cancerTypes[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF259450),
                          Color(0xFF27AE60),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFEEEEEE),
                  width: 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF259450).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Cancer Facilities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6C757D)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Search by hospital name or location...',
                      hintStyle: TextStyle(color: Color(0xFF6C757D)),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(DocumentSnapshot hospitalDoc) {
    final facility = hospitalDoc.data() as Map<String, dynamic>;
    final isFavorite = _favoriteHospitals.contains(hospitalDoc.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                        color: Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_hospital, size: 50, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text(
                              'Hospital Image',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                      onPressed: () => _toggleFavorite(hospitalDoc.id),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          facility['rating']?.toString() ?? '0.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Hospital Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hospital Name and Share
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facility['name'] ?? 'Unknown Hospital',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, size: 18),
                          onPressed: () => _shareHospital(facility),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location and Distance
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          facility['location'] ?? 'Unknown Location',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          facility['distance'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF259450),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cancer Types
                  const Text(
                    'Specialized In:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (facility['cancerTypes'] as List<dynamic>?)?.map((type) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF259450),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList() ?? [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No data available',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Specialists Section
                  _buildSpecialistsSection(facility),
                  const SizedBox(height: 16),

                  // Equipment Section
                  _buildEquipmentSection(facility),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistsSection(Map<String, dynamic> facility) {
    final specialists = facility['specialists'] as List<dynamic>?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Top Specialists',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            if (specialists != null && specialists.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF259450),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (specialists == null || specialists.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No specialists listed',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...specialists.take(2).map((specialist) {
            final specData = specialist as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: specData['image'] != null 
                        ? NetworkImage(specData['image']!)
                        : null,
                    child: specData['image'] == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          specData['name'] ?? 'Unknown Specialist',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specData['specialty'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                            const SizedBox(width: 4),
                            Text(
                              specData['rating']?.toString() ?? '0.0',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${specData['experience'] ?? ''} exp',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF259450),
                          Color(0xFF27AE60),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEquipmentSection(Map<String, dynamic> facility) {
    final equipment = facility['equipment'] as List<dynamic>?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Advanced Equipment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            if (equipment != null && equipment.isNotEmpty)
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF259450),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (equipment == null || equipment.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No equipment listed',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipment.take(4).map((equip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                equip.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Cancer Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        actions: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.map_outlined, size: 18),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            
            const SizedBox(height: 24),
            
            // Quick Access Cards
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessCard(
                    title: 'Nearby Centers',
                    subtitle: 'Find closest facilities',
                    icon: Icons.near_me,
                    color: const Color(0xFFFFF0F5),
                    iconColor: const Color(0xFFE75480),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessCard(
                    title: 'Emergency Care',
                    subtitle: '24/7 emergency services',
                    icon: Icons.emergency,
                    color: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1976D2),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Categories Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Cancer Types',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildHorizontalCategories(),
            
            const SizedBox(height: 24),
            
            // Search Section
            _buildSearchBar(),
            
            const SizedBox(height: 32),
            
            // Facilities List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Specialized Facilities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load facilities',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No facilities found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for updates',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
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
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching facilities',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: hospitals.map((hospital) => _buildFacilityCard(hospital)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}