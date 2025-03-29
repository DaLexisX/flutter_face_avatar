import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/camera_service.dart';

class FacialTrackingPage extends StatefulWidget {
  const FacialTrackingPage({Key? key}) : super(key: key);

  @override
  State<FacialTrackingPage> createState() => _FacialTrackingPageState();
}

class _FacialTrackingPageState extends State<FacialTrackingPage> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  
  bool _isInitialized = false;
  bool _isProcessing = false;
  Face? _detectedFace;
  Size? _imageSize;
  
  // Animation control values
  double _smileAmount = 0.0;
  double _eyeLeftOpenAmount = 1.0;
  double _eyeRightOpenAmount = 1.0;
  double _headRotationX = 0.0;
  double _headRotationY = 0.0;
  double _headRotationZ = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      
      if (_cameraService.controller != null) {
        _cameraService.controller!.startImageStream(_processCameraImage);
        
        setState(() {
          _isInitialized = true;
          _imageSize = Size(
            _cameraService.controller!.value.previewSize!.height,
            _cameraService.controller!.value.previewSize!.width,
          );
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    
    _isProcessing = true;
    
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
      
      final InputImageRotation imageRotation = InputImageRotation.rotation90deg;
      
      final InputImageFormat inputImageFormat = InputImageFormat.nv21;
      
      final planeData = image.planes.map((Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      }).toList();
      
      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );
      
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: inputImageData,
      );
      
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isNotEmpty) {
        setState(() {
          _detectedFace = faces.first;
          _updateFacialExpressionValues(_detectedFace!);
        });
      } else {
        setState(() {
          _detectedFace = null;
        });
      }
    } catch (e) {
      print('Error processing camera image: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  void _updateFacialExpressionValues(Face face) {
    // Update smile amount (0.0 to 1.0)
    _smileAmount = face.smilingProbability ?? 0.0;
    
    // Update eye open amounts (0.0 to 1.0)
    _eyeLeftOpenAmount = face.leftEyeOpenProbability ?? 1.0;
    _eyeRightOpenAmount = face.rightEyeOpenProbability ?? 1.0;
    
    // Update head rotation values (in degrees)
    _headRotationX = face.headEulerAngleX ?? 0.0; // Pitch
    _headRotationY = face.headEulerAngleY ?? 0.0; // Yaw
    _headRotationZ = face.headEulerAngleZ ?? 0.0; // Roll
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facial Expression Tracking'),
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      // Camera preview (left side)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: _cameraService.controller!.value.aspectRatio,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_cameraService.controller!),
                                if (_detectedFace != null) _buildFaceOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Avatar preview (right side)
                      Expanded(
                        child: _buildAvatarPreview(appState),
                      ),
                    ],
                  ),
                ),
                
                // Facial expression values display
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black12,
                  child: Column(
                    children: [
                      _buildExpressionValueRow('Smile', _smileAmount),
                      _buildExpressionValueRow('Left Eye', _eyeLeftOpenAmount),
                      _buildExpressionValueRow('Right Eye', _eyeRightOpenAmount),
                      _buildExpressionValueRow('Head X', _headRotationX / 45),
                      _buildExpressionValueRow('Head Y', _headRotationY / 45),
                      _buildExpressionValueRow('Head Z', _headRotationZ / 45),
                    ],
                  ),
                ),
                
                // Controls
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/hand-tracking');
                        },
                        icon: const Icon(Icons.pan_tool),
                        label: const Text('Hand Tracking'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _cameraService.switchCamera();
                        },
                        icon: const Icon(Icons.flip_camera_ios),
                        label: const Text('Switch Camera'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildFaceOverlay() {
    if (_detectedFace == null || _imageSize == null) return Container();
    
    return CustomPaint(
      painter: FaceOverlayPainter(
        face: _detectedFace!,
        imageSize: _imageSize!,
        rotation: InputImageRotation.rotation90deg,
      ),
    );
  }
  
  Widget _buildAvatarPreview(AppState appState) {
    final avatar = appState.generatedAvatar;
    
    // In a real implementation, this would display a 3D model that mimics facial expressions
    // For now, we'll use a placeholder with expression indicators
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.face,
            size: 100,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          const Text(
            'Avatar Expression',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Smile indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😐'),
              Expanded(
                child: Slider(
                  value: _smileAmount,
                  onChanged: null,
                  activeColor: Colors.deepPurple,
                ),
              ),
              const Text('😁'),
            ],
          ),
          
          // Eye openness indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👁️'),
              Expanded(
                child: Slider(
                  value: (_eyeLeftOpenAmount + _eyeRightOpenAmount) / 2,
                  onChanged: null,
                  activeColor: Colors.deepPurple,
                ),
              ),
              const Text('😌'),
            ],
          ),
          
          // Head rotation indicator
          Text(
            'Head Rotation: ${_headRotationY.toStringAsFixed(1)}°',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpressionValueRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value.abs().clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                value >= 0 ? Colors.deepPurple : Colors.red,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final Face face;
  final Size imageSize;
  final InputImageRotation rotation;
  
  FaceOverlayPainter({
    required this.face,
    required this.imageSize,
    required this.rotation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw face bounding box
    final Rect faceRect = face.boundingBox;
    final Rect scaledRect = _scaleRect(
      rect: faceRect,
      imageSize: imageSize,
      widgetSize: size,
      rotation: rotation,
    );
    canvas.drawRect(scaledRect, paint);
    
    // Draw facial landmarks
    final Paint landmarkPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;
    
    face.landmarks.forEach((type, point) {
      final Offset scaledPoint = _scalePoint(
        point: point,
        imageSize: imageSize,
        widgetSize: size,
        rotation: rotation,
      );
      canvas.drawCircle(scaledPoint, 3.0, landmarkPaint);
    });
  }
  
  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size widgetSize,
    required InputImageRotation rotation,
  }) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;
    
    if (rotation == InputImageRotation.rotation90deg || 
        rotation == InputImageRotation.rotation270deg) {
      return Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );
    } else {
      return Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );
    }
  }
  
  Offset _scalePoint({
    required Point point,
    required Size imageSize,
    required Size widgetSize,
    required InputImageRotation rotation,
  }) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;
    
    if (rotation == InputImageRotation.rotation90deg || 
        rotation == InputImageRotation.rotation270deg) {
      return Offset(
        point.x.toDouble() * scaleX,
        point.y.toDouble() * scaleY,
      );
    } else {
      return Offset(
        point.x.toDouble() * scaleX,
        point.y.toDouble() * scaleY,
      );
    }
  }
  
  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.face != face;
  }
}
