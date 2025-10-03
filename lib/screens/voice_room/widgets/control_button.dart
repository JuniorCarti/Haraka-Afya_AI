import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDanger;
  final bool isActive;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDanger = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon only - no background container
            Icon(
              icon,
              color: isDanger 
                  ? Colors.red 
                  : isActive 
                    ? Colors.blue 
                    : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDanger 
                    ? Colors.red 
                    : isActive 
                      ? Colors.blue 
                      : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}