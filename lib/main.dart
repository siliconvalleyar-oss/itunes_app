import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/audio_service.dart';
import 'services/library_service.dart';
import 'services/playlist_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/player_screen.dart';
import 'components/neu_bottom_nav.dart';
import 'components/mini_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MusicStudioApp());
}

class MusicStudioApp extends StatelessWidget {
  const MusicStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: () => setState(() => _showSplash = false));
    }
    return const AppShell();
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final AudioService _audioService;
  late final LibraryService _libraryService;
  late final PlaylistService _playlistService;
  final _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _libraryService = LibraryService();
    _playlistService = PlaylistService();
    _libraryService.loadSavedData();
    _playlistService.loadPlaylists();
    _themeProvider.addListener(_onThemeChange);
  }

  void _onThemeChange() {
    AppColors.applyTheme(_themeProvider.isDark);
    Neumorphic.applyTheme(_themeProvider.isDark);
    setState(() {});
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChange);
    _audioService.dispose();
    _libraryService.dispose();
    _playlistService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(audioService: _audioService, libraryService: _libraryService, playlistService: _playlistService),
                LibraryScreen(audioService: _audioService, libraryService: _libraryService, playlistService: _playlistService),
                PlaylistsScreen(playlistService: _playlistService, audioService: _audioService),
                EditorScreen(audioService: _audioService),
                SettingsScreen(themeProvider: _themeProvider),
              ],
            ),
          ),
          MiniPlayer(
            audioService: _audioService,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerScreen(audioService: _audioService, playlistService: _playlistService),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: NeuBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}
