# SendToObsidianService Design

macOS service extension that captures selected text to Obsidian inbox via right-click menu.

## Requirements

- macOS 15+ only
- Xcode 15+

## Architecture

```
SendToObsidianService/
├── SendToObsidianService.xcodeproj
├── SendToObsidian/               # Main app (minimal, for installation)
│   └── AppDelegate.swift
└── SendToObsidianExtension/      # Services extension
    ├── SendToObsidianExtension.swift
    └── Info.plist
```

**Flow:**
1. User installs app → Services extension registers with macOS
2. User selects text in any app → right-clicks → "Send to Obsidian"
3. Extension receives text via `NSPasteboard`
4. Detects source app via `NSWorkspace.shared.frontmostApplication`
5. Formats entry with timestamp + source + text
6. Appends to hardcoded inbox path
7. Attempts silent Writing Tools summarization; skips if not possible

The main app is minimal — exists only for service registration.

## Data Format

Each capture appended to Inbox.md:

```markdown
- 2026-02-19 14:30 | Safari | https://example.com
  Selected text goes here, preserving original formatting.

- 2026-02-19 14:35 | Notes |
  Another captured snippet without URL.
```

**Format rules:**
- Timestamp: `YYYY-MM-DD HH:mm` (24-hour, local timezone)
- Source: App name from `frontmostApplication.localizedName`
- URL: Included if source app provides it (Safari, Chrome); omitted otherwise
- Text: Indented under the header line, preserving whitespace
- Separator: Blank line between entries

**With AI summary (if Writing Tools works silently):**

```markdown
- 2026-02-19 14:30 | Safari | https://example.com
  Selected text goes here.

  > AI Summary: Brief summary of the content.
```

## Configuration

Hardcoded constants in `SendToObsidianExtension.swift`:

```swift
enum Config {
    static let inboxPath = "~/Documents/Obsidian/Vault/Inbox.md"
    static let dateFormat = "yyyy-MM-dd HH:mm"
    static let serviceName = "Send to Obsidian"
}
```

To change vault/inbox location: edit `inboxPath` and rebuild. If file doesn't exist, service creates it.

## Error Handling

| Error | Response |
|-------|----------|
| Inbox file path invalid | Notification: "Send to Obsidian: Failed to save — check inbox path" |
| No write permission | Notification: "Send to Obsidian: Cannot write to Inbox.md — check permissions" |
| No text selected | Do nothing (service won't be invoked) |
| Source app detection fails | Use "Unknown" as app name |
| URL detection fails | Omit URL field |
| Writing Tools unavailable | Skip AI summary silently |
| Writing Tools requires UI | Skip AI summary silently |

Notifications via `UNUserNotificationCenter` for errors only. Successful saves are silent.

## Testing

**Manual testing checklist:**
1. Select text in Safari → verify entry with URL
2. Select text in Notes → verify entry without URL
3. Select text in Terminal → verify timestamp and source
4. Test with non-existent inbox file → verify file creation
5. Test with read-only inbox file → verify error notification
6. Test Writing Tools summary behavior

**Unit tests:**
- `formatEntry()` — verify timestamp/source/text formatting
- `expandPath()` — verify `~` expansion
