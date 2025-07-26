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

  // Top 6 killer cancer diseases in Kenya
  final List<String> cancerTypes = [
    'Breast Cancer',
    'Cervical Cancer',
    'Prostate Cancer',
    'Esophageal Cancer',
    'Colorectal Cancer',
    'Liver Cancer'
  ];

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
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Healthcare Facilities'),
            Text(
              'Find quality care near you',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black, // Changed from white70 to black
                  ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0C6D5B), // Keeping app bar color consistent
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // View toggle card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildViewToggle('List View', Icons.list),
                  _buildViewToggle('Map View', Icons.map),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search Cancer Facilities, Hospitals and Doctors',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_outlined),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Category filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('General'),
                ...cancerTypes.map((type) => _buildCategoryChip(type)).toList(),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedView == 'Map View' ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(String title, IconData icon) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: _selectedView == title ? const Color(0xFF0C6D5B) : Colors.white,
          foregroundColor: _selectedView == title ? Colors.white : Colors.black,
          side: BorderSide(
            color: _selectedView == title ? const Color(0xFF0C6D5B) : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => setState(() => _selectedView = title),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = selected ? category : 'All';
          });
        },
        selectedColor: const Color(0xFF0C6D5B),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: _selectedCategory == category ? Colors.white : Colors.black,
        ),
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
              elevation: 2,
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
        ...doctors.map((doc) => _buildDoctorCard(doc)),
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
      elevation: 2,
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