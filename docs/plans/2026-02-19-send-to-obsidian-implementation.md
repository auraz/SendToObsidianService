# SendToObsidianService Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a macOS 15+ service extension that captures selected text from any app and appends it to an Obsidian inbox file with timestamp and source info.

**Architecture:** Minimal macOS app with a Services extension. The app exists only for service registration. The extension handles text capture, formatting, and file writing. Optional Writing Tools integration for AI summaries.

**Tech Stack:** Swift 5.9+, AppKit, UserNotifications, Xcode 15+

---

### Task 1: Create Xcode Project

**Files:**
- Create: `SendToObsidianService/SendToObsidianService.xcodeproj`
- Create: `SendToObsidianService/SendToObsidian/AppDelegate.swift`

**Step 1: Create the Xcode project**

Run:
```bash
cd /Users/ok/Documents/02-areas/career/repos/1.Inprogress/ObsidianRightMouseMenu
mkdir -p SendToObsidianService
cd SendToObsidianService
```

Open Xcode and create new project:
- Template: macOS → App
- Product Name: `SendToObsidian`
- Organization Identifier: `com.yourname`
- Interface: AppKit (not SwiftUI)
- Language: Swift
- Uncheck: Create Git repository, Include Tests
- Save in: `SendToObsidianService/`

**Step 2: Configure minimal app**

Edit `SendToObsidian/AppDelegate.swift`:
```swift
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
```

**Step 3: Remove MainMenu.xib window**

In Xcode:
- Delete `MainMenu.xib` or set app to have no main window
- In Info.plist, set `LSUIElement` to `YES` (Application is agent)

**Step 4: Build and verify**

Run: `xcodebuild -project SendToObsidian.xcodeproj -scheme SendToObsidian build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
cd /Users/ok/Documents/02-areas/career/repos/1.Inprogress/ObsidianRightMouseMenu
git add SendToObsidianService/
git commit -m "feat: create minimal macOS app for service hosting"
```

---

### Task 2: Add Services Extension Target

**Files:**
- Create: `SendToObsidianService/SendToObsidianExtension/SendToObsidianExtension.swift`
- Create: `SendToObsidianService/SendToObsidianExtension/Info.plist`

**Step 1: Add extension target in Xcode**

In Xcode:
- File → New → Target
- macOS → Services Extension (if available) OR App Extension
- Product Name: `SendToObsidianExtension`
- Embed in: `SendToObsidian`

If Services Extension template not available, create manually:

**Step 2: Create extension principal class**

Create `SendToObsidianExtension/SendToObsidianExtension.swift`:
```swift
import Cocoa

class SendToObsidianExtension: NSObject {
    @objc func sendToObsidian(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pboard.string(forType: .string), !text.isEmpty else { return }
        // Placeholder - will implement in next tasks
        print("Received text: \(text)")
    }
}
```

**Step 3: Configure Info.plist for service**

Add to main app's Info.plist (NOT extension):
```xml
<key>NSServices</key>
<array>
    <dict>
        <key>NSMenuItem</key>
        <dict>
            <key>default</key>
            <string>Send to Obsidian</string>
        </dict>
        <key>NSMessage</key>
        <string>sendToObsidian</string>
        <key>NSPortName</key>
        <string>SendToObsidian</string>
        <key>NSSendTypes</key>
        <array>
            <string>NSStringPboardType</string>
        </array>
    </dict>
</array>
```

**Step 4: Register service provider in AppDelegate**

Edit `SendToObsidian/AppDelegate.swift`:
```swift
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let serviceProvider = SendToObsidianExtension()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NSApp.servicesProvider = serviceProvider
        NSUpdateDynamicServices()
    }
}
```

**Step 5: Build and verify**

Run: `xcodebuild -project SendToObsidan.xcodeproj -scheme SendToObsidian build`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add SendToObsidianService/
git commit -m "feat: add services extension with placeholder handler"
```

---

### Task 3: Implement Entry Formatting

**Files:**
- Create: `SendToObsidianService/SendToObsidian/EntryFormatter.swift`
- Create: `SendToObsidianService/SendToObsidianTests/EntryFormatterTests.swift`

**Step 1: Create test file**

Create `SendToObsidianTests/EntryFormatterTests.swift`:
```swift
import XCTest
@testable import SendToObsidian

final class EntryFormatterTests: XCTestCase {
    func testFormatEntryWithURL() {
        let formatter = EntryFormatter()
        let result = formatter.format(
            text: "Hello world",
            appName: "Safari",
            url: "https://example.com",
            date: Date(timeIntervalSince1970: 1771502400) // 2026-02-19 14:00 UTC
        )
        XCTAssertTrue(result.contains("| Safari | https://example.com"))
        XCTAssertTrue(result.contains("  Hello world"))
    }

