import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIconFactory {
  static final Map<String, Future<BitmapDescriptor>> _cache = {};

  // 生成圆形底的图标位图：背景色+Material Icon
  static Future<BitmapDescriptor> create({
    required IconData icon,
    Color background = Colors.indigo,
    Color foreground = Colors.white,
    double size = 36, // 像素
  }) async {
    final key =
        '${icon.codePoint}_${background.toARGB32()}_${foreground.toARGB32()}_${size.toInt()}';
    final cached = _cache[key];
    if (cached != null) return cached;
    final fut = _draw(
        icon: icon, background: background, foreground: foreground, size: size);
    _cache[key] = fut;
    return fut;
  }

  static Future<BitmapDescriptor> _draw({
    required IconData icon,
    required Color background,
    required Color foreground,
    required double size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = background;

    // 画圆背景
    final radius = size / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // 绘制图标（使用 TextPainter 渲染 IconData 字形）
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconSize = size * 0.54; // 留白略多，让图标更精致
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: foreground,
      ),
    );
    textPainter.layout();
    final dx = (size - textPainter.width) / 2;
    final dy = (size - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(dx, dy));

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }
}
