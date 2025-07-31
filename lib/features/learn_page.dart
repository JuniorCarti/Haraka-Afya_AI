import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/article_detail_page.dart';
import '../screens/medical_dictionary_page.dart';
import '../screens/educational_videos_page.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  String selectedCategory = 'All Topics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        title: const Text(
          'Health Education',
          style: TextStyle(
            fontSize: 18, // Matches HomeScreen app bar
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cancer Medical Dictionary Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MedicalDictionaryPage(),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                color: const Color(0xFFFFF0F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book, size: 30, color: Color(0xFFE75480)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Cancer Medical Dictionary',
                              style: TextStyle(
                                fontSize: 18, // Matches HomeScreen greeting
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '500+ cancer medical terms explained',
                              style: TextStyle(
                                fontSize: 14, // Secondary text
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Educational Videos Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EducationalVideosPage(),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_fill, size: 28, color: Color(0xFF4285F4)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Educational Video Library',
                              style: TextStyle(
                                fontSize: 18, // Consistent card title
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Watch and learn from expert discussions',
                              style: TextStyle(
                                fontSize: 14, // Secondary text
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16, // Section headers at 16sp
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_education')
                  .doc('categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories =
                    List<String>.from(snapshot.data!.get('categories'));
                return _buildHorizontalCategories(categories);
              },
            ),
            
            const Divider(height: 40, thickness: 1),
            
            // Articles Section
            const Text(
              'Health Articles',
              style: TextStyle(
                fontSize: 16, // Section headers at 16sp
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_education')
                  .doc('articles')
                  .collection('list')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final articles = snapshot.data!.docs.where((doc) {
                  if (selectedCategory == 'All Topics') return true;
                  return doc['category'] == selectedCategory;
                }).toList();

                if (articles.isEmpty) {
                  return Center(
                    child: Text(
                      'No articles found',
                      style: TextStyle(
                        fontSize: 14, // Consistent empty state
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return Column(
                  children: articles.map((doc) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticleDetailPage(
                              title: doc['title'],
                              subtitle: doc['subtitle'],
                              author: doc['author'],
                              readTime: doc['readTime'],
                              date: doc['date'],
                              imageUrl: doc['imageUrl'] ?? '',
                              content: doc['content'] ?? 'No content available.',
                            ),
                          ),
                        );
                      },
                      child: _buildArticleCard(
                        title: doc['title'],
                        subtitle: doc['subtitle'],
                        author: doc['author'],
                        readTime: doc['readTime'],
                        date: doc['date'],
                        isTrending: doc['isTrending'] ?? false,
                        imageUrl: doc['imageUrl'] ?? '',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCategories(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[100] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.green.shade300,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 14, // Consistent with HomeScreen filter chips
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.green[800] : Colors.black,
                ),
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
    required String imageUrl,
    bool isTrending = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                          fontSize: 18, // Article title matches card titles
                          fontWeight: FontWeight.bold,
                        ),
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
                            fontSize: 12, // Smaller for tags
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14, // Secondary text
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
                        fontSize: 12, // Metadata smaller
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$readTime • $date',
                      style: const TextStyle(
                        fontSize: 12, // Metadata smaller
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}