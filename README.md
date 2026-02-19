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
