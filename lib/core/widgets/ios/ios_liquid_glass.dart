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
  // 动效参数：
  final double pressScale; // 按压缩放（默认 0.95）
  final double rippleMaxDiameter; // 波纹最大直径（默认 60）
  final double springResponse; // 弹簧响应时间
  final double springDampingFraction; // 弹簧阻尼
  // 阴影与背景参数：
  final Color? bgColor;
  final double bgOpacity; // 0..1
  final Color? shadowColor;
  final double shadowOpacity; // 0..1
  final double shadowRadius;
  final double shadowOffsetX;
  final double shadowOffsetY;

  const _IOSLiquidGlassContainer({
    required this.child,
    required this.borderRadius,
    required this.interactive,
    required this.alignment,
    this.margin,
    this.padding,
    this.onNativeTap,
    this.pressScale = 0.95,
    this.rippleMaxDiameter = 60,
    this.springResponse = 0.3,
    this.springDampingFraction = 0.6,
    this.bgColor,
    this.bgOpacity = 0.0,
    this.shadowColor,
    this.shadowOpacity = 0.15,
    this.shadowRadius = 10,
    this.shadowOffsetX = 0,
    this.shadowOffsetY = 4,
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
              'pressScale': widget.pressScale,
              'rippleMaxDiameter': widget.rippleMaxDiameter,
              'springResponse': widget.springResponse,
              'springDampingFraction': widget.springDampingFraction,
              if (widget.bgColor != null) 'bgColor': widget.bgColor!.value,
              'bgOpacity': widget.bgOpacity,
              if (widget.shadowColor != null) 'shadowColor': widget.shadowColor!.value,
              'shadowOpacity': widget.shadowOpacity,
              'shadowRadius': widget.shadowRadius,
              'shadowOffsetX': widget.shadowOffsetX,
              'shadowOffsetY': widget.shadowOffsetY,
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
    double pressScale = 0.95,
    double rippleMaxDiameter = 60,
    double springResponse = 0.3,
    double springDampingFraction = 0.6,
    Color? bgColor,
    double bgOpacity = 0.0,
    Color? shadowColor,
    double shadowOpacity = 0.15,
    double shadowRadius = 10,
    double shadowOffsetX = 0,
    double shadowOffsetY = 4,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _IOSLiquidGlassContainer(
        borderRadius: borderRadius,
        interactive: interactive,
        alignment: alignment,
        margin: margin,
        padding: padding,
        onNativeTap: onNativeTap,
        pressScale: pressScale,
        rippleMaxDiameter: rippleMaxDiameter,
        springResponse: springResponse,
        springDampingFraction: springDampingFraction,
        bgColor: bgColor,
        bgOpacity: bgOpacity,
        shadowColor: shadowColor,
        shadowOpacity: shadowOpacity,
        shadowRadius: shadowRadius,
        shadowOffsetX: shadowOffsetX,
        shadowOffsetY: shadowOffsetY,
        child: this,
      );
    }

    // 非 iOS：使用现有 shader 方案回退
    return glassy(borderRadius: borderRadius, padding: padding);
  }
}
