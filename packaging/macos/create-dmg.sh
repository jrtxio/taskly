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
# (Common on GitHub Actions macOS runners — Spotlight/indexing holds the volume.)
EJECT_DEV=$(hdiutil info 2>/dev/null | awk '/^\/dev\/disk/{dev=$1} /Taskly/{if(dev)print dev; dev=""}' | head -1)
if [ -n "$EJECT_DEV" ]; then
    echo "Ejecting stale mount: $EJECT_DEV"
    hdiutil detach "$EJECT_DEV" -force 2>/dev/null || true
    sleep 2
fi

MAX_RETRIES=5
for i in $(seq 1 "$MAX_RETRIES"); do
    echo "Attempt $i/$MAX_RETRIES: creating $OUTPUT_DMG via appdmg"
    if appdmg "$SPEC" "$OUTPUT_DMG" 2>&1; then
        echo "Success: $OUTPUT_DMG created"
        # Clean up any mount appdmg left behind
        EJECT_DEV=$(hdiutil info 2>/dev/null | awk '/^\/dev\/disk/{dev=$1} /Taskly/{if(dev)print dev; dev=""}' | head -1)
        [ -n "$EJECT_DEV" ] && hdiutil detach "$EJECT_DEV" -force 2>/dev/null || true
        exit 0
    fi
    echo "Failed, retrying in 5s..."
    rm -f "$OUTPUT_DMG"
    # Eject again before retry
    EJECT_DEV=$(hdiutil info 2>/dev/null | awk '/^\/dev\/disk/{dev=$1} /Taskly/{if(dev)print dev; dev=""}' | head -1)
    [ -n "$EJECT_DEV" ] && hdiutil detach "$EJECT_DEV" -force 2>/dev/null || true
    sleep 5
done

echo "ERROR: Failed to create DMG after $MAX_RETRIES attempts"
exit 1
