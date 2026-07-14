import 'package:flutter/material.dart';

import '../../../common/constant/config.dart';

/// A reusable image widget for displaying question or option images.
///
/// Resolves relative URLs against [Config.apiBaseUrl] and provides
/// proper border radius, error handling, and loading placeholders.
class QuestionImageWidget extends StatelessWidget {
  const QuestionImageWidget({
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  String get _resolvedUrl {
    if (imageUrl.startsWith('http')) return imageUrl;
    if (Config.apiBaseUrl.isEmpty) return imageUrl;

    final base = Config.apiBaseUrl.endsWith('/')
        ? Config.apiBaseUrl.substring(0, Config.apiBaseUrl.length - 1)
        : Config.apiBaseUrl;
    final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: Image.network(
      _resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    ),
  );
}
