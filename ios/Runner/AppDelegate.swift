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
    @ObservedObject var tapModel: GlassTapModel

    @State private var pressed: Bool = false

    var body: some View {
        ZStack { Color.clear }
            .background(
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .fill(.clear)
                    .modifier(GlassEffectModifier(borderRadius: borderRadius, interactive: interactive))
            )
            .overlay(
                // 使用 SwiftUI 动画产生点击反馈（原生层实现）
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .stroke(.primary.opacity(pressed ? 0.25 : 0.0), lineWidth: 1)
                    .animation(.easeOut(duration: 0.18), value: pressed)
            )
            .onChange(of: tapModel.tapCounter) { _ in
                // 每次收到 Dart 同步的 tap，触发一次原生 SwiftUI 动画与可选触觉反馈
                pressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    pressed = false
                }
                if #available(iOS 13.0, *) {
                    let gen = UIImpactFeedbackGenerator(style: .light)
                    gen.impactOccurred()
                }
            }
            .clipped()
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
    private var channel: FlutterMethodChannel?
    @available(iOS 13.0, *)
    private var tapModel: GlassTapModel?

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.containerView = UIView(frame: frame)
        super.init()

        containerView.backgroundColor = .clear
        containerView.clipsToBounds = false

        var borderRadius: CGFloat = 20
        var interactive: Bool = true

        if let dict = args as? [String: Any] {
            if let br = dict["borderRadius"] as? NSNumber {
                borderRadius = CGFloat(truncating: br)
            } else if let brd = dict["borderRadius"] as? Double {
                borderRadius = CGFloat(brd)
            }
            if let inter = dict["interactive"] as? Bool {
                interactive = inter
            }
        }

        if #available(iOS 13.0, *) {
            if #available(iOS 26.0, *) {
                let model = GlassTapModel()
                self.tapModel = model
                let hosting = UIHostingController(rootView: LiquidGlassSwiftUIView(borderRadius: borderRadius, interactive: interactive, tapModel: model))
                hosting.view.backgroundColor = .clear
                hosting.view.frame = containerView.bounds
                hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                containerView.addSubview(hosting.view)
            } else {
                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                blur.frame = containerView.bounds
                blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blur.clipsToBounds = true
                blur.layer.cornerRadius = borderRadius
                containerView.addSubview(blur)
            }
        } else {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blur.frame = containerView.bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blur.clipsToBounds = true
            blur.layer.cornerRadius = borderRadius
            containerView.addSubview(blur)
        }

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)

        // 建立与 Dart 的 MethodChannel，用于接收 tap 事件
        let ch = FlutterMethodChannel(name: "GlassContainer/\(viewId)", binaryMessenger: messenger)
        self.channel = ch
        ch.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(FlutterError(code: "unavailable", message: "deallocated", details: nil)); return }
            switch call.method {
            case "tap":
                // 解析参数中的类型，默认为 liquid_glass
                var kind = "liquid_glass"
                if let args = call.arguments as? [String: Any], let t = args["type"] as? String {
                    kind = t
                }
                if kind == "liquid_glass" {
                    if #available(iOS 13.0, *) {
                        DispatchQueue.main.async {
                            self.tapModel?.tapCounter += 1
                        }
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "invalid_args", message: "Unsupported type: \(kind)", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView { containerView }
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
