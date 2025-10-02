import 'package:flutter/material.dart';

class EmptySeat extends StatelessWidget {
  final int seatNumber;
  final VoidCallback onTap;

  const EmptySeat({super.key, required this.seatNumber, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Seat #$seatNumber',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
          Text(
            'Join',
            style: TextStyle(
              color: Colors.green.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}