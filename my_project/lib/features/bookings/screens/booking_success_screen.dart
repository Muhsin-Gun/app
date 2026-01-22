import 'package:flutter/material.dart';
import 'package:promarket/core/app_colors.dart';
import 'package:promarket/routing/app_router.dart';
import 'package:promarket/core/utils/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green)
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 12),
            const Text(
              'Your provider has been notified.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                // Pop back to dashboard (pop until first route then replace or specific logic)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}
