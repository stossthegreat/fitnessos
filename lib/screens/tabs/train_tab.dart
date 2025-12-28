import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../utils/app_colors.dart';
import '../../services/pose_detector_service.dart';
import '../../widgets/skeleton_painter.dart';

class TrainTab extends StatefulWidget {
  const TrainTab({super.key});

  @override
  State<TrainTab> createState() => _TrainTabState();
}

class _TrainTabState extends State<TrainTab> with TickerProviderStateMixin {
  // Workout state
  bool _isWorkoutActive = false;
  bool _isRecording = false;
  bool _isResting = false;
  int _repCount = 0;
  int _currentSet = 1;
  int _restTime = 0;
  String? _formFeedback;
  bool _showRepFlash = false;
  bool _screenFlash = false;

  // Camera & AI state
  CameraController? _cameraController;
  List<PoseLandmark>? _landmarks;
  PoseDetectorService? _poseDetectorService;
  bool _isCameraInitialized = false;
  String? _cameraError;

  Timer? _repTimer;
  Timer? _restTimer;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _currentWorkout = [
    {'name': 'Bench Press', 'sets': 3, 'reps': 10, 'rest': 90},
    {'name': 'Incline Press', 'sets': 3, 'reps': 10, 'rest': 90},
    {'name': 'Chest Flys', 'sets': 3, 'reps': 12, 'rest': 60},
    {'name': 'Push-ups', 'sets': 3, 'reps': 15, 'rest': 60},
  ];
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _repTimer?.cancel();
    _restTimer?.cancel();
    _pulseController.dispose();
    _cameraController?.dispose();
    _poseDetectorService?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _cameraError = 'Camera permission denied. Please enable it in settings.';
        });
        return;
      }

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'No cameras available';
        });
        return;
      }

      // Use FRONT camera for selfie view
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback to first camera
      );

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      // Initialize pose detector
      _poseDetectorService = PoseDetectorService();

      // Start image stream for pose detection
      _cameraController!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _cameraError = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_poseDetectorService == null) return;

    final landmarks = await _poseDetectorService!.detectPose(image);
    
    if (landmarks != null && mounted) {
      // Debug: Print landmark count to verify detection
      debugPrint('✅ POSE DETECTED: ${landmarks.length} landmarks');
      setState(() {
        _landmarks = landmarks;
      });
    } else if (mounted) {
      // Debug: No pose detected
      debugPrint('❌ NO POSE DETECTED');
    }
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _currentExerciseIndex = 0;
      _repCount = 0;
      _currentSet = 1;
      _isResting = false;
    });
    
    // Initialize camera when workout starts
    _initializeCamera();
    // NO MORE SIMULATION - real rep counting will happen via pose detection in Phase 2
  }

  void _finishSet() {
    final exercise = _currentWorkout[_currentExerciseIndex];
    _repTimer?.cancel();
    
    setState(() {
      _isResting = true;
      _restTime = exercise['rest'] as int;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTime > 0) {
        setState(() => _restTime--);
      } else {
        timer.cancel();
        setState(() {
          _isResting = false;
          _repCount = 0;
          if (_currentSet < exercise['sets']) {
            _currentSet++;
          } else if (_currentExerciseIndex < _currentWorkout.length - 1) {
            _currentExerciseIndex++;
            _currentSet = 1;
          }
        });
        // NO MORE SIMULATION - Phase 2 will add real rep counting
      }
    });
  }

  void _endWorkout() {
    _repTimer?.cancel();
    _restTimer?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _poseDetectorService?.dispose();
    _poseDetectorService = null;
    
    setState(() {
      _isWorkoutActive = false;
      _isResting = false;
      _repCount = 0;
      _currentSet = 1;
      _currentExerciseIndex = 0;
      _isCameraInitialized = false;
      _landmarks = null;
      _cameraError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWorkoutActive) {
      return _buildStartScreen();
    }

    if (_isResting) {
      return _buildRestScreen();
    }

    return _buildTrainingScreen();
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 80,
            color: AppColors.cyberLime,
          ),
          const SizedBox(height: 24),
          const Text(
            'READY TO TRAIN?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _startWorkout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.cyberLime,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyberLime.withOpacity(0.6),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Text(
                'START WORKOUT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingScreen() {
    final exercise = _currentWorkout[_currentExerciseIndex];
    final size = MediaQuery.of(context).size;

    // Show error if camera failed
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.neonCrimson),
              const SizedBox(height: 24),
              Text(
                _cameraError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                },
                child: const Text('OPEN SETTINGS'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _endWorkout,
                child: const Text('END WORKOUT'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading while camera initializes
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.cyberLime),
            SizedBox(height: 24),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // 1. CAMERA PREVIEW (Full screen)
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // 2. VIGNETTE OVERLAY (Subtle dark edges - lighter than before)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3), // Lighter vignette (was 0.4)
                  ],
                ),
              ),
            ),
          ),
        ),

        // 3. SKELETON OVERLAY (GLOWING CYBER SKELETON!)
        if (_landmarks != null)
          Positioned.fill(
            child: CustomPaint(
              painter: SkeletonPainter(
                landmarks: _landmarks,
                imageSize: Size(
                  _cameraController!.value.previewSize!.height,
                  _cameraController!.value.previewSize!.width,
                ),
              ),
            ),
          ),

        // DEBUG: Show landmark count indicator
        Positioned(
          top: 200,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _landmarks != null ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _landmarks != null ? '✅ TRACKING: ${_landmarks!.length} points' : '❌ NO POSE DETECTED',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // Screen flash effect
        if (_screenFlash)
          AnimatedOpacity(
            opacity: _screenFlash ? 0.15 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(color: AppColors.cyberLime),
          ),

        // 4. EXISTING UI ELEMENTS

        // Compact Exercise Info - Top Left
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white20,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white50,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SET $_currentSet / ${exercise['sets']}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white40,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Close Button - Top Center
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _endWorkout,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white20,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Recording Indicator - Top Right
        if (_isRecording)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonCrimson.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.neonCrimson,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'REC',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Form Feedback - Top Right Corner
        if (_formFeedback != null)
          Positioned(
            top: 120,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _formFeedback == 'PERFECT FORM'
                      ? AppColors.cyberLime
                      : AppColors.neonCrimson,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_formFeedback == 'PERFECT FORM'
                            ? AppColors.cyberLime
                            : AppColors.neonCrimson)
                        .withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                _formFeedback!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _formFeedback == 'PERFECT FORM'
                      ? AppColors.cyberLime
                      : AppColors.neonCrimson,
                ),
              ),
            ),
          ),

        // Next Exercises Dots - Top Center
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _currentWorkout.length,
              (index) => Container(
                width: index == _currentExerciseIndex ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == _currentExerciseIndex
                      ? AppColors.cyberLime
                      : AppColors.white20,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: index == _currentExerciseIndex
                      ? [
                          BoxShadow(
                            color: AppColors.cyberLime.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),

        // Compact Rep Counter - Bottom Left
        Positioned(
          bottom: 100,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cyberLime.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyberLime.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.3);
                    return Transform.scale(
                      scale: scale,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$_repCount',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cyberLime,
                          shadows: [
                            Shadow(
                              color: AppColors.cyberLime
                                  .withOpacity(_pulseController.value),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'TARGET: ${exercise['reps']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.white40,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rep Flash
        if (_showRepFlash)
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.2),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: 1 - ((value - 0.5) / 0.7),
                    child: Text(
                      '+1',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cyberLime,
                        shadows: [
                          Shadow(
                            color: AppColors.cyberLime,
                            blurRadius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Bottom Buttons
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Record Button
              GestureDetector(
                onTap: () => setState(() => _isRecording = !_isRecording),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isRecording
                          ? AppColors.neonCrimson
                          : AppColors.white30,
                      width: 4,
                    ),
                    boxShadow: _isRecording
                        ? [
                            BoxShadow(
                              color: AppColors.neonCrimson.withOpacity(0.5),
                              blurRadius: 30,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Container(
                      width: _isRecording ? 20 : 50,
                      height: _isRecording ? 20 : 50,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppColors.neonCrimson
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(_isRecording ? 4 : 25),
                        border: _isRecording
                            ? null
                            : Border.all(
                                color: Colors.red,
                                width: 4,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Finish Set Button
              GestureDetector(
                onTap: _finishSet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyberLime,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyberLime.withOpacity(0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Text(
                    'FINISH SET',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestScreen() {
    final exercise = _currentWorkout[_currentExerciseIndex];
    
    return Container(
      color: Colors.black.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'REST',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.white40,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 48),
            TweenAnimationBuilder<double>(
              key: ValueKey(_restTime),
              tween: Tween(begin: 1.0, end: 1.1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    '$_restTime',
                    style: TextStyle(
                      fontSize: 160,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cyberLime,
                      shadows: [
                        Shadow(
                          color: AppColors.cyberLime,
                          blurRadius: 50,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            if (_currentSet < exercise['sets'])
              Text(
                'NEXT: SET ${_currentSet + 1}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white80,
                ),
              )
            else if (_currentExerciseIndex < _currentWorkout.length - 1)
              Text(
                'NEXT: ${_currentWorkout[_currentExerciseIndex + 1]['name']}'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white80,
                ),
              )
            else
              const Text(
                'FINAL SET!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white80,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Last set: $_repCount reps',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.white50,
              ),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _restTimer?.cancel();
                    setState(() {
                      _isResting = false;
                      _repCount = 0;
                    });
                    // NO MORE SIMULATION
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white5,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.white20,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'SKIP REST',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _endWorkout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.white10,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'END WORKOUT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
