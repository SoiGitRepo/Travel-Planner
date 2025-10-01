import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../glassy/glassy.dart';

extension IOSLiquidGlassX on Widget {
  Widget iosLiquidGlass({
    double borderRadius = 20,
    bool interactive = true,
    Alignment alignment = Alignment.center,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final content = padding != null ? Padding(padding: padding, child: this) : this;
      final body = Stack(
        alignment: alignment,
        children: [
          // iOS 原生 Liquid Glass 背景
          Positioned.fill(
            child: UiKitView(
              viewType: 'GlassContainer',
              creationParams: {
                'borderRadius': borderRadius,
                'interactive': interactive,
              },
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
          // 前景内容
          content,
        ],
      );
      return margin != null ? Container(margin: margin, child: body) : body;
    }

    // 非 iOS：使用现有 shader 方案回退
    return glassy(borderRadius: borderRadius, padding: padding);
  }
}
