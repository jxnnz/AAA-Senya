import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'web_video_view_registry.dart'
    if (dart.library.html) 'web_video_view_registry.dart'
    if (dart.library.io) 'stub_video_view_registry.dart';

class VideoCell extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const VideoCell({
    super.key,
    required this.url,
    this.width = 120,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final viewId = 'video-${DateTime.now().millisecondsSinceEpoch}';
      registerVideoView(viewId, url);

      return SizedBox(
        width: width,
        height: height,
        child: HtmlElementView(viewType: viewId),
      );
    }

    return const Text('Video preview not supported on this platform.');
  }
}
