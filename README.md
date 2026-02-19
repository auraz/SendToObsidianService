# SendToObsidianService

Capture selected text to Obsidian inbox via macOS Services menu or Share Sheet.

## Features

- Right-click selected text → Services → "Send to Obsidian"
- Share button → "Send to Obsidian"
- Adds timestamp
- Shows notification on success

## Installation

### 1. Install the script

```bash
mkdir -p ~/bin && cat > ~/bin/send-to-obsidian.sh << 'EOF'
#!/bin/bash
INBOX_FILE="$HOME/repos/ExpressionVault/Inbox/Inbox.md"

TEXT="${1:-$(cat)}"
[ -z "$TEXT" ] && exit 0

{
    echo "- $(date '+%Y-%m-%d %H:%M')"
    echo "$TEXT" | sed 's/^/  /'
    echo ""
} >>"$INBOX_FILE"

osascript -e 'display notification "Saved to Obsidian inbox" with title "Send to Obsidian"' 2>/dev/null
EOF
chmod +x ~/bin/send-to-obsidian.sh
```

### 2. Create the Shortcut

1. Open **Shortcuts.app** → create new shortcut
2. Add action: **Run Shell Script**
   - Script: `~/bin/send-to-obsidian.sh "$@"`
   - Input: Shortcut Input
   - Pass Input: as arguments
3. Click shortcut settings (ⓘ):
   - Enable **Services Menu**
   - Enable **Share Sheet**
   - Receives: **Text**
4. Name: `Send to Obsidian`

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
- 2024-01-15 14:30
  Selected text appears here
  with preserved line breaks
```

## Requirements

- macOS 15+
- Shortcuts.app
