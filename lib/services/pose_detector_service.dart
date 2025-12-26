import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';

class PoseDetectorService {
  late PoseDetector _poseDetector;
  
  PoseDetectorService() {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseModel.accurate,
    );
    _poseDetector = PoseDetector(options: options);
  }
  
  Future<List<Pose>> detectPoses(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    
    if (inputImage == null) {
      return [];
    }
    
    final poses = await _poseDetector.processImage(inputImage);
    return poses;
  }
  
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      
      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      
      const InputImageRotation rotation = InputImageRotation.rotation0deg;
      const InputImageFormat format = InputImageFormat.nv21;
      
      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }
  
  void dispose() {
    _poseDetector.close();
  }
}
