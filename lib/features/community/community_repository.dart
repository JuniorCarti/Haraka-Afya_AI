import 'package:haraka_afya_ai/features/community/community_post.dart';

class CommunityRepository {
  final List<CommunityPost> _posts = [
    CommunityPost(
      id: '1',
      authorName: 'Sarah M.',
      authorTitle: 'Cancer Survivor',
      title: 'My Journey with Breast Cancer - 5 Years Strong',
      content: 'Today marks 5 years since my diagnosis...',
      category: 'Cancer Survivor',
      postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 45,
      comments: 12,
    ),
    CommunityPost(
      id: '2',
      authorName: 'Dr. James K.',
      authorTitle: 'Diabetes Specialist',
      title: 'Managing Diabetes: Tips from a Specialist',
      content: 'As an endocrinologist, I want to share...',
      category: 'Diabetes',
      postedAt: DateTime.now().subtract(const Duration(hours: 4)),
      likes: 32,
      comments: 8,
    ),
  ];

  List<CommunityPost> getPosts() => _posts;
  List<CommunityPost> getEvents() => _posts.where((post) => post.isEvent).toList();
  
  Future<void> addPost(CommunityPost post) async {
    _posts.insert(0, post);
  }
}