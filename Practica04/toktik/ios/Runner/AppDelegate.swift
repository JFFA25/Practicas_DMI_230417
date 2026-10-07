import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    let channel = FlutterMethodChannel(
      name: "toktik/launcher_icon",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setLauncherIcon",
            let theme = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }

      let iconName: String?
      switch theme {
      case "halloween":
        iconName = "AppIconHalloween"
      case "christmas":
        iconName = "AppIconChristmas"
      case "valentinesDay":
        iconName = "AppIconValentines"
      default:
        iconName = nil
      }
      UIApplication.shared.setAlternateIconName(iconName) { error in
        if let error {
          result(FlutterError(
            code: "icon_change_failed",
            message: error.localizedDescription,
            details: nil
          ))
        } else {
          result(nil)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
