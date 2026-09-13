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
    cream: Color(0xFFFBF8F2),
    creamCard: Color(0xFFFFFFFF),
    creamSunk: Color(0xFFF3EBE0),
    forest: Color(0xFF3A2718),
    leaf: Color(0xFFC45C26),
    gold: Color(0xFFC4A35A),
    ink: Color(0xFF2C241C),
    muted: Color(0xFF75695D),
    line: Color(0xFFE7DCCB),
    danger: Color(0xFFA6392B),
    btnText: Color(0xFFFFFAF4),
  );

  static const dark = FarmColors(
    cream: Color(0xFF16110E),
    creamCard: Color(0xFF201914),
    creamSunk: Color(0xFF1B1511),
    forest: Color(0xFFF4E7D8),
    leaf: Color(0xFFD66B34),
    gold: Color(0xFFD6B66F),
    ink: Color(0xFFF5EEE7),
    muted: Color(0xFFB9AA9C),
    line: Color(0xFF3D3027),
    danger: Color(0xFFE0796A),
    btnText: Color(0xFFFFFAF4),
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
