# Parametric Pancake Cycloidal Gearbox

A configurable **OpenSCAD cycloidal reducer** for NEMA stepper motors, with CNC-oriented bearing-supported builds and progressively simplified 3D-printable variants.

**Current design version: v1.9**

## Assembly

![OpenSCAD assembly render](docs/images/assembly_v1_8.png)

The output carrier is the external face flange, giving a short pancake package without a long projecting output shaft.

## Machined coupled input shaft — v1.9

v1.9 adds a second input architecture for motors whose stock shaft is too short or inconvenient for the full eccentric stack.

`input_shaft_mode` now offers:

- `Direct motor shaft` — preserves the original compact architecture.
- `Machined coupled shaft` — uses a stepped fabricated shaft with a female socket over the existing motor shaft.

The coupled shaft keeps a configurable gearbox-side drive diameter for the existing eccentric sleeves, while a larger rear hub provides the motor-shaft socket and radial locking screws. A registered NEMA spacer moves the gearbox away from the motor by the required amount.

The spacer includes a **motor-side pilot pocket** and a **gearbox-side locating boss**, so the offset does not rely only on the four mounting screws for concentric alignment.

For the default NEMA17 commodity values, the coupled-input starting point is:

| Parameter | Default |
| --- | ---: |
| Motor shaft | 5 mm × 20 mm protrusion |
| Gearbox drive shaft | 5 mm |
| Coupling hub OD | 12 mm |
| Female socket | 5.05 mm × 10 mm deep |
| Locking | 2 × M3 radial set screws |
| Motor offset | 22.5 mm |
| Socket engagement | 9.5 mm |
| Blind-end clearance | 0.5 mm |

The relevant dimensions are all exposed in the Customizer: motor shaft protrusion and pilot height, drive-shaft diameter, hub OD, socket depth/clearance, minimum engagement, motor offset, locating-boss height, and set-screw size/count. The named NEMA presets populate starting values for these controls, and the values remain editable after loading a preset.

The `part` selector also includes `motor_standoff_plate`, `motor_standoff_pilot_pocket_template`, and `coupled_input_shaft`.

See [`INPUT_SHAFT_OPTIONS_v1_9.csv`](docs/data/INPUT_SHAFT_OPTIONS_v1_9.csv) and [`PROFILE_GUIDE_v1_9.csv`](docs/data/PROFILE_GUIDE_v1_9.csv).

## What changed in v1.8

Two configurator areas were reworked:

1. **Simplified ring contacts now use case-rooted lobes.** The circular contact surface is preserved, but each printed lobe flares into a broad root that overlaps the case wall instead of hanging from a thin stem.
2. **Profiles are real OpenSCAD Customizer presets.** The companion JSON file contains named parameter sets. Selecting one fills the actual numeric and hardware fields in the Customizer, and those fields remain editable afterward.

### Case-rooted printed lobes

![Case-rooted lobe geometry](docs/images/case_rooted_lobes_top_v1_8.png)

The lobe root can be tuned with `printed_lobe_root_fraction`, `printed_lobe_embed_depth`, and `printed_lobe_cavity_overlap`. The previous narrow-bridge geometry remains available as `Legacy narrow bridges`.

![Simplified lobe assembly](docs/images/simplified_lobes_assembly_v1_8.png)

## Customizer presets

Keep the SCAD and JSON files together in `src/`. Use the **Preset** drop-down at the top of OpenSCAD's Customizer.

Supplied sets: NEMA17 Commodity R15; NEMA17 Light R11; NEMA17 Medium R21; NEMA17 Heavy R29; NEMA23 Light R11; NEMA23 Medium R18; NEMA23 Heavy R29; NEMA34 Light R11; NEMA34 Medium R21; NEMA34 Heavy R29.

Preset names use `R15`, `R18`, etc. instead of `15:1` so the Customizer does not confuse the colon with range syntax.

A preset updates the motor dimensions, ratio, torque class, catalog bearing selections, ring pitch, eccentricity, disc thickness, output-pin radius, plate thicknesses, housing radius, tie-bolt geometry, and center bore. After selection, each populated control remains editable.

See [`PROFILE_GUIDE_v1_8.csv`](docs/data/PROFILE_GUIDE_v1_8.csv).

## Motion

The motion section is a single animated GIF rendered from OpenSCAD.

![OpenSCAD motion animation](docs/images/motion_demo_v1_8.gif)

The animation is prescribed kinematics, not a force/contact simulation.

## Input stack

![Input stack](docs/images/input_stack_v1_8.png)

The central gearbox input is the NEMA motor's own shaft. Each cycloid disc uses an eccentric sleeve phased 180° from the other.

## Simplification levels

| Level | Ring contact | Eccentric support | Output-pin contact | Output support |
| --- | --- | --- | --- | --- |
| **Full hardware** | Catalog ring bearings / sleeves | Ball bearings | Roller bearings | Large output bearing |
| **Integrated case lobes** | Printed case-rooted lobes | Ball bearings | Roller bearings | Large output bearing |
| **Direct pin and cam contact** | Printed case-rooted lobes | Direct sliding cam | Smooth pins | Large output bearing |
| **Bearingless printed journals** | Printed case-rooted lobes | Direct sliding cam | Smooth pins | Printed plain journal |

## Default commodity profile

The `NEMA17 Commodity R15` preset uses 624ZZ ring rollers on 4 mm rod, 625ZZ output rollers on 5 mm rod, 6000ZZ eccentric bearings, and a 6814ZZ output-flange bearing.

## Exploded and manufacturing views

![Exploded view](docs/images/exploded_v1_8.png)

![Separated 3D layout](docs/images/layout_3d_v1_8.png)

## Validation

The v1.8 source was compiled locally across all 10 supplied presets and all four simplification modes: **40/40 combinations passed the current geometry assertions**.

These checks are geometric only. They are not torque, fatigue, thermal, bearing-life, or safety ratings.

## Project status

**Prototype / engineering development.** Before structural or safety-critical use, validate contact stress, output-pin loading, bearing life, fits, lubrication, fatigue, thermal behavior, fastener preload, and the actual motor shaft/pilot dimensions for the application.
