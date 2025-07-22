import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:haraka_afya_ai/models/post.dart';
import 'package:haraka_afya_ai/repositories/post_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HealthArticlesCarousel extends StatefulWidget {
  const HealthArticlesCarousel({super.key});

  @override
  State<HealthArticlesCarousel> createState() => _HealthArticlesCarouselState();
}

class _HealthArticlesCarouselState extends State<HealthArticlesCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_posts.length <= 1) return; // No need to auto-play if only one post
      
      final nextPage = _currentPage + 1;
      if (nextPage >= _posts.length) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Restart timer when user manually swipes
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    final postRepo = Provider.of<PostRepository>(context);

    return StreamBuilder<List<Post>>(
      stream: postRepo.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final newPosts = snapshot.data ?? [];
        if (newPosts.isEmpty) {
          return _buildEmptyState();
        }

        // Only update posts if they've actually changed
        if (_posts.length != newPosts.length || 
            (_posts.isNotEmpty && _posts[0].id != newPosts[0].id)) {
          _posts = newPosts;
          // Reset to first page when posts change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
          });
          _startAutoPlay();
        }

        return _buildCarousel();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 280,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(String error) {
    return SizedBox(
      height: 280,
      child: Center(child: Text('Error loading posts: $error')),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 280,
      child: Center(
        child: Text(
          'No posts available yet. Be the first to share!',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _posts.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _PostCard(post: post),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_posts.length > 1) // Only show dots if there are multiple posts
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_posts.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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

class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({required this.post});

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
          if (post.mediaUrls.isNotEmpty) _buildPostImage(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title.isNotEmpty ? post.title : 'Community Post',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(post.authorImage),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        post.authorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimestamp(post.timestamp),
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

  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: post.mediaUrls.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'Just now';
  }
}