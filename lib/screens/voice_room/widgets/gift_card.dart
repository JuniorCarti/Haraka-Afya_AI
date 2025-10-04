import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftCard extends StatelessWidget {
  final Gift gift;
  final VoidCallback onTap;
  final bool isCompact;

  const GiftCard({
    super.key, 
    required this.gift, 
    required this.onTap,
    this.isCompact = true, // New parameter for compact mode
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2), // Reduced margin
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: isCompact ? 70 : 80, // Fixed width for grid alignment
            height: isCompact ? 90 : 100, // Fixed height for consistency
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gift.color.withOpacity(0.2),
                  gift.color.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: gift.color.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gift.color.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: RadialGradient(
                        colors: [
                          gift.color.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        radius: 0.6,
                        center: Alignment.center,
                      ),
                    ),
                  ),
                ),
                
                // Main content - Optimized for compact view
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji - Smaller container
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: gift.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gift.color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            gift.emoji,
                            style: const TextStyle(fontSize: 16), // Smaller emoji
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Gift name - Single line
                      Text(
                        gift.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Cost badge - Compact version
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, 
                          vertical: 2
                        ),
                        decoration: BoxDecoration(
                          color: gift.color.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: gift.color.withOpacity(0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: gift.color,
                              size: 8, // Smaller icon
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${gift.cost}',
                              style: TextStyle(
                                color: gift.color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Hover overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Premium indicator - Tiny dot instead of crown
                if (gift.cost >= 300)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Cost tier indicator - Top left color dot
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getTierColor(gift.cost),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTierColor(int cost) {
    if (cost >= 500) return const Color(0xFFFFD700); // Gold
    if (cost >= 300) return const Color(0xFFC0C0C0); // Silver
    if (cost >= 200) return const Color(0xFFCD7F32); // Bronze
    if (cost >= 100) return Colors.purple;
    return Colors.blue;
  }

  String _getValueTier(int cost) {
    if (cost >= 500) return 'PREMIUM';
    if (cost >= 300) return 'ELITE';
    if (cost >= 200) return 'RARE';
    if (cost >= 100) return 'SPECIAL';
    return 'STANDARD';
  }
}