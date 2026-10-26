// How the generator presents the design's Customizer parameters: which section each one
// belongs to, a plain-language label and help text, and when it applies. Any parameter in
// the .scad file that is not listed here still appears, in "Other settings", so the page
// never hides a parameter the design gained later (tools/check_web_schema.py guards this).

export const LEVELS = ["Full hardware", "Integrated case lobes", "Direct pin and cam contact", "Bearingless printed journals"];
const level = p => LEVELS.indexOf(p.simplification_level);
const coupled = p => p.input_shaft_mode === "Machined coupled shaft";
const integrated = p => coupled(p) && p.coupled_eccentric_mode === "Integrated double eccentric";
const separateSleeves = p => !integrated(p);
const doubleSleeve = p => separateSleeves(p) && p.eccentric_sleeve_style === "One-piece double eccentric";
const roundBore = p => separateSleeves(p) && p.eccentric_bore_style !== "D-flat";
const frontPilot = p => p.input_front_support !== "None";

export const SECTIONS = [
  { id: "motor", title: "Motor and reduction", blurb: "The motor the gearbox bolts to and the reduction it gives." },
  { id: "build", title: "Build method", blurb: "Machined hardware build, or one of three cumulative 3D-printable simplifications." },
  { id: "input", title: "Input shaft", blurb: "How the motor drives the two eccentric journals." },
  { id: "support", title: "Input shaft support", blurb: "Bearings that support the eccentric in front of and behind the discs." },
  { id: "bearings", title: "Bearings", blurb: "Catalog bearings for the ring rollers, eccentrics, output rollers and output flange." },
  { id: "geometry", title: "Gear geometry", blurb: "Size of the ring, the eccentricity and the cycloid discs." },
  { id: "housing", title: "Housing and output flange", blurb: "Plate thicknesses, tie bolts and the output bolt pattern." },
  { id: "tuning", title: "Profile and running clearances", advanced: true, blurb: "Cycloid profile sampling and the axial and radial running gaps." },
  { id: "fits", title: "Machined fits", advanced: true, blurb: "Press and slip allowances. Tune to your machine, material and bearing maker." },
  { id: "other", title: "Other settings", advanced: true, blurb: "Parameters in the design file that this page has no dedicated place for." },
];

// Parameters the page drives itself from the Preview and Export panels.
export const VIEW_PARAMS = new Set([
  "part", "export_mode", "show_motor_mockup", "show_hardware", "animate_preview",
  "animation_input_revolutions", "show_rotation_markers", "show_motion_debug",
  "exploded_gap", "layout_3d_clearance", "spec_output", "spec_include_hardware", "$fn",
  "profile_name",
]);

const bearingCustom = (select, p) => p[select] === "Custom";

