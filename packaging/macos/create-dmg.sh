#!/bin/bash
# Create a decorated .dmg (background + /Applications link + icon layout)
# using node-appdmg, then hide the .background folder.
#
# Usage: create-dmg.sh <spec_json> <output_dmg>
set -u

SPEC="$1"
OUTPUT_DMG="$2"

if [ -z "$SPEC" ] || [ -z "$OUTPUT_DMG" ]; then
    echo "Usage: create-dmg.sh <spec_json> <output_dmg>"
    exit 1
fi

if ! command -v appdmg >/dev/null 2>&1; then
    echo "create-dmg.sh: appdmg not found. Install with: npm install -g appdmg"
    exit 1
fi

EJECT_TASKLY() {
    local dev
    dev=$(hdiutil info 2>/dev/null | awk '/^\/dev\/disk/{d=$1} /Taskly/{if(d)print d; d=""}' | head -1)
    if [ -n "$dev" ]; then
        echo "Ejecting stale mount: $dev"
        hdiutil detach "$dev" -force 2>/dev/null || true
        sleep 2
    fi
}

hide_background() {
    # Mount the DMG read-write, set invisible flag + move .background
    # icon off-screen, then convert back to compressed read-only.
    local rw_dmg="${OUTPUT_DMG%.dmg}-rw.dmg"
    local mnt
    mnt=$(mktemp -d /tmp/taskly-dmg-XXXX)

    if ! hdiutil convert -format UDRW -ov "$OUTPUT_DMG" -o "$rw_dmg" 2>/dev/null; then
        echo "Warning: UDRW convert failed, .background may be visible"
        rm -rf "$mnt"; return 0
    fi
    if ! hdiutil attach -readwrite -nobrowse -mountpoint "$mnt" "$rw_dmg" 2>/dev/null; then
        echo "Warning: RW mount failed, .background may be visible"
        rm -f "$rw_dmg"; rm -rf "$mnt"; return 0
    fi

    # 1) Invisible flag
    if [ -d "$mnt/.background" ]; then
        chflags hidden "$mnt/.background" 2>/dev/null || true
        command -v SetFile >/dev/null 2>&1 && SetFile -a V "$mnt/.background" 2>/dev/null || true
    fi

    # 2) Move .background icon off-screen via Python ds_store
    python3 "$SPEC_DIR/hide_dsstore.py" "$mnt/.DS_Store" 2>/dev/null || true

    sync
    hdiutil detach "$mnt" -force 2>/dev/null || true
    rm -f "$OUTPUT_DMG"
    hdiutil convert -format UDZO -ov "$rw_dmg" -o "$OUTPUT_DMG" 2>/dev/null
    rm -f "$rw_dmg"
    rm -rf "$mnt"
}

# Resolve the directory containing spec.json (for sibling scripts)
SPEC_DIR=$(cd "$(dirname "$SPEC")" && pwd)

MAX_RETRIES=5
for i in $(seq 1 "$MAX_RETRIES"); do
    echo "Attempt $i/$MAX_RETRIES: creating $OUTPUT_DMG via appdmg"
    EJECT_TASKLY
    if appdmg "$SPEC" "$OUTPUT_DMG" 2>&1; then
        echo "Success: $OUTPUT_DMG created"
        echo "Hiding .background folder..."
        hide_background
        EJECT_TASKLY
        exit 0
    fi
    echo "Failed, retrying in 5s..."
    rm -f "$OUTPUT_DMG"
    sleep 5
done

echo "ERROR: Failed to create DMG after $MAX_RETRIES attempts"
exit 1
