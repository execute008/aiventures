import 'package:aiventures/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:aiventures/config/theme.dart';
import 'package:aiventures/features/adventure/screens/adventure_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AIVentureApp());
}

class AIVentureApp extends StatelessWidget {
  const AIVentureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIVenture',
      theme: AIVentureTheme.darkTheme,
      home: const AdventureScreen(title: 'AIVenture'),
    );
  }
}