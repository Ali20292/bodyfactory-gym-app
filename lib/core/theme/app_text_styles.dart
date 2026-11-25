import 'package:flutter/material.dart';

/// Type scale.
///
/// Two brand faces, both bundled as variable fonts:
/// * **Jost** — everything in the product UI.
/// * **Oswald** — the condensed face from the logo lockup. Reserved for the
///   wordmark; using it for body text would fight the logo rather than
///   support it.
///
/// Every style sets `fontVariations` as well as `fontWeight`. Flutter does not
/// reliably map `fontWeight` onto a variable font's weight axis, so without
/// the explicit axis value everything renders at the file's default weight.
/// `fontWeight` is kept alongside it so fallback fonts still bold correctly.
///
/// Colours are applied by the theme, not baked in here, so one style works in
/// both light and dark.
class AppTextStyles {
  const AppTextStyles._();

  static const String bodyFont = 'Jost';
  static const String displayFont = 'Oswald';

  static List<FontVariation> _wght(double weight) => <FontVariation>[
    FontVariation('wght', weight),
  ];

  static TextStyle get displayLarge => TextStyle(
    fontFamily: bodyFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontVariations: _wght(700),
    letterSpacing: -1,
    height: 1.1,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: bodyFont,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    letterSpacing: -0.6,
    height: 1.18,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: bodyFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    letterSpacing: -0.2,
    height: 1.25,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    height: 1.3,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontVariations: _wght(400),
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: bodyFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    fontVariations: _wght(400),
    height: 1.5,
  );

  /// Small label above a field or a section. The letter-spacing is what makes
  /// it read as a label without needing to be shouted in capitals — which
  /// would not survive translation to Arabic.
  static TextStyle get fieldLabel => TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    letterSpacing: 0.6,
    height: 1.2,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: bodyFont,
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    letterSpacing: 0.2,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: bodyFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    fontVariations: _wght(500),
    letterSpacing: 0.1,
    height: 1.35,
  );

  /// Big centred number, e.g. the occupancy percentage on the capacity bar.
  static TextStyle get statNumber => TextStyle(
    fontFamily: bodyFont,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    letterSpacing: -1.5,
    height: 1,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Monospaced digits — OTP boxes, counters that must not jitter.
  static TextStyle get digits => TextStyle(
    fontFamily: bodyFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// The logo lockup's wordmark. Oswald, wide tracking, matching the artwork.
  ///
  /// Weight 600 rather than the source animation's 400: that runs at 100px in
  /// a 1080p video, where thin strokes hold up. At splash size the same weight
  /// anti-aliases to grey and loses the artwork's presence.
  static TextStyle wordmark({required double size}) => TextStyle(
    fontFamily: displayFont,
    fontSize: size,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    letterSpacing: size * 0.16,
    height: 1,
  );
}
