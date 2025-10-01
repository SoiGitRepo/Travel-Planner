import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../glassy/glassy.dart';

class _IOSLiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final bool interactive;
  final Alignment alignment;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onNativeTap;
  final double outerMargin; // 传递给原生侧的透明外边距

  const _IOSLiquidGlassContainer({
    required this.child,
    required this.borderRadius,
    required this.interactive,
    required this.alignment,
    this.margin,
    this.padding,
    this.onNativeTap,
    this.outerMargin = 12,
  });

  @override
  State<_IOSLiquidGlassContainer> createState() =>
      _IOSLiquidGlassContainerState();
}

class _IOSLiquidGlassContainerState extends State<_IOSLiquidGlassContainer> {
  // 取消与原生的点击传播：无通道、无回调，仅各自处理自身点击。

  @override
  Widget build(BuildContext context) {
    final content = widget.padding != null
        ? Padding(padding: widget.padding!, child: widget.child)
        : widget.child;

    final stack = Stack(
      alignment: widget.alignment,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: UiKitView(
            viewType: 'GlassContainer',
            creationParams: {
              'borderRadius': widget.borderRadius,
              'interactive': widget.interactive,
              'outerMargin': widget.outerMargin,
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
        // 前景内容保持自身交互，不与原生互相传播
        content,
      ],
    );

    return widget.margin != null
        ? Container(margin: widget.margin, child: stack)
        : stack;
  }
}

extension IOSLiquidGlassX on Widget {
  Widget iosLiquidGlass({
    double borderRadius = 20,
    bool interactive = true,
    Alignment alignment = Alignment.center,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    VoidCallback? onNativeTap,
    double outerMargin = 12,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _IOSLiquidGlassContainer(
        borderRadius: borderRadius,
        interactive: interactive,
        alignment: alignment,
        margin: margin,
        padding: padding,
        onNativeTap: onNativeTap,
        outerMargin: outerMargin,
        child: this,
      );
    }

    // 非 iOS：使用现有 shader 方案回退
    return glassy(borderRadius: borderRadius, padding: padding);
  }
}
