#!/bin/bash
set -u

SETTINGS_FILE="${1:-$HOME/.warp/settings.toml}"
[ -f "$SETTINGS_FILE" ] || exit 0

python3 - "$SETTINGS_FILE" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
original = text

rules = [
    (r'(?m)^cloud_conversation_storage_enabled\s*=\s*(true|false)\s*$', 'cloud_conversation_storage_enabled = false'),
    (r'(?m)^should_force_disable_cloud_handoff\s*=\s*(true|false)\s*$', 'should_force_disable_cloud_handoff = true'),
    (r'(?m)^can_use_warp_credits_with_byok\s*=\s*(true|false)\s*$', 'can_use_warp_credits_with_byok = false'),
    (r'(?m)^is_settings_sync_enabled\s*=\s*(true|false)\s*$', 'is_settings_sync_enabled = false'),
]

for pattern, replacement in rules:
    text = re.sub(pattern, replacement, text)

if text != original:
    path.write_text(text)
PY
