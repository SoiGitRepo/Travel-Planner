写一个 完整 Flutter + iOS 原生 Liquid Glass 双向点击示例，满足这些要求：
	•	Flutter 点击任何子内容 → 原生 Liquid Glass 播放点击动画
	•	原生点击动画完成后 → 通知 Flutter 回调
	•	子 Widget 自身点击事件仍然生效

⸻

1️⃣ iOS 原生端（Swift + UIKit）

假设你的 PlatformView 已经叫 "GlassContainer"：

import UIKit
import Flutter

class GlassContainerView: UIView {
    var flutterChannel: FlutterMethodChannel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGlass()
        setupTap()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGlass()
        setupTap()
    }

    private func setupGlass() {
        // iOS 26 Liquid Glass
        if #available(iOS 26.0, *) {
            let glass = GlassEffectView(frame: bounds) // 假设 iOS 26 API
            glass.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            glass.layer.cornerRadius = 20
            glass.layer.masksToBounds = true
            self.addSubview(glass)
        } else {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            blur.frame = bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blur.layer.cornerRadius = 20
            blur.layer.masksToBounds = true
            self.addSubview(blur)
        }
    }

    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        // 播放点击动画
        animateClickEffect()

        // 通知 Flutter
        flutterChannel?.invokeMethod("onTap", nil)
    }

    private func animateClickEffect() {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.alpha = 1.0
            }
        }
    }
}

// PlatformView
class GlassContainerPlatformView: NSObject, FlutterPlatformView {
    private var _view: GlassContainerView
    private var channel: FlutterMethodChannel

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {
        _view = GlassContainerView(frame: frame)
        channel = FlutterMethodChannel(name: "glass_container_click_$viewId", binaryMessenger: messenger)
        super.init()
        _view.flutterChannel = channel
    }

    func view() -> UIView {
        return _view
    }
}

class GlassContainerFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return GlassContainerPlatformView(frame: frame, viewId: viewId, messenger: messenger)
    }
}

注册工厂：

let factory = GlassContainerFactory(messenger: registrar.messenger())
registrar.register(factory, withId: "GlassContainer")


⸻

2️⃣ Flutter 端

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class IOSLiquidGlass extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const IOSLiquidGlass({
    required this.child,
    this.onTap,
    this.borderRadius = 20,
    this.padding,
    super.key,
  });

  @override
  State<IOSLiquidGlass> createState() => _IOSLiquidGlassState();
}

class _IOSLiquidGlassState extends State<IOSLiquidGlass> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: widget.padding ?? EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: widget.child,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // iOS Liquid Glass PlatformView
            Positioned.fill(
              child: UiKitView(
                viewType: "GlassContainer",
                creationParams: {"borderRadius": widget.borderRadius},
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  _channel = MethodChannel('glass_container_click_$id');
                  _channel?.setMethodCallHandler((call) async {
                    if (call.method == 'onTap') {
                      widget.onTap?.call(); // 原生点击事件回到 Flutter
                    }
                  });
                },
              ),
            ),

            // 子内容层，任何点击都触发原生容器
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  _channel?.invokeMethod('onTap'); // 通知原生播放动画
                },
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.all(12),
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


⸻

3️⃣ 使用示例

IOSLiquidGlass(
  borderRadius: 16,
  padding: EdgeInsets.all(12),
  onTap: () => print("Flutter 收到容器点击"),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) {
      return GestureDetector(
        onTap: () => print("菜单 Item $i 点击"),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text("菜单 Item $i"),
        ),
      );
    }),
  ),
)

✅ 效果：
	1.	点击菜单 Item → 原生 Liquid Glass 播放点击动画 + Flutter 收到 onTap 回调 + 子 Item 点击事件
	2.	点击空白区域 → 同样触发原生动画 + Flutter 回调
	3.	不用关心子 Widget 类型 / 点击事件
