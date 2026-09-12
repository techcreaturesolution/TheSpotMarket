import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_IN');

  // Firebase is optional: without google-services.json the app runs as guest.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase not configured: $e');
  }

  final storage = await StorageService.create();
  AdService.instance.init();

  runApp(TheSpotMarketApp(storage: storage, firebaseReady: firebaseReady));
}

class TheSpotMarketApp extends StatelessWidget {
  const TheSpotMarketApp({super.key, required this.storage, required this.firebaseReady});
  final StorageService storage;
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState(storage: storage)),
          ChangeNotifierProvider(create: (_) => AuthService(isAvailable: firebaseReady)),
        ],
        child: Consumer<AppState>(
          builder: (context, s, _) => MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            home: const _Gate(),
          ),
        ),
      );

  static ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        brightness: b,
        colorSchemeSeed: const Color(0xFF0F4C81),
        cardTheme: const CardThemeData(elevation: 0.5, margin: EdgeInsets.zero),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      );
}

/// Shows the login screen once (skippable) when Firebase is configured and
/// the user is not signed in; otherwise goes straight to the app.
class _Gate extends StatefulWidget {
  const _Gate();

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool _skipped = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (auth.isAvailable && !auth.isSignedIn && !_skipped) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, _) => setState(() => _skipped = true),
        child: const AuthScreen(),
      );
    }
    return const HomeShell();
  }
}
