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

    @State private var isPressed: Bool = false

    var body: some View {
        ZStack { Color.clear }
            .background(
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .modifier(GlassEffectModifier(borderRadius: borderRadius, interactive: interactive))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .overlay(
                ZStack {
                    // 液体波纹效果（参考示例）
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: isPressed ? 60 : 0)
                        .scaleEffect(isPressed ? 1.5 : 0)
                        .opacity(isPressed ? 1 : 0)
                        .animation(.easeOut(duration: 0.4), value: isPressed)
                }
            )
            .onChange(of: tapModel.tapCounter) { _ in
                // 原生手势触发：使用弹簧动画带来液体般的反馈
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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
        var outerMargin: CGFloat = 12 // 透明外边距，避免动画被裁剪

        if let dict = args as? [String: Any] {
            if let br = dict["borderRadius"] as? NSNumber {
                borderRadius = CGFloat(truncating: br)
            } else if let brd = dict["borderRadius"] as? Double {
                borderRadius = CGFloat(brd)
            }
            if let inter = dict["interactive"] as? Bool {
                interactive = inter
            }
            if let m = dict["outerMargin"] as? NSNumber {
                outerMargin = max(0, CGFloat(truncating: m))
            } else if let md = dict["outerMargin"] as? Double {
                outerMargin = max(0, CGFloat(md))
            }
        }

        // 通过 layoutMargins 在容器内部留出透明外边距
        containerView.layoutMargins = UIEdgeInsets(top: outerMargin, left: outerMargin, bottom: outerMargin, right: outerMargin)
        containerView.preservesSuperviewLayoutMargins = false

        if #available(iOS 13.0, *) {
            if #available(iOS 26.0, *) {
                let model = GlassTapModel()
                self.tapModel = model
                let hosting = UIHostingController(rootView: LiquidGlassSwiftUIView(borderRadius: borderRadius, interactive: interactive, tapModel: model))
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
                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
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

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)

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