// section, label, unit, help, when (applies only if true), whenText (why it is hidden)
export const PARAMS = {
  // Motor and reduction
  motor_frame: { section: "motor", label: "Motor frame", help: "NEMA frames use built-in mounting dimensions. Choose CUSTOM to enter your own." },
  custom_frame_side: { section: "motor", label: "Frame width", unit: "mm", when: p => p.motor_frame === "CUSTOM", sub: "Custom motor" },
  custom_mount_spacing: { section: "motor", label: "Mount hole spacing", unit: "mm", when: p => p.motor_frame === "CUSTOM", sub: "Custom motor" },
  custom_motor_pilot_d: { section: "motor", label: "Pilot diameter", unit: "mm", when: p => p.motor_frame === "CUSTOM", sub: "Custom motor" },
  custom_mount_hole_d: { section: "motor", label: "Mount hole diameter", unit: "mm", when: p => p.motor_frame === "CUSTOM", sub: "Custom motor" },
  custom_motor_shaft_d: { section: "motor", label: "Shaft diameter", unit: "mm", when: p => p.motor_frame === "CUSTOM", sub: "Custom motor" },
  reduction_ratio: { section: "motor", label: "Reduction ratio (n : 1)", help: "Equals the lobe count and must be odd, because the second disc is the first one turned 180°." },
  torque_class: { section: "motor", label: "Torque class", help: "Scales pins, plates and fasteners. Heavy also selects the rear keeper plate." },
  motor_shaft_protrusion_setting: { section: "motor", label: "Motor shaft length", unit: "mm", help: "Usable shaft length from the motor face. Check the motor drawing: NEMA17 shafts are commonly 20, 22 or 24 mm." },
  motor_pilot_height_setting: { section: "motor", label: "Motor pilot height", unit: "mm" },

  // Build method
  simplification_level: { section: "build", label: "Build level", control: "cards" },
  print_radial_clearance: { section: "build", label: "Radial print clearance", unit: "mm", when: p => level(p) >= 1, sub: "Printing clearances", help: "Per side, on printed sliding and journal fits. Also the flank clearance when it is larger than the machined one." },
  print_axial_clearance: { section: "build", label: "Axial print clearance", unit: "mm", when: p => level(p) >= 1, sub: "Printing clearances" },
  print_bearing_pocket_clearance: { section: "build", label: "Bearing pocket clearance", unit: "mm", when: p => level(p) >= 1, sub: "Printing clearances", help: "Diametral clearance added to every bearing pocket in place of the press fit. Glue or a heat-set fit is expected." },
  printed_lobe_root_fraction: { section: "build", label: "Lobe root fraction", when: p => level(p) >= 1, sub: "Printed case lobes" },
  printed_lobe_embed_depth: { section: "build", label: "Lobe embed depth", unit: "mm", when: p => level(p) >= 1, sub: "Printed case lobes" },
  printed_lobe_cavity_overlap: { section: "build", label: "Lobe cavity overlap", unit: "mm", when: p => level(p) >= 1, sub: "Printed case lobes" },
  printed_lobe_root_fillet: { section: "build", label: "Lobe root fillet", unit: "mm", when: p => level(p) >= 1, sub: "Printed case lobes", help: "Removes the sharp internal corner so a level 1 case can also be milled. 0 disables." },
  printed_lobe_end_chamfer: { section: "build", label: "Lobe end chamfer", unit: "mm", when: p => level(p) >= 1, sub: "Printed case lobes", help: "3D solids only. Slows the case render noticeably. 0 disables." },
  direct_cam_od_setting: { section: "build", label: "Direct cam diameter", unit: "mm", when: p => level(p) >= 2, sub: "Direct contact (level 2+)", help: "The eccentric runs straight in the disc bore. Bigger is stronger and lowers contact pressure." },
  plain_output_journal_t: { section: "build", label: "Plain output journal thickness", unit: "mm", when: p => level(p) >= 3, sub: "Bearingless (level 3)" },
  motor_pilot_pocket_depth: { section: "build", label: "Motor pilot pocket depth", unit: "mm", when: p => level(p) >= 3, sub: "Bearingless (level 3)" },

  // Input shaft
  input_shaft_mode: { section: "input", label: "Input type", control: "cards" },
  eccentric_sleeve_style: { section: "input", label: "Sleeve style", when: separateSleeves, sub: "Eccentric sleeve", help: "One-piece fixes the 180° phase by machining and enables the front pilot journal." },
  eccentric_bore_style: { section: "input", label: "Bore style", when: separateSleeves, sub: "Eccentric sleeve", help: "D-flat takes torque from the motor shaft flat with no set screw. Round adds a set-screw collar." },
  motor_shaft_flat_depth: { section: "input", label: "Motor shaft flat depth", unit: "mm", when: p => separateSleeves(p) && !roundBore(p), sub: "Eccentric sleeve" },
  eccentric_collar_length: { section: "input", label: "Set-screw collar length", unit: "mm", when: roundBore, sub: "Eccentric sleeve" },
  eccentric_set_screw_thread: { section: "input", label: "Collar set screw", when: roundBore, sub: "Eccentric sleeve" },
  coupled_eccentric_mode: { section: "input", label: "Eccentric journals", when: coupled, sub: "Coupled shaft", help: "Machine both journals into the shaft, or keep separate eccentric sleeves on its core." },
  coupled_drive_shaft_d_setting: { section: "input", label: "Drive shaft diameter", unit: "mm", when: coupled, sub: "Coupled shaft" },
  coupled_hub_od_setting: { section: "input", label: "Coupling hub diameter", unit: "mm", when: p => coupled(p) && !integrated(p), sub: "Coupled shaft", help: "Must equal the rear support bearing bore when that bearing is used." },
  integrated_coupling_hub_od_setting: { section: "input", label: "Coupling hub diameter", unit: "mm", when: integrated, sub: "Coupled shaft" },
  coupled_socket_depth_setting: { section: "input", label: "Motor socket depth", unit: "mm", when: coupled, sub: "Coupled shaft" },
  coupled_socket_diametral_clearance: { section: "input", label: "Socket clearance (diametral)", unit: "mm", when: coupled, sub: "Coupled shaft" },
  coupled_socket_front_wall: { section: "input", label: "Socket front wall", unit: "mm", when: coupled, sub: "Coupled shaft" },
  coupled_shaft_end_clearance: { section: "input", label: "Shaft end clearance", unit: "mm", when: coupled, sub: "Coupled shaft" },
  coupled_min_engagement: { section: "input", label: "Minimum socket engagement", unit: "mm", when: coupled, sub: "Coupled shaft" },
  coupled_set_screw_thread: { section: "input", label: "Socket set screw", when: coupled, sub: "Coupled shaft" },
  coupled_set_screw_count: { section: "input", label: "Socket set screw count", when: coupled, sub: "Coupled shaft" },
  integrated_rear_assembly_clearance: { section: "input", label: "Rear assembly clearance", unit: "mm", when: integrated, sub: "Coupled shaft" },
  integrated_front_extension: { section: "input", label: "Front extension", unit: "mm", when: integrated, sub: "Coupled shaft" },
  motor_mount_offset_setting: { section: "input", label: "Motor spacer thickness", unit: "mm", when: coupled, sub: "Motor spacer", help: "The report recommends an offset for the current shaft length." },
  motor_spacer_register_height: { section: "input", label: "Spacer register height", unit: "mm", when: coupled, sub: "Motor spacer" },
  motor_spacer_radial_clearance: { section: "input", label: "Spacer bore clearance", unit: "mm", when: coupled, sub: "Motor spacer" },

  // Input support
  input_front_support: { section: "support", label: "Front pilot", help: "A journal in front of the eccentrics runs in a bearing in the output hub, so the motor bearings carry no eccentric load. Auto uses it whenever a forward journal exists.", sub: "Front support" },
  front_pilot_bearing_select: { section: "support", label: "Front pilot bearing", when: p => frontPilot(p) && level(p) < 2, sub: "Front support", help: "Auto picks the largest bearing that clears the hub clamp screws; the choice appears in the report." },
  custom_front_pilot_bearing_id: { section: "support", label: "Custom pilot bore", unit: "mm", when: p => frontPilot(p) && level(p) < 2 && bearingCustom("front_pilot_bearing_select", p), sub: "Front support" },
  custom_front_pilot_bearing_od: { section: "support", label: "Custom pilot OD", unit: "mm", when: p => frontPilot(p) && level(p) < 2 && bearingCustom("front_pilot_bearing_select", p), sub: "Front support" },
  custom_front_pilot_bearing_w: { section: "support", label: "Custom pilot width", unit: "mm", when: p => frontPilot(p) && level(p) < 2 && bearingCustom("front_pilot_bearing_select", p), sub: "Front support" },
  front_pilot_journal_extra: { section: "support", label: "Extra journal length", unit: "mm", when: frontPilot, sub: "Front support" },
  coupled_rear_support: { section: "support", label: "Rear support bearing", when: p => coupled(p) && !integrated(p), sub: "Rear support", help: "A bearing on the coupling hub, seated in the motor spacer." },
  rear_support_bearing_select: { section: "support", label: "Rear bearing", when: p => coupled(p) && !integrated(p) && p.coupled_rear_support !== "None", sub: "Rear support" },
  custom_rear_support_bearing_id: { section: "support", label: "Custom rear bore", unit: "mm", when: p => coupled(p) && !integrated(p) && bearingCustom("rear_support_bearing_select", p), sub: "Rear support" },
  custom_rear_support_bearing_od: { section: "support", label: "Custom rear OD", unit: "mm", when: p => coupled(p) && !integrated(p) && bearingCustom("rear_support_bearing_select", p), sub: "Rear support" },
  custom_rear_support_bearing_w: { section: "support", label: "Custom rear width", unit: "mm", when: p => coupled(p) && !integrated(p) && bearingCustom("rear_support_bearing_select", p), sub: "Rear support" },

  // Bearings
  ring_bearing_select: { section: "bearings", label: "Ring roller bearing", when: p => level(p) === 0, sub: "Ring rollers", help: "Two per ring axle, one aligned with each disc. Printed builds use case lobes instead." },
  custom_ring_bearing_id: { section: "bearings", label: "Custom bore", unit: "mm", when: p => level(p) === 0 && bearingCustom("ring_bearing_select", p), sub: "Ring rollers" },
  custom_ring_bearing_od: { section: "bearings", label: "Custom OD", unit: "mm", when: p => level(p) === 0 && bearingCustom("ring_bearing_select", p), sub: "Ring rollers" },
  custom_ring_bearing_w: { section: "bearings", label: "Custom width", unit: "mm", when: p => level(p) === 0 && bearingCustom("ring_bearing_select", p), sub: "Ring rollers" },
  rear_pin_capture: { section: "bearings", label: "Ring axle capture", when: p => level(p) === 0, sub: "Ring rollers", help: "Auto uses the rear keeper for Heavy builds and when blind pockets would leave a thin plate floor." },
  ecc_bearing_select: { section: "bearings", label: "Eccentric bearing", when: p => level(p) < 2, sub: "Eccentric", help: "One per disc, on the eccentric journal." },
  custom_ecc_bearing_id: { section: "bearings", label: "Custom bore", unit: "mm", when: p => level(p) < 2 && bearingCustom("ecc_bearing_select", p), sub: "Eccentric" },
  custom_ecc_bearing_od: { section: "bearings", label: "Custom OD", unit: "mm", when: p => level(p) < 2 && bearingCustom("ecc_bearing_select", p), sub: "Eccentric" },
  custom_ecc_bearing_w: { section: "bearings", label: "Custom width", unit: "mm", when: p => level(p) < 2 && bearingCustom("ecc_bearing_select", p), sub: "Eccentric" },
  output_roller_bearing_select: { section: "bearings", label: "Output roller bearing", when: p => level(p) < 2, sub: "Output pins", help: "Rollers on the output pins, two per pin." },
  custom_output_roller_id: { section: "bearings", label: "Custom bore", unit: "mm", when: p => level(p) < 2 && bearingCustom("output_roller_bearing_select", p), sub: "Output pins" },
  custom_output_roller_od: { section: "bearings", label: "Custom OD", unit: "mm", when: p => level(p) < 2 && bearingCustom("output_roller_bearing_select", p), sub: "Output pins" },
  custom_output_roller_w: { section: "bearings", label: "Custom width", unit: "mm", when: p => level(p) < 2 && bearingCustom("output_roller_bearing_select", p), sub: "Output pins" },
  flange_bearing_select: { section: "bearings", label: "Output flange bearing", when: p => level(p) < 3, sub: "Output flange", help: "The large thin-section bearing that carries the output flange." },
  custom_flange_bearing_id: { section: "bearings", label: "Custom bore", unit: "mm", when: p => level(p) < 3 && bearingCustom("flange_bearing_select", p), sub: "Output flange" },
  custom_flange_bearing_od: { section: "bearings", label: "Custom OD", unit: "mm", when: p => level(p) < 3 && bearingCustom("flange_bearing_select", p), sub: "Output flange" },
  custom_flange_bearing_w: { section: "bearings", label: "Custom width", unit: "mm", when: p => level(p) < 3 && bearingCustom("flange_bearing_select", p), sub: "Output flange" },

  // Gear geometry
  ring_pitch_base_r_setting: { section: "geometry", label: "Ring pitch radius", unit: "mm", help: "Grows automatically if the ring rollers cannot pack on this circle, up to the limit below." },
  eccentricity_setting: { section: "geometry", label: "Eccentricity", unit: "mm" },
  cycloid_disc_t_setting: { section: "geometry", label: "Disc thickness", unit: "mm" },
  output_pin_circle_r_setting: { section: "geometry", label: "Output pin circle radius", unit: "mm" },
  max_ring_pitch_growth: { section: "geometry", label: "Allowed pitch growth", unit: "mm", help: "How far roller packing may enlarge the ring before the design check stops." },

  // Housing and output
  housing_base_r_setting: { section: "housing", label: "Housing radius", unit: "mm", sub: "Housing" },
  rear_plate_t_setting: { section: "housing", label: "Rear plate thickness", unit: "mm", sub: "Housing" },
  case_wall_clearance: { section: "housing", label: "Case wall clearance", unit: "mm", sub: "Housing" },
  bearing_retainer_t: { section: "housing", label: "Bearing retainer thickness", unit: "mm", sub: "Housing" },
  tie_count: { section: "housing", label: "Tie bolt count", sub: "Tie bolts" },
  tie_base_r_setting: { section: "housing", label: "Tie bolt circle radius", unit: "mm", sub: "Tie bolts" },
  tie_clear_d_setting: { section: "housing", label: "Tie bolt clearance hole", unit: "mm", sub: "Tie bolts" },
  output_face_t_setting: { section: "housing", label: "Output face thickness", unit: "mm", sub: "Output flange" },
  output_center_bore_d_setting: { section: "housing", label: "Output centre bore", unit: "mm", sub: "Output flange" },
  output_mount_count: { section: "housing", label: "Output mounting holes", sub: "Output flange" },
  inner_retainer_screw_count: { section: "housing", label: "Hub clamp screws", sub: "Output flange" },
  output_face_radial_clearance: { section: "housing", label: "Output face radial clearance", unit: "mm", sub: "Output flange" },
  output_bearing_race_overlap_fraction: { section: "housing", label: "Race retainer overlap", sub: "Output flange", help: "Fraction of the bearing race width the retainers overlap." },

  // Tuning
  profile_resolution: { section: "tuning", label: "Profile points", sub: "Cycloid profile", help: "Points on the exported cycloid outline, placed by curvature so the facet error is uniform." },
  profile_dense_multiplier: { section: "tuning", label: "Resampler density", sub: "Cycloid profile" },
  profile_clearance_radial: { section: "tuning", label: "Flank clearance (machined)", unit: "mm", sub: "Cycloid profile", help: "Backlash clearance per side between disc flank and ring roller." },
  output_orbit_clearance_d: { section: "tuning", label: "Output orbit clearance", unit: "mm", sub: "Running clearances" },
  disc_gap: { section: "tuning", label: "Gap between discs", unit: "mm", sub: "Running clearances" },
  rear_running_gap: { section: "tuning", label: "Rear running gap", unit: "mm", sub: "Running clearances" },
  front_running_gap: { section: "tuning", label: "Front running gap", unit: "mm", sub: "Running clearances" },
  min_design_web: { section: "tuning", label: "Minimum web", unit: "mm", sub: "Running clearances", help: "Smallest material web the design rules accept." },

  // Fits
  ring_axle_press: { section: "fits", label: "Ring axle press", unit: "mm" },
  ring_axle_slip: { section: "fits", label: "Ring axle slip", unit: "mm" },
  output_pin_press: { section: "fits", label: "Output pin press", unit: "mm" },
  output_pin_hub_slip: { section: "fits", label: "Output pin hub slip", unit: "mm" },
  bearing_pocket_interference: { section: "fits", label: "Bearing pocket interference", unit: "mm" },
  flange_hub_interference: { section: "fits", label: "Flange hub interference", unit: "mm" },
  motor_shaft_slip: { section: "fits", label: "Motor shaft slip", unit: "mm" },
  eccentric_bearing_inner_interference: { section: "fits", label: "Eccentric bearing inner interference", unit: "mm" },
  stock_margin_xy: { section: "fits", label: "Rough stock margin", unit: "mm", help: "Added to each part envelope for the rough blank size in the report." },
};

