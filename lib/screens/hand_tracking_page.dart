import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/camera_service.dart';

class HandTrackingPage extends StatefulWidget {
  const HandTrackingPage({Key? key}) : super(key: key);

  @override
  State<HandTrackingPage> createState() => _HandTrackingPageState();
}

class _HandTrackingPageState extends State<HandTrackingPage> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  // Hand tracking state
  List<Offset> _handLandmarks = [];
  bool _handDetected = false;
  
  // Finger states
  bool _thumbUp = false;
  bool _indexPointing = false;
  int _fingersExtended = 0;
  
  // For demonstration purposes, we'll simulate hand detection
  // In a real implementation, this would use MediaPipe Hand Landmarker
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    
    // For demonstration, simulate hand detection
    _startHandSimulation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
      _simulationTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
      _startHandSimulation();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      
      if (_cameraService.controller != null) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }
  
  void _startHandSimulation() {
    // This is a placeholder for actual hand tracking
    // In a real implementation, we would process camera frames to detect hands
    
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      
      setState(() {
        // Randomly decide if hand is detected
        _handDetected = Random().nextDouble() > 0.2;
        
        if (_handDetected) {
          // Generate random hand landmarks
          _handLandmarks = List.generate(21, (index) {
            return Offset(
              150 + Random().nextDouble() * 100,
              150 + Random().nextDouble() * 100,
            );
          });
          
          // Simulate finger states
          _thumbUp = Random().nextBool();
          _indexPointing = Random().nextBool();
          _fingersExtended = Random().nextInt(6);
        } else {
          _handLandmarks = [];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hand Tracking'),
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CameraPreview(_cameraService.controller!),
                              if (_handDetected) _buildHandOverlay(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Hand visualization (right side)
                      Expanded(
                        child: _buildHandVisualization(),
                      ),
                    ],
                  ),
                ),
                
                // Hand detection status
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black12,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hand Detected:'),
                          Text(
                            _handDetected ? 'Yes' : 'No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _handDetected ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Thumb Up:'),
                          Text(
                            _thumbUp ? 'Yes' : 'No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _thumbUp ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Index Pointing:'),
                          Text(
                            _indexPointing ? 'Yes' : 'No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _indexPointing ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fingers Extended:'),
                          Text(
                            '$_fingersExtended',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                          Navigator.of(context).pushNamed('/facial-tracking');
                        },
                        icon: const Icon(Icons.face),
                        label: const Text('Facial Tracking'),
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
  
  Widget _buildHandOverlay() {
    if (!_handDetected || _handLandmarks.isEmpty) return Container();
    
    return CustomPaint(
      painter: HandOverlayPainter(
        landmarks: _handLandmarks,
      ),
    );
  }
  
  Widget _buildHandVisualization() {
    // In a real implementation, this would display a 3D hand model
    // For now, we'll use a placeholder with hand gesture indicators
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pan_tool,
            size: 100,
            color: _handDetected ? Colors.deepPurple : Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Hand Gestures',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Gesture indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGestureIndicator(
                icon: Icons.thumb_up,
                active: _thumbUp,
                label: 'Thumb Up',
              ),
              const SizedBox(width: 16),
              _buildGestureIndicator(
                icon: Icons.touch_app,
                active: _indexPointing,
                label: 'Pointing',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Fingers extended indicator
          Text(
            'Fingers Extended: $_fingersExtended',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _fingersExtended / 5,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGestureIndicator({
    required IconData icon,
    required bool active,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
          color: active ? Colors.deepPurple : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.deepPurple : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class HandOverlayPainter extends CustomPainter {
  final List<Offset> landmarks;
  
  HandOverlayPainter({
    required this.landmarks,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;
    
    final Paint pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;
    
    final Paint linePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw landmarks
    for (final point in landmarks) {
      canvas.drawCircle(point, 5.0, pointPaint);
    }
    
    // Draw connections between landmarks
    // In a real implementation, we would connect specific landmarks
    // to form the hand skeleton
    if (landmarks.length > 1) {
      for (int i = 0; i < landmarks.length - 1; i++) {
        canvas.drawLine(landmarks[i], landmarks[i + 1], linePaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(HandOverlayPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
