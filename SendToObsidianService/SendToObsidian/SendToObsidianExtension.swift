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
        var entry = formatter.format(text: text, appName: appName, url: url)
        if let summary = attemptAISummary(for: text) {
            entry += "\n  > AI Summary: \(summary)\n"
        }
        do {
            try writer.append(entry)
        } catch {
            showError("Failed to save - check inbox path")
        }
    }

    /// Placeholder for future Writing Tools (Apple Intelligence) integration.
    private func attemptAISummary(for text: String) -> String? {
        nil // Writing Tools API requires UI interaction on macOS 15, return nil to skip silently
    }

    private func detectSourceApp() -> String {
        NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
    }

    private func detectURL(from pboard: NSPasteboard) -> String? {
        pboard.string(forType: .URL) ?? pboard.string(forType: NSPasteboard.PasteboardType("public.url"))
    }

    private func showError(_ message: String) {
        NotificationHelper.showError(message, serviceName: Config.serviceName)
    }
}
