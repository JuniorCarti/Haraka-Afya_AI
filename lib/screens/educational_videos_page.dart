import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EducationalVideosPage extends StatelessWidget {
  const EducationalVideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDFCF5),
      appBar: AppBar(
        title: const Text('Educational Videos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.orange[50],
            child: Text(
              'Disclaimer: We do not own these videos. They are shared for educational purposes only.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_education')
                  .doc('videos')
                  .collection('list')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No videos available'));
                }

                final videos = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
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
    // Load like/dislike counts
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

    // Load user's reaction if logged in
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
        const SnackBar(content: Text('Please sign in to react to videos')),
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

    // Determine the current and new states
    final bool? currentStatus = _userLikeStatus;
    final bool isSameReaction = currentStatus == newLikeStatus;
    final bool isRemovingReaction = isSameReaction;
    final bool isSwitchingReaction = currentStatus != null && !isSameReaction;

    // Update local state immediately for responsiveness
    setState(() {
      if (isRemovingReaction) {
        // Removing reaction
        _userLikeStatus = null;
        if (newLikeStatus) {
          _likeCount--;
        } else {
          _dislikeCount--;
        }
      } else if (isSwitchingReaction) {
        // Switching between like and dislike
        _userLikeStatus = newLikeStatus;
        if (newLikeStatus) {
          _likeCount++;
          _dislikeCount--;
        } else {
          _likeCount--;
          _dislikeCount++;
        }
      } else {
        // Adding new reaction
        _userLikeStatus = newLikeStatus;
        if (newLikeStatus) {
          _likeCount++;
        } else {
          _dislikeCount++;
        }
      }
    });

    try {
      // Update Firestore
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
          // Switching reaction - decrement old and increment new
          batch.update(videoRef, {
            newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(1),
            !newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(-1),
          });
        } else {
          // New reaction - just increment
          batch.update(videoRef, {
            newLikeStatus ? 'likes' : 'dislikes': FieldValue.increment(1),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      // Revert local state if Firestore update fails
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
        const SnackBar(content: Text('Failed to update reaction. Please try again.')),
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
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Column(
            children: [
              // Disclaimer in player view
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange[50],
                child: Text(
                  'Disclaimer: This video is embedded from YouTube for educational purposes. We do not own this content.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Center(
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
                    progressIndicatorColor: Colors.blueAccent,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.blue,
                      handleColor: Colors.blueAccent,
                    ),
                  ),
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
      'Check out this health education video: ${widget.title}\n$videoUrl\n\nNote: This video is shared for educational purposes. We do not own this content.',
      subject: 'Health Education Video',
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = 'https://img.youtube.com/vi/${widget.youtubeId}/mqdefault.jpg';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _playYoutubeVideo,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    thumbnailUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.videocam_off, size: 50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Uploaded: ${widget.uploadDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _shareVideo,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: _userLikeStatus == true ? Colors.blue : null,
                      ),
                      onPressed: _isUpdating ? null : () => _updateReaction(true),
                    ),
                    Text(_likeCount.toString()),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        color: _userLikeStatus == false ? Colors.red : null,
                      ),
                      onPressed: _isUpdating ? null : () => _updateReaction(false),
                    ),
                    Text(_dislikeCount.toString()),
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