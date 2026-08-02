#!/bin/bash
# Create a clean .dmg with /Applications link for drag-to-install.
# Uses node-appdmg, then removes the empty .background folder appdmg creates.
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

MAX_RETRIES=5
for i in $(seq 1 "$MAX_RETRIES"); do
    echo "Attempt $i/$MAX_RETRIES: creating $OUTPUT_DMG via appdmg"
    EJECT_TASKLY
    if appdmg "$SPEC" "$OUTPUT_DMG" 2>&1; then
        echo "Success: $OUTPUT_DMG created"

        # appdmg always creates an empty .background folder even when no
        # background image is specified. Remove it so users never see it.
        echo "Removing empty .background folder..."
        RW_DMG="${OUTPUT_DMG%.dmg}-rw.dmg"
        MOUNT_POINT=$(mktemp -d /tmp/taskly-dmg-XXXX)

        if hdiutil convert -format UDRW -ov "$OUTPUT_DMG" -o "$RW_DMG" 2>/dev/null && \
           hdiutil attach -readwrite -nobrowse -mountpoint "$MOUNT_POINT" "$RW_DMG" 2>/dev/null; then
            rm -rf "$MOUNT_POINT/.background" 2>/dev/null || true
            sync
            hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
            rm -f "$OUTPUT_DMG"
            hdiutil convert -format UDZO -ov "$RW_DMG" -o "$OUTPUT_DMG" 2>/dev/null
            rm -f "$RW_DMG"
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
