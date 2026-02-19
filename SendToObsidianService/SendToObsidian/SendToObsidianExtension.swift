import Cocoa

/// Service extension handler for receiving text via macOS Services menu.
class SendToObsidianExtension: NSObject {
    /// Handles text received from Services menu selection.
    @objc func sendToObsidian(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pboard.string(forType: .string), !text.isEmpty else { return }
        print("Received text: \(text)")
    }
}
