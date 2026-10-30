import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.initial,
    this.size = 40,
    this.colors = const [Color(0xFF8E9BE8), Color(0xFF4A63C4)],
  });

  final String initial;
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
