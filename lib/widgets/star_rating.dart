import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating; // Ví dụ: 4.5
  final double size;
  final Color color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14,
    this.color = AppColors.amber,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      IconData icon;
      Color iconColor = color;

      if (i < fullStars) {
        icon = Icons.star;
      } else if (i == fullStars && halfStar) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
        iconColor = AppColors.textGrey.withOpacity(0.5);
      }
      stars.add(Icon(icon, color: iconColor, size: size));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}