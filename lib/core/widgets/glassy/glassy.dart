import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../ios/ios_liquid_glass.dart';

/// A lightweight wrapper to apply Liquid Glass effect around any widget.
///
/// Usage:
///   ElevatedButton(...).glassy(borderRadius: 12)
class Glassy extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final LiquidGlassSettings? settings;
  final EdgeInsetsGeometry? padding;

  const Glassy({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.settings,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final shape = LiquidRoundedSuperellipse(
      borderRadius: Radius.circular(borderRadius),
    );

    final content =
        padding != null ? Padding(padding: padding!, child: child) : child;

    return LiquidGlass(
      shape: shape,
      glassContainsChild: false,
      settings: settings ?? const LiquidGlassSettings(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }
}

extension GlassyX on Widget {
  Widget glassy({
    bool apply = true,
    bool glassContainsChild = false,
    double borderRadius = 12,
    LiquidGlassSettings? settings,
    EdgeInsetsGeometry? padding,
  }) {
    if (!apply) return this;

    // iOS 平台：改用原生 iosLiquidGlass，其他平台保持原有渲染器
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSLiquidGlassX(this).iosLiquidGlass(
        borderRadius: borderRadius,
        padding: padding,
      );
    }

    final shape = LiquidRoundedSuperellipse(
      borderRadius: Radius.circular(borderRadius),
    );

    final content = padding != null
        ? Padding(
            padding: padding,
            child: this,
          )
        : this;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LiquidGlass(
        shape: shape,
        glassContainsChild: glassContainsChild,
        settings: settings ?? const LiquidGlassSettings(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      ),
    );
  }

  Widget glassyOval({
    bool glassContainsChild = true,
    LiquidGlassSettings? settings,
    EdgeInsetsGeometry? padding,
  }) {
    final content = padding != null
        ? Padding(
            padding: padding,
            child: this,
          )
        : this;
    return LiquidGlass(
      shape: const LiquidOval(),
      glassContainsChild: glassContainsChild,
      settings: settings ?? const LiquidGlassSettings(),
      child: ClipOval(
        child: content,
      ),
    );
  }
}
