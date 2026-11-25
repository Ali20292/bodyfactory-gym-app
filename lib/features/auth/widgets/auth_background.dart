import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// SystemUiOverlayStyle lives here, not in material.dart.
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Photographic backdrop for the auth screens.
///
/// Three layers over the gym photo:
/// 1. a slight blur — the source art is 275x183, so it is soft at full-screen
///    size whatever we do. Blurring makes that read as depth of field rather
///    than as a low-resolution image;
/// 2. a translucent black scrim, which is what keeps white text legible over
///    a photo that has its own bright spots;
/// 3. an orange vignette at the edges, fading to nothing by the middle.
class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
    this.imageAsset = defaultImage,
  });

  /// The gym floor. Used by Login.
  static const String defaultImage = 'assets/images/backgym1.jpg';

  /// The reception wall with the signage. Used by Sign Up.
  static const String receptionImage = 'assets/images/backgym2.jpg';

  final Widget child;

  /// Which photo sits behind the form, so each screen can have its own.
  final String imageAsset;

  /// How dark the scrim is. Tuned so the photo still reads while body text
  /// stays comfortably above contrast minimums.
  static const double _scrimOpacity = 0.72;

  @override
  Widget build(BuildContext context) {
    // Without this the OS keeps its default dark status-bar icons, which are
    // near-invisible against this backdrop. Scoped to these screens, so the
    // product screens keep icons that suit their own background.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS
        systemNavigationBarColor: AppColors.brand,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Black underneath, so nothing shows through while the image decodes
          // and the edges stay black on any aspect ratio.
          const ColoredBox(color: AppColors.brand),

          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              // A missing asset should not take the login screen down with it.
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? _) =>
                      const ColoredBox(color: AppColors.brand),
            ),
          ),

          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, _scrimOpacity),
            ),
          ),

          // Orange edge glow. Transparent through the middle so it never sits
          // behind the form's text.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: <Color>[
                  Colors.transparent,
                  Colors.transparent,
                  Color.fromRGBO(242, 72, 27, 0.18),
                  Color.fromRGBO(242, 72, 27, 0.42),
                ],
                stops: <double>[0, 0.45, 0.78, 1],
              ),
            ),
          ),

          // Deepen the very top and bottom so the status bar and the system
          // navigation gesture bar keep their contrast.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.fromRGBO(0, 0, 0, 0.55),
                  Colors.transparent,
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.55),
                ],
                stops: <double>[0, 0.22, 0.78, 1],
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}