    func testFormatEntryWithoutURL() {
        let formatter = EntryFormatter()
        let result = formatter.format(
            text: "Some note",
            appName: "Notes",
            url: nil,
            date: Date(timeIntervalSince1970: 1771502400)
        )
        XCTAssertTrue(result.contains("| Notes |"))
        XCTAssertFalse(result.contains("https://"))
        XCTAssertTrue(result.contains("  Some note"))
    }

    func testMultilineTextIndentation() {
        let formatter = EntryFormatter()
        let result = formatter.format(
            text: "Line 1\nLine 2\nLine 3",
            appName: "TextEdit",
            url: nil,
            date: Date(timeIntervalSince1970: 1771502400)
        )
        XCTAssertTrue(result.contains("  Line 1\n  Line 2\n  Line 3"))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project SendToObsidian.xcodeproj -scheme SendToObsidian -destination 'platform=macOS'`
Expected: FAIL with "cannot find 'EntryFormatter' in scope"

**Step 3: Implement EntryFormatter**

Create `SendToObsidian/EntryFormatter.swift`:
```swift
import Foundation

struct EntryFormatter {
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.timeZone = .current
        return df
    }()

    func format(text: String, appName: String, url: String?, date: Date = Date()) -> String {
        let timestamp = dateFormatter.string(from: date)
        let urlPart = url.map { " \($0)" } ?? ""
        let header = "- \(timestamp) | \(appName) |\(urlPart)"
        let indentedText = text.split(separator: "\n", omittingEmptySubsequences: false)
            .map { "  \($0)" }
            .joined(separator: "\n")
        return "\(header)\n\(indentedText)\n"
    }
}
```

**Step 4: Run tests to verify they pass**

Run: `xcodebuild test -project SendToObsidian.xcodeproj -scheme SendToObsidian -destination 'platform=macOS'`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add SendToObsidianService/
git commit -m "feat: add EntryFormatter with timestamp and indentation"
```

---

### Task 4: Implement File Writer

**Files:**
- Create: `SendToObsidianService/SendToObsidian/InboxWriter.swift`
- Create: `SendToObsidianService/SendToObsidanTests/InboxWriterTests.swift`

**Step 1: Create test file**

Create `SendToObsidanTests/InboxWriterTests.swift`:
```swift
import XCTest
@testable import SendToObsidian

final class InboxWriterTests: XCTestCase {
    var tempFile: URL!

    override func setUp() {
        tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("test-inbox-\(UUID()).md")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempFile)
    }

    func testAppendToNewFile() throws {
        let writer = InboxWriter(path: tempFile.path)
        try writer.append("First entry\n")
        let content = try String(contentsOf: tempFile)
        XCTAssertEqual(content, "First entry\n")
    }

    func testAppendToExistingFile() throws {
        try "Existing content\n".write(to: tempFile, atomically: true, encoding: .utf8)
        let writer = InboxWriter(path: tempFile.path)
        try writer.append("New entry\n")
        let content = try String(contentsOf: tempFile)
        XCTAssertEqual(content, "Existing content\n\nNew entry\n")
    }

    func testExpandTildePath() {
        let expanded = InboxWriter.expandPath("~/Documents/test.md")
        XCTAssertFalse(expanded.contains("~"))
        XCTAssertTrue(expanded.hasPrefix("/Users/"))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -project SendToObsidian.xcodeproj -scheme SendToObsidian -destination 'platform=macOS'`
Expected: FAIL with "cannot find 'InboxWriter' in scope"

**Step 3: Implement InboxWriter**

Create `SendToObsidian/InboxWriter.swift`:
```swift
import Foundation

struct InboxWriter {
    let path: String

    static func expandPath(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    func append(_ entry: String) throws {
        let expandedPath = Self.expandPath(path)
        let url = URL(fileURLWithPath: expandedPath)
        let directory = url.deletingLastPathComponent()

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        if FileManager.default.fileExists(atPath: expandedPath) {
            let handle = try FileHandle(forWritingTo: url)
            handle.seekToEndOfFile()
            handle.write("\n".data(using: .utf8)!)
            handle.write(entry.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try entry.write(toFile: expandedPath, atomically: true, encoding: .utf8)
        }
    }
}
```

**Step 4: Run tests to verify they pass**

Run: `xcodebuild test -project SendToObsidian.xcodeproj -scheme SendToObsidian -destination 'platform=macOS'`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add SendToObsidianService/
git commit -m "feat: add InboxWriter with path expansion and append"
```

---

### Task 5: Implement Source App Detection

**Files:**
- Modify: `SendToObsidianService/SendToObsidian/SendToObsidianExtension.swift`

**Step 1: Add source detection helper**

Edit `SendToObsidanExtension.swift`:
```swift
import Cocoa

enum Config {
    static let inboxPath = "~/Documents/Obsidian/Vault/Inbox.md"
    static let serviceName = "Send to Obsidian"
}

class SendToObsidianExtension: NSObject {
    private let formatter = EntryFormatter()
    private lazy var writer = InboxWriter(path: Config.inboxPath)

