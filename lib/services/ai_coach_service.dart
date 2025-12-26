import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

class AICoachService {
  int _frameCount = 0;
  String _lastCue = '';
  
  Future<Map<String, dynamic>> analyzeForm(
    Pose pose,
    String exercise,
    int currentReps,
    String phase,
  ) async {
    _frameCount++;
    
    if (_frameCount % 30 != 0) {
      return {
        'cue': _lastCue,
        'score': _calculateFormScore(pose, exercise),
        'speak': false,
      };
    }
    
    final analysis = _analyzeExerciseForm(pose, exercise, phase);
    _lastCue = analysis['cue'] ?? '';
    
    return {
      'cue': analysis['cue'],
      'score': analysis['score'],
      'speak': analysis['speak'],
    };
  }
  
  Map<String, dynamic> _analyzeExerciseForm(
    Pose pose,
    String exercise,
    String phase,
  ) {
    final landmarks = pose.landmarks;
    
    if (exercise == 'Push-ups') {
      final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
      final leftHip = landmarks[PoseLandmarkType.leftHip];
      final leftKnee = landmarks[PoseLandmarkType.leftKnee];
      
      if (leftShoulder == null || leftHip == null || leftKnee == null) {
        return {'cue': 'Get in frame', 'score': 0.0, 'speak': false};
      }
      
      final shoulderHipDist = (leftShoulder.y - leftHip.y).abs();
      final hipKneeDist = (leftHip.y - leftKnee.y).abs();
      final ratio = shoulderHipDist / (hipKneeDist + 0.001);
      
      if (ratio < 0.6) {
        return {
          'cue': 'Keep your core tight',
          'score': 65.0,
          'speak': true,
        };
      }
      
      final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = landmarks[PoseLandmarkType.rightElbow];
      
      if (rightShoulder != null && rightElbow != null) {
        final elbowFlare = (rightElbow.x - rightShoulder.x).abs();
        
        if (elbowFlare > 0.15) {
          return {
            'cue': 'Elbows closer to body',
            'score': 70.0,
            'speak': true,
          };
        }
      }
      
      return {
        'cue': 'Good form',
        'score': 90.0,
        'speak': false,
      };
    } else if (exercise == 'Squats') {
      final leftHip = landmarks[PoseLandmarkType.leftHip];
      final leftKnee = landmarks[PoseLandmarkType.leftKnee];
      final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
      
      if (leftHip == null || leftKnee == null || leftAnkle == null) {
        return {'cue': 'Get in frame', 'score': 0.0, 'speak': false};
      }
      
      if (leftKnee.x > leftAnkle.x + 0.05) {
        return {
          'cue': 'Knees behind toes',
          'score': 65.0,
          'speak': true,
        };
      }
      
      final kneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);
      
      if (phase == 'down' && kneeAngle > 120) {
        return {
          'cue': 'Go deeper',
          'score': 70.0,
          'speak': false,
        };
      }
      
      return {
        'cue': 'Strong squat',
        'score': 88.0,
        'speak': false,
      };
    }
    
    return {
      'cue': 'Keep going',
      'score': 75.0,
      'speak': false,
    };
  }
  
  double _calculateFormScore(Pose pose, String exercise) {
    final analysis = _analyzeExerciseForm(pose, exercise, 'up');
    return analysis['score'] ?? 75.0;
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
}
