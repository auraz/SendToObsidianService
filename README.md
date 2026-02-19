# SendToObsidianService

macOS 15+ service to capture selected text to Obsidian inbox via right-click menu.

## Features

- Right-click any selected text → "Send to Obsidian"
- Adds timestamp and source app name
- Includes URL if captured from browser
- Silent operation (no UI interruption)

## Installation

1. Open `SendToObsidianService/SendToObsidian.xcodeproj` in Xcode
2. Edit `Config.inboxPath` in `SendToObsidianExtension.swift` to your vault path
3. Build and run (⌘R)
4. Move app to Applications folder
5. Log out and back in to refresh services

## Configuration

Edit `SendToObsidianExtension.swift`:
```swift
enum Config {
    static let inboxPath = "~/Documents/Obsidian/Vault/Inbox.md"
}
```

## Requirements

- macOS 15+
- Xcode 15+