export const LEVEL_CARDS = [
  { value: "Full hardware", title: "Full hardware", tag: "Machined", text: "Catalog bearings everywhere. CNC aluminium plate." },
  { value: "Integrated case lobes", title: "Integrated case lobes", tag: "Level 1", text: "Printed ring lobes replace the ring bearings and axles." },
  { value: "Direct pin and cam contact", title: "Direct pin and cam", tag: "Level 2", text: "Cam and output pins run directly in the discs." },
  { value: "Bearingless printed journals", title: "Bearingless", tag: "Level 3", text: "Plain printed journal replaces the output bearing. Low duty." },
];

export const INPUT_CARDS = [
  { value: "Direct motor shaft", title: "Direct motor shaft", text: "Eccentric sleeve on the motor shaft. Compact; needs enough shaft length." },
  { value: "Machined coupled shaft", title: "Machined coupled shaft", text: "Stepped shaft over the motor shaft with a motor spacer. For short shafts." },
];

// Preview views. kind: 3d or 2d.
export const VIEWS = [
  { id: "assembly", label: "Assembly", kind: "3d" },
  { id: "exploded", label: "Exploded", kind: "3d", extra: ["exploded_gap"] },
  { id: "input_stack", label: "Input stack", kind: "3d" },
  { id: "layout_3d", label: "Parts laid out", kind: "3d", extra: ["layout_3d_clearance"] },
  { id: "layout_2d", label: "Profiles (2D)", kind: "2d" },
];