    @objc func sendToObsidian(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pboard.string(forType: .string), !text.isEmpty else { return }

        let appName = detectSourceApp()
        let url = detectURL(from: pboard)
        let entry = formatter.format(text: text, appName: appName, url: url)

        do {
            try writer.append(entry)
        } catch {
            showError("Failed to save — check inbox path")
        }
    }

    private func detectSourceApp() -> String {
        NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
    }

    private func detectURL(from pboard: NSPasteboard) -> String? {
        pboard.string(forType: .URL) ?? pboard.string(forType: NSPasteboard.PasteboardType("public.url"))
    }

    private func showError(_ message: String) {
        // Will implement in next task
        print("\(Config.serviceName): \(message)")
    }
}
```

**Step 2: Build and verify**

Run: `xcodebuild -project SendToObsidian.xcodeproj -scheme SendToObsidian build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add SendToObsidianService/
git commit -m "feat: integrate formatter and writer in service extension"
```

---

### Task 6: Implement Error Notifications

**Files:**
- Create: `SendToObsidianService/SendToObsidian/NotificationHelper.swift`
- Modify: `SendToObsidianService/SendToObsidian/SendToObsidianExtension.swift`

**Step 1: Create NotificationHelper**

Create `SendToObsidian/NotificationHelper.swift`:
```swift
import UserNotifications

struct NotificationHelper {
    static func showError(_ message: String, serviceName: String) {
        let content = UNMutableNotificationContent()
        content.title = serviceName
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
```

**Step 2: Update AppDelegate to request notification permission**

Edit `AppDelegate.swift`:
```swift
import Cocoa

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
```

**Step 3: Update extension to use NotificationHelper**

Edit `SendToObsidianExtension.swift`, replace `showError` method:
```swift
private func showError(_ message: String) {
    NotificationHelper.showError(message, serviceName: Config.serviceName)
}
```

**Step 4: Build and verify**

Run: `xcodebuild -project SendToObsidian.xcodeproj -scheme SendToObsidian build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add SendToObsidianService/
git commit -m "feat: add error notifications via UNUserNotificationCenter"
```

---

### Task 7: Add Writing Tools Integration (Optional)

**Files:**
- Modify: `SendToObsidianService/SendToObsidian/SendToObsidianExtension.swift`

**Step 1: Research Writing Tools API availability**

Check Apple documentation for programmatic Writing Tools access in macOS 15+. As of knowledge cutoff, Writing Tools API may not support silent/programmatic invocation.

**Step 2: Add conditional Writing Tools call (if API exists)**

If programmatic API exists, add to `SendToObsidianExtension.swift`:
```swift
private func attemptAISummary(for text: String) -> String? {
    // Check if Writing Tools can be invoked programmatically
    // If not available or requires UI, return nil
    // This is a placeholder - actual API may differ
    return nil
}
```

Update `sendToObsidian` method:
```swift
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
        showError("Failed to save — check inbox path")
    }
}
```

**Step 3: Build and verify**

Run: `xcodebuild -project SendToObsidian.xcodeproj -scheme SendToObsidian build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add SendToObsidianService/
git commit -m "feat: add placeholder for Writing Tools integration"
```

---

### Task 8: Manual Testing

**Files:**
- None (testing only)

**Step 1: Build and run app**

Run: `xcodebuild -project SendToObsidian.xcodeproj -scheme SendToObsidian build`
Then run the app from `~/Library/Developer/Xcode/DerivedData/SendToObsidian-*/Build/Products/Debug/SendToObsidian.app`

**Step 2: Refresh services**

Run: `/System/Library/CoreServices/pbs -update`
Log out and back in OR run: `killall -KILL SystemUIServer`

**Step 3: Test in Safari**

- Open Safari, select text on a page
- Right-click → Services → "Send to Obsidian"
- Check `~/Documents/Obsidian/Vault/Inbox.md` for entry with URL

**Step 4: Test in Notes**

- Open Notes, select text
- Right-click → Services → "Send to Obsidian"
- Check inbox for entry without URL

**Step 5: Test error case**

- Set `inboxPath` to a read-only location
- Capture text
- Expected: Error notification appears

**Step 6: Document results**

Record any issues found and create follow-up tasks if needed.

---

### Task 9: Update README

**Files:**
- Modify: `README.md`

**Step 1: Write README**

Create/update `README.md`:
```markdown
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
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with installation instructions"
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | Create Xcode project with minimal app |
| 2 | Add Services extension with placeholder handler |
| 3 | Implement EntryFormatter with TDD |
| 4 | Implement InboxWriter with TDD |
| 5 | Integrate formatter and writer in extension |
| 6 | Add error notifications |
| 7 | Add Writing Tools placeholder |
| 8 | Manual testing |
| 9 | Update README |

Total: 9 tasks, ~9 commits
