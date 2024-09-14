import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final Color color;
  final ImageProvider<Object> widget;

  const Avatar({super.key, required this.radius, required this.widget, required this.color});

  const Avatar.small({super.key, required this.widget, required this.color}) : radius = 16;

  const Avatar.medium({
    super.key,
    required this.widget,
    required this.color,
  }) : radius = 28;

  const Avatar.large({super.key, required this.widget, required this.color}) : radius = 42;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: ClipOval(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: widget,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
