import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class AvatarPreviewPage extends StatelessWidget {
  const AvatarPreviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final avatar = appState.generatedAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Avatar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.of(context).pushNamed('/facial-tracking');
            },
            tooltip: 'Start Facial Tracking',
          ),
        ],
      ),
      body: avatar == null
          ? const Center(
              child: Text('No avatar available. Please generate an avatar first.'),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAvatarPreview(avatar),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/facial-tracking');
                        },
                        icon: const Icon(Icons.face),
                        label: const Text('Start Facial Tracking'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/photo-capture');
                        },
                        child: const Text('Take New Photos'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatarPreview(File avatar) {
    // In a real implementation, this would display a 3D model
    // For now, we'll use a placeholder or a simple ModelViewer if the file is a valid 3D model
    
    // Check if the file is a valid 3D model (glb, gltf)
    final extension = avatar.path.split('.').last.toLowerCase();
    if (extension == 'glb' || extension == 'gltf') {
      return ModelViewer(
        src: avatar.path,
        alt: 'Your 3D Avatar',
        autoRotate: true,
        cameraControls: true,
      );
    } else {
      // Placeholder for non-3D model files
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.face,
              size: 120,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Avatar is Ready!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Avatar saved at: ${avatar.path}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }
  }
}
