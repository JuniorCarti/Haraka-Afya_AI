import 'dart:async';
import 'package:flutter/material.dart';

class HealthArticlesCarousel extends StatefulWidget {
  const HealthArticlesCarousel({super.key});

  @override
  State<HealthArticlesCarousel> createState() => _HealthArticlesCarouselState();
}

class _HealthArticlesCarouselState extends State<HealthArticlesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> articles = [
    {
      'imageUrl': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'title': 'Understanding Malaria',
      'description': 'Essential tips for protecting yourself and your family from malaria',
      'author': 'Dr. Sarah Wanjiku',
      'readTime': '5 min read • 2 days ago',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'title': 'Healthy Eating on a Budget',
      'description': 'How to maintain a nutritious diet without breaking the bank',
      'author': 'Nutritionist Mary Kibet',
      'readTime': '8 min read • 1 week ago',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1713947503867-3b27964f042b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzV8fHN0cmVzc3xlbnwwfHwwfHx8MA%3D%3D',
      'title': 'Managing Stress in Urban Kenya',
      'description': 'Practical strategies for mental wellness in busy city life',
      'author': 'Dr. James Mwangi',
      'readTime': '6 min read • 3 days ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_currentPage < articles.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Health Articles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: articles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final article = articles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _ArticleCard(
                  imageUrl: article['imageUrl']!,
                  title: article['title']!,
                  description: article['description']!,
                  author: article['author']!,
                  readTime: article['readTime']!,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(articles.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPage 
                    ? const Color(0xFF259450) 
                    : Colors.grey[300],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String author;
  final String readTime;

  const _ArticleCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.author,
    required this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        author,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      readTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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