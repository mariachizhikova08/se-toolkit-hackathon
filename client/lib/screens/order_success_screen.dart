import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import 'home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;
  final double totalPrice;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF69B4).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, size: 64, color: Colors.white),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text(
                'Заказ оформлен!',
                style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text(
                '🎉 Спасибо за ваш заказ',
                style: GoogleFonts.dancingScript(fontSize: 24, color: const Color(0xFFFF69B4)),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Номер заказа: #$orderId',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Сумма: ${totalPrice.toStringAsFixed(0)} ₽',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              Text(
                'Мы свяжемся с вами для подтверждения',
                style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF888888)),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Вернуться в каталог', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
