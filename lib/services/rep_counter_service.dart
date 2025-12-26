import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

class RepCounterService {
  String _lastPhase = 'down';
  double _lastAngle = 0;
  
  Map<String, dynamic> processFrame(
    Pose pose,
    String exercise,
    String currentPhase,
  ) {
    double angle = _calculateKeyAngle(pose, exercise);
    
    if (angle == 0) {
      return {'repCompleted': false, 'nextPhase': currentPhase};
    }
    
    bool repCompleted = false;
    String nextPhase = currentPhase;
    
    if (exercise == 'Push-ups' || exercise == 'Bench Press') {
      if (currentPhase == 'down' && angle > 160) {
        nextPhase = 'up';
      } else if (currentPhase == 'up' && angle < 90) {
        nextPhase = 'down';
        repCompleted = true;
      }
    } else if (exercise == 'Squats') {
      if (currentPhase == 'down' && angle > 160) {
        nextPhase = 'up';
      } else if (currentPhase == 'up' && angle < 100) {
        nextPhase = 'down';
        repCompleted = true;
      }
    } else if (exercise == 'Bicep Curls') {
      if (currentPhase == 'down' && angle < 50) {
        nextPhase = 'up';
      } else if (currentPhase == 'up' && angle > 160) {
        nextPhase = 'down';
        repCompleted = true;
      }
    }
    
    _lastAngle = angle;
    _lastPhase = nextPhase;
    
    return {
      'repCompleted': repCompleted,
      'nextPhase': nextPhase,
      'angle': angle,
    };
  }
  
  double _calculateKeyAngle(Pose pose, String exercise) {
    final landmarks = pose.landmarks;
    
    if (exercise == 'Push-ups' || exercise == 'Bench Press') {
      final shoulder = landmarks[PoseLandmarkType.rightShoulder];
      final elbow = landmarks[PoseLandmarkType.rightElbow];
      final wrist = landmarks[PoseLandmarkType.rightWrist];
      
      if (shoulder == null || elbow == null || wrist == null) return 0;
      
      return _calculateAngle(shoulder, elbow, wrist);
    } else if (exercise == 'Squats') {
      final hip = landmarks[PoseLandmarkType.rightHip];
      final knee = landmarks[PoseLandmarkType.rightKnee];
      final ankle = landmarks[PoseLandmarkType.rightAnkle];
      
      if (hip == null || knee == null || ankle == null) return 0;
      
      return _calculateAngle(hip, knee, ankle);
    } else if (exercise == 'Bicep Curls') {
      final shoulder = landmarks[PoseLandmarkType.rightShoulder];
      final elbow = landmarks[PoseLandmarkType.rightElbow];
      final wrist = landmarks[PoseLandmarkType.rightWrist];
      
      if (shoulder == null || elbow == null || wrist == null) return 0;
      
      return _calculateAngle(shoulder, elbow, wrist);
    }
    
    return 0;
  }
  
  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final baX = a.x - b.x;
    final baY = a.y - b.y;
    final bcX = c.x - b.x;
    final bcY = c.y - b.y;
    
    final dot = baX * bcX + baY * bcY;
    final magBA = sqrt(baX * baX + baY * baY);
    final magBC = sqrt(bcX * bcX + bcY * bcY);
    
    final cosine = dot / (magBA * magBC + 0.000001);
    final angleRad = acos(cosine.clamp(-1.0, 1.0));
    
    return angleRad * 180 / pi;
  }
  
  void reset() {
    _lastPhase = 'down';
    _lastAngle = 0;
  }
}
