# Parametric Pancake Cycloidal Gearbox

A configurable **OpenSCAD cycloidal reducer** for NEMA stepper motors, with CNC-oriented bearing-supported builds and progressively simplified 3D-printable variants.

**Current design version: v1.10**

## Assembly

![OpenSCAD assembly render](docs/images/assembly_v1_8.png)

The output carrier is the external face flange, giving a short pancake package without a long projecting output shaft.

## What changed in v1.10

v1.10 integrates the two eccentric cams into the machined coupled input shaft. The earlier separate-sleeve coupled input remains selectable.

### One-piece double-eccentric input shaft

Set input_shaft_mode to **Machined coupled shaft** and coupled_eccentric_mode to **Integrated double eccentric**.

The machined part combines the female socket for the existing motor shaft, coupling hub and locking screws, concentric shaft core, and **two integral eccentric journals machined 180° apart**. Their phase is therefore fixed by the part itself rather than by two independently adjusted eccentric sleeves.

The existing v1.9 registered motor spacer is retained:

![Coupled input stack](docs/images/coupled_input_stack_v1_9.png)

![Coupled-input assembly](docs/images/coupled_input_assembly_v1_9.png)

The coupled_input_shaft part output now changes with coupled_eccentric_mode:

- **Integrated double eccentric** — one machined shaft, no eccentric sleeves or eccentric set screws.
- **Separate eccentric sleeves** — the v1.9 arrangement, easier to turn on simple equipment but requiring two sleeves to be phased 180° during assembly.

### Assembly path for the integrated shaft

A one-piece double-eccentric shaft creates an important assembly constraint: the rear cycloid bearing cannot pass over the front eccentric journal. v1.10 therefore sizes and checks the coupling end so the rear cycloid/bearing can be installed from the motor/coupling end.

The intended sequence is:

1. Press the rear eccentric bearing into the rear cycloid disc.
2. Slide that disc/bearing over the coupling end and onto the rear eccentric journal.
3. Slide the rear plate and registered motor spacer over the coupling end behind the rear disc.
4. Install the front cycloid/bearing from the front onto the front eccentric journal.
5. Couple the shaft socket to the motor shaft and tighten the radial locking screws.

The model asserts that the coupling hub is smaller than the rear bearing ID—or the direct-contact cycloid bore at simplified levels—by the configured assembly clearance.

### New integrated-shaft controls

- coupled_eccentric_mode
- integrated_coupling_hub_od_setting
- integrated_rear_assembly_clearance
- integrated_front_extension

The named NEMA presets populate starting values for the integrated coupling hub. All values remain editable after loading the preset.

See [INPUT_SHAFT_OPTIONS_v1_10.csv](docs/data/INPUT_SHAFT_OPTIONS_v1_10.csv), [PROFILE_GUIDE_v1_10.csv](docs/data/PROFILE_GUIDE_v1_10.csv), and [INTEGRATED_SHAFT_NOTES_v1_10.md](docs/data/INTEGRATED_SHAFT_NOTES_v1_10.md).

## Machined coupled input

input_shaft_mode still offers:

- **Direct motor shaft** — the shortest arrangement.
- **Machined coupled shaft** — a fabricated input with a female socket over the existing motor shaft and a registered motor spacer.

For the default NEMA17 commodity profile, the coupled-input starting point remains a 5 mm motor shaft, 10 mm socket depth, 22.5 mm motor offset, and M3 locking screws. In integrated mode the coupling hub is reduced to **9.5 mm OD** so the 10 mm-ID rear 6000ZZ bearing can pass over it during assembly.

## Case-rooted simplified lobes

The case-rooted printed lobe geometry remains the default simplified ring-contact system.

![Case-rooted lobe geometry](docs/images/case_rooted_lobes_top_v1_8.png)

The contact circle stays at the correct cycloid generating radius while the root flares into the case wall for a stronger printed structure.

## Customizer presets

Keep the SCAD and JSON files together:

- src/cnc_nema_cycloidal_gearbox_pancake_v1_10.scad
- src/cnc_nema_cycloidal_gearbox_pancake_v1_10.json

Use the **Preset** drop-down in OpenSCAD's Customizer. The supplied sets are:

- NEMA17 Commodity R15
- NEMA17 Light R11
- NEMA17 Medium R21
- NEMA17 Heavy R29
- NEMA23 Light R11
- NEMA23 Medium R18
- NEMA23 Heavy R29
- NEMA34 Light R11
- NEMA34 Medium R21
- NEMA34 Heavy R29

A preset writes literal values into the motor, ratio, bearing, housing, cycloid, and input-coupling controls. After selection, every populated field remains editable.

## Motion

![OpenSCAD motion animation](docs/images/motion_demo_v1_8.gif)

The animation is prescribed kinematics: it rotates the motor/input shaft and eccentric system, orbits and counter-rotates the two cycloid discs, and advances the output flange at the selected reduction ratio. It is not a force/contact simulation.

## Simplification levels

| Level | Ring contact | Eccentric support | Output-pin contact | Output support |
| --- | --- | --- | --- | --- |
| **Full hardware** | Catalog ring bearings / sleeves | Ball bearings | Roller bearings | Large output bearing |
| **Integrated case lobes** | Printed case-rooted lobes | Ball bearings | Roller bearings | Large output bearing |
| **Direct pin and cam contact** | Printed case-rooted lobes | Direct sliding cam | Smooth pins | Large output bearing |
| **Bearingless printed journals** | Printed case-rooted lobes | Direct sliding cam | Smooth pins | Printed plain journal |

The integrated double-eccentric shaft works with all four simplification levels. At Levels 2–3, its eccentric journals become direct sliding cam surfaces rather than bearing journals.

## Default commodity profile

The NEMA17 Commodity R15 preset uses:

| Function | Hardware |
| --- | --- |
| Motor/input | NEMA 17, 5 mm motor shaft |
| Ring rollers | 624ZZ, 4 × 13 × 5 mm |
| Ring axles | 4 mm precision smooth rod |
| Output rollers | 625ZZ, 5 × 16 × 5 mm |
| Output pins | 5 mm precision smooth rod |
| Eccentric bearings | 6000ZZ, 10 × 26 × 8 mm |
| Output flange bearing | 6814ZZ, 70 × 90 × 10 mm |
| Reduction | 15:1 |

## Views and manufacturing output

![Exploded view](docs/images/exploded_v1_8.png)

![Separated 3D layout](docs/images/layout_3d_v1_8.png)

The OpenSCAD manufacturing report now includes integrated-journal OD and length, ± eccentric offsets, journal axial positions, minimum blank OD, rear assembly-passage diameter, socket geometry, set-screw drilling, registered spacer geometry, and motor offset.

When integrated mode is selected, eccentric_A and eccentric_B report quantity zero and are omitted from generated part geometry because those journals are machined into the input shaft.

## Validation

v1.10 was compiled across all **10 named presets × 4 simplification levels × 3 input/eccentric architectures**:

- direct motor shaft + separate eccentric sleeves,
- coupled shaft + separate eccentric sleeves,
- coupled shaft + integrated double eccentric.

**120/120 combinations pass the current OpenSCAD geometry assertions.** See [profile_input_eccentric_simplification_validation_v1_10.csv](docs/data/profile_input_eccentric_simplification_validation_v1_10.csv).

These checks are geometric and assembly-clearance checks only. They are not torque, fatigue, thermal, bearing-life, shaft-coupling, journal-surface, or safety ratings. The one-piece eccentric shaft requires appropriate material, bearing-journal tolerance and surface finish, and a machining method capable of holding both eccentricity and 180° phase.

## Project status

**Prototype / engineering development.**
