import 'package:flutter/material.dart';

/// The app's entire colour vocabulary. Widgets never hardcode a `Color`.
///
/// The system is high-contrast: a near-black primary carrying the weight, a
/// single lime accent for the things that should catch the eye, and neutrals
/// doing everything else.
class AppColors {
  const AppColors._();

  // --- Primary -----------------------------------------------------------
  // The primary action *inverts* between themes. A near-black button is
  // invisible on a dark background, so on dark it becomes near-white with
  // black text. Both directions stay at maximum contrast against their
  // background.
  static const Color primaryLight = Color(0xFF101014);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFFF5F5F7);
  static const Color onPrimaryDark = Color(0xFF101014);

  /// The fixed brand colour — splash background, logo tile. Pure black in
  /// both themes, matching the logo artwork, because the brand mark should
  /// not change identity with the OS theme.
  static const Color brand = Color(0xFF000000);
  static const Color onBrand = Color(0xFFF3EFEC);

  // --- Accent ------------------------------------------------------------
  /// Body Factory orange, taken from the logo. Used sparingly: the brand
  /// mark, focus rings, offer badges, and anything that must pull the eye.
  ///
  /// Never for body text on a light background — at small sizes it fails
  /// contrast. On black it is fine, which is why the splash can lean on it.
  static const Color accent = Color(0xFFF2481B);

  /// The lighter tint from the logo animation, for highlights and the ignite
  /// flash on the mark.
  static const Color accentHi = Color(0xFFFF8A4C);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentMuted = Color(0xFFFFE7DE);
  static const Color accentDarkSurface = Color(0xFF3A1A0F);

  /// The wordmark's off-white, from the logo animation.
  static const Color cream = Color(0xFFF3EFEC);

  // --- Brand surfaces ----------------------------------------------------
  // The black-and-orange UI runs on pure black, so anything that should read
  // as a *surface* has to be lifted just off it — otherwise cards look like
  // holes in the screen rather than objects on it.
  static const Color brandSurface = Color(0xFF141416);

  /// One step above [brandSurface], for a card sitting on top of a card.
  static const Color brandSurfaceHi = Color(0xFF1C1D21);
  static const Color brandLine = Color(0xFF2E2F33);

  /// Placeholder and disabled text on black.
  static const Color brandHint = Color(0xFF77797F);

  /// Secondary text on black. Measures 7.4:1 against pure black, so it stays
  /// readable at body size rather than just looking quiet.
  static const Color brandMuted = Color(0xFFAEB0B5);

  // --- Neutrals ----------------------------------------------------------
  static const Color ink = Color(0xFF101014);
  static const Color inkMuted = Color(0xFF63666F);
  static const Color inkFaint = Color(0xFF9A9DA6);
  static const Color line = Color(0xFFE4E5E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF7F7F9);

  static const Color inkDark = Color(0xFFF5F5F7);
  static const Color inkMutedDark = Color(0xFFA0A3AC);
  static const Color inkFaintDark = Color(0xFF6B6E77);
  static const Color lineDark = Color(0xFF2B2C33);
  static const Color surfaceDark = Color(0xFF17181D);
  static const Color surfaceAltDark = Color(0xFF0D0E12);

  // --- Occupancy bands ---------------------------------------------------
  // These encode a reading, not an identity: green → amber → orange → red is
  // the sequence people already know, and the spec fixes those hues.
  //
  // Two things forced a re-tune when the UI went black-and-orange. The
  // mid-tones the original set used were mixed for a white card and go muddy
  // on black, so each one is lighter and more saturated here. And "busy" was
  // `#F07627`, close enough to brand orange `#F2481B` that the bar looked like
  // it was painted in the brand colour rather than reporting a level — so it
  // has moved yellow-ward, away from the accent, while staying orange.
  static const Color occupancyQuiet = Color(0xFF2FD26B);
  static const Color occupancyModerate = Color(0xFFF6C445);
  static const Color occupancyBusy = Color(0xFFFF9A2E);
  static const Color occupancyPacked = Color(0xFFFF4D4D);

  // --- Status ------------------------------------------------------------
  static const Color success = Color(0xFF2BA84A);
  static const Color warning = Color(0xFFF2A93B);
  static const Color danger = Color(0xFFE03B3B);
  static const Color dangerLight = Color(0xFFFDECEC);
  static const Color dangerDarkSurface = Color(0xFF3A1A1A);
}
