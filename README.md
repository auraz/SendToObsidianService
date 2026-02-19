# SendToObsidianService

Capture selected text to Obsidian inbox via macOS Services menu or Share Sheet.

## Features

- Right-click selected text → Services → "Send to Obsidian"
- Share button → "Send to Obsidian"
- Adds timestamp and source app name
- Includes URL from clipboard if present
- Optional AI summary via Apple Intelligence
- Shows notification on success

## Installation

### 1. Install the script

```bash
mkdir -p ~/bin
curl -o ~/bin/send-to-obsidian.sh https://raw.githubusercontent.com/.../send-to-obsidian.sh
chmod +x ~/bin/send-to-obsidian.sh
```

Or create `~/bin/send-to-obsidian.sh` manually:

```bash
#!/bin/bash
# Usage: send-to-obsidian.sh "text" [app_name] [ai_summary]

INBOX_FILE="$HOME/repos/ExpressionVault/Inbox/Inbox.md"

TEXT="${1:-$(cat)}"
[ -z "$TEXT" ] && exit 0
APP_NAME="${2:-$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null || echo "Unknown")}"
AI_SUMMARY="$3"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
CLIPBOARD=$(pbpaste 2>/dev/null)
URL="" && [[ "$CLIPBOARD" =~ ^https?:// ]] && URL=" $CLIPBOARD"

{
    echo "- $TIMESTAMP | $APP_NAME |$URL"
    [ -n "$AI_SUMMARY" ] && echo "  > $AI_SUMMARY"
    echo "$TEXT" | sed 's/^/  /'
    echo ""
} >> "$INBOX_FILE"

osascript -e 'display notification "Saved to Obsidian inbox" with title "Send to Obsidian"' 2>/dev/null
```

### 2. Create the Shortcut

1. Open **Shortcuts.app** → create new shortcut
2. Add action: **Summarize** (Apple Intelligence)
   - Input: Shortcut Input
   - Store result in variable: `Summary`
3. Add action: **Run Shell Script**
   - Script: `~/bin/send-to-obsidian.sh "$@" "" "$1"`
   - Input: Shortcut Input
   - Pass Input: as arguments
   - Add `Summary` variable as second argument after the script
4. Click shortcut settings (ⓘ):
   - Enable **Services Menu**
   - Enable **Share Sheet**
   - Receives: **Text**
5. Name: `Send to Obsidian`

### Without AI Summary

Skip the Summarize action and use:
```
~/bin/send-to-obsidian.sh "$@"
```

## Configuration

Edit `INBOX_FILE` in `~/bin/send-to-obsidian.sh`:

```bash
INBOX_FILE="$HOME/path/to/your/Inbox.md"
```

## Usage

- Select text → right-click → **Services** → **Send to Obsidian**
- Select text → **Share** → **Send to Obsidian**

## Output Format

```markdown
- 2024-01-15 14:30 | Safari | https://example.com
  > AI-generated summary of the content appears here
  Selected text appears here
  with preserved line breaks
```

## Requirements

- macOS 15+
- Shortcuts.app
- Apple Intelligence (for summarization)
