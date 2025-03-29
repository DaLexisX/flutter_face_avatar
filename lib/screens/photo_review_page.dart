import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class PhotoReviewPage extends StatelessWidget {
  const PhotoReviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final photos = appState.capturedPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Photos'),
        actions: [
          TextButton(
            onPressed: photos.length >= 1 
                ? () => Navigator.of(context).pushNamed('/avatar-generation')
                : null,
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: photos.isEmpty
          ? const Center(
              child: Text(
                'No photos captured yet.\nGo back and take some photos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Review your ${photos.length} photo${photos.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return PhotoTile(
                        photo: photos[index],
                        isSelected: index == appState.currentPhotoIndex,
                        onTap: () {
                          appState.setCurrentPhotoIndex(index);
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, index);
                        },
                      );
                    },
                  ),
                ),
                if (photos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Take More Photos'),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.capturedPhotos.removeAt(index);
              if (appState.currentPhotoIndex >= appState.capturedPhotos.length) {
                appState.setCurrentPhotoIndex(
                  appState.capturedPhotos.isEmpty ? 0 : appState.capturedPhotos.length - 1,
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PhotoTile extends StatelessWidget {
  final File photo;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PhotoTile({
    Key? key,
    required this.photo,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                width: isSelected ? 3.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Image.file(
                photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Delete button
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          
          // Selected indicator
          if (isSelected)
            Positioned(
              bottom: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
