# ObsidianRightMouseMenu

macOS Services extension that captures selected text and saves it to Obsidian.

## Project Structure

- `SendToObsidianService/` - Xcode project for the macOS service app
  - `project.yml` - xcodegen specification
  - `SendToObsidian/` - Main app source
  - `SendToObsidianTests/` - Unit tests

## Requirements

- macOS 15.0+
- Xcode 16.0+
- Swift 5.9+

## Build

```bash
cd SendToObsidianService
xcodegen generate
xcodebuild -project SendToObsidian.xcodeproj -scheme SendToObsidian build
```

## Architecture

The app runs as an accessory (LSUIElement=YES) with no dock icon or menu bar presence. It exists solely to host the macOS Services extension.

### Services Integration

The app registers as a macOS Services provider, appearing in right-click context menus under "Services > Send to Obsidian" when text is selected. The service accepts NSStringPboardType and processes text via SendToObsidianExtension.

### Config

Hardcoded settings for inbox path and service name:
```swift
enum Config {
    static let inboxPath = "~/Documents/Obsidian/Vault/Inbox.md"
    static let serviceName = "Send to Obsidian"
}
```

### Integration Flow

1. User selects text and triggers "Send to Obsidian" from Services menu
2. SendToObsidianExtension receives text via NSPasteboard
3. Detects source app name and URL from pasteboard
4. EntryFormatter creates markdown entry with timestamp and metadata
5. InboxWriter appends entry to inbox file
6. On error, NotificationHelper displays user-facing notification

### Error Notifications

Uses UNUserNotificationCenter to display errors to users. Permission is requested on app launch. Errors appear as system notifications with the service name as title.

### EntryFormatter

Formats captured text into markdown entries with timestamp, source app, and optional URL:
```
- 2026-02-19 14:30 | Safari | https://example.com
  Selected text here
```
