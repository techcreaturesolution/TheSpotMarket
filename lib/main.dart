import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_IN');

  // Firebase is optional: when unconfigured or on desktop the app runs in guest mode.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        child: Selector<AppState, bool>(
          selector: (_, s) => s.darkMode,
          builder: (context, isDark, _) => MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            home: const _Gate(),
          ),
        ),
      );

  static ThemeData _theme(Brightness b) {
    final isDark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: Color(0xFF10B981),
              secondary: Color(0xFF059669),
              surface: Color(0xFF111827),
              outline: Color(0xFF4B5563),
            )
          : const ColorScheme.light(
              primary: Color(0xFF0F172A),
              secondary: Color(0xFF059669),
              surface: Colors.white,
              outline: Color(0xFF94A3B8),
            ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        selectedItemColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
        unselectedItemColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF64748B),
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF475569),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white70 : const Color(0xFF475569),
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669), width: 1.5),
        ),
      ),
    );
  }
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
        onPopInvokedWithResult: (didPop, result) => setState(() => _skipped = true),
        child: const AuthScreen(),
      );
    }
    return const HomeShell();
  }
}
