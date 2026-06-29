import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_service.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/trimmer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ITunesApp());
}

class ITunesApp extends StatefulWidget {
  const ITunesApp({super.key});

  @override
  State<ITunesApp> createState() => _ITunesAppState();
}

class _ITunesAppState extends State<ITunesApp> {
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iTunes Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: HomeScreen(audioService: _audioService),
      routes: {
        '/home': (context) => HomeScreen(audioService: _audioService),
        '/player': (context) => PlayerScreen(audioService: _audioService),
        '/editor': (context) => EditorScreen(audioService: _audioService),
        '/trimmer': (context) => TrimmerScreen(audioService: _audioService),
      },
    );
  }
}
