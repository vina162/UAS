import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/masjid_provider.dart';
import 'screens/map_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MasjidNearApp());
}

// Main app with splash screen
class MasjidNearApp extends StatelessWidget {
  const MasjidNearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid Near',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// Actual app with provider and theme
class MasjidNearMainApp extends StatelessWidget {
  const MasjidNearMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MasjidProvider(),
      child: MaterialApp(
        title: 'Masjid Near',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF059669),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            actionsIconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF059669),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const MapScreen(),
      ),
    );
  }
}