import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: const NgopiKuyApp(),
    ),
  );
}

class NgopiKuyApp extends StatelessWidget {
  const NgopiKuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YPLAB-NgopiKuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5A2B), // Soft Coffee Brown
          primary: const Color(0xFF6F4E37),
          secondary: const Color(0xFFD2B48C), // Tan
          surface: const Color(0xFFFDFBF7), // Off-white/Cream background
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF3E2723)),
          titleTextStyle: TextStyle(
            color: Color(0xFF3E2723),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(height: 16),
            Text(
              'NgopiKuy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modern Coffee Experience',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
