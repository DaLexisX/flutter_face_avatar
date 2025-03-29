import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../widgets/camera_preview_widget.dart';

class PhotoCapturePage extends StatefulWidget {
  const PhotoCapturePage({Key? key}) : super(key: key);

  @override
  State<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _permissionsGranted = false;
  bool _isLoading = true;

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_permissionsGranted) {
        _cameraService.initialize();
      }
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
    });

    // Request permissions
    final hasPermissions = await PermissionService.hasAllPermissions();
    if (!hasPermissions) {
      final permissions = await PermissionService.requestAllPermissions();
      _permissionsGranted = permissions.values.every((status) => status.isGranted);
    } else {
      _permissionsGranted = true;
    }

    if (_permissionsGranted) {
      try {
        await _cameraService.initialize();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _takePhoto() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    try {
      final photo = await _cameraService.takePhoto();
      if (photo != null) {
        appState.addCapturedPhoto(photo);
        
        // If we have enough photos, navigate to review screen
        if (appState.capturedPhotos.length >= 3) {
          Navigator.of(context).pushNamed('/photo-review');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Your Face'),
        actions: [
          if (appState.capturedPhotos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.of(context).pushNamed('/photo-review'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_permissionsGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Camera and storage permissions are required',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Grant Permissions'),
            ),
          ],
        ),
      );
    }

    if (!_cameraService.isInitialized) {
      return const Center(
        child: Text('Failed to initialize camera. Please restart the app.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: CameraPreviewWidget(
            cameraService: _cameraService,
            onTakePhoto: _takePhoto,
            onSwitchCamera: () async {
              await _cameraService.switchCamera();
              setState(() {});
            },
          ),
        ),
        _buildPhotoCounter(),
      ],
    );
  }

  Widget _buildPhotoCounter() {
    final appState = Provider.of<AppState>(context);
    final photoCount = appState.capturedPhotos.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Photos: $photoCount/3',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          if (photoCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Reset', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Provider.of<AppState>(context, listen: false).clearCapturedPhotos();
              },
            ),
        ],
      ),
    );
  }
}
