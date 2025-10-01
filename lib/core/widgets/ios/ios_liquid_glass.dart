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

  const _IOSLiquidGlassContainer({
    required this.child,
    required this.borderRadius,
    required this.interactive,
    required this.alignment,
    this.margin,
    this.padding,
  });

  @override
  State<_IOSLiquidGlassContainer> createState() => _IOSLiquidGlassContainerState();
}

class _IOSLiquidGlassContainerState extends State<_IOSLiquidGlassContainer> {
  MethodChannel? _channel;

  void _onPlatformViewCreated(int id) {
    setState(() {
      _channel = MethodChannel('GlassContainer/$id');
    });
  }

  Future<void> _forwardTap() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      await ch.invokeMethod('tap', {
        'type': 'liquid_glass',
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.padding != null
        ? Padding(padding: widget.padding!, child: widget.child)
        : widget.child;

    // 使用 Listener 捕获指针抬起，既不打断子树手势，又能同步上报到原生
    final mirroredTap = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: (_) => _forwardTap(),
      child: content,
    );

    final stack = Stack(
      alignment: widget.alignment,
      children: [
        Positioned.fill(
          child: UiKitView(
            viewType: 'GlassContainer',
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: {
              'borderRadius': widget.borderRadius,
              'interactive': widget.interactive,
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
        // 前景内容依旧可交互
        mirroredTap,
      ],
    );

    return widget.margin != null ? Container(margin: widget.margin, child: stack) : stack;
  }
}

extension IOSLiquidGlassX on Widget {
  Widget iosLiquidGlass({
    double borderRadius = 20,
    bool interactive = true,
    Alignment alignment = Alignment.center,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _IOSLiquidGlassContainer(
        borderRadius: borderRadius,
        interactive: interactive,
        alignment: alignment,
        margin: margin,
        padding: padding,
        child: this,
      );
    }

    // 非 iOS：使用现有 shader 方案回退
    return glassy(borderRadius: borderRadius, padding: padding);
  }
}
