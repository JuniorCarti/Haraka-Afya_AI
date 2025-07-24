import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  String _selectedView = 'List View';
  String _selectedCategory = 'All';
  late GoogleMapController mapController;

  final Map<String, List<String>> cancerSubcategories = {
    'Cancer': [
      'Breast Cancer',
      'Cervical Cancer',
      'Prostate Cancer',
      'Lung Cancer',
      'Colorectal Cancer',
      'Leukemia'
    ],
  };

  final List<Map<String, dynamic>> hospitals = [
    {
      'name': 'HCG CCK Cancer Centre',
      'location': LatLng(-1.2921, 36.8219),
      'type': 'Cancer',
      'specialties': ['Breast Cancer', 'Lung Cancer']
    },
    {
      'name': 'Aga Khan University Hospital',
      'location': LatLng(-1.2684, 36.8044),
      'type': 'Cancer',
      'specialties': ['Leukemia', 'Cervical Cancer']
    },
  ];

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Sarah Wanjiku',
      'specialty': 'Oncologist',
      'hospital': 'Kenyatta National Hospital',
      'availability': 'Today 2:00 PM - 6:00 PM',
      'rating': 4.8,
      'experience': '15 years',
      'specialties': ['Lung Cancer', 'Breast Cancer']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals & Facilities'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildViewToggle('List View'),
              _buildViewToggle('Map View'),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryFilters(),
          const Divider(),
          Expanded(
            child: _selectedView == 'Map View' ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(String title) {
    return ChoiceChip(
      label: Text(title),
      selected: _selectedView == title,
      onSelected: (_) => setState(() => _selectedView = title),
      selectedColor: const Color(0xFF0C6D5B),
      labelStyle: TextStyle(
        color: _selectedView == title ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildCategoryFilters() {
    List<String> allCategories = ['All', 'General', 'Maternity', 'Dental', ...cancerSubcategories['Cancer']!];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          String category = allCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (bool selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'All';
                });
              },
              selectedColor: const Color(0xFF0C6D5B),
              labelStyle: TextStyle(
                color: _selectedCategory == category ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    List<Map<String, dynamic>> filteredHospitals = _selectedCategory == 'All'
        ? hospitals
        : hospitals.where((h) => h['specialties'].contains(_selectedCategory)).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ...filteredHospitals.map((hospital) => Card(
              child: ListTile(
                title: Text(hospital['name']),
                subtitle: Text(hospital['type']),
              ),
            )),
        const SizedBox(height: 16),
        const Text(
          'Specialist Doctors',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...doctors.map((doc) => _buildDoctorCard(doc)).toList(),
      ],
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      initialCameraPosition: const CameraPosition(
        target: LatLng(-1.2921, 36.8219),
        zoom: 12,
      ),
      markers: hospitals.map((h) => Marker(
            markerId: MarkerId(h['name']),
            position: h['location'],
            infoWindow: InfoWindow(title: h['name']),
          )).toSet(),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(doc['specialty']),
            Text(doc['hospital']),
            const SizedBox(height: 8),
            Text(doc['availability'], style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            Text('Rating: ${doc['rating']}, Experience: ${doc['experience']}'),
            Wrap(
              spacing: 8,
              children: List.generate(
                doc['specialties'].length,
                (index) => Chip(label: Text(doc['specialties'][index])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
