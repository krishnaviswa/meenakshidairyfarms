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
    creamSunk: Color(0xFFF1ECDF),
    forest: Color(0xFF1F3D2B),
    leaf: Color(0xFF3E8B40),
    gold: Color(0xFFE0A82E),
    ink: Color(0xFF2A2A24),
    muted: Color(0xFF6E7A6A),
    line: Color(0xFFE3E6DD),
    danger: Color(0xFFA6392B),
    btnText: Color(0xFFFFFAF4),
  );

  static const dark = FarmColors(
    cream: Color(0xFF14160E),
    creamCard: Color(0xFF1C2117),
    creamSunk: Color(0xFF181D13),
    forest: Color(0xFFEAF1E2),
    leaf: Color(0xFF5DB85D),
    gold: Color(0xFFE8B84A),
    ink: Color(0xFFEAF1E2),
    muted: Color(0xFFA8B4A4),
    line: Color(0xFF2E3527),
    danger: Color(0xFFE0796A),
    btnText: Color(0xFFFFFAF4),
  );
}

ThemeData farmTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
  final body = GoogleFonts.mulishTextTheme(
    ThemeData(brightness: brightness).textTheme,
  ).apply(bodyColor: c.ink, displayColor: c.ink);
  final serif = GoogleFonts.frauncesTextTheme(body);
  final textTheme = body.copyWith(
    displayLarge: serif.displayLarge?.copyWith(color: c.forest),
    displayMedium: serif.displayMedium?.copyWith(color: c.forest),
    displaySmall: serif.displaySmall?.copyWith(color: c.forest),
    headlineLarge: serif.headlineLarge?.copyWith(color: c.forest),
    headlineMedium: serif.headlineMedium?.copyWith(color: c.forest),
    headlineSmall: serif.headlineSmall?.copyWith(color: c.forest),
    titleLarge: serif.titleLarge?.copyWith(color: c.forest),
  );

  return ThemeData(
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
    textTheme: textTheme,
    dividerColor: c.line,
    cardTheme: CardThemeData(
      color: c.creamCard,
      elevation: brightness == Brightness.light ? 1 : 0,
      shadowColor: c.forest.withValues(alpha: 0.12),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: c.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.creamCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: TextStyle(color: c.muted, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: c.muted.withValues(alpha: 0.75)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.leaf, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.leaf,
        foregroundColor: c.btnText,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.forest,
        side: BorderSide(color: c.leaf),
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.creamCard,
      side: BorderSide(color: c.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(color: c.forest, fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.cream.withValues(alpha: 0.96),
      foregroundColor: c.forest,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: c.forest.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 68,
      titleTextStyle: GoogleFonts.fraunces(
        color: c.forest,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.creamCard,
      elevation: 4,
      shadowColor: c.forest.withValues(alpha: 0.12),
      indicatorColor: c.gold.withValues(alpha: 0.22),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected) ? c.forest : c.muted,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
          fontSize: 12,
        ),
      ),
    ),
  );
}
