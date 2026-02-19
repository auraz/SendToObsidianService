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
