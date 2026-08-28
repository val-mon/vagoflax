import 'package:flutter/material.dart';

class UserRatingBadge extends StatelessWidget {
  final double rating;
  final int count;

  const UserRatingBadge({super.key, required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: 18,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            'No reviews yet',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 20, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
