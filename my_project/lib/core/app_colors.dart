import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4F46E5);
  
  static const darkBackground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const background = Color(0xFFF5F7FA);

  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF6366F1),
      Color(0xFF4F46E5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
