import 'package:flutter/material.dart';
import '../models/room_game.dart';

class GameCard extends StatelessWidget {
  final RoomGame game;
  final VoidCallback onTap;

  const GameCard({
    super.key, 
    required this.game, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  game.color.withOpacity(0.25),
                  game.color.withOpacity(0.15),
                  game.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: game.color.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: game.color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: RadialGradient(
                        colors: [
                          game.color.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        radius: 1.0,
                        center: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: game.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: game.color.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: game.color.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          game.icon,
                          color: game.color,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Game Name
                      Text(
                        game.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Game Type Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, 
                          vertical: 3
                        ),
                        decoration: BoxDecoration(
                          color: game.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: game.color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getGameType(game.name),
                          style: TextStyle(
                            color: game.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Hover Overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Top Right Corner Accent
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: game.color,
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

  String _getGameType(String gameName) {
    switch (gameName.toLowerCase()) {
      case 'pool':
      case 'chess':
      case 'dice':
        return 'STRATEGY';
      case 'sudoku':
      case 'words':
        return 'PUZZLE';
      case 'cards':
        return 'CARD GAME';
      default:
        return 'GAME';
    }
  }
}