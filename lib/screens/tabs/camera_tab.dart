import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import '../../services/pose_detector_service.dart';
import '../../services/rep_counter_service.dart';
import '../../services/ai_coach_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/pose_painter.dart';

class CameraTab extends ConsumerStatefulWidget {
  const CameraTab({super.key});

  @override
  ConsumerState<CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends ConsumerState<CameraTab> {
  CameraController? _controller;
  PoseDetectorService? _poseDetector;
  RepCounterService? _repCounter;
  AICoachService? _aiCoach;
  FlutterTts? _tts;
  
  bool _isInitialized = false;
  bool _isDetecting = false;
  bool _isAIActive = true; // AI coaching ON by default
  
  List<Pose> _poses = [];
  int _currentReps = 0;
  String _currentExercise = 'Push-ups'; // Default, let user change
  String _coachingCue = '';
  double _formScore = 0.0;
  
  // Rest timer
  bool _isResting = false;
  int _restTimeRemaining = 0;
  Timer? _restTimer;
  
  // Exercise state
  String _exercisePhase = 'down'; // 'up' or 'down'
  
  @override
  void initState() {
    super.initState();
    _initCamera();
    _initServices();
  }
  
  Future<void> _initServices() async {
    _poseDetector = PoseDetectorService();
    _repCounter = RepCounterService();
    _aiCoach = AICoachService();
    _tts = FlutterTts();
    
    await _tts!.setLanguage('en-US');
    await _tts!.setSpeechRate(0.5);
    await _tts!.setVolume(1.0);
    await _tts!.setPitch(1.0);
  }
  
  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) return;
    
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    
    try {
      await _controller!.initialize();
      
      await _controller!.startImageStream((CameraImage image) {
        if (!_isDetecting && !_isResting) {
          _isDetecting = true;
          _processFrame(image);
        }
      });
      
      setState(() => _isInitialized = true);
      
      // Welcome message
      _speak('AI trainer active. Start your workout.');
      
    } catch (e) {
      print('Camera error: $e');
    }
  }
  
  Future<void> _processFrame(CameraImage image) async {
    try {
      // 1. Detect pose
      final poses = await _poseDetector!.detectPoses(image);
      
      if (poses.isEmpty) {
        setState(() {
          _poses = [];
          _coachingCue = 'Step into frame';
        });
        _isDetecting = false;
        return;
      }
      
      final pose = poses.first;
      
      // 2. Count reps
      final repResult = _repCounter!.processFrame(
        pose,
        _currentExercise,
        _exercisePhase,
      );
      
      if (repResult['repCompleted'] == true) {
        setState(() {
          _currentReps++;
          _exercisePhase = repResult['nextPhase'];
        });
        
        // Voice confirmation
        _speak('$_currentReps');
      } else {
        setState(() {
          _exercisePhase = repResult['nextPhase'] ?? _exercisePhase;
        });
      }
      
      // 3. Get AI coaching (every 30 frames to save API calls)
      if (_isAIActive && _currentReps % 2 == 0) {
        final coaching = await _aiCoach!.analyzeForm(
          pose,
          _currentExercise,
          _currentReps,
          _exercisePhase,
        );
        
        if (coaching['cue'] != null && coaching['cue'] != _coachingCue) {
          setState(() {
            _coachingCue = coaching['cue'];
            _formScore = coaching['score'] ?? 0.0;
          });
          
          // Speak important cues
          if (coaching['speak'] == true) {
            _speak(coaching['cue']);
          }
        }
      }
      
      setState(() {
        _poses = poses;
      });
      
    } catch (e) {
      print('Processing error: $e');
    } finally {
      _isDetecting = false;
    }
  }
  
  Future<void> _speak(String text) async {
    try {
      await _tts?.speak(text);
    } catch (e) {
      print('TTS error: $e');
    }
  }
  
  void _finishSet() {
    setState(() {
      _isResting = true;
      _restTimeRemaining = 90; // 90 second rest
    });
    
    _speak('Set complete. Rest for 90 seconds.');
    
    // Start countdown
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restTimeRemaining--;
      });
      
      // Voice cues at specific times
      if (_restTimeRemaining == 30) {
        _speak('30 seconds remaining');
      } else if (_restTimeRemaining == 10) {
        _speak('10 seconds');
      } else if (_restTimeRemaining == 0) {
        _speak('Time to go. Next set.');
        _isResting = false;
        timer.cancel();
      }
    });
  }
  
  void _resetSet() {
    setState(() {
      _currentReps = 0;
      _coachingCue = '';
      _formScore = 0.0;
      _exercisePhase = 'down';
    });
    _repCounter?.reset();
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    _poseDetector?.dispose();
    _tts?.stop();
    _restTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.amber400),
              SizedBox(height: 20),
              Text(
                'Initializing AI trainer...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview (full screen)
          SizedBox(
            width: size.width,
            height: size.height,
            child: CameraPreview(_controller!),
          ),
          
          // Pose overlay
          if (_poses.isNotEmpty)
            CustomPaint(
              painter: PosePainter(
                poses: _poses,
                imageSize: Size(
                  _controller!.value.previewSize!.height,
                  _controller!.value.previewSize!.width,
                ),
                screenSize: size,
                score: _formScore,
              ),
              child: Container(),
            ),
          
          // Rest timer overlay
          if (_isResting)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'REST',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amber400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$_restTimeRemaining',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'seconds',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        _restTimer?.cancel();
                        setState(() {
                          _isResting = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white20,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('SKIP REST'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Top bar - Exercise selector
          if (!_isResting)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.amber400.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentExercise,
                            style: AppTextStyles.h3.copyWith(fontSize: 20),
                          ),
                          Text(
                            _isAIActive ? '🤖 AI Coach Active' : '👁️ Tracking Only',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _isAIActive ? AppColors.emerald400 : AppColors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showExerciseSelector();
                      },
                      icon: const Icon(Icons.edit, color: AppColors.amber400),
                    ),
                  ],
                ),
              ),
            ),
          
          // Rep counter (big and bold)
          if (!_isResting)
            Positioned(
              top: size.height * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber400.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber400.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    '$_currentReps',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          
          // Coaching cue
          if (!_isResting && _coachingCue.isNotEmpty)
            Positioned(
              bottom: 250,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(_formScore).withOpacity(0.9),
                      _getScoreColor(_formScore).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreColor(_formScore).withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _coachingCue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Control buttons
          if (!_isResting)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // AI Toggle
                  _buildControlButton(
                    icon: _isAIActive ? Icons.psychology : Icons.psychology_outlined,
                    label: 'AI',
                    color: _isAIActive ? AppColors.emerald400 : AppColors.white40,
                    onTap: () {
                      setState(() {
                        _isAIActive = !_isAIActive;
                      });
                      _speak(_isAIActive ? 'AI coach activated' : 'AI coach paused');
                    },
                  ),
                  
                  // Finish Set
                  _buildControlButton(
                    icon: Icons.check_circle,
                    label: 'Finish Set',
                    color: AppColors.amber400,
                    onTap: _finishSet,
                    isPrimary: true,
                  ),
                  
                  // Reset
                  _buildControlButton(
                    icon: Icons.restart_alt,
                    label: 'Reset',
                    color: AppColors.rose400,
                    onTap: _resetSet,
                  ),
                ],
              ),
            ),
          
          // Form score indicator
          if (!_isResting && _formScore > 0)
            Positioned(
              top: 140,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(_formScore).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_formScore.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'FORM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 24 : 16,
          vertical: isPrimary ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(isPrimary ? 20 : 16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.black : color,
              size: isPrimary ? 32 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isPrimary ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.black : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 85) return AppColors.emerald400;
    if (score >= 70) return AppColors.amber400;
    return AppColors.rose400;
  }
  
  void _showExerciseSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate900,
      builder: (context) {
        final exercises = [
          'Push-ups',
          'Squats',
          'Pull-ups',
          'Bench Press',
          'Deadlift',
          'Shoulder Press',
          'Bicep Curls',
          'Tricep Dips',
        ];
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Exercise',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 20),
              ...exercises.map((exercise) {
                return ListTile(
                  title: Text(
                    exercise,
                    style: AppTextStyles.bodyLarge,
                  ),
                  trailing: _currentExercise == exercise
                      ? const Icon(Icons.check, color: AppColors.amber400)
                      : null,
                  onTap: () {
                    setState(() {
                      _currentExercise = exercise;
                    });
                    _resetSet();
                    Navigator.pop(context);
                    _speak('Switched to $exercise');
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
