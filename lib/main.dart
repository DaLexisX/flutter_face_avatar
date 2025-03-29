import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/home_page.dart';
import 'screens/photo_capture_page.dart';
import 'screens/photo_review_page.dart';
import 'screens/avatar_generation_page.dart';
import 'screens/avatar_preview_page.dart';
import 'screens/facial_tracking_page.dart';
import 'screens/hand_tracking_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Avatar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/photo-capture': (context) => const PhotoCapturePage(),
        '/photo-review': (context) => const PhotoReviewPage(),
        '/avatar-generation': (context) => const AvatarGenerationPage(),
        '/avatar-preview': (context) => const AvatarPreviewPage(),
        '/facial-tracking': (context) => const FacialTrackingPage(),
        '/hand-tracking': (context) => const HandTrackingPage(),
      },
    );
  }
}
