import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // The Live Activity bridge is app code, not a plugin, so it registers
    // its channel on the same engine right after the plugins.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveActivityBridge") {
      LiveActivityBridge.register(with: registrar.messenger())
    }
  }
}
