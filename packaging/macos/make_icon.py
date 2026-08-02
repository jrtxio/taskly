#!/usr/bin/env python3
"""Generate all Taskly icons from the single SVG source (assets/taskly.svg).

Produces:
  - icon.icns          (macOS app icon bundle)
  - icon_512.png       (512px PNG, used as Linux icon + favicon source)
  - favicon.ico        (multi-size .ico for the website)
  - taskly.png         (256px PNG for Linux .desktop / AppImage)

Uses cairosvg for SVG→PNG rasterization (pip install cairosvg Pillow).
Falls back to Pillow-native drawing if cairosvg is unavailable.

Usage: python3 make_icon.py <output_dir> [--source path/to/taskly.svg]
"""
import sys
import os
import subprocess
import argparse

try:
    from PIL import Image
except ImportError:
    print("Pillow is required: pip install pillow", file=sys.stderr)
    sys.exit(1)

# ---- Palette (fallback drawing, matches SVG) ----
BG = (193, 95, 60)
CHECK = (255, 255, 255)


def _svg_to_png(svg_path, size):
    """Rasterize SVG to PNG at the given size. Returns PIL Image."""
    try:
        import cairosvg
        import io
        png_bytes = cairosvg.svg2png(url=svg_path, output_width=size, output_height=size)
        return Image.open(io.BytesIO(png_bytes)).convert("RGBA")
    except Exception:
        # cairosvg or its native cairo library unavailable — use Pillow fallback
        return _draw_icon(size)


def _draw_icon(size):
    """Fallback: draw the icon with Pillow if cairosvg is unavailable."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    from PIL import ImageDraw
    draw = ImageDraw.Draw(img)
    r = int(size * 0.225)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=BG + (255,))
    cx, cy = size // 2, size // 2
    s = size * 0.28
    lw = max(3, int(size * 0.08))
    p1 = (cx - s * 0.55, cy + s * 0.05)
    p2 = (cx - s * 0.15, cy + s * 0.45)
    p3 = (cx + s * 0.6, cy - s * 0.4)
    draw.line([p1, p2], fill=CHECK, width=lw, joint="curve")
    draw.line([p2, p3], fill=CHECK, width=lw, joint="curve")
    for p in (p1, p2, p3):
        draw.ellipse([p[0]-lw//2, p[1]-lw//2, p[0]+lw//2, p[1]+lw//2], fill=CHECK)
    return img


def make_icns(source_img, out_path):
    """Create a .icns file via iconutil (macOS only)."""
    iconset = out_path.replace(".icns", ".iconset")
    os.makedirs(iconset, exist_ok=True)
    sizes = {
        "icon_16x16.png": 16, "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32, "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128, "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256, "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512, "icon_512x512@2x.png": 1024,
    }
    for filename, px in sizes.items():
        source_img.resize((px, px), Image.LANCZOS).save(os.path.join(iconset, filename))
    subprocess.run(["iconutil", "-c", "icns", iconset, "-o", out_path], check=True)
    subprocess.run(["rm", "-rf", iconset], check=True)


def make_ico(source_img, out_path):
    """Create a multi-size .ico (16, 32, 48, 64, 128, 256)."""
    sizes = [16, 32, 48, 64, 128, 256]
    source_img.save(out_path, format="ICO", sizes=[(s, s) for s in sizes])


def main():
    parser = argparse.ArgumentParser(description="Generate Taskly icons from SVG")
    parser.add_argument("output_dir", help="Directory for generated files")
    parser.add_argument("--source", default=None, help="Path to taskly.svg")
    args = parser.parse_args()

    out_dir = args.output_dir
    os.makedirs(out_dir, exist_ok=True)

    # Find SVG source
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))
    svg_path = args.source or os.path.join(project_root, "assets", "taskly.svg")

    # Rasterize at high resolution (1024px master)
    print(f"Source: {svg_path}")
    master = _svg_to_png(svg_path, 1024)
    print(f"Master image: {master.size}")

    # icon_512.png
    icon_512 = master.resize((512, 512), Image.LANCZOS)
    p = os.path.join(out_dir, "icon_512.png")
    icon_512.save(p)
    print(f"Generated {p}")

    # taskly.png (256px, for Linux)
    icon_256 = master.resize((256, 256), Image.LANCZOS)
    p = os.path.join(out_dir, "taskly.png")
    icon_256.save(p)
    print(f"Generated {p}")

    # favicon.ico
    p = os.path.join(out_dir, "favicon.ico")
    make_ico(master, p)
    print(f"Generated {p}")

    # icon.icns (macOS only)
    if sys.platform == "darwin":
        p = os.path.join(out_dir, "icon.icns")
        make_icns(master, p)
        print(f"Generated {p}")
    else:
        print("Skipping .icns (not macOS)")


if __name__ == "__main__":
    main()
