import Flutter
import SwiftUI
import UIKit
import Joyfill
import JoyfillModel

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let registrar = self.registrar(forPlugin: "plugin-name") {
            registrar.register(FLNativeViewFactory(messenger: registrar.messenger()), withId: "JoyFill-FormView")
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

// MARK: - FLNativeViewFactory
class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(frame: frame, viewId: viewId)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - FLNativeView
class FLNativeView: NSObject, FlutterPlatformView {
    private let _view: UIView

    init(frame: CGRect, viewId: Int64) {
        self._view = UIView(frame: frame)
        super.init()
        setupNativeView()
    }

    func view() -> UIView { return _view }

    private func setupNativeView() {
        guard let topController = UIApplication.shared.windows.first?.rootViewController else { return }

        let formController = FormContainerViewController()
        let formView = formController.view!
        formView.translatesAutoresizingMaskIntoConstraints = false

        topController.addChild(formController)
        _view.addSubview(formView)

        NSLayoutConstraint.activate([
            formView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
            formView.topAnchor.constraint(equalTo: _view.topAnchor),
            formView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
        ])

        formController.didMove(toParent: topController)
    }
}
