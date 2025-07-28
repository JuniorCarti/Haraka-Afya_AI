import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/widgets/app_drawer.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  String? _selectedFilter = 'All'; // Default filter value
  final List<String> _filterOptions = [
    'All',
    'Runs/Walks',
    'Screenings',
    'Workshops',
    'Fundraisers'
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFEDFCF5),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding + 16),
        child: Column(
          children: [
            // Filter dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: _selectedFilter,
                decoration: InputDecoration(
                  labelText: 'Filter by',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _filterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _buildFilteredEventCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilteredEventCards() {
    // In a real app, you would filter your actual data list here
    // For this example, we'll just return all cards and implement the filter logic
    
    // This would be your actual filtering logic:
    // final filteredEvents = allEvents.where((event) {
    //   if (_selectedFilter == 'All') return true;
    //   return event.type == _selectedFilter;
    // }).toList();
    
    // For now, we'll just return all cards
    return [
      _buildEventCard(
        title: 'Annual Cancer Awareness Run',
        date: 'October 15, 2025',
        time: '8:00 AM - 12:00 PM',
        location: 'Uhuru Park, Nairobi',
        description: 'Join our 5km/10km run to raise funds for cancer research and support patients in need. All proceeds go to cancer treatment centers.',
        color: const Color(0xFFE8F5E9),
        imageUrl: 'https://plus.unsplash.com/premium_photo-1723619058127-5f2308556d1f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTd8fGNhbmNlciUyMGF3YXJlbmVzcyUyMHJ1bnxlbnwwfHwwfHx8MA%3D%3D',
        photographer: 'John Doe',
        hasSupportButton: true,
        eventType: 'Runs/Walks',
      ),
      const SizedBox(height: 16),
      _buildEventCard(
        title: 'Free Cancer Screening Camp',
        date: 'November 3-5, 2025',
        time: '9:00 AM - 4:00 PM Daily',
        location: 'Kenyatta National Hospital',
        description: 'Free breast, cervical, and prostate cancer screenings for all attendees. Early detection saves lives!',
        color: const Color(0xFFE3F2FD),
        imageUrl: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
        photographer: 'Jane Smith',
        eventType: 'Screenings',
      ),
      const SizedBox(height: 16),
      _buildEventCard(
        title: 'Nutrition Workshop for Cancer Patients',
        date: 'November 20, 2025',
        time: '10:00 AM - 1:00 PM',
        location: 'Online (Zoom)',
        description: 'Learn about cancer-fighting foods and dietary strategies from leading nutritionists. Special focus on managing treatment side effects.',
        color: const Color(0xFFF3E5F5),
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1453&q=80',
        photographer: 'Mike Johnson',
        eventType: 'Workshops',
      ),
      const SizedBox(height: 16),
      _buildEventCard(
        title: 'Cancer Survivors Annual Gala',
        date: 'December 1, 2025',
        time: '6:00 PM - 10:00 PM',
        location: 'Safari Park Hotel',
        description: 'An evening of celebration and fundraising with inspiring stories from survivors. Black tie event with auction.',
        color: const Color(0xFFFFEBEE),
        imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
        photographer: 'Sarah Williams',
        hasSupportButton: true,
        eventType: 'Fundraisers',
      ),
    ];
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String time,
    required String location,
    required String description,
    required Color color,
    required String imageUrl,
    required String photographer,
    required String eventType,
    bool hasSupportButton = false,
  }) {
    // Skip rendering if the event doesn't match the filter
    if (_selectedFilter != 'All' && _selectedFilter != eventType) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Photo by $photographer',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          eventType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildEventDetailRow(Icons.calendar_today, date),
                  const SizedBox(height: 4),
                  _buildEventDetailRow(Icons.access_time, time),
                  const SizedBox(height: 4),
                  _buildEventDetailRow(Icons.location_on, location),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasSupportButton)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle Support action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD8FBE5),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Support',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle Register action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFECFDF5),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}