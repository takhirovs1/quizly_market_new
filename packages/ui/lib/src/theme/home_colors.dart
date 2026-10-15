import 'package:flutter/material.dart';

/// Home-screen design tokens (Figma "Tests" file, variable collection `c/*`).
///
/// Kept as a dedicated palette so Home widgets never hardcode hex. Selected by
/// brightness via `ThemeData.appHomeColors` / `context.x.homeColors`, mirroring
/// [ThemeColors]. Light values come straight from the Figma variables; dark
/// values are sensible equivalents (the Home redesign is specced light-only).
@immutable
final class HomeColors {
  const HomeColors({
    required this.primary,
    required this.primaryTint,
    required this.success,
    required this.successTint,
    required this.warning,
    required this.warningTint,
    required this.danger,
    required this.dangerTint,
    required this.purple,
    required this.purpleTint,
    required this.teal,
    required this.tealTint,
    required this.text,
    required this.text2,
    required this.text3,
    required this.surface,
    required this.surface2,
    required this.bg,
    required this.track,
    required this.border,
    required this.orangeAccent,
    required this.streakBg,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.cardShadow,
    required this.onAccent,
  });

  final Color primary;
  final Color primaryTint;
  final Color success;
  final Color successTint;
  final Color warning;
  final Color warningTint;
  final Color danger;
  final Color dangerTint;
  final Color purple;
  final Color purpleTint;
  final Color teal;
  final Color tealTint;
  final Color text;
  final Color text2;
  final Color text3;
  final Color surface;
  final Color surface2;
  final Color bg;
  final Color track;
  final Color border;
  final Color orangeAccent;
  final Color streakBg;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color cardShadow;

  /// White — text/icons on top of a saturated accent (buttons, hero, badges).
  final Color onAccent;

  /// Hero / today-bar gradient (top-left → bottom-right).
  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[heroGradientStart, heroGradientEnd],
  );

  BoxShadow get softShadow => BoxShadow(color: cardShadow, blurRadius: 8, offset: const Offset(0, 4));

  static const HomeColors light = HomeColors(
    primary: Color(0xFF007AFF),
    primaryTint: Color(0xFFEAF2FF),
    success: Color(0xFF34C759),
    successTint: Color(0xFFE8F8EC),
    warning: Color(0xFFFF9500),
    warningTint: Color(0xFFFFF3E0),
    danger: Color(0xFFFF3B30),
    dangerTint: Color(0xFFFFEDEC),
    purple: Color(0xFF7B5CFF),
    purpleTint: Color(0xFFF0ECFF),
    teal: Color(0xFF00B8D9),
    tealTint: Color(0xFFE3F8FC),
    text: Color(0xFF1C1C1E),
    text2: Color(0xFF3C3C43),
    text3: Color(0xFF8A8A8E),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF6F7FB),
    bg: Color(0xFFF2F3F7),
    track: Color(0xFFEEF0F5),
    border: Color(0xFFE5E5EA),
    orangeAccent: Color(0xFFFF7A00),
    streakBg: Color(0xFFFFF1E0),
    heroGradientStart: Color(0xFF0A84FF),
    heroGradientEnd: Color(0xFF5E5CE6),
    cardShadow: Color(0x0F121A40), // rgba(18,26,64,0.06)
    onAccent: Color(0xFFFFFFFF),
  );

  static const HomeColors dark = HomeColors(
    primary: Color(0xFF0A84FF),
    primaryTint: Color(0xFF16233A),
    success: Color(0xFF32D74B),
    successTint: Color(0xFF14321E),
    warning: Color(0xFFFF9F0A),
    warningTint: Color(0xFF33260E),
    danger: Color(0xFFFF453A),
    dangerTint: Color(0xFF3A1A18),
    purple: Color(0xFF8E7BFF),
    purpleTint: Color(0xFF221E3A),
    teal: Color(0xFF40C8E0),
    tealTint: Color(0xFF123038),
    text: Color(0xFFF8F9FA),
    text2: Color(0xFFC7C9CE),
    text3: Color(0xFF8A8A8E),
    surface: Color(0xFF161B27),
    surface2: Color(0xFF1E2533),
    bg: Color(0xFF0F1420),
    track: Color(0xFF243042),
    border: Color(0xFF2A3344),
    orangeAccent: Color(0xFFFF9A3D),
    streakBg: Color(0xFF2A1E10),
    heroGradientStart: Color(0xFF0A84FF),
    heroGradientEnd: Color(0xFF5E5CE6),
    cardShadow: Color(0x59000000), // rgba(0,0,0,0.35)
    onAccent: Color(0xFFFFFFFF),
  );
}
