import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback? onBrowseTap;

  const HeroBanner({super.key, this.onBrowseTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = width > 900 ? 420.0 : (width > 600 ? 320.0 : 260.0);
    final subtitleSize = width > 900 ? 20.0 : (width > 600 ? 17.0 : 14.0);

    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB6C1), Color(0xFFFFE4E8), Color(0xFFFFF5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Katrin\'s Cakes',
                style: GoogleFonts.greatVibes(
                  fontSize: width > 900 ? 80.0 : (width > 600 ? 60.0 : 46.0),
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF8B4513).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 12),
              Text(
                'Ручная работа · Натуральные ингредиенты',
                style: GoogleFonts.poppins(
                  fontSize: subtitleSize,
                  color: Colors.white.withOpacity(0.85),
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onBrowseTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF8B4513),
                  padding: EdgeInsets.symmetric(
                    horizontal: width > 600 ? 40 : 28,
                    vertical: width > 600 ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.1),
                ),
                child: Text(
                  'Смотреть каталог',
                  style: GoogleFonts.poppins(
                    fontSize: width > 600 ? 17 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
