import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support Loved Ones',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // This keeps the back button black
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Haraka Afya Loved Ones Appeal',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF259450),
              ),
            ),
            const SizedBox(height: 16),
            
            // Image slider
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage('https://plus.unsplash.com/premium_photo-1722945689852-0bcf3669b894?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mzd8fGNhbmNlciUyMGRvbmF0ZXxlbnwwfHwwfHx8MA%3D%3D'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
                controller: PageController(viewportFraction: 0.9),
                onPageChanged: (index) {},
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'After a cancer diagnosis, loved ones are left with a million questions. '
              'We\'re here to help them too.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Haraka-Afya can help to answer and support through services like our support lines and online community.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Donate today to make sure we can continue to support people living with cancer and their loved ones.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'How do you want to donate?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF259450),
              ),
            ),
            const SizedBox(height: 16),
            _buildDonationOption(
              title: 'Make a single donation',
              description: 'You can make a one-off donation today, as an individual or on behalf of an organisation.',
              onTap: () => _launchDonationUrl('https://donate.example.com/single'),
            ),
            const SizedBox(height: 12),
            _buildDonationOption(
              title: 'Make a monthly donation',
              description: 'You can make a regular donation either monthly or annually by setting up a Direct Debit.',
              onTap: () => _launchDonationUrl('https://donate.example.com/monthly'),
            ),
            const SizedBox(height: 12),
            _buildDonationOption(
              title: 'Pay in money from your collection',
              description: 'You can pay in the money you have collected or fundraised as a group.',
              onTap: () => _launchDonationUrl('https://donate.example.com/collection'),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16, // Add extra space for navigation bar
              ),
              child: _buildDonateButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationOption({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF259450), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.radio_button_unchecked, color: Color(0xFF259450)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF259450)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF259450),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Handle donation button press
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to donation page...')),
          );
          _launchDonationUrl('https://donate.example.com');
        },
        child: const Text(
          'DONATE NOW',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _launchDonationUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}