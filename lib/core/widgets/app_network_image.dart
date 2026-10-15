import 'dart:async';

import 'package:flutter/material.dart';

// Network image that shows a loader, retries failed downloads a few times,
// and falls back to a tap-to-retry placeholder instead of a broken image.
class AppNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int maxRetries;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.maxRetries = 3,
  });

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  int _attempt = 0;
  Timer? _retryTimer;

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _retryTimer?.cancel();
      _attempt = 0;
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  // Drops the failed image from the cache and rebuilds to download it again.
  void _retry() {
    _retryTimer?.cancel();
    NetworkImage(widget.url).evict();
    if (mounted) setState(() => _attempt++);
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive ?? false) return;
    _retryTimer = Timer(Duration(seconds: 1 << _attempt), _retry);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) return _placeholder(icon: Icons.image_outlined);

    return Image.network(
      widget.url,
      key: ValueKey('${widget.url}#$_attempt'),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (_attempt < widget.maxRetries) {
          _scheduleRetry();
          return _placeholder(
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return GestureDetector(
          onTap: _retry,
          child: _placeholder(icon: Icons.refresh),
        );
      },
    );
  }

  Widget _placeholder({IconData? icon, Widget? child}) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: child ?? Icon(icon, color: Colors.grey.shade400),
    );
  }
}
