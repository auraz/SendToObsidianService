import UserNotifications

/// Helper for displaying user-facing error notifications.
struct NotificationHelper {
    /// Shows an error notification to the user.
    static func showError(_ message: String, serviceName: String) {
        let content = UNMutableNotificationContent()
        content.title = serviceName
        content.body = message
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    /// Requests notification permission from the user.
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
