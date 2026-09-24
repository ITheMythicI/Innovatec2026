import 'package:flutter/material.dart';

/// Sistema de Diseño "Resguardo Emergency Response" extraído rigurosamente de `DESIGN.md`.
/// Alta legibilidad, utilitarismo de alto contraste, bordes definidos y cero artefactos difusos.
class ResguardoTheme {
  // Paleta de Colores
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  
  static const Color background = Color(0xFFF8F9FF);
  static const Color primary = Color(0xFF0A192F); // Deep Navy estructural
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  static const Color onSurface = Color(0xFF0A192F);
  static const Color onSurfaceVariant = Color(0xFF44474D);
  static const Color textMuted = Color(0xFF64748B);
  
  // Triage y Estados
  static const Color emergencyCrimson = Color(0xFFDC2626); // SOS / Destructivo / Urgente
  static const Color emergencyCrimsonActive = Color(0xFFB91C1C);
  static const Color emergencyCrimsonContainer = Color(0xFFFEF2F2);
  static const Color emergencyCrimsonBorder = Color(0xFFFECACA);
  
  static const Color safeEmerald = Color(0xFF16A34A); // Estoy a Salvo / Bienestar
  static const Color safeEmeraldActive = Color(0xFF15803D);
  static const Color safeEmeraldContainer = Color(0xFFF0FDF4);
  static const Color safeEmeraldBorder = Color(0xFFBBF7D0);
  
  static const Color warningAmber = Color(0xFFD97706); // Advertencia / Batería baja
  static const Color warningAmberActive = Color(0xFFB45309);
  static const Color warningAmberContainer = Color(0xFFFEF3C7);
  static const Color warningAmberBorder = Color(0xFFFDE68A);

  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFCBD5E1);
  static const Color outlineFocused = Color(0xFF0A192F);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // Bordes y Radios
  static final BorderRadius radiusSm = BorderRadius.circular(2.0);  // 0.125rem
  static final BorderRadius radiusDefault = BorderRadius.circular(4.0); // 0.25rem
  static final BorderRadius radiusMd = BorderRadius.circular(6.0);  // 0.375rem
  static final BorderRadius radiusLg = BorderRadius.circular(8.0);  // 0.5rem (Cards)
  static final BorderRadius radiusXl = BorderRadius.circular(12.0); // 0.75rem (Acciones primarias)
  static final BorderRadius radiusFull = BorderRadius.circular(9999.0); // Píldoras / SOS

  // Sombras y Profundidad (Level 1, 2, 3)
  static const BoxShadow shadowLevel2 = BoxShadow(
    color: Color.fromRGBO(10, 25, 47, 0.08),
    offset: Offset(0, 2),
    blurRadius: 4,
  );

  static const BoxShadow shadowLevel3 = BoxShadow(
    color: Color.fromRGBO(10, 25, 47, 0.16),
    offset: Offset(0, 8),
    blurRadius: 24,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: emergencyCrimson,
        onSecondary: Colors.white,
        tertiary: safeEmerald,
        onTertiary: Colors.white,
        error: emergencyCrimson,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        outline: outline,
        outlineVariant: inputBorder,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: outline, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: outlineFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: emergencyCrimson, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          backgroundColor: surface,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
