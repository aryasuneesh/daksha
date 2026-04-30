import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';
import 'typography.dart';

ThemeData buildDakshaTheme() {
  const base = TextStyle(
    fontFamily: 'DMSans',
    fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'],
    color: DT.text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: DT.primary,
      onPrimary: DT.primaryFg,
      secondary: DT.accent,
      onSecondary: DT.primaryFg,
      surface: DT.bg,
      onSurface: DT.text,
      error: DT.error,
      onError: DT.primaryFg,
    ),
    scaffoldBackgroundColor: DT.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: DT.bg,
      foregroundColor: DT.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: DakshaTypography.headingMd,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: DT.bg,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    textTheme: TextTheme(
      displayLarge:  DakshaTypography.display,
      titleLarge:    DakshaTypography.headingLg,
      titleMedium:   DakshaTypography.headingMd,
      bodyLarge:     DakshaTypography.body,
      bodyMedium:    DakshaTypography.sm,
      bodySmall:     DakshaTypography.caption,
      labelLarge:    base.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    cardTheme: CardThemeData(
      color: DT.elev1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DT.radius),
        side: const BorderSide(color: DT.outline, width: DT.bwCard),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerColor: DT.outline,
    dividerTheme: const DividerThemeData(color: DT.outline, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DT.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: DT.cardHPad, vertical: DT.lg),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DT.radius),
        borderSide: const BorderSide(color: DT.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DT.radius),
        borderSide: const BorderSide(color: DT.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DT.radius),
        borderSide: const BorderSide(color: DT.primary, width: 2),
      ),
      hintStyle: DakshaTypography.sm.copyWith(color: DT.muted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DT.primary,
        foregroundColor: DT.primaryFg,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: DT.btnHPad, vertical: DT.lg),
        textStyle: base.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        minimumSize: const Size(double.infinity, DT.minTouch),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DT.primary,
        side: const BorderSide(color: DT.primary, width: 2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: DT.btnHPad, vertical: DT.lg),
        textStyle: base.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
        minimumSize: const Size(double.infinity, DT.minTouch),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DT.accent,
        padding: const EdgeInsets.all(DT.sm),
        textStyle: base.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
        minimumSize: const Size(DT.minTouch, DT.minTouch),
      ),
    ),
  );
}
