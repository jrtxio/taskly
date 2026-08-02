#!/bin/bash
# 从 .app bundle 创建 .dmg，带重试（避开 GitHub Actions macOS runner 的 "Resource busy" 问题）。
# 用法: create-dmg.sh <app_path> <output_dmg> <volume_name>
set -e

APP_PATH="$1"
OUTPUT_DMG="$2"
VOL_NAME="${3:-Taskly}"

if [ -z "$APP_PATH" ] || [ -z "$OUTPUT_DMG" ]; then
    echo "Usage: create-dmg.sh <app_path> <output_dmg> [volume_name]"
    exit 1
fi

MAX_RETRIES=5
for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $i/$MAX_RETRIES: creating $OUTPUT_DMG"
    if hdiutil create \
        -volname "$VOL_NAME" \
        -srcfolder "$APP_PATH" \
        -fs HFS+ \
        -format UDZO \
        -imagekey zlib-level=9 \
        "$OUTPUT_DMG"; then
        echo "Success: $OUTPUT_DMG created"
        exit 0
    fi
    echo "Failed, retrying in 5s..."
    rm -f "$OUTPUT_DMG"
    sleep 5
done

echo "ERROR: Failed to create DMG after $MAX_RETRIES attempts"
exit 1
