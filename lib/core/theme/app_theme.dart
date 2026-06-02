import 'package:conduit/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  const AppTheme._();

  static SystemUiOverlayStyle systemUiOverlayStyle(Brightness brightness) {
    final iconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return (brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: iconBrightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: iconBrightness,
          systemNavigationBarContrastEnforced: false,
        );
  }

  static ThemeData build({
    required Brightness brightness,
    required AppPalette palette,
  }) {
    final canvas = palette.canvasFor(brightness);
    final panel = palette.panelFor(brightness);
    final panelElevated = palette.panelElevatedFor(brightness);
    final hairline = palette.hairlineFor(brightness);
    final border = palette.borderFor(brightness);
    final foreground = palette.foregroundFor(brightness);
    final muted = palette.mutedForegroundFor(brightness);
    final subtle = palette.subtleForegroundFor(brightness);
    final accent = palette.accent;

    final base = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final colorScheme = base.copyWith(
      primary: accent,
      onPrimary: brightness == Brightness.dark ? palette.canvas : Colors.white,
      primaryContainer: Color.alphaBlend(accent.withValues(alpha: 0.14), panel),
      onPrimaryContainer: foreground,
      secondary: palette.accentSecondary,
      onSecondary: brightness == Brightness.dark
          ? palette.canvas
          : Colors.white,
      tertiary: palette.accentSecondary,
      surface: panel,
      onSurface: foreground,
      surfaceContainer: panel,
      surfaceContainerHigh: panelElevated,
      surfaceContainerHighest: panelElevated,
      surfaceContainerLow: canvas,
      surfaceContainerLowest: canvas,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: hairline,
      error: palette.danger,
      onError: brightness == Brightness.dark ? palette.canvas : Colors.white,
    );

    final textTheme = _buildTextTheme(
      foreground: foreground,
      muted: muted,
      subtle: subtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: muted, size: 22),
      primaryIconTheme: IconThemeData(color: foreground),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvas,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: systemUiOverlayStyle(brightness),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: panel,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: hairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panelElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: panelElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: panelElevated,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: subtle,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.danger, width: 1.5),
        ),
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Color.alphaBlend(Colors.black.withValues(alpha: 0.18), panel)
            : panel,
        hintStyle: textTheme.bodyMedium?.copyWith(color: subtle),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: accent),
        prefixIconColor: muted,
        suffixIconColor: muted,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          backgroundColor: accent,
          foregroundColor: brightness == Brightness.dark
              ? palette.canvas
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(64, 48),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: brightness == Brightness.dark
            ? palette.canvas
            : Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: panelElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: hairline),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panel,
        selectedColor: Color.alphaBlend(accent.withValues(alpha: 0.18), panel),
        side: BorderSide(color: hairline),
        labelStyle: textTheme.labelMedium?.copyWith(color: foreground),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: foreground),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: panel,
          foregroundColor: muted,
          selectedBackgroundColor: Color.alphaBlend(
            accent.withValues(alpha: 0.16),
            panel,
          ),
          selectedForegroundColor: accent,
          side: BorderSide(color: hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: hairline, space: 1, thickness: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: panelElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hairline),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: foreground),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: panelElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: foreground),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: hairline),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: hairline,
        circularTrackColor: hairline,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(subtle.withValues(alpha: 0.5)),
        thickness: WidgetStateProperty.all(4),
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required Color foreground,
    required Color muted,
    required Color subtle,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        color: foreground,
        fontSize: 56,
        height: 1.05,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      displayMedium: TextStyle(
        color: foreground,
        fontSize: 44,
        height: 1.08,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      displaySmall: TextStyle(
        color: foreground,
        fontSize: 34,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      headlineLarge: TextStyle(
        color: foreground,
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        color: foreground,
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        color: foreground,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.15,
      ),
      titleLarge: TextStyle(
        color: foreground,
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        color: foreground,
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.05,
      ),
      titleSmall: TextStyle(
        color: foreground,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: foreground,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: foreground,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        color: muted,
        fontSize: 12.5,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        color: foreground,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: muted,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        color: subtle,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}
