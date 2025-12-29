import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الأساسية (Neon Green & Dark Theme)
  static const Color primaryColor = Color(0xFFE6E6E2); // Neon Green (unchanged)
  static const Color primaryDark = Color(0xFF000000);  // Pure Black
  static const Color primaryLight = Color(0xFF2C2C2C); // Dark Grey

  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFF050505); // Very Dark Grey (Almost Black)
  static const Color cardBackground = Color(0xFF141414); // Dark Grey Card
  static const Color surfaceColor = Color(0xFF1A1A1A);

  // ألوان النصوص
  static const Color textPrimary = Colors.white;          
  static const Color textSecondary = Color(0xFF9CA3AF);   // Slate 400
  static const Color textLight = Color(0xFF6B7280);       // Slate 500
  static const Color textdark = Color(0xFF000000);       // Slate 500

  // ألوان الحالة
  static const Color successColor = Color(0xFF19E66B); 
  static const Color errorColor = Color(0xFFEF4444);   
  static const Color warningColor = Color(0xFFF59E0B); 
  static const Color infoColor = Color(0xFF3B82F6);    

  // الظلال (Shadows)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4), // Darker shadow
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFFE1E0DF).withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // القياسات (Border Radius & Spacing)
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0; 
  static const double borderRadiusLarge = 24.0;  
  static const double borderRadiusXLarge = 32.0; 

  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // التدرج اللوني (Gradient)
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCCC9C9), Color(0xFF000000)], // Black/Grey Gradient
  );

  static LinearGradient primaryGradiente = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF292828), Color(0xFF000000)], // Black/Grey Gradient
  );

  static LinearGradient accentGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4F1F0), Color(0xFF0B0201)],
  );

  static BoxDecoration cardDecoration({
    Color? color,
    double? borderRadius,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusMedium),
      boxShadow: shadows ?? cardShadow,
      border: border ?? Border.all(color: const Color(0xFF2C2C2C), width: 1), // Grey Border
    );
  }

  // ستايلات النصوص (Lexend)
  static TextStyle get heading1 => GoogleFonts.lexend(
    fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5,
  );

  static TextStyle get heading2 => GoogleFonts.lexend(
    fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.3,
  );

  static TextStyle get heading3 => GoogleFonts.lexend(
    fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.lexend(
    fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.lexend(
    fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.lexend(
    fontSize: 12, fontWeight: FontWeight.normal, color: textLight,
  );

  // أزرار فخمة
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: primaryDark, // Black text on Green button
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusMedium)),
    shadowColor: primaryColor.withOpacity(0.4),
    textStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: Color(0xFFECEBEB), width: 1),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusMedium)),
    textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600),
  );
}