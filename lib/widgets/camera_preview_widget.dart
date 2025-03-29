import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraService cameraService;
  final Function() onTakePhoto;
  final Function() onSwitchCamera;

  const CameraPreviewWidget({
    Key? key,
    required this.cameraService,
    required this.onTakePhoto,
    required this.onSwitchCamera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!cameraService.isInitialized || cameraService.controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Camera preview
        AspectRatio(
          aspectRatio: cameraService.controller!.value.aspectRatio,
          child: CameraPreview(cameraService.controller!),
        ),
        
        // Face overlay guide
        Positioned.fill(
          child: CustomPaint(
            painter: FaceOverlayPainter(),
          ),
        ),
        
        // Camera controls
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Switch camera button
              IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 36),
                onPressed: onSwitchCamera,
              ),
              
              // Take photo button
              GestureDetector(
                onTap: onTakePhoto,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              
              // Placeholder to balance the row
              const SizedBox(width: 36),
            ],
          ),
        ),
      ],
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw oval face guide
    final double ovalWidth = size.width * 0.65;
    final double ovalHeight = ovalWidth * 1.4;
    final Rect ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: ovalWidth,
      height: ovalHeight,
    );
    
    canvas.drawOval(ovalRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
