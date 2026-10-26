#!/usr/bin/env bash
# Render the README images from the current design file. Needs openscad, xvfb-run and
# ImageMagick (convert). Run from anywhere: paths are relative to the repository root.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCAD="$ROOT/src/cycloidal_gearbox.scad"
PARAMS="$ROOT/src/cycloidal_gearbox.json"
PRESET="${PRESET:-NEMA17 Commodity R15}"
OUT="$ROOT/docs/images"
mkdir -p "$OUT"
render() { # name, extra openscad args...
    local name=$1; shift
    xvfb-run -a openscad -q -o "$OUT/$name.png" --imgsize=1600,1200 --viewall --autocenter \
        -p "$PARAMS" -P "$PRESET" "$@" "$SCAD"
    echo "rendered $name.png"
}
render assembly               -D 'part="assembly"'
render exploded               -D 'part="exploded"'
render input_stack            -D 'part="input_stack"'
render layout_3d              -D 'part="layout_3d"'
# A -P preset overrides -D for every key it contains (input_shaft_mode included), so the
# coupled variant is rendered from the file defaults, which equal the commodity preset.
xvfb-run -a openscad -q -o "$OUT/coupled_input_stack.png" --imgsize=1600,1200 --viewall --autocenter \
    -D 'part="input_stack"' -D 'input_shaft_mode="Machined coupled shaft"' -D 'coupled_eccentric_mode="Separate eccentric sleeves"' "$SCAD"
echo "rendered coupled_input_stack.png"
render case_rooted_lobes_top  -D 'part="case_ring"' -D 'simplification_level="Integrated case lobes"' --projection=o --camera=0,0,0,0,0,0,180
render simplified_lobes_assembly -D 'part="assembly"' -D 'simplification_level="Integrated case lobes"'

if command -v convert >/dev/null; then
    TMP="$(mktemp -d)"
    # One process per frame: OpenSCAD's --animate aborts with an X "BadRequest" error under
    # the GitHub runner's Xvfb, while single-frame renders are fine.
    FRAMES=24
    for i in $(seq 0 $((FRAMES-1))); do
        xvfb-run -a openscad -q -o "$(printf '%s/frame%03d.png' "$TMP" "$i")" --imgsize=800,640 --viewall --autocenter \
            -p "$PARAMS" -P "$PRESET" -D 'part="motion_demo"' -D "\$t=$i/$FRAMES" "$SCAD"
    done
    convert -delay 10 -loop 0 "$TMP"/frame*.png "$OUT/motion_demo.gif"
    rm -rf "$TMP"
    echo "rendered motion_demo.gif"
else
    echo "ImageMagick convert not found; skipping motion_demo.gif" >&2
fi
