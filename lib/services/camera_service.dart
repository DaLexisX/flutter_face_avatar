import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  
  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  
  // Initialize camera
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException('No cameras available', 'No cameras were found on this device');
      }
      
      // Use front camera for face capture
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _controller!.initialize();
      _isInitialized = true;
    } on CameraException catch (e) {
      print('Error initializing camera: ${e.description}');
      _isInitialized = false;
      rethrow;
    }
  }
  
  // Take a photo
  Future<File?> takePhoto() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }
    
    try {
      final XFile photo = await _controller!.takePicture();
      
      // Save the image to a permanent directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${appDir.path}/Photos';
      await Directory(dirPath).create(recursive: true);
      
      final String filePath = path.join(dirPath, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(photo.path).copy(filePath);
      
      return File(filePath);
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }
  
  // Switch camera (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized || _controller == null || _cameras == null || _cameras!.length < 2) {
      return;
    }
    
    final CameraLensDirection currentDirection = _controller!.description.lensDirection;
    CameraDescription? newCamera;
    
    if (currentDirection == CameraLensDirection.front) {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    } else {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
    }
    
    if (newCamera == null) return;
    
    await _controller!.dispose();
    
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    await _controller!.initialize();
  }
  
  // Dispose camera resources
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }
}
