# v1.8

## Case-rooted printed lobes

Simplified ring contacts now default to broad case-rooted lobes. Each lobe preserves the circular cycloid contact tip while widening into the stationary case wall, eliminating the thin radial stem used by the earlier printed-boss geometry.

New tuning controls:
- `printed_ring_feature_style`
- `printed_lobe_root_fraction`
- `printed_lobe_embed_depth`
- `printed_lobe_cavity_overlap`

The legacy narrow-bridge mode remains selectable for comparison.

## Editable Customizer presets

Named configurations are now stored as OpenSCAD Customizer parameter sets in `src/cnc_nema_cycloidal_gearbox_pancake_v1_8.json`.

Selecting a preset writes its motor, ratio, bearing, and geometry values into the normal Customizer fields. Those fields remain editable after loading the preset.

Preset names use `R11`, `R15`, `R18`, etc. rather than a colon-based ratio label to avoid Customizer range-syntax ambiguity.

## Documentation

README graphics are generated directly from OpenSCAD as lossless PNG files. The motion section uses one animated GIF instead of a four-frame contact sheet.

A GitHub Actions workflow regenerates these documentation renders from the v1.8 source and preset file.

## Validation

All 10 supplied parameter sets were compiled locally at all four simplification levels. 40/40 combinations passed the current OpenSCAD geometry assertions.

This is geometric validation only and is not a torque, bearing-life, fatigue, thermal, or safety certification.
