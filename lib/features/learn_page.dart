import 'package:flutter/material.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        title: const Text('Health Education'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Health Tips Section
            const Text(
              "Today's Health Tips",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHealthTipItem('1. Drink at least 8 glasses of water daily'),
            _buildHealthTipItem('2. Take a 10-minute walk after meals'),
            _buildHealthTipItem('3. Practice deep breathing for stress relief'),
            _buildHealthTipItem('4. Wash hands frequently to prevent infections'),
            const Divider(height: 40, thickness: 1),

            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHorizontalCategories(),
            const Divider(height: 40, thickness: 1),

            // Health Articles Section
            const Text(
              'Health Articles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildArticleCard(
              title: 'Understanding Malaria',
              subtitle: 'Essential tips for protecting yourself and your family from malaria',
              author: 'Dr. Sarah Wanjiku',
              readTime: '5 min read',
              date: '2 days ago',
              isTrending: true,
            ),
            const SizedBox(height: 16),
            _buildArticleCard(
              title: 'Healthy Eating on a Budget',
              subtitle: 'How to maintain a nutritious diet without breaking the bank',
              author: 'Nutritionist Mary Kibet',
              readTime: '8 min read',
              date: '1 week ago',
            ),
            const SizedBox(height: 16),
            _buildArticleCard(
              title: 'Managing Stress in Urban Kenya',
              subtitle: 'Practical strategies for mental wellness in busy city life',
              author: 'Dr. James Mwanqi',
              readTime: '6 min read',
              date: '3 days ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategories() {
    final categories = [
      'All Topics',
      'Prevention',
      'Nutrition',
      'Cancer',
      'Breast Cancer',
      'Cervical Cancer',
      'Prostate Cancer',
      'Esophageal Cancer',
      'Colorectal Cancer',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Text(
              categories[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String subtitle,
    required String author,
    required String readTime,
    required String date,
    bool isTrending = false,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isTrending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Trending',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$readTime • $date',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
