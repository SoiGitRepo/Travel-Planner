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
      // 按要求：在 iOS 上无论内容层级如何，触摸事件都传递给原生 Liquid Glass。
      // 使用 IgnorePointer 让 Flutter 前景内容不拦截指针事件，事件将命中下层 UiKitView。
      final nonInteractiveForeground = IgnorePointer(
        ignoring: true,
        child: content,
      );
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
          nonInteractiveForeground,
        ],
      );
      return margin != null ? Container(margin: margin, child: body) : body;
    }

    // 非 iOS：使用现有 shader 方案回退
    return glassy(borderRadius: borderRadius, padding: padding);
  }
}
