class CommunityPost {
  final String id;
  final String authorName;
  final String authorTitle;
  final String title;
  final String content;
  final String category;
  final DateTime postedAt;
  final int likes;
  final int comments;
  final bool isEvent;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorTitle,
    required this.title,
    required this.content,
    required this.category,
    required this.postedAt,
    this.likes = 0,
    this.comments = 0,
    this.isEvent = false,
  });
}