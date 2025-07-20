import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyServicesPage extends StatefulWidget {
  const EmergencyServicesPage({super.key});

  @override
  State<EmergencyServicesPage> createState() => _EmergencyServicesPageState();
}

class _EmergencyServicesPageState extends State<EmergencyServicesPage> {
  Position? _currentPosition;
  String? _locationError;
  bool _isLoading = true;
  List<EmergencyFacility> facilities = [];
  Map<PolylineId, Polyline> polylines = {};
  LatLng? _selectedFacilityLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeFacilities();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permissions are denied';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Location permissions are permanently denied, we cannot request permissions.';
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        // Sort facilities by distance
        facilities.sort((a, b) {
          double distanceA = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            a.latitude,
            a.longitude,
          );
          double distanceB = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            b.latitude,
            b.longitude,
          );
          return distanceA.compareTo(distanceB);
        });
      });
    } catch (e) {
      setState(() {
        _locationError = 'Could not get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _initializeFacilities() {
    // In a real app, you might fetch these from an API
    facilities = [
      EmergencyFacility(
        id: '1',
        title: 'General Emergency',
        location: 'Citywide',
        latitude: -1.286389,
        longitude: 36.817223,
        available: 5,
        inUse: 3,
      ),
      EmergencyFacility(
        id: '2',
        title: 'Aga Khan Hospital',
        location: 'Parklands',
        latitude: -1.254722,
        longitude: 36.813056,
        available: 3,
        inUse: 1,
      ),
      EmergencyFacility(
        id: '3',
        title: 'Nairobi Hospital',
        location: 'Upper Hill',
        latitude: -1.291389,
        longitude: 36.810833,
        available: 4,
        inUse: 2,
      ),
      EmergencyFacility(
        id: '4',
        title: 'Kenyatta National Hospital',
        location: 'Dagoretti',
        latitude: -1.304722,
        longitude: 36.8075,
        available: 8,
        inUse: 0,
      ),
      EmergencyFacility(
        id: '5',
        title: 'MP Shah Hospital',
        location: 'Parklands',
        latitude: -1.256944,
        longitude: 36.808611,
        available: 2,
        inUse: 0,
      ),
    ];
  }

  Future<void> _callEmergency() async {
    const url = 'tel:911';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _showRoute(EmergencyFacility facility) async {
    if (_currentPosition == null) return;

    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      'YOUR_GOOGLE_MAPS_API_KEY', // Replace with your API key
      PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      PointLatLng(facility.latitude, facility.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      final polylineId = PolylineId(facility.id);
      final polyline = Polyline(
        polylineId: polylineId,
        color: Colors.red,
        points: polylineCoordinates,
        width: 5,
      );

      setState(() {
        polylines[polylineId] = polyline;
        _selectedFacilityLocation = LatLng(facility.latitude, facility.longitude);
      });
    }
  }

  Future<Map<String, dynamic>> _getTravelTime(LatLng destination) async {
    if (_currentPosition == null) return {'duration': 'Unknown', 'distance': 'Unknown'};

    final apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your API key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json?'
      'origins=${_currentPosition!.latitude},${_currentPosition!.longitude}'
      '&destinations=${destination.latitude},${destination.longitude}'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['rows'].isNotEmpty && data['rows'][0]['elements'].isNotEmpty) {
        final element = data['rows'][0]['elements'][0];
        return {
          'duration': element['duration']['text'],
          'distance': element['distance']['text'],
        };
      }
    }
    return {'duration': 'Unknown', 'distance': 'Unknown'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: Colors.red[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_locationError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _locationError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Your location: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        '${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ...facilities.map((facility) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getTravelTime(LatLng(facility.latitude, facility.longitude)),
                      builder: (context, snapshot) {
                        final travelInfo = snapshot.data ?? {
                          'duration': 'Calculating...',
                          'distance': 'Calculating...'
                        };
                        return _buildEmergencyCard(
                          title: facility.title,
                          location: facility.location,
                          available: facility.available,
                          inUse: facility.inUse,
                          waitTime: travelInfo['duration'],
                          distance: travelInfo['distance'],
                          onCallPressed: _callEmergency,
                          onRoutePressed: () => _showRoute(facility),
                        );
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emergency Tip',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "If you're experiencing chest pain, difficulty breathing, or severe bleeding, call immediately. Don't wait!",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.red),
                              ),
                              onPressed: _callEmergency,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emergency, size: 24, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'CALL EMERGENCY (911)',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedFacilityLocation != null && _currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        height: 300,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              (_currentPosition!.latitude + _selectedFacilityLocation!.latitude) / 2,
                              (_currentPosition!.longitude + _selectedFacilityLocation!.longitude) / 2,
                            ),
                            zoom: 13,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('currentLocation'),
                              position: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              infoWindow: const InfoWindow(title: 'Your Location'),
                            ),
                            Marker(
                              markerId: MarkerId(_selectedFacilityLocation.toString()),
                              position: _selectedFacilityLocation!,
                              infoWindow: InfoWindow(
                                title: facilities.firstWhere(
                                  (f) => f.latitude == _selectedFacilityLocation!.latitude &&
                                      f.longitude == _selectedFacilityLocation!.longitude,
                                ).title,
                              ),
                            ),
                          },
                          polylines: Set<Polyline>.of(polylines.values),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String location,
    required int available,
    required int inUse,
    required String waitTime,
    required String distance,
    required VoidCallback onCallPressed,
    required VoidCallback onRoutePressed,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusIndicator('Available', available),
                const SizedBox(width: 16),
                _buildStatusIndicator('In Use', inUse),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distance:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Est. Time:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      waitTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: onCallPressed,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone),
                          SizedBox(width: 8),
                          Text('Call'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      onPressed: onRoutePressed,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions),
                          SizedBox(width: 8),
                          Text('Route'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class EmergencyFacility {
  final String id;
  final String title;
  final String location;
  final double latitude;
  final double longitude;
  final int available;
  final int inUse;

  EmergencyFacility({
    required this.id,
    required this.title,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.available,
    required this.inUse,
  });
}