// kind: plate (2D profile or 3D solid), lathe (3D only), template (2D only)
export const PARTS = [
  { id: "rear_plate", label: "Rear plate", kind: "plate", group: "Housing", desc: "Motor mounting plate; carries the rear ring-axle ends." },
  { id: "rear_keeper_plate", label: "Rear keeper plate", kind: "plate", group: "Housing", desc: "Captures the ring axles behind the rear plate." },
  { id: "case_ring", label: "Case ring", kind: "plate", group: "Housing", desc: "Encloses the disc chamber. Printed builds carry the ring lobes." },
  { id: "front_pin_plate", label: "Front pin plate", kind: "plate", group: "Housing", desc: "Closes the chamber and supports the front ring-axle ends." },
  { id: "bearing_race_retainer", label: "Bearing race retainer", kind: "plate", group: "Housing", desc: "Two identical rings that clamp the output bearing outer race." },
  { id: "bearing_carrier", label: "Bearing carrier", kind: "plate", group: "Housing", desc: "Holds the output bearing, or the plain journal at level 3." },
  { id: "motor_standoff_plate", label: "Motor spacer plate", kind: "plate", group: "Housing", desc: "Spaces the motor back for the coupled shaft." },
  { id: "cycloid_disc", label: "Cycloid disc", kind: "plate", group: "Drive train", desc: "Make two; the second is the first turned 180°." },
  { id: "eccentric_sleeve", label: "One-piece eccentric sleeve", kind: "lathe", group: "Drive train", desc: "Both journals 180° apart on one sleeve." },
  { id: "eccentric_A", label: "Eccentric sleeve A", kind: "plate", group: "Drive train", desc: "Separate sleeve for disc 1 (mirror of B)." },
  { id: "eccentric_B", label: "Eccentric sleeve B", kind: "plate", group: "Drive train", desc: "Separate sleeve for disc 2 (mirror of A)." },
  { id: "coupled_input_shaft", label: "Coupled input shaft", kind: "lathe", group: "Drive train", desc: "Stepped shaft over the motor shaft." },
  { id: "output_face_plate", label: "Output face plate", kind: "plate", group: "Output", desc: "The rotating output flange with the mounting bolt pattern." },
  { id: "output_hub_ring", label: "Output hub ring", kind: "plate", group: "Output", desc: "Sits in the output bearing; carries the output pins and the front pilot bearing." },
  { id: "inner_race_retainer", label: "Inner race retainer", kind: "plate", group: "Output", desc: "Clamps the output bearing inner race to the hub." },
  { id: "rear_pin_drill_template", label: "Rear plate pin pockets", kind: "template", group: "Drill templates", desc: "Blind ring-axle pockets in the rear plate." },
  { id: "rear_motor_pilot_pocket_template", label: "Rear plate motor pilot pocket", kind: "template", group: "Drill templates", desc: "Blind pilot pocket on the motor side." },
  { id: "front_pin_drill_template", label: "Front plate pin pockets", kind: "template", group: "Drill templates", desc: "Blind ring-axle pockets in the front pin plate." },
  { id: "output_face_front_drill_template", label: "Output face, front holes", kind: "template", group: "Drill templates", desc: "Blind tapped mounting holes." },
  { id: "output_face_rear_drill_template", label: "Output face, rear pockets", kind: "template", group: "Drill templates", desc: "Output-pin press pockets and hub clamp taps." },
  { id: "motor_standoff_pilot_pocket_template", label: "Motor spacer pilot pocket", kind: "template", group: "Drill templates", desc: "Blind motor pilot pocket in the spacer." },
];

