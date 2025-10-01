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
private struct LiquidGlassSwiftUIView: View {
    let borderRadius: CGFloat
    let interactive: Bool

    var body: some View {
        ZStack { Color.clear }
            .background(
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .fill(.clear)
                    .modifier(GlassEffectModifier(borderRadius: borderRadius, interactive: interactive))
            )
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
                let hosting = UIHostingController(rootView: LiquidGlassSwiftUIView(borderRadius: borderRadius, interactive: interactive))
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
