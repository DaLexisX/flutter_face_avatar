import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/avatar_generation_service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AvatarGenerationPage extends StatefulWidget {
  const AvatarGenerationPage({Key? key}) : super(key: key);

  @override
  State<AvatarGenerationPage> createState() => _AvatarGenerationPageState();
}

class _AvatarGenerationPageState extends State<AvatarGenerationPage> {
  final AvatarGenerationService _avatarService = AvatarGenerationService();
  bool _isGenerating = false;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _avatarService.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _avatarService.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize avatar service: $e';
      });
    }
  }

  Future<void> _generateAvatar() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final photos = appState.capturedPhotos;
    
    if (photos.isEmpty) {
      setState(() {
        _errorMessage = 'No photos available for avatar generation';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _progress = 0.0;
    });

    try {
      // Update progress for feature extraction
      setState(() {
        _progress = 0.3;
      });
      
      // Extract facial features from photos
      final facialFeatures = await _avatarService.extractFacialFeatures(photos);
      
      // Update progress for avatar generation
      setState(() {
        _progress = 0.6;
      });
      
      // Generate avatar based on extracted features
      final avatarPath = await _avatarService.generateAvatar(facialFeatures);
      
      if (avatarPath != null) {
        // Update app state with generated avatar
        appState.setGeneratedAvatar(File(avatarPath));
        
        // Update progress to complete
        setState(() {
          _progress = 1.0;
          _isGenerating = false;
        });
        
        // Navigate to avatar preview page
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/avatar-preview');
          }
        });
      } else {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Failed to generate avatar';
        });
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Error generating avatar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final photos = appState.capturedPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Avatar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Your 3D Avatar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ll analyze your photos to create a personalized 3D avatar that looks like you.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Photo preview grid
            Expanded(
              child: photos.isEmpty
                  ? const Center(
                      child: Text('No photos available. Please capture photos first.'),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            photos[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ),
            
            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Progress indicator
            if (_isGenerating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 8),
                    Text(
                      _getProgressText(_progress),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            // Generate button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _isGenerating || photos.isEmpty ? null : _generateAvatar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  _isGenerating ? 'Generating...' : 'Generate Avatar',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            
            // Back button
            TextButton(
              onPressed: _isGenerating
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Back to Photos'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getProgressText(double progress) {
    if (progress < 0.3) {
      return 'Initializing...';
    } else if (progress < 0.6) {
      return 'Analyzing facial features...';
    } else if (progress < 0.9) {
      return 'Creating your avatar...';
    } else {
      return 'Finalizing avatar...';
    }
  }
}
