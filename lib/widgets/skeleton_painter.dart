import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/app_colors.dart';

/// CustomPainter that draws a glowing cyber-themed skeleton overlay
/// Uses Electric Cyan for lines and Cyber Lime for joints
class SkeletonPainter extends CustomPainter {
  final List<PoseLandmark>? landmarks;
  final Size imageSize;
  final bool isFrontCamera;

  SkeletonPainter({
    required this.landmarks,
    required this.imageSize,
    this.isFrontCamera = true, // Default to front camera
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks == null || landmarks!.isEmpty) {
      return;
    }

    // Paint for lines (Electric Cyan with glow)
    final linePaint = Paint()
      ..color = AppColors.electricCyan
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Paint for large joints (Cyber Lime with glow) - shoulders, hips
    final largeJointPaint = Paint()
      ..color = AppColors.cyberLime
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Paint for small joints (Electric Cyan with glow)
    final smallJointPaint = Paint()
      ..color = AppColors.electricCyan
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Create a map for quick landmark lookup
    final Map<PoseLandmarkType, PoseLandmark> landmarkMap = {};
    for (final landmark in landmarks!) {
      landmarkMap[landmark.type] = landmark;
    }

    // Helper function to get position with proper scaling and mirroring
    Offset? getPosition(PoseLandmarkType type) {
      final landmark = landmarkMap[type];
      if (landmark == null) return null;

      // Scale coordinates from image space to canvas space
      double x = landmark.x * size.width / imageSize.width;
      double y = landmark.y * size.height / imageSize.height;

      // Mirror X for front camera (selfie mode)
      if (isFrontCamera) {
        x = size.width - x;
      }

      return Offset(x, y);
    }

    // Helper to draw line between two landmarks
    void drawLine(PoseLandmarkType type1, PoseLandmarkType type2) {
      final pos1 = getPosition(type1);
      final pos2 = getPosition(type2);
      if (pos1 != null && pos2 != null) {
        canvas.drawLine(pos1, pos2, linePaint);
      }
    }

    // Helper to draw joint
    void drawJoint(PoseLandmarkType type, {bool large = false}) {
      final pos = getPosition(type);
      if (pos != null) {
        final radius = large ? 12.0 : 8.0;
        final paint = large ? largeJointPaint : smallJointPaint;
        canvas.drawCircle(pos, radius, paint);
      }
    }

    // === DRAW SKELETON ===

    // Torso
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    // Left arm
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

    // Right arm
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // Left leg
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

    // Right leg
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    // === DRAW JOINTS ===

    // Large joints (Cyber Lime)
    drawJoint(PoseLandmarkType.leftShoulder, large: true);
    drawJoint(PoseLandmarkType.rightShoulder, large: true);
    drawJoint(PoseLandmarkType.leftHip, large: true);
    drawJoint(PoseLandmarkType.rightHip, large: true);

    // Small joints (Electric Cyan)
    drawJoint(PoseLandmarkType.leftElbow);
    drawJoint(PoseLandmarkType.rightElbow);
    drawJoint(PoseLandmarkType.leftWrist);
    drawJoint(PoseLandmarkType.rightWrist);
    drawJoint(PoseLandmarkType.leftKnee);
    drawJoint(PoseLandmarkType.rightKnee);
    drawJoint(PoseLandmarkType.leftAnkle);
    drawJoint(PoseLandmarkType.rightAnkle);

    // Optional: Draw nose/head indicator
    drawJoint(PoseLandmarkType.nose, large: true);
  }

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
