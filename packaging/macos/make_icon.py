#!/usr/bin/env python3
"""Generate the Taskly app icon (.icns) and a square PNG fallback.

The icon is a rounded-square with the Taskly warm palette (Crail terracotta)
and a white checkmark — evoking a calm task-completion feeling.

Produces:
  - icon_512.png  (high-res source, also used as Linux .desktop icon)
  - icon.icns     (macOS icon bundle, via iconutil)

Requirements: Pillow + macOS (iconutil is built-in).
Usage: python3 make_icon.py <output_dir>
"""
import sys
import os
import subprocess

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Pillow is required: pip install pillow", file=sys.stderr)
    sys.exit(1)

# ---- Palette ----
BG = (193, 95, 60)        # Crail terracotta (solid — clean, fast)
CHECK = (255, 255, 255)   # white checkmark


def draw_icon(size):
    """Draw the Taskly icon at the given pixel size."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Rounded-square background (macOS squircle style: ~22.5% radius)
    r = int(size * 0.225)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=BG + (255,))

    # White checkmark — bold, centered
    cx, cy = size // 2, size // 2
    s = size * 0.28   # checkmark scale
    lw = max(3, int(size * 0.08))  # line width

    # Checkmark path: three points (left, bottom-middle, right-top)
    p1 = (cx - s * 0.55, cy + s * 0.05)
    p2 = (cx - s * 0.15, cy + s * 0.45)
    p3 = (cx + s * 0.6, cy - s * 0.4)

    draw.line([p1, p2], fill=CHECK, width=lw, joint="curve")
    draw.line([p2, p3], fill=CHECK, width=lw, joint="curve")
    # Round the joints
    for p in (p1, p2, p3):
        draw.ellipse([p[0]-lw//2, p[1]-lw//2, p[0]+lw//2, p[1]+lw//2], fill=CHECK)

    return img


def make_icns(icon_1024_img, out_path):
    """Create a .icns file via iconutil (macOS only)."""
    iconset = out_path.replace(".icns", ".iconset")
    os.makedirs(iconset, exist_ok=True)

    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }

    for filename, px in sizes.items():
        icon_1024_img.resize((px, px), Image.LANCZOS).save(os.path.join(iconset, filename))

    subprocess.run(["iconutil", "-c", "icns", iconset, "-o", out_path], check=True)
    subprocess.run(["rm", "-rf", iconset], check=True)


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
    os.makedirs(out_dir, exist_ok=True)

    icon = draw_icon(1024)

    # PNG (used as Linux icon + favicon fallback)
    png_path = os.path.join(out_dir, "icon_512.png")
    icon.resize((512, 512), Image.LANCZOS).save(png_path)
    print(f"Generated {png_path}")

    # .icns (macOS)
    if sys.platform == "darwin":
        icns_path = os.path.join(out_dir, "icon.icns")
        make_icns(icon, icns_path)
        print(f"Generated {icns_path}")
    else:
        print("Skipping .icns (not macOS)")


if __name__ == "__main__":
    main()
