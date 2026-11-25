/// Spacing and radius scale. No magic numbers for layout anywhere else.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Extra breathing room between major blocks on a screen.
  static const double section = 40;

  /// Standard horizontal padding for a screen body.
  static const double screenH = 20;

  /// Height of a primary call-to-action button and a text field. Generous:
  /// these are the two things people actually hit with a thumb.
  static const double controlHeight = 56;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Fully rounded — the primary button and chips.
  static const double pill = 999;
}