// Which parts this configuration uses. The rear keeper choice comes from the design check
// report, because its Auto rule depends on derived values.
export function partApplies(id, p, report) {
  const lvl = level(p);
  const keeper = report && report.build && report.build["Rear ring contact/capture"]
    ? report.build["Rear ring contact/capture"].startsWith("Rear keeper")
    : (lvl === 0 && (p.rear_pin_capture === "Rear keeper" || (p.rear_pin_capture === "Auto" && p.torque_class === "Heavy")));
  switch (id) {
    case "motor_standoff_plate": case "motor_standoff_pilot_pocket_template": case "coupled_input_shaft": return coupled(p);
    case "eccentric_sleeve": return doubleSleeve(p);
    case "eccentric_A": case "eccentric_B": return separateSleeves(p) && !doubleSleeve(p);
    case "rear_motor_pilot_pocket_template": return lvl >= 3;
    case "rear_keeper_plate": return lvl === 0 && keeper;
    case "rear_pin_drill_template": return lvl === 0 && !keeper;
    case "front_pin_drill_template": return lvl === 0;
    case "bearing_race_retainer": return lvl < 3;
    default: return true;
  }
}

export const isPrintedLevel = p => level(p) >= 1;

// Settings to suggest when a design rule fails, matched against the assertion message.
// Parameter names that appear in a message are linked as well.
export const RULE_HINTS = [
  [/Reduction ratio/, ["reduction_ratio"]],
  [/undercuts/, ["eccentricity_setting", "ring_bearing_select", "ring_pitch_base_r_setting"]],
  [/Ring roller packing|too tightly packed/, ["ring_pitch_base_r_setting", "ring_bearing_select", "max_ring_pitch_growth"]],
  [/Motor shaft is too short/, ["motor_shaft_protrusion_setting", "cycloid_disc_t_setting", "rear_plate_t_setting", "input_shaft_mode"]],
  [/ring bearing is wider/, ["ring_bearing_select", "cycloid_disc_t_setting"]],
  [/Eccentric bearings overlap/, ["cycloid_disc_t_setting", "ecc_bearing_select"]],
  [/Housing tie holes/, ["tie_base_r_setting", "housing_base_r_setting", "tie_clear_d_setting"]],
  [/Output mounting holes/, ["output_center_bore_d_setting", "output_mount_count"]],
  [/Output pin roots|Inner-race clamp/, ["output_pin_circle_r_setting", "output_center_bore_d_setting", "inner_retainer_screw_count"]],
  [/Output orbital holes/, ["output_pin_circle_r_setting", "eccentricity_setting", "output_roller_bearing_select", "direct_cam_od_setting"]],
  [/Output pin count/, ["reduction_ratio", "torque_class"]],
  [/Pancake output bearing ID/, ["flange_bearing_select", "output_pin_circle_r_setting"]],
  [/front pilot|Front pilot/, ["input_front_support", "front_pilot_bearing_select", "output_center_bore_d_setting"]],
  [/collar|Collar/, ["eccentric_bore_style", "eccentric_collar_length"]],
  [/D-flat bore selected/, ["motor_shaft_flat_depth"]],
  [/Two separate eccentric sleeves/, ["eccentric_bore_style", "eccentric_sleeve_style"]],
  [/socket|Motor offset|motor-shaft engagement|bottom in the coupled/, ["motor_mount_offset_setting", "coupled_socket_depth_setting", "motor_shaft_protrusion_setting"]],
  [/[Ss]pacer/, ["motor_mount_offset_setting", "motor_spacer_register_height", "rear_support_bearing_select"]],
  [/[Rr]ear support/, ["coupled_rear_support", "rear_support_bearing_select", "coupled_hub_od_setting"]],
  [/[Ii]ntegrated/, ["integrated_coupling_hub_od_setting", "coupled_drive_shaft_d_setting", "eccentricity_setting"]],
  [/Blind ring-axle pocket/, ["rear_plate_t_setting", "rear_pin_capture"]],
  [/Unknown .* bearing designation/, ["ring_bearing_select", "ecc_bearing_select", "output_roller_bearing_select", "flange_bearing_select"]],
];
