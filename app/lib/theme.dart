import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

/// Brand tokens from shared/BRAND.md.
class FarmColors {
  const FarmColors({
    required this.cream,
    required this.creamCard,
    required this.creamSunk,
    required this.forest,
    required this.leaf,
    required this.gold,
    required this.ink,
    required this.muted,
    required this.line,
    required this.danger,
    required this.btnText,
  });

  final Color cream;
  final Color creamCard;
  final Color creamSunk;
  final Color forest;
  final Color leaf;
  final Color gold;
  final Color ink;
  final Color muted;
  final Color line;
  final Color danger;
  final Color btnText;

  static const light = FarmColors(
    cream: Color(0xFFF5EFE0),
    creamCard: Color(0xFFFDFBF3),
    creamSunk: Color(0xFFEFE7D3),
    forest: Color(0xFF1E4A2B),
    leaf: Color(0xFF3C7D45),
    gold: Color(0xFFBE8F35),
    ink: Color(0xFF2A2A22),
    muted: Color(0xFF6E6A5A),
    line: Color(0xFFDCD2B9),
    danger: Color(0xFFA6392B),
    btnText: Color(0xFFFFFDF6),
  );

  static const dark = FarmColors(
    cream: Color(0xFF101C15),
    creamCard: Color(0xFF17271C),
    creamSunk: Color(0xFF12211A),
    forest: Color(0xFFDDEAD7),
    leaf: Color(0xFF58A55E),
    gold: Color(0xFFD9B267),
    ink: Color(0xFFECEFE4),
    muted: Color(0xFF9AA893),
    line: Color(0xFF2C3E30),
    danger: Color(0xFFE0796A),
    btnText: Color(0xFF0E1A12),
  );
}

ThemeData farmTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
  final display = GoogleFonts.frauncesTextTheme();
  final body = GoogleFonts.mulishTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.cream,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.leaf,
      onPrimary: c.btnText,
      secondary: c.gold,
      onSecondary: c.btnText,
      error: c.danger,
      onError: c.btnText,
      surface: c.creamCard,
      onSurface: c.ink,
    ),
    dividerColor: c.line,
    cardTheme: CardThemeData(
      color: c.creamCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.cream,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.leaf,
        foregroundColor: c.btnText,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.cream,
      foregroundColor: c.forest,
      elevation: 0,
      titleTextStyle: GoogleFonts.fraunces(
        color: c.forest,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.creamCard,
      indicatorColor: c.creamSunk,
    ),
  );

  return base.copyWith(
    textTheme: body.apply(bodyColor: c.ink, displayColor: c.forest).merge(
          display.apply(bodyColor: c.ink, displayColor: c.forest),
        ),
  );
}
