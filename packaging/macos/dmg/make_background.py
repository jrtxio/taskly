#!/usr/bin/env python3
"""Generate DMG background images (1x + 2x retina) for the Taskly installer.

Produces background.png (660×400) and background@2x.png (1320×800) using the
Taskly warm palette (Pampas cream + Crail terracotta). The layout has:
  - app icon on the left (~x=190), Applications shortcut on the right (~x=470)
  - a subtle arrow between them inviting the user to drag
  - centered hint text at the bottom

Usage: python3 make_background.py [output_dir]
       (default output_dir: same directory as this script)
"""
import sys
import os

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Pillow is required: pip install pillow", file=sys.stderr)
    sys.exit(1)

# ---- Palette (matches RemindersColors.cs) ----
BG = (244, 243, 238)          # Pampas — warm cream
ARROW = (193, 95, 60, 90)     # Crail terracotta, semi-transparent
ARROW_SOLID = (193, 95, 60)   # Crail — for arrow head
TEXT_PRIMARY = (26, 23, 20)   # warm near-black
TEXT_HINT = (155, 148, 137)   # warm light gray

# ---- Layout (1x coordinates; retina doubles these) ----
W, H = 660, 400
ICON_Y = 190                   # vertical center of both icons
APP_X = 190                    # app icon center x
APPS_X = 470                   # Applications icon center x

# Arrow goes between the two icons (leave room for icon labels below)
ARROW_START = APP_X + 50
ARROW_END = APPS_X - 50


def _font(size, bold=False):
    """Try to load a system font; fall back to PIL default."""
    candidates = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSDisplay.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_background(scale=1):
    """Render the background at the given scale (1 or 2)."""
    w, h = W * scale, H * scale
    img = Image.new("RGBA", (w, h), BG + (255,))
    draw = ImageDraw.Draw(img)

    s = scale  # shorthand

    # --- Arrow (horizontal line + arrowhead) ---
    ay = int(ICON_Y * s)
    x1 = int(ARROW_START * s)
    x2 = int(ARROW_END * s)
    line_w = max(2, int(2 * s))

    # Semi-transparent line
    draw.line([(x1, ay), (x2 - int(12 * s), ay)], fill=ARROW, width=line_w)

    # Arrow head (solid triangle pointing right)
    hs = int(10 * s)  # head size
    draw.polygon(
        [(x2, ay), (x2 - hs, ay - hs), (x2 - hs, ay + hs)],
        fill=ARROW_SOLID,
    )

    # --- Hint text (centered at bottom) ---
    hint = "Drag Taskly to the Applications folder"
    font_hint = _font(int(13 * s))
    bbox = draw.textbbox((0, 0), hint, font=font_hint)
    tw = bbox[2] - bbox[0]
    tx = (w - tw) // 2
    ty = int((H - 40) * s)
    draw.text((tx, ty), hint, fill=TEXT_HINT, font=font_hint)

    # --- App name (top-left, subtle) ---
    name = "Taskly"
    font_name = _font(int(22 * s), bold=True)
    draw.text((int(40 * s), int(30 * s)), name, fill=TEXT_PRIMARY, font=font_name)

    return img


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(
        os.path.abspath(__file__)
    )
    os.makedirs(out_dir, exist_ok=True)

    # 1x
    img1 = draw_background(scale=1)
    p1 = os.path.join(out_dir, "background.png")
    img1.save(p1, "PNG")
    print(f"Generated {p1} ({img1.size})")

    # 2x retina
    img2 = draw_background(scale=2)
    p2 = os.path.join(out_dir, "background@2x.png")
    img2.save(p2, "PNG")
    print(f"Generated {p2} ({img2.size})")


if __name__ == "__main__":
    main()
