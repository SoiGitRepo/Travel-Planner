import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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
    final shape = LiquidRoundedSuperellipse(
      borderRadius: Radius.circular(borderRadius),
    );

    final content = padding != null
        ? Padding(
            padding: padding,
            child: this,
          )
        : this;
    return apply
        ? ClipRRect(
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
          )
        : this;
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
      shape: LiquidOval(),
      glassContainsChild: glassContainsChild,
      settings: settings ?? const LiquidGlassSettings(),
      child: ClipOval(
        child: content,
      ),
    );
  }
}
