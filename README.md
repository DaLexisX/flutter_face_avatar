# Flutter Face Avatar

A Flutter application that allows users to create photo-realistic avatars from facial photos and animate them with real-time facial expression tracking and hand gesture recognition.

## Features

- **Photo Capture**: Take multiple photos of your face from different angles
- **Avatar Generation**: Create a photo-realistic 3D avatar based on your facial features
- **Real-time Facial Tracking**: Animate your avatar with real-time facial expression tracking
- **Hand Tracking**: Control your avatar with hand gestures and finger movements

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Camera Plugin**: For accessing device cameras
- **MediaPipe Face Detection**: For facial feature extraction and tracking
- **Google ML Kit Face Detection**: For facial landmark detection and expression analysis
- **Model Viewer Plus**: For displaying 3D avatar models

## Getting Started

### Prerequisites

- Flutter SDK (version 3.19.0 or higher)
- Android Studio or Xcode for mobile deployment
- A physical device with a front-facing camera (emulators may not work properly with camera features)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/DaLexisX/flutter_face_avatar.git
```

2. Navigate to the project directory:
```bash
cd flutter_face_avatar
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

## Usage

1. **Capture Photos**: Take multiple photos of your face from different angles for best results
2. **Review Photos**: Select the best photos for avatar generation
3. **Generate Avatar**: Create your personalized 3D avatar
4. **Facial Tracking**: Use your device camera to animate your avatar with your facial expressions
5. **Hand Tracking**: Control your avatar with hand gestures

## Project Structure

- `lib/models/`: Data models and state management
- `lib/screens/`: UI screens for different features
- `lib/services/`: Business logic and service classes
- `lib/widgets/`: Reusable UI components

## Implementation Details

### Photo Capture

The application uses the device's front-facing camera to capture multiple photos of the user's face. These photos are used to extract facial features for avatar generation.

### Avatar Generation

Facial features are extracted from the captured photos using MediaPipe Face Detection and Google ML Kit. These features are then used to generate a photo-realistic 3D avatar.

### Real-time Facial Tracking

The application uses the device's camera and ML Kit Face Detection to track facial expressions in real-time. The detected expressions are mapped to the avatar to animate it.

### Hand Tracking

Hand gestures and finger movements are detected and tracked to provide additional control over the avatar.

## License

This project is licensed under the BSD-3-Clause License - see the LICENSE file for details.

## Acknowledgements

- [MediaPipe](https://mediapipe.dev/) for facial detection and tracking
- [Google ML Kit](https://developers.google.com/ml-kit) for facial landmark detection
- [Flutter](https://flutter.dev/) for the cross-platform framework
