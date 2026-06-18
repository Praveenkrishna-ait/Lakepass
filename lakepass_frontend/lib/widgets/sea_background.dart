import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SeaBackground extends StatelessWidget {
  final Widget child;
  final bool useGlassmorphism;
  final double glassPadding;
  final double glassMaxWidth;

  const SeaBackground({
    super.key,
    required this.child,
    this.useGlassmorphism = false,
    this.glassPadding = 32.0,
    this.glassMaxWidth = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.backgroundAlt, AppColors.background],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
