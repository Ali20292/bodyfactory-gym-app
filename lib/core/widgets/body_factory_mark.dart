import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Body Factory mark: an inverted triangle with three spokes running from
/// its centre to each corner.
///
/// Geometry is lifted verbatim from the brand animation
/// (`design/logo_animation/bodyfactory-scene.jsx`), which uses an SVG viewBox
/// of `-160 -110 320 320`. Keeping the same coordinate space means the shape
/// is identical to the artwork rather than an approximation.
class BodyFactoryMark extends StatelessWidget {
  const BodyFactoryMark({
    super.key,
    required this.size,
    this.progress = 1,
    this.color = AppColors.accent,
    this.highlight = AppColors.accentHi,
  });

  final double size;

  /// 0 → nothing drawn, 1 → fully assembled. Values between run the
  /// assemble sequence: edges fly in and lock, then the spokes draw out.
  final double progress;

  final Color color;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MarkPainter(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          highlight: highlight,
        ),
      ),
    );
  }
}

// --- Geometry, in viewBox units ------------------------------------------

const Offset _topLeft = Offset(-100, -45);
const Offset _topRight = Offset(100, -45);
const Offset _bottom = Offset(0, 130);

/// Where the three spokes meet. Deliberately below the centroid — that offset
/// is what gives the mark its sense of depth.
const Offset _joint = Offset(0, 16);

/// Stroke weight in viewBox units, matching the source artwork.
const double _strokeWidth = 4.4;

/// Floor for the stroke once scaled, in logical pixels.
///
/// The viewBox stroke shrinks with the mark, so at small sizes the outline
/// thins to about a pixel and the inner spokes all but disappear. Below this
/// size the stroke stops scaling and holds its weight instead.
const double _minStrokePx = 1.9;

/// One edge of the outer triangle, with the direction it flies in from and
/// the angle it unwinds through.
class _Edge {
  const _Edge(this.a, this.b, this.normal, this.spin);

  final Offset a;
  final Offset b;

  /// Unit vector the edge travels along as it arrives.
  final Offset normal;

  /// Degrees of rotation it unwinds, giving each edge its own character.
  final double spin;
}

const List<_Edge> _edges = <_Edge>[
  _Edge(_topLeft, _topRight, Offset(0, -1), -16),
  _Edge(_topRight, _bottom, Offset(0.87, 0.5), 20),
  _Edge(_bottom, _topLeft, Offset(-0.87, 0.5), -20),
];

const List<Offset> _spokeEnds = <Offset>[_topLeft, _topRight, _bottom];

/// The mark's own timeline, in seconds. [BodyFactoryMark.progress] maps onto
/// it, so the caller only deals in 0..1.
const double _markDuration = 1.85;

class _MarkPainter extends CustomPainter {
  const _MarkPainter({
    required this.progress,
    required this.color,
    required this.highlight,
  });

  final double progress;
  final Color color;
  final Color highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress * _markDuration;

    // Map the viewBox (320 x 320, origin at -160,-110) onto the widget.
    final double scale = size.width / 320;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    // The viewBox is not centred on the origin vertically: its centre sits at
    // y = 50, so shift up by that much to centre the artwork.
    canvas.translate(0, -50);

    // Everything below is drawn in viewBox units, so the floor has to be
    // converted back through the scale to mean anything in pixels.
    final double stroke = math.max(_strokeWidth, _minStrokePx / scale);

    _paintSpokes(canvas, t, stroke);
    _paintEdges(canvas, t, stroke);
    _paintJointAndRing(canvas, t, stroke);

    canvas.restore();
  }

  void _paintEdges(Canvas canvas, double t, double stroke) {
    for (int i = 0; i < _edges.length; i++) {
      final _Edge edge = _edges[i];
      final double start = i * 0.18;
      final double end = start + 0.75;

      final double arrive = _segment(t, start, end, Curves.easeOutExpo);
      final double opacity = _segment(
        t,
        start,
        start + 0.22,
        Curves.easeOutQuad,
      );
      if (opacity <= 0) continue;

      // A brief thickening as the edge locks home — the "ignite" flash.
      final double flash =
          1 - _segment(t, end - 0.07, end + 0.35, Curves.easeOutQuad);

      final double offset = 340 * (1 - arrive);
      final double spin = edge.spin * (1 - arrive);

      canvas.save();
      canvas.translate(edge.normal.dx * offset, edge.normal.dy * offset);
      canvas.rotate(spin * math.pi / 180);

      final Paint paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = stroke + flash * 5.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(edge.a, edge.b, paint);
      canvas.restore();
    }
  }

  void _paintSpokes(Canvas canvas, double t, double stroke) {
    for (int i = 0; i < _spokeEnds.length; i++) {
      final Offset end = _spokeEnds[i];
      final double start = 0.95 + i * 0.12;
      final double drawn = _segment(t, start, start + 0.5, Curves.easeOutExpo);
      if (drawn <= 0) continue;

      // Grows outward from the joint rather than fading in.
      final Offset tip = Offset.lerp(_joint, end, drawn)!;

      final Paint paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(_joint, tip, paint);
    }
  }

  void _paintJointAndRing(Canvas canvas, double t, double stroke) {
    // A node pops at the joint as the spokes land, then collapses.
    final double pop = _segment(t, 1.42, 1.62, Curves.easeOutBack);
    final double collapse = 1 - _segment(t, 1.6, 1.85, Curves.easeInQuad);
    final double radius = 9 * pop * collapse;
    if (radius > 0.05) {
      canvas.drawCircle(_joint, radius, Paint()..color = highlight);
    }

    // A shockwave ring expanding out of the joint. Only while in flight.
    final double ring = _segment(t, 1.45, 1.85, Curves.easeOutQuart);
    if (ring > 0 && ring < 1) {
      final Paint paint = Paint()
        ..color = highlight.withValues(alpha: (1 - ring) * 0.7)
        // Thinner than the mark itself, but held to the same pixel floor.
        ..strokeWidth = stroke * 0.6
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(_joint, 10 + ring * 165, paint);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.highlight != highlight;
}

/// Eases [t] across the window [start]..[end], flat at 0 and 1 outside it.
///
/// The animation source drives everything off absolute times rather than
/// chained tweens, so this is the one primitive the whole port needs.
double _segment(double t, double start, double end, Curve curve) {
  if (t <= start) return 0;
  if (t >= end) return 1;
  return curve.transform((t - start) / (end - start));
}
