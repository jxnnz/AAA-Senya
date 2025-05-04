// Only compiled on web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

void registerVideoView(String viewId, String url) {
  ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
    final video =
        html.VideoElement()
          ..src = url
          ..autoplay = true
          ..loop = true
          ..muted = true
          ..style.border = 'none'
          ..style.height =
              '80px' // 👈 fix height
          ..style.width = '120px'; // 👈 fix width
    return video;
  });
}
