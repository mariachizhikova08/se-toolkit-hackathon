import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/constants.dart';
import 'services/cart_service.dart';
import 'services/chat_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DessertApp());
}

class DessertApp extends StatelessWidget {
  const DessertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: MaterialApp(
        title: 'Katrin\'s Cakes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFF5F5),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFB6C1),
            primary: const Color(0xFFFFB6C1),
            secondary: const Color(0xFF8B4513),
          ),
          // Typography
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            displayLarge: GoogleFonts.playfairDisplay(fontSize: 48, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
            displayMedium: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
            displaySmall: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
            headlineMedium: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A)),
            titleLarge: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A)),
            titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF4A4A4A)),
            bodyLarge: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF4A4A4A)),
            bodyMedium: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4A4A4A)),
            labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          // AppBar
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4A4A4A),
            elevation: 0,
            scrolledUnderElevation: 1,
            centerTitle: true,
            titleTextStyle: GoogleFonts.greatVibes(fontSize: 28, color: const Color(0xFFFF69B4)),
          ),
          // Buttons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB6C1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              elevation: 2,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF69B4),
            ),
          ),
          // Cards
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          // Input decoration
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF69B4), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          // FAB
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFFFFB6C1),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          // Snackbar
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF8B4513),
          ),
          // Chip
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
