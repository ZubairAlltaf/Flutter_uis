import 'package:flutter/material.dart';
import 'dart:math' as math;

// --- Master-Level Liquid Morph Clipper by Zubair Altaf Dev ---
// This clipper creates a complex, multi-layered wavy reveal effect.
class LiquidClipper extends CustomClipper<Path> {
  // The percentage of the screen to reveal (0.0 to 1.0).
  final double revealPercent;

  LiquidClipper({required this.revealPercent});

  @override
  Path getClip(Size size) {
    final path = Path();

    // The main vertical position of the wave.
    // We use a curve to make the animation start and end slower.
    final curve = Curves.easeInOut;
    final progress = curve.transform(revealPercent);
    final verticalPosition = size.height * (1 - progress);

    // --- The Magic of Layered Sine Waves ---
    // We will combine multiple sine waves with different properties
    // to create a more natural, less repetitive liquid edge.

    // Wave 1: A large, slow base wave.
    final wave1Amplitude = size.height * 0.04;
    final wave1Frequency = 1.5;
    final wave1Phase = progress * math.pi;

    // Wave 2: A smaller, faster wave to add detail.
    final wave2Amplitude = size.height * 0.025;
    final wave2Frequency = 3.5;
    final wave2Phase = progress * math.pi * 2;

    // Wave 3: A very subtle, high-frequency ripple for texture.
    final wave3Amplitude = size.height * 0.01;
    final wave3Frequency = 7.0;
    final wave3Phase = progress * math.pi * 1.5;

    // Start the path from the bottom-left, but off-screen to ensure no gaps.
    path.moveTo(-10, size.height);
    // Go up to the starting vertical position on the left edge.
    path.lineTo(-10, verticalPosition);

    // Generate the complex wave by adding the sine waves together.
    for (int i = 0; i <= size.width.toInt() + 10; i++) {
      final x = i.toDouble();

      // Calculate the y-offset for each wave at this x-position.
      final y1 = wave1Amplitude * math.sin((x / size.width) * 2 * math.pi * wave1Frequency + wave1Phase);
      final y2 = wave2Amplitude * math.sin((x / size.width) * 2 * math.pi * wave2Frequency + wave2Phase);
      final y3 = wave3Amplitude * math.cos((x / size.width) * 2 * math.pi * wave3Frequency + wave3Phase); // Use cosine for variation

      // The final y-position is the base position plus all the wave offsets.
      final y = verticalPosition + y1 + y2 + y3;

      path.lineTo(x, y);
    }

    // Connect the end of the wave to the bottom-right corner (off-screen).
    path.lineTo(size.width + 10, size.height);

    // Close the path to form a complete shape.
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Reclip whenever the reveal percentage changes to create the animation.
    return true;
  }
}
