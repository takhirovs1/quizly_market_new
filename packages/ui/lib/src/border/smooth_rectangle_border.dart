import 'dart:math' as math;
import 'dart:ui' as ui show lerpDouble;

import 'package:flutter/material.dart';

enum _CornerLocation { tl, tr, bl, br }

/// A rectangular border with variable smoothness transitions between
/// the straight sides and the rounded corners.
class SmoothRectangleBorders extends OutlinedBorder {
  const SmoothRectangleBorders({this.smoothness = .6, this.borderRadius = BorderRadius.zero, super.side});

  /// The radius for each corner.
  ///
  /// Negative radius values are clamped to 0.0 by [getInnerPath] and
  /// [getOuterPath].
  ///
  /// If radiuses of X and Y from one corner are not equal, the smallest one will be used.
  final BorderRadiusGeometry borderRadius;

  /// The smoothness of corners.
  ///
  /// The concept comes from a feature called "corner smoothing" of Figma.
  ///
  /// 0.0 - 1.0
  final double smoothness;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getPath(borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width));

  Path getPath(RRect rrect) {
    var path = Path();
    if (smoothness == 0 || borderRadius == BorderRadius.zero) {
      path.addRRect(rrect);
    } else {
      final width = rrect.width;
      final height = rrect.height;
      final top = rrect.top;
      final left = rrect.left;
      final bottom = rrect.bottom;
      final right = rrect.right;

      var centerX = width / 2 + left;

      var tl = _Corner(rrect, _CornerLocation.tl, smoothness);
      var tr = _Corner(rrect, _CornerLocation.tr, smoothness);
      var br = _Corner(rrect, _CornerLocation.br, smoothness);
      var bl = _Corner(rrect, _CornerLocation.bl, smoothness);

      path
        ..moveTo(centerX, top)
        // top right
        ..lineTo(left + math.max(width / 2, width - tr.p), top)
        ..cubicTo(
          right - (tr.p - tr.a),
          top,
          right - (tr.p - tr.a - tr.b),
          top,
          right - (tr.p - tr.a - tr.b - tr.c),
          top + tr.d,
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(right - tr.radius, top + tr.radius), radius: tr.radius),
          (270 + tr.angleBezier).toRadian(),
          (90 - 2 * tr.angleBezier).toRadian(),
          false,
        )
        ..cubicTo(
          right,
          top + (tr.p - tr.a - tr.b),
          right,
          top + (tr.p - tr.a),
          right,
          top + math.min(height / 2, tr.p),
        )
        //bottom right
        ..lineTo(right, top + math.max(height / 2, height - br.p))
        ..cubicTo(
          right,
          bottom - (br.p - br.a),
          right,
          bottom - (br.p - br.a - br.b),
          right - br.d,
          bottom - (br.p - br.a - br.b - br.c),
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(right - br.radius, bottom - br.radius), radius: br.radius),
          br.angleBezier.toRadian(),
          (90 - br.angleBezier * 2).toRadian(),
          false,
        )
        ..cubicTo(
          right - (br.p - br.a - br.b),
          bottom,
          right - (br.p - br.a),
          bottom,
          left + math.max(width / 2, width - br.p),
          bottom,
        )
        //bottom left
        ..lineTo(left + math.min(width / 2, bl.p), bottom)
        ..cubicTo(
          left + (bl.p - bl.a),
          bottom,
          left + (bl.p - bl.a - bl.b),
          bottom,
          left + (bl.p - bl.a - bl.b - bl.c),
          bottom - bl.d,
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(left + bl.radius, bottom - bl.radius), radius: bl.radius),
          (90 + bl.angleBezier).toRadian(),
          (90 - bl.angleBezier * 2).toRadian(),
          false,
        )
        ..cubicTo(
          left,
          bottom - (bl.p - bl.a - bl.b),
          left,
          bottom - (bl.p - bl.a),
          left,
          top + math.max(height / 2, height - bl.p),
        )
        //top left
        ..lineTo(left, top + math.min(height / 2, tl.p))
        ..cubicTo(
          left,
          top + (tl.p - tl.a),
          left,
          top + (tl.p - tl.a - tl.b),
          left + tl.d,
          top + (tl.p - tl.a - tl.b - tl.c),
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(left + tl.radius, top + tl.radius), radius: tl.radius),
          (180 + tl.angleBezier).toRadian(),
          (90 - tl.angleBezier * 2).toRadian(),
          false,
        )
        ..cubicTo(left + (tl.p - tl.a - tl.b), top, left + (tl.p - tl.a), top, left + math.min(width / 2, tl.p), top)
        ..close();
    }
    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      getPath(borderRadius.resolve(textDirection).toRRect(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return;
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final path = getPath(borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width / 2));
        final paint = side.toPaint()..isAntiAlias = true;
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  ShapeBorder scale(double t) => SmoothRectangleBorders(borderRadius: borderRadius * t, side: side.scale(t));

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SmoothRectangleBorders) {
      return SmoothRectangleBorders(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
        smoothness: ui.lerpDouble(a.smoothness, smoothness, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SmoothRectangleBorders) {
      return SmoothRectangleBorders(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!,
        smoothness: ui.lerpDouble(smoothness, b.smoothness, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  SmoothRectangleBorders copyWith({BorderSide? side, BorderRadiusGeometry? borderRadius, double? smoothness}) =>
      SmoothRectangleBorders(
        borderRadius: borderRadius ?? this.borderRadius,
        side: side ?? this.side,
        smoothness: smoothness ?? this.smoothness,
      );

  @override
  int get hashCode => Object.hash(smoothness, borderRadius, side);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is SmoothRectangleBorders &&
        other.smoothness == smoothness &&
        other.borderRadius == borderRadius &&
        other.side == side;
  }
}

extension _Math on double {
  double toRadian() => this * math.pi / 180;
}

class _Corner {
  _Corner(RRect rrect, _CornerLocation location, double smoothness) {
    if (smoothness > 1) smoothness = 1;
    shortestSide = rrect.shortestSide;

    radius = _getRadius(rrect, location);

    p = math.min(shortestSide / 2, (1 + smoothness) * radius);

    if (radius > shortestSide / 4) {
      var changePercentage = (radius - shortestSide / 4) / (shortestSide / 4);
      angleCircle = 90 * (1 - smoothness * (1 - changePercentage));
      angleBezier = 45 * smoothness * (1 - changePercentage);
    } else {
      angleCircle = 90 * (1 - smoothness);
      angleBezier = 45 * smoothness;
    }

    var dToC = math.tan(angleBezier.toRadian());
    var longest = radius * math.tan(angleBezier.toRadian() / 2);
    var l = math.sin(angleCircle.toRadian() / 2) * radius * math.pow(2, 0.5);
    c = longest * math.cos(angleBezier.toRadian());
    d = c * dToC;
    b = ((p - l) - (1 + dToC) * c) / 3;
    a = 2 * b;
  }
  late double angleBezier;
  late double angleCircle;
  late double a;
  late double b;
  late double c;
  late double d;
  late double p;
  late double radius;
  late double shortestSide;

  double _getRadius(RRect rrect, _CornerLocation location) {
    double radiusX, radiusY;
    switch (location) {
      case _CornerLocation.tl:
        radiusX = rrect.tlRadiusX;
        radiusY = rrect.tlRadiusY;
        break;
      case _CornerLocation.tr:
        radiusX = rrect.trRadiusX;
        radiusY = rrect.trRadiusY;
        break;
      case _CornerLocation.bl:
        radiusX = rrect.blRadiusX;
        radiusY = rrect.blRadiusY;
        break;
      case _CornerLocation.br:
        radiusX = rrect.brRadiusX;
        radiusY = rrect.brRadiusY;
        break;
    }
    var radius = math.max<double>(0, math.min(radiusX, radiusY));
    return math.min(radius, shortestSide / 2);
  }
}

final class SmoothRectangleClipPath extends CustomClipper<Path> {
  const SmoothRectangleClipPath({required this.borderRadius, this.smoothness = .6});

  final BorderRadius borderRadius;

  /// The smoothness of corners.
  ///
  /// The concept comes from a feature called "corner smoothing" of Figma.
  ///
  /// 0.0 - 1.0
  final double smoothness;

  @override
  Path getClip(Size size) => SmoothRectangleBorders(smoothness: smoothness, borderRadius: borderRadius).getPath(
    RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    ),
  );

  @override
  bool shouldReclip(SmoothRectangleClipPath oldClipper) =>
      borderRadius != oldClipper.borderRadius || smoothness != oldClipper.smoothness;
}
