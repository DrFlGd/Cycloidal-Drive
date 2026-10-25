# v1.11

Correctness and manufacturability release. See the README section "What changed in v1.11" for the user-facing summary.

## Geometry
- Assert odd lobe count (the 180-degree second disc only meshes for odd N); `NEMA23 Medium R18` became `NEMA23 Medium R19`.
- Curvature-weighted arc-length resampling of the cycloid profile; facet error echoed in the build report.
- New assertions: undercut margin, ring-packing pitch growth (`max_ring_pitch_growth`), direct-shaft protrusion, tie-bolt wall inside the cavity, sleeve collar clearance, two-sleeve set-screw impossibility.
- All ten presets re-derived so the stored ring pitch, housing and tie radii are the values the model uses (packing growth is now 0 on every preset). Heavy R29 presets use smaller ring bearings and larger output bearings so the housings are 163/196/233 mm instead of 194/240/263 mm.

## Fits
- Printed builds (levels 1-3): flank clearance, bearing pockets and motor pilot bore use print clearances.
- `direct_cam_od_setting` for the level 2-3 sliding cam.
- Fillet at printed lobe roots; optional lobe end chamfer for 3D solids.
- ISO-style fit hints in the manufacturing report; rear keeper chosen automatically for thin plate floors.

## Eccentric input
- One-piece double-eccentric sleeve with D-flat bore is the default for direct-shaft and separate-sleeve builds; round bore with set-screw collar and two mirror-image D-bore sleeves remain selectable.
- Minimum shaft length is now computed from the true sleeve front face.

## Export and tooling
- `export_mode` (2D profile / 3D solid) for every plate part; `eccentric_sleeve` part.
- Blind pockets cut from the exported 2D drill templates (about half the CGAL time of per-hole cylinders).
- `tools/validate_presets.py` and `docs/data/profile_input_eccentric_simplification_validation_v1_11.csv`.
