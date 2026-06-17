import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:logbook/logbook.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../extension/context_extension.dart';
import 'screen_util.dart';

sealed class Helpers {
  const Helpers._();

  static double getTextWidth({
    required BuildContext context,
    required String letter,
    required TextStyle style,
    double extraWidth = 8,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: letter, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    // extraWidth is the padding of the button
    return textPainter.width + extraWidth;
  }

  static LinearGradient get shimmerGradient => const LinearGradient(
    colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
    stops: [0.1, 0.3, 0.5],
    begin: Alignment(-1, -0.7),
    end: Alignment(1, 0.7),
    tileMode: .clamp,
  );

  static Future<({String path, double scale})?> getPlatformSpecificLogo() async {
    final logo = Assets.lib.images.logoPng;

    if (kIsWeb) {
      return (path: logo.path, scale: 1.0);
    }

    if (Platform.isIOS) {
      return (path: logo.path, scale: 360 / ScreenUtil.size().width);
    } else if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final version = int.tryParse(androidInfo.version.release) ?? 0;

      if (version <= 12) {
        return (path: logo.path, scale: .5);
      } else {
        return (path: logo.path, scale: 0.7);
      }
    }

    return (path: logo.path, scale: 1.0);
  }

  static void scrollToShowWidget({
    required BuildContext context,
    required ScrollController scrollController,
    double padding = 16.0,
    double extraPadding = 8.0,
  }) {
    final widgetBox = context.findRenderObject() as RenderBox?;
    if (widgetBox == null) return;

    final widgetSize = widgetBox.size;
    final widgetGlobalPosition = widgetBox.localToGlobal(Offset.zero);

    // Find the scrollable ancestor to get viewport bounds
    final scrollable =
        context.findAncestorRenderObjectOfType<RenderViewport>() ??
        context.findAncestorRenderObjectOfType<RenderSliverFixedExtentBoxAdaptor>();

    if (scrollable is RenderBox) {
      final scrollablePosition = scrollable.localToGlobal(Offset.zero);
      final scrollableSize = scrollable.size;

      final viewportLeft = scrollablePosition.dx + padding;
      final viewportRight = scrollablePosition.dx + scrollableSize.width - padding;
      final widgetLeft = widgetGlobalPosition.dx;
      final widgetRight = widgetGlobalPosition.dx + widgetSize.width;

      double scrollAdjustment = 0;

      if (widgetLeft < viewportLeft) {
        // Widget is cut off on the left
        scrollAdjustment = widgetLeft - viewportLeft - extraPadding;
      } else if (widgetRight > viewportRight) {
        // Widget is cut off on the right
        scrollAdjustment = widgetRight - viewportRight + extraPadding;
      }

      if (scrollAdjustment != 0) {
        scrollController.animateTo(
          scrollController.offset + scrollAdjustment,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      l.s('scrollable is not RenderBox: ${scrollable.runtimeType}');
    }
  }

  static CrossAxisAlignment getCrossAxisAlignment(BuildContext context, {required String text}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: context.x.textStyle.w400s16.copyWith(color: context.x.colors.onSurface, fontStyle: FontStyle.italic),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final lines = (textPainter.width / (context.x.width)).ceil();

    return lines >= 2 ? CrossAxisAlignment.start : CrossAxisAlignment.center;
  }

  static Future<void> launchUrl(String url) async {
    try {
      await url_launcher.launchUrl(Uri.parse(url));
    } on Object catch (error, stackTrace) {
      l.s(error, stackTrace);
    }
  }
}
