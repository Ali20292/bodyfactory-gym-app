import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds the light and dark [ThemeData] from the design constants.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  /// The app's theme: black-and-orange, everywhere, whatever the OS is set to.
  ///
  /// It started as the auth-only look and now runs the product screens too, so
  /// the app reads as one piece from the splash onward rather than switching
  /// identity once you log in. [light] and [dark] stay behind it as the
  /// neutral base this is built on — nothing points at them directly.
  ///
  /// The primary action is orange here, not the usual near-black: a near-black
  /// button on a black background is invisible. Its label is near-black rather
  /// than white, which is a contrast decision, not a stylistic one — white on
  /// `#F2481B` measures 3.67:1 and fails WCAG AA for text this size, while
  /// near-black measures 5.72:1 and passes.
  static ThemeData get brand {
    final ThemeData base = _build(Brightness.dark);
    final TextTheme text = base.textTheme;

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.brand,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        onPrimary: AppColors.ink,
        surface: AppColors.brandSurface,
        onSurface: AppColors.cream,
        outline: AppColors.brandLine,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.cream,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.cream,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: AppColors.brandSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.brandLine),
        ),
      ),
      dividerTheme: base.dividerTheme.copyWith(color: AppColors.brandLine),
      // The one place the tab bar differs from a stock dark bar: the selected
      // tab is orange rather than white, which is the only cue that survives
      // being glanced at.
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: AppColors.brandSurface,
        indicatorColor: AppColors.accent.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => AppTextStyles.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.brandHint,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.brandHint,
          ),
        ),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: AppColors.brandSurface,
      ),
      // The neutral dark theme inverts its snackbar — near-white with dark
      // text — which is correct there and glaring here, where it lands on
      // black as a bright slab. Dark surface, cream text, orange action.
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: AppColors.brandSurfaceHi,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.cream,
        ),
        actionTextColor: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.brandLine),
        ),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: AppColors.brandSurface,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.cream,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.brandMuted,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.brandSurfaceHi,
        side: const BorderSide(color: AppColors.brandLine),
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(color: AppColors.cream),
        titleLarge: text.titleLarge?.copyWith(color: AppColors.cream),
        titleMedium: text.titleMedium?.copyWith(color: AppColors.cream),
        bodyLarge: text.bodyLarge?.copyWith(color: AppColors.cream),
        bodyMedium: text.bodyMedium?.copyWith(color: AppColors.brandMuted),
        labelLarge: text.labelLarge?.copyWith(color: AppColors.cream),
        labelMedium: text.labelMedium?.copyWith(color: AppColors.cream),
        labelSmall: text.labelSmall?.copyWith(color: AppColors.brandMuted),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: AppColors.brandSurface,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.brandHint),
        border: _inputBorder(AppColors.brandLine),
        enabledBorder: _inputBorder(AppColors.brandLine),
        focusedBorder: _inputBorder(AppColors.accent, width: 1.8),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.ink.withValues(alpha: 0.6),
          textStyle: AppTextStyles.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // Links are the one thing that is orange rather than white.
          foregroundColor: AppColors.accent,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.brandHint),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color ink = isDark ? AppColors.inkDark : AppColors.ink;
    final Color inkMuted = isDark ? AppColors.inkMutedDark : AppColors.inkMuted;
    final Color line = isDark ? AppColors.lineDark : AppColors.line;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final Color surfaceAlt = isDark
        ? AppColors.surfaceAltDark
        : AppColors.surfaceAlt;

    // The primary inverts by theme — see AppColors.
    final Color primary = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final Color onPrimary = isDark
        ? AppColors.onPrimaryDark
        : AppColors.onPrimaryLight;

    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryLight,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: AppColors.accent,
          onSecondary: AppColors.onAccent,
          error: AppColors.danger,
          surface: surface,
          onSurface: ink,
          outline: line,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surfaceAlt,
      // Jost everywhere by default; Oswald is reserved for the wordmark.
      fontFamily: AppTextStyles.bodyFont,
      textTheme: _textTheme(ink, inkMuted),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceAlt,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: ink),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: line),
        ),
      ),
      dividerTheme: DividerThemeData(color: line, space: 1, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.inkFaintDark : AppColors.inkFaint,
        ),
        border: _inputBorder(line),
        enabledBorder: _inputBorder(line),
        // The focus ring is the one place the accent earns its keep on a
        // form: it marks where you are without shouting.
        focusedBorder: _inputBorder(ink, width: 1.8),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.8),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: primary.withValues(alpha: 0.35),
          disabledForegroundColor: onPrimary.withValues(alpha: 0.7),
          textStyle: AppTextStyles.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
          foregroundColor: ink,
          side: BorderSide(color: isDark ? AppColors.inkFaintDark : ink),
          textStyle: AppTextStyles.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark
            ? AppColors.accentDarkSurface
            : AppColors.accentMuted,
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => AppTextStyles.caption.copyWith(
            color: states.contains(WidgetState.selected) ? ink : inkMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? ink : inkMuted,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: ink),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: inkMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        side: BorderSide(color: line),
        labelStyle: AppTextStyles.caption.copyWith(color: inkMuted),
        shape: const StadiumBorder(),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );

  static TextTheme _textTheme(Color ink, Color inkMuted) => TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(color: ink),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(color: ink),
    titleLarge: AppTextStyles.titleLarge.copyWith(color: ink),
    titleMedium: AppTextStyles.titleMedium.copyWith(color: ink),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: ink),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: inkMuted),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: ink),
    labelMedium: AppTextStyles.fieldLabel.copyWith(color: ink),
    labelSmall: AppTextStyles.caption.copyWith(color: inkMuted),
  );
}
