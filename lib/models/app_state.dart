import 'dart:io';
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  // Photo capture state
  List<File> _capturedPhotos = [];
  bool _isCapturing = false;
  int _currentPhotoIndex = 0;
  
  // Avatar state
  File? _generatedAvatar;
  bool _isGeneratingAvatar = false;
  
  // Tracking state
  bool _isFacialTrackingEnabled = false;
  bool _isHandTrackingEnabled = false;
  
  // Getters
  List<File> get capturedPhotos => _capturedPhotos;
  bool get isCapturing => _isCapturing;
  int get currentPhotoIndex => _currentPhotoIndex;
  File? get generatedAvatar => _generatedAvatar;
  bool get isGeneratingAvatar => _isGeneratingAvatar;
  bool get isFacialTrackingEnabled => _isFacialTrackingEnabled;
  bool get isHandTrackingEnabled => _isHandTrackingEnabled;
  
  // Methods for photo capture
  void startCapturing() {
    _isCapturing = true;
    notifyListeners();
  }
  
  void stopCapturing() {
    _isCapturing = false;
    notifyListeners();
  }
  
  void addCapturedPhoto(File photo) {
    _capturedPhotos.add(photo);
    _currentPhotoIndex = _capturedPhotos.length - 1;
    notifyListeners();
  }
  
  void clearCapturedPhotos() {
    _capturedPhotos.clear();
    _currentPhotoIndex = 0;
    notifyListeners();
  }
  
  void setCurrentPhotoIndex(int index) {
    if (index >= 0 && index < _capturedPhotos.length) {
      _currentPhotoIndex = index;
      notifyListeners();
    }
  }
  
  // Methods for avatar generation
  void setGeneratingAvatar(bool isGenerating) {
    _isGeneratingAvatar = isGenerating;
    notifyListeners();
  }
  
  void setGeneratedAvatar(File avatar) {
    _generatedAvatar = avatar;
    notifyListeners();
  }
  
  // Methods for tracking
  void toggleFacialTracking() {
    _isFacialTrackingEnabled = !_isFacialTrackingEnabled;
    notifyListeners();
  }
  
  void toggleHandTracking() {
    _isHandTrackingEnabled = !_isHandTrackingEnabled;
    notifyListeners();
  }
}
