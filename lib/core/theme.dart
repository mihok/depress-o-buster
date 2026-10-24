import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Calm, low-stimulation palette. Dark first.
class AppColors {
  AppColors._();

  static const Color approach = Color(0xFF8FB39A); // muted sage
  static const Color rest = Color(0xFF8E9BC7); // dusk blue
  static const Color darkBackground = Color(0xFF0F1114);
  static const Color darkSurface = Color(0xFF171A1E);
  static const Color darkSurfaceHigh = Color(0xFF1F2328);
  static const Color darkText = Color(0xFFE6E8EA);
  static const Color darkMuted = Color(0xFF9AA3AB);
  static const Color lightBackground = Color(0xFFF4F3EF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF23272B);
  static const Color lightMuted = Color(0xFF5F6B74);
}

class AppTheme {
  AppTheme._();

  static const double minTouchTarget = 56;

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData light() => _build(Brightness.light);

  /// Clear system bars whose icons follow the theme. The app draws behind
  /// both bars (main.dart turns edge-to-edge on), so neither may bring a
  /// colour or a contrast scrim of its own.
  /// [navigationBar] is the bar's own colour where it needs one: below
  /// Android 10 the window stops above the bar, and a transparent colour
  /// there shows the Android theme's background behind icons styled for
  /// ours.
  static SystemUiOverlayStyle systemOverlayStyle(Brightness brightness, {Color? navigationBar}) {
    final icons = brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // iOS asks for the brightness of the bar's background, not its icons.
      statusBarBrightness: brightness,
      statusBarIconBrightness: icons,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: navigationBar ?? Colors.transparent,
      systemNavigationBarIconBrightness: icons,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.approach,
      brightness: brightness,
      primary: isDark ? AppColors.approach : const Color(0xFF4E7A5C),
      secondary: isDark ? AppColors.rest : const Color(0xFF59689E),
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkText : AppColors.lightText,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
    );
    // Button text derives from labelLarge so the font family and spacing stay
    // those of the typography, not a bare TextStyle with no family.
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: textColor, displayColor: textColor).copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: -1,
          color: textColor,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
        bodySmall: base.textTheme.bodySmall?.copyWith(color: muted),
        labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // Left to itself an AppBar judges the status icons by its transparent
        // background, which reads as dark, and the light theme gets light
        // icons on a light screen.
        systemOverlayStyle: systemOverlayStyle(brightness),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(72, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: base.textTheme.labelLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(72, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: base.textTheme.labelLarge?.copyWith(fontSize: 17),
          side: BorderSide(color: muted.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          textStyle: base.textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 14,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Quiet, short fades on every platform. Low stimulation by default.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(color: muted.withValues(alpha: 0.2)),
    );
  }
}
