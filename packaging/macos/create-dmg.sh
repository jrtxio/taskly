#!/bin/bash
# Create a decorated .dmg (background + /Applications link + icon layout)
# using node-appdmg, which writes the .DS_Store binary directly — no
# Finder/AppleScript needed, so it works reliably in headless CI.
#
# Usage: create-dmg.sh <spec_json> <output_dmg>
#   <spec_json>   — path to the appdmg spec JSON
#   <output_dmg>  — destination .dmg path
set -u

SPEC="$1"
OUTPUT_DMG="$2"

if [ -z "$SPEC" ] || [ -z "$OUTPUT_DMG" ]; then
    echo "Usage: create-dmg.sh <spec_json> <output_dmg>"
    exit 1
fi

# Ensure appdmg is available
if ! command -v appdmg >/dev/null 2>&1; then
    echo "create-dmg.sh: appdmg not found. Install with: npm install -g appdmg"
    exit 1
fi

# Force-eject any stale "Taskly" mounts that would cause "Resource busy".
EJECT_TASKLY() {
    local dev
    dev=$(hdiutil info 2>/dev/null | awk '/^\/dev\/disk/{d=$1} /Taskly/{if(d)print d; d=""}' | head -1)
    if [ -n "$dev" ]; then
        echo "Ejecting stale mount: $dev"
        hdiutil detach "$dev" -force 2>/dev/null || true
        sleep 2
    fi
}

MAX_RETRIES=5
for i in $(seq 1 "$MAX_RETRIES"); do
    echo "Attempt $i/$MAX_RETRIES: creating $OUTPUT_DMG via appdmg"
    EJECT_TASKLY
    if appdmg "$SPEC" "$OUTPUT_DMG" 2>&1; then
        echo "Success: $OUTPUT_DMG created"

        # Hide the .background folder inside the DMG image.
        # Mount read-write, set hidden flag, repack as compressed read-only.
        echo "Hiding .background folder..."
        RW_DMG="${OUTPUT_DMG%.dmg}-rw.dmg"
        MOUNT_POINT=$(mktemp -d /tmp/taskly-dmg-XXXX)
        if hdiutil convert -format UDRW -ov "$OUTPUT_DMG" -o "$RW_DMG" 2>/dev/null && \
           hdiutil attach -readwrite -nobrowse -mountpoint "$MOUNT_POINT" "$RW_DMG" 2>/dev/null; then
            # Set the hidden/invisible flag on .background
            if [ -d "$MOUNT_POINT/.background" ]; then
                chflags hidden "$MOUNT_POINT/.background" 2>/dev/null || true
                command -v SetFile >/dev/null 2>&1 && SetFile -a V "$MOUNT_POINT/.background" 2>/dev/null || true
            fi
            hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
            # Repack as compressed read-only DMG
            rm -f "$OUTPUT_DMG"
            hdiutil convert -format UDZO -ov "$RW_DMG" -o "$OUTPUT_DMG" 2>/dev/null
            rm -f "$RW_DMG"
        else
            echo "Warning: could not hide .background (non-fatal)"
        fi
        rm -rf "$MOUNT_POINT"
        EJECT_TASKLY
        exit 0
    fi
    echo "Failed, retrying in 5s..."
    rm -f "$OUTPUT_DMG"
    sleep 5
done

echo "ERROR: Failed to create DMG after $MAX_RETRIES attempts"
exit 1
