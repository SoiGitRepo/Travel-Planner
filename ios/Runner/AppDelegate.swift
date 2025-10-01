import Flutter
import UIKit
import GoogleMaps
import SwiftUI

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String, !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    }
    GeneratedPluginRegistrant.register(with: self)
    // Register iOS PlatformView: GlassContainer
    if let registrar = self.registrar(forPlugin: "GlassContainer") {
      let factory = GlassContainerFactory(messenger: registrar.messenger())
      registrar.register(factory, withId: "GlassContainer")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - Inline GlassContainer types (fallback if Xcode project doesn't include the file)

@available(iOS 13.0, *)
final class GlassTapModel: ObservableObject {
    @Published var tapCounter: Int = 0
}

@available(iOS 13.0, *)
private struct LiquidGlassSwiftUIView: View {
    let borderRadius: CGFloat
    let interactive: Bool
    // 动效参数（由 Flutter 传入）
    let pressScale: CGFloat
    let rippleMaxDiameter: CGFloat
    let springResponse: Double
    let springDampingFraction: Double
    // 背景着色（由 Flutter 传入，可选）
    let bgUIColor: UIColor?
    let bgOpacity: Double
    @ObservedObject var tapModel: GlassTapModel

    @State private var isPressed: Bool = false

    var body: some View {
        ZStack { Color.clear }
            .background(
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .modifier(GlassEffectModifier(borderRadius: borderRadius, interactive: interactive))
            )
            .overlay(
                Group {
                    if let tint = bgUIColor, bgOpacity > 0 {
                        RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                            .fill(Color(uiColor: tint).opacity(bgOpacity))
                    }
                }
            )
            .scaleEffect(isPressed ? pressScale : 1.0)
            .overlay(
                ZStack {
                    // 液体波纹效果（参考示例）
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: isPressed ? rippleMaxDiameter : 0)
                        .scaleEffect(isPressed ? 1.0 : 0)
                        .opacity(isPressed ? 1 : 0)
                        .animation(.easeOut(duration: 0.4), value: isPressed)
                }
            )
            .onChange(of: tapModel.tapCounter) { _ in
                // 原生手势触发：使用弹簧动画带来液体般的反馈
                withAnimation(.spring(response: springResponse, dampingFraction: springDampingFraction)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: springResponse, dampingFraction: springDampingFraction)) {
                        isPressed = false
                    }
                }
                let gen = UIImpactFeedbackGenerator(style: .light)
                gen.impactOccurred()
            }
    }
}

@available(iOS 13.0, *)
private struct GlassEffectModifier: ViewModifier {
    let borderRadius: CGFloat
    let interactive: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            return AnyView(
                content.glassEffect(
                    interactive ? .regular.interactive() : .regular,
                    in: RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                )
            )
        } else {
            return AnyView(
                content.background(
                    RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 0.7)
                        )
                )
            )
        }
    }
}

class GlassContainerPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    @available(iOS 13.0, *)
    private var tapModel: GlassTapModel?

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.containerView = UIView(frame: frame)
        super.init()

        containerView.backgroundColor = .clear
        containerView.clipsToBounds = false

        var borderRadius: CGFloat = 20
        var interactive: Bool = true
        // 动效参数（默认值应与 Flutter 端保持一致）
        var pressScale: CGFloat = 0.95
        var rippleMaxDiameter: CGFloat = 60
        var springResponse: Double = 0.3
        var springDampingFraction: Double = 0.6
        // 阴影与背景（默认值）
        var shadowColor: UIColor = UIColor.black
        var shadowOpacity: Float = 0.15
        var shadowRadius: CGFloat = 10
        var shadowOffset = CGSize(width: 0, height: 4)
        var bgColor: UIColor? = nil
        var bgOpacity: Double = 0.0

        if let dict = args as? [String: Any] {
            if let br = dict["borderRadius"] as? NSNumber {
                borderRadius = CGFloat(truncating: br)
            } else if let brd = dict["borderRadius"] as? Double {
                borderRadius = CGFloat(brd)
            }
            if let inter = dict["interactive"] as? Bool {
                interactive = inter
            }
            if let ps = dict["pressScale"] as? Double { pressScale = CGFloat(ps) }
            if let rd = dict["rippleMaxDiameter"] as? Double { rippleMaxDiameter = CGFloat(rd) }
            if let sr = dict["springResponse"] as? Double { springResponse = sr }
            if let sdf = dict["springDampingFraction"] as? Double { springDampingFraction = sdf }
            // 背景/阴影参数
            if let sc = dict["shadowColor"] as? NSNumber { shadowColor = GlassContainerPlatformView.colorFromARGBInt(sc.int64Value) }
            if let so = dict["shadowOpacity"] as? Double { shadowOpacity = Float(so) }
            if let sradius = dict["shadowRadius"] as? Double { shadowRadius = CGFloat(sradius) }
            if let sdx = dict["shadowOffsetX"] as? Double, let sdy = dict["shadowOffsetY"] as? Double {
                shadowOffset = CGSize(width: sdx, height: sdy)
            }
            if let bg = dict["bgColor"] as? NSNumber { bgColor = GlassContainerPlatformView.colorFromARGBInt(bg.int64Value) }
            if let bgo = dict["bgOpacity"] as? Double { bgOpacity = max(0.0, min(1.0, bgo)) }
        }

        // 根据动效参数动态计算所需外边距：
        // - 波纹最大半径会向外扩展 rippleMaxDiameter/2
        // - 阴影也会带来额外扩展（使用当前 shadowRadius）
        // - 额外 2pt 缓冲保障抗锯齿
        let shadowR: CGFloat = shadowRadius
        let rippleMargin: CGFloat = max(0, rippleMaxDiameter / 2)
        let buffer: CGFloat = 2
        var dynamicOuterMargin: CGFloat = interactive ? max(4, rippleMargin + shadowR + buffer) : 4
        // 依据容器初始尺寸限制外边距上限，避免内部空间被完全挤占
        let maxAllowedMargin = max(0, min(frame.size.width, frame.size.height) / 2 - 4)
        dynamicOuterMargin = min(dynamicOuterMargin, maxAllowedMargin)
        // 通过 layoutMargins 在容器内部留出透明外边距（尽量最小化浪费空间）
        containerView.layoutMargins = UIEdgeInsets(top: dynamicOuterMargin, left: dynamicOuterMargin, bottom: dynamicOuterMargin, right: dynamicOuterMargin)
        containerView.preservesSuperviewLayoutMargins = false

        if #available(iOS 13.0, *) {
            // if #available(iOS 26.0, *) {
            let model = GlassTapModel()
            self.tapModel = model
            let hosting = UIHostingController(
                rootView: LiquidGlassSwiftUIView(
                    borderRadius: borderRadius,
                    interactive: interactive,
                    pressScale: pressScale,
                    rippleMaxDiameter: rippleMaxDiameter,
                    springResponse: springResponse,
                    springDampingFraction: springDampingFraction,
                    bgUIColor: bgColor,
                    bgOpacity: bgOpacity,
                    tapModel: model
                )
            )
            hosting.view.backgroundColor = .clear
            hosting.view.clipsToBounds = false
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(hosting.view)
            NSLayoutConstraint.activate([
                hosting.view.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: containerView.layoutMarginsGuide.bottomAnchor)
            ])
        } else {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blur.translatesAutoresizingMaskIntoConstraints = false
            blur.clipsToBounds = true
            blur.layer.cornerRadius = borderRadius
            containerView.addSubview(blur)
            NSLayoutConstraint.activate([
                blur.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor),
                blur.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
                blur.bottomAnchor.constraint(equalTo: containerView.layoutMarginsGuide.bottomAnchor)
            ])
        }

        containerView.layer.shadowColor = shadowColor.cgColor
        containerView.layer.shadowOpacity = shadowOpacity
        containerView.layer.shadowRadius = shadowRadius
        containerView.layer.shadowOffset = shadowOffset

        // 原生侧点击：添加手势识别，触发原生反馈并回调 Flutter
        let nativeTap = UITapGestureRecognizer(target: self, action: #selector(handleNativeTap))
        containerView.addGestureRecognizer(nativeTap)
        containerView.isUserInteractionEnabled = true

        // 取消与 Flutter 的 MethodChannel 互通：不再建立通道与处理方法。
    }

    func view() -> UIView { containerView }

    @objc private func handleNativeTap() {
        // 原生触发：SwiftUI 动效 & 触觉
        if #available(iOS 13.0, *) {
            self.tapModel?.tapCounter += 1
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
        }
        // 不再回调 Flutter，原生侧只处理自身点击效果
    }
}

class GlassContainerFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol) {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        GlassContainerPlatformView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    }
}

// MARK: - Utilities
extension GlassContainerPlatformView {
    static func colorFromARGBInt(_ argb: Int64) -> UIColor {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
