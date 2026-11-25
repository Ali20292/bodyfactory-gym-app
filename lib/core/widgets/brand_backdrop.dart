import 'package:flutter/material.dart';
// SystemUiOverlayStyle lives here, not in material.dart.
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Black background with an orange glow, for the product screens.
///
/// The auth screens put the same black-and-orange over a gym photo. That works
/// behind a short centred form; behind a scrolling list it fights the content,
/// so the photo is dropped here and only the light is kept — a warm bloom at
/// the top where the header sits, fading to black well before the list starts.
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS
        systemNavigationBarColor: AppColors.brandSurface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ColoredBox(color: AppColors.brand),

          // The bloom. Anchored above the top edge so what shows is the lower
          // half of it — a horizon rather than a spotlight with a visible
          // centre.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -1.15),
                radius: 1.05,
                colors: <Color>[
                  Color.fromRGBO(242, 72, 27, 0.34),
                  Color.fromRGBO(242, 72, 27, 0.12),
                  Colors.transparent,
                ],
                stops: <double>[0, 0.45, 1],
              ),
            ),
          ),

          // A cooler counterweight in the bottom corner, so the screen does
          // not read as evenly lit from one side.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1, 1.1),
                radius: 0.9,
                colors: <Color>[
                  Color.fromRGBO(242, 72, 27, 0.14),
                  Colors.transparent,
                ],
                stops: <double>[0, 1],
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}
