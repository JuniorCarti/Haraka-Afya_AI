import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';

class EducationalVideosPage extends StatelessWidget {
  const EducationalVideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Health Education Videos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal_1),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF259450),
                  Color(0xFF1976D2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF259450).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.video_play,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Learn Through Videos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expert-led health education and cancer awareness',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEEBA)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Educational content from trusted sources. We do not own these videos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Categories Filter (Optional - you can add this later)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryChip('All Topics', true),
                const SizedBox(width: 8),
                _buildCategoryChip('Cancer Prevention', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Treatment Options', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Nutrition', false),
                const SizedBox(width: 8),
                _buildCategoryChip('Mental Health', false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Videos List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_education')
                  .doc('videos')
                  .collection('list')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.video_remove,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Videos Available',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new content',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final videos = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return VideoCard(
                      videoId: video.id,
                      title: video['title'],
                      description: video['description'],
                      duration: video['duration'],
                      youtubeId: video['youtubeId'],
                      uploadDate: video['uploadDate'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color(0xFF259450),
                  Color(0xFF27AE60),
                ],
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFE9ECEF),
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF259450).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF666666),
        ),
      ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final String videoId;
  final String title;
  final String description;
  final String duration;
  final String youtubeId;
  final String uploadDate;

  const VideoCard({
    super.key,
    required this.videoId,
    required this.title,
    required this.description,
    required this.duration,
    required this.youtubeId,
    required this.uploadDate,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool? _userLikeStatus;
  int _likeCount = 0;
  int _dislikeCount = 0;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadReactionData();
  }

  Future<void> _loadReactionData() async {
    final doc = await _firestore
        .collection('health_education')
        .doc('videos')
        .collection('list')
        .doc(widget.videoId)
        .get();

    setState(() {
      _likeCount = doc.data()?['likes'] ?? 0;
      _dislikeCount = doc.data()?['dislikes'] ?? 0;
    });

    final user = _auth.currentUser;
    if (user != null) {
      final reactionDoc = await _firestore
          .collection('video_reactions')
          .doc('${widget.videoId}_${user.uid}')
          .get();

      if (reactionDoc.exists) {
        setState(() {
          _userLikeStatus = reactionDoc.data()?['liked'];
        });
      }
    }
  }

  Future<void> _updateReaction(bool newLikeStatus) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to react to videos'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      _isUpdating = false;
      return;
    }

    final videoRef = _firestore
        .collection('health_education')
        .doc('videos')
        .collection('list')
        .doc(widget.videoId);

    final reactionRef = _firestore
        .collection('video_reactions')
        .doc('${widget.videoId}_${user.uid}');

    final batch = _firestore.batch();

    final bool? currentStatus = _userLikeStatus;
    final bool isSameReaction = currentStatus == newLikeStatus;
    final bool isRemovingReaction = isSameReaction;
    final bool isSwitchingReaction = currentStatus != null && !isSameReaction;

    setState(() {
      if (isRemovingReaction) {
        _userLikeStatus = null;
        if (newLikeStatus) {
          _likeCount--;
        } else {
          _dislikeCount--;
        }
      } else if (isSwitchingReaction) {
        _userLikeStatus = newLikeStatus;
        if (newLikeStatus) {
          _likeCount++;
          _dislikeCount--;
        } else {
          _likeCount--;
          _dislikeCount++;
        }
      } else {
        _userLikeStatus = newLikeStatus;
        if (newLikeStatus) {
          _likeCount++;
        } else {
          _dislikeCount++;
        }
      }
    });

    try {
      if (isRemovingReaction) {
        batch.delete(reactionRef);
        batch.update(videoRef, {
          newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(-1),
        });
      } else {
        batch.set(reactionRef, {
          'liked': newLikeStatus,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (isSwitchingReaction) {
          batch.update(videoRef, {
            newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(1),
            !newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(-1),
          });
        } else {
          batch.update(videoRef, {
            newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(1),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      setState(() {
        if (isRemovingReaction) {
          _userLikeStatus = currentStatus;
          if (newLikeStatus) {
            _likeCount++;
          } else {
            _dislikeCount++;
          }
        } else if (isSwitchingReaction) {
          _userLikeStatus = !newLikeStatus;
          if (newLikeStatus) {
            _likeCount--;
            _dislikeCount++;
          } else {
            _likeCount++;
            _dislikeCount--;
          }
        } else {
          _userLikeStatus = null;
          if (newLikeStatus) {
            _likeCount--;
          } else {
            _dislikeCount--;
          }
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update reaction'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _isUpdating = false;
    }
  }

  void _playYoutubeVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Column(
            children: [
              // Disclaimer in player view
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade900,
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade100, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Educational content from YouTube. We do not own this video.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: widget.youtubeId,
                    flags: const YoutubePlayerFlags(
                      autoPlay: true,
                      mute: false,
                      disableDragSeek: false,
                      loop: false,
                      isLive: false,
                      forceHD: true,
                      enableCaption: true,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                  onReady: () {
                    // Player is ready
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareVideo() {
    final videoUrl = 'https://youtu.be/${widget.youtubeId}';
    Share.share(
      'Check out this health education video: ${widget.title}\n$videoUrl\n\nShared from Haraka Afya - Empowering Cancer Care',
      subject: 'Health Education Video - Haraka Afya',
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = 'https://img.youtube.com/vi/${widget.youtubeId}/maxresdefault.jpg';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with play button
          GestureDetector(
            onTap: _playYoutubeVideo,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.video_slash, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Video unavailable',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.play_circle,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Video Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Metadata and Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.uploadDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF259450),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Iconsax.share, size: 18),
                        onPressed: _shareVideo,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reactions
                Row(
                  children: [
                    _buildReactionButton(
                      icon: Iconsax.like_1,
                      count: _likeCount,
                      isActive: _userLikeStatus == true,
                      onTap: () => _updateReaction(true),
                    ),
                    const SizedBox(width: 16),
                    _buildReactionButton(
                      icon: Iconsax.dislike,
                      count: _dislikeCount,
                      isActive: _userLikeStatus == false,
                      onTap: () => _updateReaction(false),
                    ),
                    const Spacer(),
                    Text(
                      'Tap to watch',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
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

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isUpdating ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF269A51).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF269A51) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? const Color(0xFF269A51) : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF269A51) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}