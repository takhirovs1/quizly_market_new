import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/constant/config.dart';

/// A reusable image widget for displaying question or option images.
///
/// - Resolves relative `photo_url` values against [Config.apiBaseUrl]
///   (bare filenames are served under `/uploads/`).
/// - Uses [BoxFit.contain] within a [maxHeight] cap so the full image is shown
///   without being cropped on either axis.
/// - Tapping opens a full-screen, zoomable preview (disable via [enablePreview]).
class QuestionImageWidget extends StatelessWidget {
  const QuestionImageWidget({
    required this.imageUrl,
    this.maxHeight = 260,
    this.borderRadius = 12,
    this.enablePreview = true,
    super.key,
  });

  final String imageUrl;

  /// Upper bound on the rendered height; the image scales to fit within the
  /// available width and this height, never cropping.
  final double maxHeight;
  final double borderRadius;

  /// Whether tapping the image opens the full-screen preview.
  final bool enablePreview;

  String get _resolvedUrl {
    final raw = imageUrl.trim();
    if (raw.isEmpty || raw.startsWith('http')) return raw;
    if (Config.apiBaseUrl.isEmpty) return raw;

    final base = Config.apiBaseUrl.endsWith('/')
        ? Config.apiBaseUrl.substring(0, Config.apiBaseUrl.length - 1)
        : Config.apiBaseUrl;

    // Already an absolute path (e.g. "/uploads/x.png") — keep as-is.
    if (raw.startsWith('/')) return '$base$raw';
    // Already namespaced (e.g. "uploads/x.png").
    if (raw.startsWith('uploads/')) return '$base/$raw';
    // Bare filename — question/option images are served under /uploads/.
    return '$base/uploads/$raw';
  }

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Image.network(
          _resolvedUrl,
          width: double.infinity,
          fit: BoxFit.contain, // never crops on either axis
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return AnimatedOpacity(opacity: 1, duration: const Duration(milliseconds: 200), child: child);
            }
            return _placeholder(context, const Center(child: CupertinoActivityIndicator()));
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder(context, const Center(child: CupertinoActivityIndicator()));
          },
          errorBuilder: (context, error, stackTrace) =>
              _placeholder(context, Icon(CupertinoIcons.photo, color: Theme.of(context).disabledColor, size: 28)),
        ),
      ),
    );

    if (!enablePreview) return image;

    return GestureDetector(
      onTap: () => _openPreview(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          image,
          // Small affordance hinting the image can be opened.
          Padding(
            padding: const EdgeInsets.all(6),
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(CupertinoIcons.arrow_up_left_arrow_down_right, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context) => Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: _ImagePreviewPage(url: _resolvedUrl),
      ),
    ),
  );

  Widget _placeholder(BuildContext context, Widget child) => Container(
    width: double.infinity,
    height: maxHeight.clamp(80, 200),
    alignment: Alignment.center,
    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
    child: child,
  );
}

/// Full-screen, pinch/zoom/pan preview. Tap outside the image or the close
/// button to dismiss.
class _ImagePreviewPage extends StatelessWidget {
  const _ImagePreviewPage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        // Tap anywhere outside the image to dismiss.
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).pop()),
        ),
        Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 5,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(CupertinoIcons.photo, color: Colors.white54, size: 64),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
