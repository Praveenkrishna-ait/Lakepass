import 'dart:ui';
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // Stunning Sea Background Image
        Image.network(
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=2070&auto=format&fit=crop',
          fit: BoxFit.cover,
        ),
        // Dark Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withOpacity(0.8),
                AppColors.background.withOpacity(0.3),
                AppColors.background.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Main Content
        SafeArea(
          child: useGlassmorphism
              ? Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(glassPadding),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: glassMaxWidth),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : child,
        ),
      ],
    );
  }
}
