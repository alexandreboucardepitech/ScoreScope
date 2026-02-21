import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/theme_options.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/services/web/auth_service.dart';
import 'package:scorescope/utils/ui/app_theme.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/amis/fil_actu_amis.dart';
import 'package:scorescope/views/login/login.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:scorescope/views/statistiques/stats_view.dart';
import 'firebase_options.dart';
import 'views/all_matches/all_matches.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser AuthService (et GoogleSignIn) avant runApp
  final authService = AuthService();
  await authService.initialize();

  // Déconnexion automatique au début pour test :
  // await GoogleSignIn.instance.disconnect();
  // await FirebaseAuth.instance.signOut();

  await initializeDateFormatting('fr_FR', null);

  runApp(const RootApp());
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => RootAppState();
}

class RootAppState extends State<RootApp> {
  // Key unique pour forcer rebuild complet
  Key _appKey = UniqueKey();

  void restartApp() {
    setState(() {
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InitialApp(
      key: _appKey,
      authService: AuthService(),
    );
  }
}

enum AppState { loading, unauthenticated, authenticated }

class InitialApp extends StatefulWidget {
  final AuthService authService;

  const InitialApp({super.key, required this.authService});

  static _InitialAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_InitialAppState>();

  @override
  State<InitialApp> createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  final ThemeController _themeController = ThemeController();
  AppState _appState = AppState.loading;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> restartApp() async {
    setState(() {
      _appState = AppState.loading;
      _currentUser = null;
    });
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      _themeController.initialize(ThemeOptions.system);
      setState(() => _appState = AppState.unauthenticated);
    } else {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      _currentUser = user;
      _themeController.initialize(user?.options.theme ?? ThemeOptions.system);
      setState(() => _appState = AppState.authenticated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _themeController,
      child: MyApp(
        authService: widget.authService,
        appState: _appState,
        currentUser: _currentUser,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final AppState appState;
  final AppUser? currentUser;

  const MyApp({
    super.key,
    required this.authService,
    required this.appState,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'ScoreScope',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    switch (appState) {
      case AppState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case AppState.unauthenticated:
        return const LoginView();

      case AppState.authenticated:
        return HomePage(user: currentUser!);
    }
  }
}

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AllMatchesView(),
      FilActuAmisView(
        onBackPressed: () => setState(() => _currentIndex = 0),
      ),
      StatsView(user: widget.user),
      ProfileView(
        user: widget.user,
        onBackPressed: () => setState(() => _currentIndex = 0),
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ColorPalette.background(context),
        selectedItemColor: ColorPalette.accent(context),
        unselectedItemColor: ColorPalette.textPrimary(context),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Matchs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Amis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
