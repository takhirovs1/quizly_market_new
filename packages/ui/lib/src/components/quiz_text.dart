import 'package:flutter/material.dart';

import '../gen/fonts.gen.dart';

/// SF Pro text style matching the Figma type ramp.
/// Centralizes the font family so no component hardcodes it.
TextStyle quizText(double size, FontWeight weight, Color color, {double? height, double? letterSpacing}) => TextStyle(
  fontFamily: FontFamily.sFProDisplay,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

// Figma weight map (Regular 400, Medium 510, Semibold 590, Bold 700, Heavy 860).
const FontWeight wRegular = FontWeight.w400;
const FontWeight wMedium = FontWeight.w500;
const FontWeight wSemibold = FontWeight.w600;
const FontWeight wBold = FontWeight.w700;
const FontWeight wHeavy = FontWeight.w800;
