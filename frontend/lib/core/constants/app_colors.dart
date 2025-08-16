import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - 모던한 그라데이션
  static const Color primary = Color(0xFF6366F1); // 인디고
  static const Color primaryLight = Color(0xFF818CF8); // 라이트 인디고
  static const Color primaryDark = Color(0xFF4F46E5); // 다크 인디고
  static const Color secondary = Color(0xFF10B981); // 에메랄드
  static const Color accent = Color(0xFFF59E0B); // 앰버
  
  // Background Colors - 깔끔한 그레이스케일
  static const Color background = Color(0xFFFAFAFA); // 거의 흰색
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8F9FA); // 매우 연한 그레이
  
  // Text Colors - 세련된 타이포그래피
  static const Color textPrimary = Color(0xFF1F2937); // 다크 슬레이트
  static const Color textSecondary = Color(0xFF6B7280); // 중간 그레이
  static const Color textLight = Color(0xFF9CA3AF); // 라이트 그레이
  static const Color textInverse = Colors.white;
  
  // Status Colors - 모던한 상태 색상
  static const Color success = Color(0xFF10B981); // 에메랄드
  static const Color warning = Color(0xFFF59E0B); // 앰버
  static const Color error = Color(0xFFEF4444); // 레드
  static const Color info = Color(0xFF3B82F6); // 블루
  
  // Rating Colors
  static const Color ratingStar = Color(0xFFF59E0B); // 앰버
  
  // Shadow Colors - 부드러운 그림자
  static const Color shadow = Color(0x0A000000); // 매우 연한 그림자
  static const Color shadowMedium = Color(0x1A000000); // 중간 그림자
  static const Color shadowStrong = Color(0x33000000); // 강한 그림자
  
  // Border Colors - 세련된 테두리
  static const Color border = Color(0xFFE5E7EB); // 연한 그레이
  static const Color borderLight = Color(0xFFF3F4F6); // 매우 연한 그레이
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x0A000000);
} 