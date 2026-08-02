#!/usr/bin/env python3
"""Move the .background folder icon position outside the DMG window area.

Finder's icon view shows entries listed in .DS_Store. Even with the
invisible flag set, some macOS versions still render .background if it
has an icon position within the window. This script relocates it to
(-2000, -2000) so it never appears in the visible 660×400 window.

Uses the 'ds_store' Python package (pip install ds_store).
Falls back silently if the package is unavailable.
"""
import sys

try:
    from ds_store import DSStore
except ImportError:
    sys.exit(0)

ds_path = sys.argv[1] if len(sys.argv) > 1 else ".DS_Store"

try:
    with DSStore.open(ds_path, "w+") as ds:
        if ".background" in ds:
            entry = ds[".background"]
            entry.x = -2000
            entry.y = -2000
            # DSStore context manager writes on close
    print(f"Moved .background icon to (-2000, -2000)")
except Exception as e:
    print(f"Skipping .DS_Store edit: {e}")
    sys.exit(0)
