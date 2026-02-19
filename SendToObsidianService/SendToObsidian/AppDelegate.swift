import Cocoa

/// Main application delegate for the SendToObsidian service app.
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider = SendToObsidianExtension()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NSApp.servicesProvider = serviceProvider
        NSUpdateDynamicServices()
        NotificationHelper.requestPermission()
    }
}
