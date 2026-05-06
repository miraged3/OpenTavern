import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      super.applicationDidFinishLaunching(notification)
      return
    }
    let channel = FlutterMethodChannel(
      name: "open_tavern/external_url",
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "openUrl" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let urlString = call.arguments as? String,
        let url = URL(string: urlString)
      else {
        result(false)
        return
      }
      result(NSWorkspace.shared.open(url))
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
