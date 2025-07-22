import 'package:flutter/material.dart';
import 'package:haraka_afya_ai/features/community/post_details_screen.dart';
import 'package:haraka_afya_ai/features/community/create_post_screen.dart';
import 'package:haraka_afya_ai/features/community/community_post.dart';
import 'package:haraka_afya_ai/features/community/community_repository.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityRepository _repository = CommunityRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text('Health Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Community Posts'),
            Tab(text: 'Upcoming Events'),
          ],
          labelColor: const Color(0xFF16A249),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF16A249),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsList(_repository.getPosts()),
          _buildPostsList(_repository.getEvents()),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<CommunityPost> posts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          color: const Color(0xFFFCFFFF),
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailsScreen(post: post),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4C9E6A),
                        child: Text(
                          post.authorName[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            post.authorTitle,
                            style: TextStyle(
                              color: const Color(0xFF4C9E6A),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${post.postedAt.difference(DateTime.now()).inHours.abs()} hours ago',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content.length > 100 
                        ? '${post.content.substring(0, 100)}...' 
                        : post.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      Text(post.likes.toString()),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {},
                      ),
                      Text(post.comments.toString()),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _showShareDialog(context, post),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showShareDialog(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Post'),
          content: const Text('Select platform to share this post'),
          actions: [
            TextButton(
              onPressed: () => _shareToPlatform(context, 'WhatsApp', post),
              child: const Text('WhatsApp'),
            ),
            TextButton(
              onPressed: () => _shareToPlatform(context, 'Facebook', post),
              child: const Text('Facebook'),
            ),
            TextButton(
              onPressed: () => _shareToPlatform(context, 'Twitter', post),
              child: const Text('Twitter'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _shareToPlatform(BuildContext context, String platform, CommunityPost post) {
    // Implement actual sharing functionality
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shared to $platform')),
    );
  }
}