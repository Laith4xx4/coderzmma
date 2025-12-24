import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية (الأسود والسكني الداكن)
  static const Color primaryColor = Color(0xFF1A1A1A); // أسود كربوني
  static const Color primaryDark = Color(0xFF000000);  // أسود خالص
  static const Color primaryLight = Color(0xFF333333); // سكني غامق جداً

  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFFF2F2F2); // سكني فاتح جداً للخلفية
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Colors.white;

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF000000);   // أسود للنصوص الأساسية
  static const Color textSecondary = Color(0xFF4A4A4A); // سكني متوسط
  static const Color textLight = Color(0xFF8E8E8E);     // سكني فاتح

  // ألوان الحالة (بقيت كما هي للوضوح الوظيفي)
  static const Color successColor = Color(0xFF27AE60);
  static const Color errorColor = Color(0xFFC0392B);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color infoColor = Color(0xFF2980B9);

  // الظلال (Shadows) تم جعلها أنعم لتناسب اللون السكني
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // القياسات (Border Radius & Spacing) - بقيت ثابتة للحفاظ على الهيكلية
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // التدرج اللوني (Gradient) - تدرج سكني فخم
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF434343), Color(0xFF000000)], // من السكني الغامق للأسود
  );

  static BoxDecoration cardDecoration({
    Color? color,
    double? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusMedium),
      boxShadow: shadows ?? cardShadow,
      border: Border.all(color: Colors.black.withOpacity(0.05)), // إطار خفيف جداً
    );
  }

  // ستايلات النصوص المحدثة بالألوان الجديدة
  static const TextStyle heading1 = TextStyle(
    fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal, color: textLight,
  );

  // أزرار فخمة باللون الأسود
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusMedium)),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusMedium)),
  );
}