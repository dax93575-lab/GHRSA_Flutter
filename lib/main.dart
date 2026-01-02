import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Consider showing a UI error if needed, but for now log it.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider()
            ..loadUserData()
            ..fetchPlants(),
        ),
      ],
      child: MaterialApp(
        title: 'Gharsa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Natural Green Aesthetic
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Light background
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,

          // Arabic Font (Cairo)
          textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green[800],
            centerTitle: true,
            titleTextStyle: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // RTL Support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'AE'), // Arabic
        ],
        locale: const Locale('ar', 'AE'), // Force Arabic

        home: const SplashScreen(),
      ),
    );
  }
}
