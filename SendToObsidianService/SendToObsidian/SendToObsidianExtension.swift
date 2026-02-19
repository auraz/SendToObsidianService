import Cocoa

/// Configuration constants for the service.
enum Config {
    static let inboxPath = "~/Documents/Obsidian/Vault/Inbox.md"
    static let serviceName = "Send to Obsidian"
}

/// Service extension handler for receiving text via macOS Services menu.
class SendToObsidianExtension: NSObject {
    private let formatter = EntryFormatter()
    private lazy var writer = InboxWriter(path: Config.inboxPath)

    /// Handles text received from Services menu selection.
    @objc func sendToObsidian(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pboard.string(forType: .string), !text.isEmpty else { return }
        let appName = detectSourceApp()
        let url = detectURL(from: pboard)
        let entry = formatter.format(text: text, appName: appName, url: url)
        do {
            try writer.append(entry)
        } catch {
            showError("Failed to save - check inbox path")
        }
    }

    private func detectSourceApp() -> String {
        NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
    }

    private func detectURL(from pboard: NSPasteboard) -> String? {
        pboard.string(forType: .URL) ?? pboard.string(forType: NSPasteboard.PasteboardType("public.url"))
    }

    private func showError(_ message: String) {
        print("\(Config.serviceName): \(message)")
    }
}
