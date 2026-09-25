/*
 PANCAKE NEMA CYCLOIDAL GEARBOX — FLANGE OUTPUT — v1.10
 ===============================================
 Compact dual-disc cycloidal reducer intended for CNC-machined aluminum plate.
 The output carrier is the external face flange: no projecting output shaft and no
 small-diameter bearing tower. A large-diameter 68-series bearing supports the
 rotating flange/hub directly, producing a short "pancake" package.

 Architecture
 ------------
 MOTOR -> eccentric sleeves/bearings -> two cycloid discs -> roller-covered output
 pins -> OUTPUT FACE PLATE.

 The output flange assembly is intentionally split into flat CNC-friendly parts:
   - output_face_plate: external rotating mounting face
   - output_hub_ring: fits the large bearing inner race and supports the output pins
   - inner_race_retainer: clamps the bearing inner race from the rear

 The stationary front stack is also flat plate:
   - front_pin_plate: closes the cycloid chamber and blind-captures ring axles
   - bearing_race_retainer: two identical annular rings, rear and front
   - bearing_carrier: radial press-fit housing for the large output bearing

 This keeps nearly every custom piece 2D + constant thickness. Blind drill operations
 are intentionally exported as separate templates so a DXF profile cannot accidentally
 turn a depth-controlled feature into a through cut.

 v1.2 added a selectable ring-roller system:
   - Standard miniature bearings: two real catalog bearings per ring axle
   - Compact hardened sleeves: the smaller fabricated wear-sleeve architecture from v1.1
 The ring pitch and outer housing resize automatically if a selected bearing requires
 additional circumferential packing space.

 v1.4 added:
   - named NEMA17 / NEMA23 / NEMA34 profiles plus the NEMA17 commodity-hardware profile
   - exact ZZ-style catalog designations for common bearings
   - 4 mm ring axles and 5 mm output pins in the commodity profile
   - an explicit input_stack view showing how the motor shaft, eccentric cams and
     eccentric bearings assemble
   - the central motor shaft and input components explicitly separated in layout_3d
   - configurable layout spacing so 3D layout parts do not touch

 v1.5 adds:
   - synchronized OpenSCAD $t kinematic animation based on the supplied reference style
   - visibly rotating NEMA motor shaft / eccentric input
   - user-selectable input revolutions per animation cycle
   - optional rotation markers on input shaft, both cycloids and output flange
   - animated input_stack view for understanding the central shaft assembly

 v1.6 added cumulative simplification levels for printed prototypes:
   - Level 1: remove ring roller hardware and print integrated ring-contact features into the case
   - Level 2: also remove eccentric/output-pin bearings and use direct cam/pin contact
   - Level 3: also remove the large output bearing and use printed plain input/output journals
   - adjustable radial/axial print clearances and BOM/report annotations for omitted hardware

 v1.8 changes:
   - simplified ring contacts use broad case-rooted lobes by default; no thin stem connection
   - profile selection moved to real OpenSCAD Customizer parameter sets (sidecar JSON)
   - preset names avoid colon/range syntax ambiguity in the Customizer
   - preset values populate editable numeric controls instead of overriding them invisibly

 v1.10 adds:
   - optional one-piece coupled input shaft with two integral eccentric journals
   - eccentric journals are permanently phased 180 degrees by the machined shaft
   - rear assembly-passage checks so the rear cycloid/bearing can be installed
   - legacy coupled shaft + two separate eccentric sleeves remains selectable

 IMPORTANT ENGINEERING NOTE
 --------------------------
 Level 0 is the manufacturing-oriented bearing-supported reference design. Levels 1-3
 intentionally trade efficiency, wear life and stiffness for part-count reduction and
 printability. This is not a certified gearbox. Bearing
 life, contact stress, fastener preload, fatigue, lubrication, fits, thermal growth and
 safe torque/speed must be checked for the real application. The large output bearing
 dimensions are standard 68-series nominal sizes, but verify the exact bearing drawing
 and race/fillet geometry from your chosen manufacturer before final production machining.
*/

/* [Build / Export] */
part = "assembly"; // [assembly,motion_demo,exploded,input_stack,layout_3d,layout_2d,motor_standoff_plate,motor_standoff_pilot_pocket_template,coupled_input_shaft,rear_plate,rear_motor_pilot_pocket_template,rear_pin_drill_template,rear_keeper_plate,case_ring,front_pin_plate,front_pin_drill_template,bearing_race_retainer,bearing_carrier,cycloid_disc,output_face_plate,output_face_front_drill_template,output_face_rear_drill_template,output_hub_ring,inner_race_retainer,eccentric_A,eccentric_B]
show_motor_mockup = true;
show_hardware = true;
animate_preview = true;

/* [Animation] */
// OpenSCAD: View -> Animate. A cycle of $t=0..1 drives this many motor revolutions.
animation_input_revolutions = 10; // [1:1:30]
show_rotation_markers = true;
show_motion_debug = false;
exploded_gap = 12; // [4:2:30]
layout_3d_clearance = 30; // [10:5:80]


/* [Simplification / 3D Print] */
// Cumulative levels. Level 0 is the full bearing-supported design.
// Level 1 prints the stationary ring contacts into the case.
// Level 2 additionally runs eccentric cams and output pins directly in cycloid bores.
// Level 3 additionally replaces the large output bearing with a printed plain journal
// and gives the NEMA shaft a short plain journal in the rear plate. Prototype/low-duty only.
simplification_level = "Full hardware"; // [Full hardware,Integrated case lobes,Direct pin and cam contact,Bearingless printed journals]
print_radial_clearance = 0.25; // [0.10:0.05:0.60]
print_axial_clearance = 0.25; // [0.10:0.05:0.60]
printed_ring_feature_style = "Case-rooted lobes"; // [Case-rooted lobes,Legacy narrow bridges]
printed_ring_bridge_width = 3.0; // [1.5:0.5:6.0]
printed_lobe_root_fraction = 0.68; // [0.40:0.02:0.90]
printed_lobe_embed_depth = 3.0; // [1.0:0.25:8.0]
printed_lobe_cavity_overlap = 0.8; // [0.2:0.1:2.0]
plain_output_journal_t = 8.0; // [4:1:14]
motor_pilot_pocket_depth = 1.8; // [0.8:0.2:3.0]

/* [Manufacturing report] */
spec_output = "Selected part"; // [Off,Selected part,All parts,Hardware BOM]
spec_include_hardware = true;
stock_margin_xy = 2.0; // [0:0.5:10]


/* [Preset status] */
// Informational. Choose a named profile from the Customizer Preset menu.
// The companion v1_10.json updates the editable fields below; you can then adjust any value.
profile_name = "NEMA17 Commodity R15";

/* [Standard hardware catalog] */
// Catalog driven = bearing boundary dimensions come from the selected designation.
// Legacy preset dimensions preserves v1.0/v1.1 numeric behavior where applicable.
hardware_catalog_mode = "Catalog driven"; // [Catalog driven,Legacy preset dimensions]
ecc_bearing_select = "6000ZZ"; // [Auto,608ZZ,6000ZZ,61801,61901,61902,61903,61805,61806,Custom]
output_roller_bearing_select = "625ZZ"; // [Auto,623ZZ,624ZZ,625ZZ,626ZZ,608ZZ,6000ZZ,6001,Custom]
flange_bearing_select = "6814ZZ"; // [Auto,6813ZZ,6814ZZ,61813,61816,61817,61818,61821,61822,61824,61828,Custom]
bearing_closure_preference = "2Z"; // [2RS,2Z,Open]

// Ring roller construction.
// Standard mode uses two catalog bearings per ring axle, one aligned with each cycloid.
// Sleeve mode preserves the compact fabricated wear-sleeve architecture from v1.1.
ring_roller_system = "Standard miniature bearings"; // [Standard miniature bearings,Compact hardened sleeves]
ring_bearing_select = "624ZZ"; // [Auto,623ZZ,624ZZ,625ZZ,685VV,625,686AVV,626,688AVV,608ZZ,608,6800VV,6000ZZ,6000,6801VV,6001,Custom]
ring_bearing_closure_note = "VV/non-contact sealed preferred";

// Custom bearing boundary dimensions, used only when a selector is Custom.
custom_ecc_bearing_id = 15;
custom_ecc_bearing_od = 28;
custom_ecc_bearing_w = 7;
custom_output_roller_id = 8;
custom_output_roller_od = 22;
custom_output_roller_w = 7;
custom_flange_bearing_id = 90;
custom_flange_bearing_od = 115;
custom_flange_bearing_w = 13;
custom_ring_bearing_id = 8;
custom_ring_bearing_od = 16;
custom_ring_bearing_w = 5;

/* [Motor / Preset] */
motor_frame = "NEMA17"; // [NEMA17,NEMA23,NEMA34,CUSTOM]
use_frame_preset = false;
ratio_preset = "Custom"; // [11,13,15,17,18,21,25,29,Custom]
custom_ratio = 15;
torque_class = "Medium"; // [Light,Medium,Heavy]
rear_pin_capture = "Auto"; // [Auto,Blind pockets,Rear keeper]

// CUSTOM / override motor values (mm). Set use_frame_preset=false to use these.
custom_frame_side = 42.30; // [30:0.05:100]
custom_mount_spacing = 31.00; // [20:0.05:80]
custom_motor_pilot_d = 22.00; // [10:0.05:80]
custom_mount_hole_d = 3.50; // [2:0.05:10]
custom_motor_shaft_d = 5.00; // [3:0.05:16]

/* [Input Shaft / Motor Offset] */
// Direct preserves the original compact layout. Coupled uses a fabricated stepped shaft
// with a female socket over the existing motor shaft and a registered motor spacer.
input_shaft_mode = "Direct motor shaft"; // [Direct motor shaft,Machined coupled shaft]
motor_shaft_protrusion_setting = 20.0; // [8:0.5:50]
motor_pilot_height_setting = 2.0; // [0.5:0.25:6]
coupled_drive_shaft_d_setting = 5.0; // [4:0.05:20]
coupled_hub_od_setting = 12.0; // [8:0.25:32]
coupled_socket_depth_setting = 10.0; // [5:0.5:25]
coupled_socket_diametral_clearance = 0.05; // [0.01:0.01:0.25]
coupled_socket_front_wall = 2.0; // [1:0.25:5]
coupled_shaft_end_clearance = 0.5; // [0.2:0.1:2]
coupled_min_engagement = 8.0; // [4:0.5:20]
motor_mount_offset_setting = 22.5; // [0:0.5:50]
motor_spacer_register_height = 1.5; // [0.5:0.25:3]
motor_spacer_radial_clearance = 0.30; // [0.10:0.05:1.0]
coupled_set_screw_thread = "M3"; // [M3,M4,M5]
coupled_set_screw_count = 2; // [1,2]
// When using a machined coupled shaft, integrate the two 180-degree eccentric journals
// into the same shaft or retain the earlier separate eccentric sleeves.
coupled_eccentric_mode = "Integrated double eccentric"; // [Integrated double eccentric,Separate eccentric sleeves]
integrated_coupling_hub_od_setting = 9.5; // [8:0.25:32]
integrated_rear_assembly_clearance = 0.15; // [0.05:0.05:0.50]
integrated_front_extension = 3.0; // [1:0.5:10]

/* [Editable preset geometry] */
// These are populated by the Customizer presets and remain directly editable afterwards.
ring_pitch_base_r_setting = 42.0; // [20:0.25:120]
compact_ring_axle_d_setting = 6.0; // [3:0.25:16]
compact_ring_roller_od_setting = 8.0; // [6:0.25:24]
eccentricity_setting = 1.0; // [0.4:0.05:4.0]
cycloid_disc_t_setting = 8.0; // [3:0.25:16]
output_pin_circle_r_setting = 25.0; // [15:0.25:70]
rear_plate_t_setting = 4.0; // [3:0.25:14]
output_face_t_setting = 8.0; // [4:0.25:18]
housing_base_r_setting = 53.0; // [35:0.5:130]
tie_base_r_setting = 48.0; // [30:0.5:120]
tie_clear_d_setting = 4.5; // [3:0.1:10]
output_center_bore_d_setting = 14.0; // [8:0.5:50]

/* [Cycloidal tuning] */
profile_resolution = 900;
profile_clearance_radial = 0.04;
output_orbit_clearance_d = 0.12;
min_design_web = 2.50;
disc_gap = 0.20;
rear_running_gap = 0.25;
front_running_gap = 0.25;

/* [Nominal fits - tune to your machine/material/bearing maker] */
ring_axle_press = 0.015;
ring_axle_slip = 0.025;
output_pin_press = 0.015;
output_pin_hub_slip = 0.025;
bearing_pocket_interference = 0.015;
flange_hub_interference = 0.005;
motor_shaft_slip = 0.030;
eccentric_bearing_inner_interference = 0.010;

/* [Pancake output interface] */
output_mount_count = 8;
output_face_radial_clearance = 0.80;
output_bearing_race_overlap_fraction = 0.35;

/* [Housing / fastening] */
tie_count = 6;
inner_retainer_screw_count = 4;
bearing_retainer_t = 3.0;
case_wall_clearance = 1.00;

/* [Display quality] */
$fn = 128;

// -----------------------------------------------------------------------------
// SIMPLIFICATION STATE
// -----------------------------------------------------------------------------
simplify_level_1 = simplification_level!="Full hardware";
simplify_level_2 = simplification_level=="Direct pin and cam contact" || simplification_level=="Bearingless printed journals";
simplify_level_3 = simplification_level=="Bearingless printed journals";
use_integrated_ring_ridges = simplify_level_1;
use_reinforced_ring_lobes = use_integrated_ring_ridges && printed_ring_feature_style=="Case-rooted lobes";
use_eccentric_bearings = !simplify_level_2;
use_output_roller_bearings = !simplify_level_2;
use_flange_bearing = !simplify_level_3;
use_input_plain_journal = simplify_level_3;
use_coupled_input_shaft = input_shaft_mode=="Machined coupled shaft";
use_integrated_eccentric_shaft = use_coupled_input_shaft && coupled_eccentric_mode=="Integrated double eccentric";
use_separate_eccentric_sleeves = !use_integrated_eccentric_shaft;

// -----------------------------------------------------------------------------
// ACTIVE EDITABLE CONFIGURATION
// -----------------------------------------------------------------------------
// v1.9 uses OpenSCAD Customizer parameter sets for named profiles. The preset
// writes literal values into the controls above, so those values remain editable.
active_motor_frame = motor_frame;
active_torque_class = torque_class;
active_hardware_catalog_mode = hardware_catalog_mode;
active_ring_roller_system = ring_roller_system;
active_bearing_closure_preference = bearing_closure_preference;
active_ring_bearing_closure_note = ring_bearing_closure_note;

// -----------------------------------------------------------------------------
// PRESET VALUES
// -----------------------------------------------------------------------------
function choose(n17,n23,n34,custom) =
    use_frame_preset ?
        (active_motor_frame=="NEMA17" ? n17 :
         active_motor_frame=="NEMA23" ? n23 :
         active_motor_frame=="NEMA34" ? n34 : custom)
    : custom;

function duty(light,medium,heavy) =
    active_torque_class=="Light" ? light : active_torque_class=="Heavy" ? heavy : medium;

// Vendor-neutral catalog boundary dimensions. SKF-style ISO designations are used
// for the 618/619 families. 68xx/69xx shorthand from other suppliers is equivalent
// in boundary size but suffixes/seals must be verified before purchase.
function bearing_dims(code) =
    // Common shielded commodity bearings. Exact ZZ designations are retained in BOM output.
    code=="623ZZ" ? [3,10,4] :
    code=="624ZZ" ? [4,13,5] :
    code=="625ZZ" ? [5,16,5] :
    code=="626ZZ" ? [6,19,6] :
    code=="608ZZ" ? [8,22,7] :
    code=="6000ZZ" ? [10,26,8] :
    code=="6813ZZ" ? [65,85,10] :
    code=="6814ZZ" ? [70,90,10] :
    // Compact miniature variants used for optional ring rollers.
    // VV / AVV entries use the sealed-width boundary dimensions of those designations.
    code=="685VV" ? [5,11,5] :
    code=="625"   ? [5,16,5] :
    code=="686AVV"? [6,13,5] :
    code=="688AVV"? [8,16,5] :
    code=="6800VV"? [10,19,5] :
    code=="6801VV"? [12,21,5] :
    code=="624"   ? [4,13,5] :
    code=="605"   ? [5,14,5] :
    code=="626"   ? [6,19,6] :
    code=="608"   ? [8,22,7] :
    code=="6000"  ? [10,26,8] :
    code=="6001"  ? [12,28,8] :
    code=="61801" ? [12,21,5] :
    code=="61901" ? [12,24,6] :
    code=="61902" ? [15,28,7] :
    code=="61903" ? [17,30,7] :
    code=="61805" ? [25,37,7] :
    code=="61806" ? [30,42,7] :
    code=="61813" ? [65,85,10] :
    code=="61816" ? [80,100,10] :
    code=="61817" ? [85,110,13] :
    code=="61818" ? [90,115,13] :
    code=="61821" ? [105,130,13] :
    code=="61822" ? [110,140,16] :
    code=="61824" ? [120,150,16] :
    code=="61828" ? [140,175,18] : [0,0,0];
function bd(code)=bearing_dims(code)[0];
function bD(code)=bearing_dims(code)[1];
function bB(code)=bearing_dims(code)[2];

frame_side       = choose(42.30,57.15,86.00,custom_frame_side);
mount_spacing    = choose(31.00,47.14,69.60,custom_mount_spacing);
motor_pilot_d    = choose(22.00,38.10,73.00,custom_motor_pilot_d);
mount_hole_d     = choose(3.50,5.20,8.50,custom_mount_hole_d);
motor_shaft_d    = choose(5.00,6.35,12.70,custom_motor_shaft_d);
drive_shaft_d = use_coupled_input_shaft ? coupled_drive_shaft_d_setting : motor_shaft_d;
motor_mount_offset = use_coupled_input_shaft ? motor_mount_offset_setting : 0;
active_coupled_hub_od = use_integrated_eccentric_shaft ? integrated_coupling_hub_od_setting : coupled_hub_od_setting;

selected_ratio = ratio_preset=="Custom" ? custom_ratio :
                 ratio_preset=="11" ? 11 : ratio_preset=="13" ? 13 :
                 ratio_preset=="15" ? 15 : ratio_preset=="17" ? 17 :
                 ratio_preset=="18" ? 18 : ratio_preset=="21" ? 21 :
                 ratio_preset=="25" ? 25 : ratio_preset=="29" ? 29 : custom_ratio;
ring_count = selected_ratio + 1;
lobes = ring_count - 1;
ratio = lobes;

base_ring_pitch_r = ring_pitch_base_r_setting;
legacy_ring_axle_d = compact_ring_axle_d_setting;
legacy_ring_roller_od = compact_ring_roller_od_setting;

// Optional catalog ring bearings. Auto follows the legacy axle diameter and selects
// thin miniature bearings so the pancake envelope stays close to the sleeve version.
ring_bearing_mode = active_ring_roller_system=="Standard miniature bearings";
auto_ring_bearing_code = active_motor_frame=="NEMA17" ? duty("685VV","686AVV","688AVV") :
                         active_motor_frame=="NEMA23" ? duty("686AVV","688AVV","6800VV") :
                         active_motor_frame=="NEMA34" ? duty("688AVV","6800VV","6801VV") : "688AVV";
ring_bearing_code = ring_bearing_select=="Auto" ? auto_ring_bearing_code : ring_bearing_select;
ring_bearing_id = ring_bearing_code=="Custom" ? custom_ring_bearing_id : bd(ring_bearing_code);
ring_bearing_od = ring_bearing_code=="Custom" ? custom_ring_bearing_od : bD(ring_bearing_code);
ring_bearing_w  = ring_bearing_code=="Custom" ? custom_ring_bearing_w  : bB(ring_bearing_code);
ring_bearing_name = ring_bearing_code=="Custom" ? "CUSTOM" : ring_bearing_code;

ring_axle_d = ring_bearing_mode ? ring_bearing_id : legacy_ring_axle_d;
ring_roller_od = ring_bearing_mode ? ring_bearing_od : legacy_ring_roller_od;
ring_pitch_required_for_packing = (ring_roller_od+0.50)/(2*sin(180/ring_count));
// Preserve the v1.1 cycloid inner envelope as roller OD changes; otherwise a larger
// catalog bearing can steal radial web from the output-orbit holes.
ring_pitch_required_for_disc_web = base_ring_pitch_r + max(0,(ring_roller_od-legacy_ring_roller_od)/2);
ring_pitch_r = ring_bearing_mode ? max(base_ring_pitch_r,ring_pitch_required_for_packing,ring_pitch_required_for_disc_web) : base_ring_pitch_r;

eccentricity = eccentricity_setting;

// Eccentric bearing family: auto preset resolves to a real catalog designation.
legacy_ecc_bearing_id = choose(
    duty(12.0,12.0,15.0), duty(12.0,15.0,17.0), duty(25.0,25.0,30.0), duty(12.0,15.0,17.0));
legacy_ecc_bearing_od = choose(
    duty(21.0,24.0,28.0), duty(24.0,28.0,30.0), duty(37.0,37.0,42.0), duty(24.0,28.0,30.0));
legacy_ecc_bearing_w = choose(
    duty(5.0,6.0,7.0), duty(6.0,7.0,7.0), duty(7.0,7.0,7.0), duty(6.0,7.0,7.0));
auto_ecc_bearing_code = active_motor_frame=="NEMA17" ? duty("61801","61901","61902") :
                        active_motor_frame=="NEMA23" ? duty("61901","61902","61903") :
                        active_motor_frame=="NEMA34" ? duty("61805","61805","61806") : "61902";
ecc_bearing_code = ecc_bearing_select=="Auto" ? auto_ecc_bearing_code : ecc_bearing_select;
ecc_catalog = active_hardware_catalog_mode=="Catalog driven";
ecc_bearing_id = ecc_catalog ? (ecc_bearing_code=="Custom" ? custom_ecc_bearing_id : bd(ecc_bearing_code)) : legacy_ecc_bearing_id;
ecc_bearing_od = ecc_catalog ? (ecc_bearing_code=="Custom" ? custom_ecc_bearing_od : bD(ecc_bearing_code)) : legacy_ecc_bearing_od;
ecc_bearing_w  = ecc_catalog ? (ecc_bearing_code=="Custom" ? custom_ecc_bearing_w  : bB(ecc_bearing_code)) : legacy_ecc_bearing_w;
ecc_bearing_name = ecc_catalog ? (ecc_bearing_code=="Custom" ? "CUSTOM" : ecc_bearing_code) : "LEGACY SIZE";

disc_t = cycloid_disc_t_setting;

output_pin_count = 6;
output_pin_circle_r = output_pin_circle_r_setting;
legacy_output_pin_d = choose(
    duty(4.0,5.0,6.0), duty(6.0,8.0,10.0), duty(8.0,10.0,12.0), duty(6.0,8.0,10.0));
legacy_output_roller_od = choose(
    duty(13.0,14.0,19.0), duty(19.0,22.0,26.0), duty(22.0,26.0,28.0), duty(19.0,22.0,26.0));
legacy_output_roller_w = choose(
    duty(5.0,5.0,6.0), duty(6.0,7.0,8.0), duty(7.0,8.0,8.0), duty(6.0,7.0,8.0));
auto_output_roller_code = active_motor_frame=="NEMA17" ? duty("624","605","626") :
                          active_motor_frame=="NEMA23" ? duty("626","608","6000") :
                          active_motor_frame=="NEMA34" ? duty("608","6000","6001") : "608";
output_roller_bearing_code = output_roller_bearing_select=="Auto" ? auto_output_roller_code : output_roller_bearing_select;
output_roller_catalog = active_hardware_catalog_mode=="Catalog driven";
output_pin_d = output_roller_catalog ? (output_roller_bearing_code=="Custom" ? custom_output_roller_id : bd(output_roller_bearing_code)) : legacy_output_pin_d;
output_roller_od = output_roller_catalog ? (output_roller_bearing_code=="Custom" ? custom_output_roller_od : bD(output_roller_bearing_code)) : legacy_output_roller_od;
output_roller_w = output_roller_catalog ? (output_roller_bearing_code=="Custom" ? custom_output_roller_w : bB(output_roller_bearing_code)) : legacy_output_roller_w;
output_roller_bearing_name = output_roller_catalog ? (output_roller_bearing_code=="Custom" ? "CUSTOM" : output_roller_bearing_code) : "LEGACY SIZE";

rear_plate_t = rear_plate_t_setting;
front_pin_plate_t = rear_plate_t;
output_face_t = output_face_t_setting;
base_plate_r = housing_base_r_setting;
base_tie_r = tie_base_r_setting;
tie_clear_d = tie_clear_d_setting;

// Large pancake output bearing. Auto presets use ISO/SKF 618-series designations.
legacy_flange_bearing_id = choose(
    duty(65.0,65.0,85.0), duty(80.0,90.0,105.0), duty(110.0,120.0,140.0), duty(80.0,90.0,105.0));
legacy_flange_bearing_od = choose(
    duty(85.0,85.0,110.0), duty(100.0,115.0,130.0), duty(140.0,150.0,175.0), duty(100.0,115.0,130.0));
legacy_flange_bearing_w = choose(
    duty(10.0,10.0,13.0), duty(10.0,13.0,13.0), duty(16.0,16.0,18.0), duty(10.0,13.0,13.0));
auto_flange_bearing_code = active_motor_frame=="NEMA17" ? duty("61813","61813","61817") :
                           active_motor_frame=="NEMA23" ? duty("61816","61818","61821") :
                           active_motor_frame=="NEMA34" ? duty("61822","61824","61828") : "61818";
flange_bearing_code = flange_bearing_select=="Auto" ? auto_flange_bearing_code : flange_bearing_select;
flange_catalog = active_hardware_catalog_mode=="Catalog driven";
flange_bearing_id = flange_catalog ? (flange_bearing_code=="Custom" ? custom_flange_bearing_id : bd(flange_bearing_code)) : legacy_flange_bearing_id;
flange_bearing_od = flange_catalog ? (flange_bearing_code=="Custom" ? custom_flange_bearing_od : bD(flange_bearing_code)) : legacy_flange_bearing_od;
flange_bearing_w = flange_catalog ? (flange_bearing_code=="Custom" ? custom_flange_bearing_w : bB(flange_bearing_code)) : legacy_flange_bearing_w;
flange_bearing_name = flange_catalog ? (flange_bearing_code=="Custom" ? "CUSTOM" : flange_bearing_code) : "LEGACY SIZE";

// Grow only the outer housing by the extra radial envelope introduced by a ring-bearing
// selection. Sleeve mode therefore keeps the v1.1 external dimensions unchanged.
legacy_ring_outer_r = base_ring_pitch_r + legacy_ring_roller_od/2;
active_ring_outer_r = ring_pitch_r + ring_roller_od/2;
ring_system_radial_growth = ring_bearing_mode ? max(0,active_ring_outer_r-legacy_ring_outer_r) : 0;
plate_r = base_plate_r + ring_system_radial_growth;
tie_r = base_tie_r + ring_system_radial_growth;

// Output face fastening defaults: M4 / M5 / M6 by construction class.
output_mount_tap_d = duty(3.3,4.2,5.0);
output_mount_thread = duty("M4","M5","M6");
output_mount_depth = min(output_face_t-1.5,duty(5.0,7.0,9.0));
inner_retainer_tap_d = duty(3.3,4.2,5.0);
inner_retainer_clear_d = duty(4.5,5.5,6.6);
inner_retainer_thread = duty("M4","M5","M6");

// Hollow center keeps the output face versatile and guarantees input-shaft clearance.
output_center_bore_d = output_center_bore_d_setting;

// Optional rear keeper for ring axles.
rear_keeper_t = duty(3.0,4.0,5.0);
use_rear_keeper = !use_integrated_ring_ridges && (rear_pin_capture=="Rear keeper" ||
                  (rear_pin_capture=="Auto" && active_torque_class=="Heavy"));
rear_capture_label = use_rear_keeper ? "Rear keeper" : "Blind pockets";
rear_keeper_inner_r = max(frame_side*sqrt(2)/2 + 2.0, motor_pilot_d/2 + 6.0);
rear_keeper_outer_r = plate_r;

// -----------------------------------------------------------------------------
// DERIVED GEOMETRY
// -----------------------------------------------------------------------------
ring_roller_r_for_profile = ring_roller_od/2 + profile_clearance_radial;
output_contact_od = use_output_roller_bearings ? output_roller_od : output_pin_d;
output_orbit_hole_d = output_contact_od + 2*eccentricity + (use_output_roller_bearings ? output_orbit_clearance_d : 2*print_radial_clearance);
disc_min_r = ring_pitch_r - eccentricity - ring_roller_r_for_profile;
disc_max_r = ring_pitch_r + eccentricity - ring_roller_r_for_profile;
case_inner_r = ring_pitch_r + ring_roller_od/2 + case_wall_clearance;

rear_axle_blind_depth = max(2.0,min(0.75*ring_axle_d,rear_plate_t-1.5));
front_axle_blind_depth = max(2.0,min(0.75*ring_axle_d,front_pin_plate_t-1.5));

motor_pilot_clear_d = motor_pilot_d + 0.20;
rear_ring_axle_hole_d = ring_axle_d - ring_axle_press;
front_ring_axle_hole_d = ring_axle_d + ring_axle_slip;
ecc_bearing_pocket_d = ecc_bearing_od - bearing_pocket_interference;
ecc_bushing_od = ecc_bearing_id + eccentric_bearing_inner_interference;
ecc_cam_length = use_eccentric_bearings ? ecc_bearing_w : disc_t;
cycloid_center_bore_d = use_eccentric_bearings ? ecc_bearing_pocket_d : ecc_bushing_od + 2*print_radial_clearance;
ecc_drive_bore_d = drive_shaft_d + motor_shaft_slip;
ecc_motor_bore_d = ecc_drive_bore_d; // legacy alias
output_pin_face_hole_d = output_pin_d - output_pin_press;
output_pin_hub_hole_d = output_pin_d + output_pin_hub_slip;

// Output support. Full mode uses the large ball bearing; Level 3 converts the same
// hub/carrier interface into a printed plain journal with adjustable running clearance.
race_retainer_t = bearing_retainer_t;
race_section_d = flange_bearing_od - flange_bearing_id;
race_overlap_d = output_bearing_race_overlap_fraction * race_section_d;
outer_race_retainer_id = flange_bearing_od - race_overlap_d;
inner_race_retainer_od = flange_bearing_id + race_overlap_d;
flange_bearing_pocket_d = flange_bearing_od - bearing_pocket_interference;
output_hub_od = flange_bearing_id + flange_hub_interference;
output_support_t = use_flange_bearing ? flange_bearing_w : plain_output_journal_t;
output_carrier_bore_d = use_flange_bearing ? flange_bearing_pocket_d : output_hub_od + 2*print_radial_clearance;
output_hub_t = use_flange_bearing ? race_retainer_t + flange_bearing_w : race_retainer_t + output_support_t + 2*print_axial_clearance;
input_plain_journal_bore_d = drive_shaft_d + 2*print_radial_clearance;
active_motor_pilot_pocket_depth = min(motor_pilot_pocket_depth,max(0.6,rear_plate_t-1.0));

// Coupled-input geometry is referenced to the gearbox rear face at z=0.
coupled_socket_d = motor_shaft_d + coupled_socket_diametral_clearance;
coupled_socket_front_z = -coupled_socket_front_wall;
coupled_socket_rear_z = coupled_socket_front_z - coupled_socket_depth_setting;
coupled_hub_rear_z = coupled_socket_rear_z;
coupled_hub_length = -coupled_hub_rear_z;
motor_face_z = -motor_mount_offset;
motor_shaft_end_z = motor_face_z + motor_shaft_protrusion_setting;
motor_pilot_front_z = motor_face_z + motor_pilot_height_setting;
coupled_socket_engagement = max(0,min(coupled_socket_depth_setting,motor_shaft_end_z-coupled_socket_rear_z));
coupled_socket_bottom_clearance = coupled_socket_front_z-motor_shaft_end_z;
coupled_recommended_motor_offset = motor_shaft_protrusion_setting + coupled_socket_front_wall + coupled_shaft_end_clearance;
coupled_spacer_through_d = active_coupled_hub_od + 2*motor_spacer_radial_clearance;
coupled_spacer_pilot_pocket_d = motor_pilot_d + 0.20;
coupled_spacer_pilot_pocket_depth = min(motor_mount_offset,max(0,motor_pilot_height_setting+0.20));
coupled_spacer_register_od = motor_pilot_d - 0.05;
coupled_set_screw_tap_d = coupled_set_screw_thread=="M5" ? 4.2 : coupled_set_screw_thread=="M4" ? 3.3 : 2.5;
integrated_rear_passage_d = use_eccentric_bearings ? ecc_bearing_id : cycloid_center_bore_d;
integrated_shaft_blank_od = max(active_coupled_hub_od, ecc_bushing_od + 2*eccentricity);

// Output face fits inside the stationary front retainer, visually similar to a
// commercial pancake actuator with a visible stationary outer annulus.
output_face_d = min(flange_bearing_id + duty(10.0,12.0,14.0),
                    outer_race_retainer_id - output_face_radial_clearance);
output_face_r = output_face_d/2;
output_mount_r = min(output_face_r - duty(5.0,6.0,7.0),
                     output_pin_circle_r + output_pin_d/2 + duty(6.0,7.0,8.0));
output_mount_rot = 360/(2*output_mount_count);
inner_retainer_screw_r = (output_center_bore_d/2 + (output_pin_circle_r-output_pin_d/2))/2;
output_pin_press_depth = min(output_face_t-1.5,1.25*output_pin_d);

// Only the output pins need to pass through the front ring-pin closure plate.
front_center_clear_d = 2*(output_pin_circle_r + output_pin_d/2 + 2.0);

// Axial stack. Level 3 omits the two stationary outer-race retainers and uses the
// inner retainer/output face as the two thrust shoulders around a printed journal.
cavity_h = rear_running_gap + disc_t + disc_gap + disc_t + front_running_gap;
front_pin_z = rear_plate_t + cavity_h;
race_backer_z = front_pin_z + front_pin_plate_t;
bearing_carrier_z = use_flange_bearing ? race_backer_z + race_retainer_t : race_backer_z + race_retainer_t + print_axial_clearance;
bearing_front_z = bearing_carrier_z + output_support_t;
output_face_z = use_flange_bearing ? bearing_front_z : bearing_front_z + print_axial_clearance;
output_front_z = output_face_z + output_face_t;

disc1_z = rear_plate_t + rear_running_gap;
disc2_z = disc1_z + disc_t + disc_gap;
// Each catalog ring bearing is centered on its corresponding cycloid disc.
ring_bearing1_z = disc1_z + (disc_t-ring_bearing_w)/2;
ring_bearing2_z = disc2_z + (disc_t-ring_bearing_w)/2;
ring_axle_start_z = use_rear_keeper ? -rear_keeper_t : rear_plate_t-rear_axle_blind_depth;
ring_axle_end_z = front_pin_z + front_axle_blind_depth;
ring_axle_length = ring_axle_end_z-ring_axle_start_z;
ring_sleeve_length = 2*disc_t + disc_gap;

output_pin_rear_extension = 1.0;
output_pin_start_z = disc1_z-output_pin_rear_extension;
output_pin_end_z = output_face_z + output_pin_press_depth;
output_pin_length = output_pin_end_z-output_pin_start_z;
minimum_drive_shaft_from_rear_plate = rear_plate_t + rear_running_gap + 2*ecc_cam_length + disc_gap;
integrated_shaft_front_z = minimum_drive_shaft_from_rear_plate + integrated_front_extension;
minimum_motor_shaft_from_face = use_coupled_input_shaft ?
    (motor_mount_offset - coupled_socket_depth_setting - coupled_socket_front_wall + coupled_min_engagement) :
    minimum_drive_shaft_from_rear_plate;
overall_motor_to_output_depth = output_front_z + motor_mount_offset;

// -----------------------------------------------------------------------------
// SANITY CHECKS / BUILD REPORT
// -----------------------------------------------------------------------------
assert(selected_ratio==floor(selected_ratio) && selected_ratio>=7,
       "Reduction ratio must be an integer >= 7.");
assert(!ecc_catalog || ecc_bearing_code=="Custom" || bd(ecc_bearing_code)>0, "Unknown eccentric bearing designation.");
assert(!output_roller_catalog || output_roller_bearing_code=="Custom" || bd(output_roller_bearing_code)>0, "Unknown output roller bearing designation.");
assert(!flange_catalog || flange_bearing_code=="Custom" || bd(flange_bearing_code)>0, "Unknown flange bearing designation.");
assert(!ring_bearing_mode || ring_bearing_code=="Custom" || bd(ring_bearing_code)>0, "Unknown ring bearing designation.");
assert(!ring_bearing_mode || ring_bearing_w <= disc_t+0.25,
       "Selected ring bearing is wider than the cycloid disc; choose a thinner bearing or thicker disc.");
assert(!use_eccentric_bearings || ecc_bearing_w <= disc_t+0.25,
       "Eccentric bearings overlap axially; use thicker cycloid discs or a narrower eccentric bearing.");

assert(2*ring_pitch_r*sin(180/ring_count) > ring_roller_od + 0.35,
       "Ring rollers are too tightly packed for this frame/ratio.");
assert(disc_min_r>0,"Cycloid parameters create an invalid disc.");
assert(output_pin_circle_r + output_orbit_hole_d/2 < disc_min_r-min_design_web,
       "Output orbital holes break through cycloid perimeter or leave too little web.");
assert(output_pin_circle_r-output_orbit_hole_d/2 > ecc_bearing_od/2+min_design_web,
       "Output orbital holes are too close to the eccentric bearing bore.");
assert(!use_separate_eccentric_sleeves || (ecc_bushing_od-ecc_motor_bore_d)/2-eccentricity>1.0,
       "Eccentric sleeve wall is too thin.");
assert(!use_integrated_eccentric_shaft || ecc_bushing_od/2 > eccentricity + drive_shaft_d/2 + 0.50,
       "Integrated eccentric journal does not fully contain the concentric shaft core; reduce shaft diameter/eccentricity or increase eccentric bearing ID.");
assert(!use_integrated_eccentric_shaft || active_coupled_hub_od <= integrated_rear_passage_d-integrated_rear_assembly_clearance,
       "Integrated shaft coupling hub is too large to assemble the rear cycloid/bearing from the coupling end. Reduce integrated hub OD or select a larger eccentric bearing/bore.");
assert(!use_coupled_input_shaft || active_coupled_hub_od > coupled_socket_d + 4.0,
       "Coupled shaft hub needs at least 2 mm radial wall around the motor-shaft socket.");
assert(!use_coupled_input_shaft || motor_mount_offset >= motor_pilot_height_setting + 0.20 + coupled_socket_depth_setting + coupled_socket_front_wall,
       "Motor offset is too short: motor pilot would overlap the coupled-shaft hub/socket region.");
assert(!use_coupled_input_shaft || coupled_socket_bottom_clearance >= coupled_shaft_end_clearance-0.05,
       "Motor shaft would bottom in the coupled-shaft socket; increase motor mount offset or reduce shaft protrusion.");
assert(!use_coupled_input_shaft || coupled_socket_engagement >= coupled_min_engagement,
       "Insufficient motor-shaft engagement in coupled input shaft; reduce motor offset or increase motor shaft protrusion/socket depth.");
assert(!use_coupled_input_shaft || motor_spacer_register_height < rear_plate_t-0.4,
       "Motor spacer register is too tall for the rear plate thickness.");

assert(rear_axle_blind_depth <= rear_plate_t-1.0 && front_axle_blind_depth <= front_pin_plate_t-1.0,
       "Blind ring-axle pocket leaves insufficient plate skin.");
assert(front_center_clear_d/2 + 1.0 < ring_pitch_r-ring_axle_d/2,
       "Front center opening collides with the ring-axle capture pockets.");
assert(!use_flange_bearing || flange_bearing_id/2 > output_pin_circle_r + output_contact_od/2 + 1.5,
       "Pancake output bearing ID is too small to clear the output contact envelope.");
assert(tie_r-tie_clear_d/2 > (use_flange_bearing ? flange_bearing_od/2 : output_carrier_bore_d/2) + 1.5,
       "Housing tie holes are too close to the output support bore.");
assert(tie_r+tie_clear_d/2 < plate_r-1.5,
       "Housing tie holes are too close to the outside edge.");
assert(!use_flange_bearing || output_face_d + output_face_radial_clearance < outer_race_retainer_id,
       "Output face does not clear the stationary bearing retainer.");
assert(!use_flange_bearing || inner_race_retainer_od < outer_race_retainer_id-1.0,
       "Inner and outer bearing retainers overlap.");
assert(output_mount_r-output_mount_tap_d/2 > output_center_bore_d/2+2.0,
       "Output mounting holes are too close to center bore.");
assert(output_mount_r+output_mount_tap_d/2 < output_face_r-2.0,
       "Output mounting holes are too close to flange edge.");
assert(output_pin_circle_r-output_pin_d/2 > output_center_bore_d/2+2.0,
       "Output pin roots are too close to the hollow center.");
assert(inner_retainer_screw_r-inner_retainer_clear_d/2 > output_center_bore_d/2+1.0,
       "Inner-race clamp screws are too close to center bore.");
assert(inner_retainer_screw_r+inner_retainer_clear_d/2 < output_pin_circle_r-output_pin_d/2-1.0,
       "Inner-race clamp screws interfere with output pins.");

if ($preview) {
    echo("====================================================");
    echo("Architecture: PANCAKE FLANGE OUTPUT");
    echo(str("Configuration profile: ",profile_name));
    echo(str("Motor frame: ",active_motor_frame));
    echo(str("Ratio: ",ratio,":1 | torque class: ",active_torque_class));
    echo(str("Ring rollers / lobes: ",ring_count," / ",lobes));
    echo(str("Simplification: ",simplification_level));
    echo(str("Ring roller system: ",use_integrated_ring_ridges ? "PRINTED INTEGRATED RIDGES" : active_ring_roller_system));
    if(ring_bearing_mode && !use_integrated_ring_ridges) echo(str("Ring bearing: ",ring_bearing_name," = ",ring_bearing_id,"x",ring_bearing_od,"x",ring_bearing_w," mm | qty ",2*ring_count));
    if(use_integrated_ring_ridges) echo(str("Printed ring ridges: ",ring_count,"x OD ",ring_roller_od," mm, full cavity height ",cavity_h," mm"));
    echo(str("Ring pitch radius: ",ring_pitch_r," mm | radial housing growth vs sleeve baseline: ",ring_system_radial_growth," mm"));
    echo(str("Housing OD: ",2*plate_r," mm"));
    echo(str("Output face OD: ",output_face_d," mm"));
    echo(str("Eccentric support: ",use_eccentric_bearings ? str(ecc_bearing_name," = ",ecc_bearing_id,"x",ecc_bearing_od,"x",ecc_bearing_w," mm") : str("DIRECT CAM IN CYCLOID, bore ",cycloid_center_bore_d," mm")));
    echo(str("Output pin contact: ",use_output_roller_bearings ? str(output_roller_bearing_name," = ",output_pin_d,"x",output_roller_od,"x",output_roller_w," mm") : str("DIRECT ",output_pin_d," mm PIN IN CYCLOID")));
    echo(str("Output support: ",use_flange_bearing ? str(flange_bearing_name," = ",flange_bearing_id,"x",flange_bearing_od,"x",flange_bearing_w," mm") : str("PRINTED PLAIN JOURNAL OD ",output_hub_od," / bore ",output_carrier_bore_d," mm")));
    if(profile_name=="NEMA17 Commodity R15" && !simplify_level_1) echo("Commodity profile hardware: 624ZZ ring rollers on 4mm rod | 625ZZ output rollers on 5mm rod | 6000ZZ eccentric bearings | 6814ZZ flange bearing");
    if(profile_name=="NEMA17 Commodity R15" && simplify_level_1) echo("Commodity profile base dimensions active; simplification overrides remove the hardware reported below.");
    echo(str("Overall gearbox depth from motor face to output face: ",overall_motor_to_output_depth," mm"));
    echo(str("Input shaft system: ",input_shaft_mode,use_coupled_input_shaft?str(" | ",coupled_eccentric_mode," | motor offset ",motor_mount_offset," mm | drive shaft ",drive_shaft_d," mm"):""));
    echo(str("Cycloid chamber height: ",cavity_h," mm"));
    echo(str("Output bolt pattern: ",output_mount_count,"x ",output_mount_thread," blind @ PCD ",2*output_mount_r," mm"));
    echo(str("Output center bore: ",output_center_bore_d," mm"));
    echo(str("Rear ring contact/capture: ",use_integrated_ring_ridges ? "Integrated case ridges; no ring axles" : rear_capture_label));
    if(!use_integrated_ring_ridges) echo(str("Ring axle cut length: ",ring_axle_length," mm"));
    echo(str("Output pin cut length: ",output_pin_length," mm"));
    if(use_coupled_input_shaft) {
        echo(str("Configured motor shaft protrusion: ",motor_shaft_protrusion_setting," mm | socket engagement ",coupled_socket_engagement," mm | bottom clearance ",coupled_socket_bottom_clearance," mm"));
        if(use_integrated_eccentric_shaft) echo(str("Integrated journals: 2x OD ",ecc_bushing_od," mm | offsets +/-",eccentricity," mm | rear assembly passage ",integrated_rear_passage_d," mm vs hub OD ",active_coupled_hub_od," mm"));
        echo(str("Recommended motor offset for current shaft length: ",coupled_recommended_motor_offset," mm"));
    } else echo(str("Minimum motor shaft protrusion: ",minimum_motor_shaft_from_face," mm"));
    echo("====================================================");
}

// -----------------------------------------------------------------------------
// MANUFACTURING SPECS
// -----------------------------------------------------------------------------
function rough_xy(envelope)=envelope+2*stock_margin_xy;
function common_inch_stock_t(t)=
    t<=3.175?3.175:t<=4.7625?4.7625:t<=6.35?6.35:t<=7.9375?7.9375:
    t<=9.525?9.525:t<=12.7?12.7:t<=15.875?15.875:t<=19.05?19.05:
    t<=25.4?25.4:t<=31.75?31.75:t<=38.1?38.1:t;
function part_is_single(which)=
    which=="motor_standoff_plate" || which=="motor_standoff_pilot_pocket_template" || which=="coupled_input_shaft" || which=="rear_plate" || which=="rear_motor_pilot_pocket_template" || which=="rear_pin_drill_template" || which=="rear_keeper_plate" ||
    which=="case_ring" || which=="front_pin_plate" || which=="front_pin_drill_template" ||
    which=="bearing_race_retainer" || which=="bearing_carrier" || which=="cycloid_disc" ||
    which=="output_face_plate" || which=="output_face_front_drill_template" ||
    which=="output_face_rear_drill_template" || which=="output_hub_ring" ||
    which=="inner_race_retainer" || which=="eccentric_A" || which=="eccentric_B" || which=="input_stack";

module spec_header(scope="ALL") {
    echo("================ MANUFACTURING SPECS ================");
    echo(str("SPEC|scope=",scope,"|version=1.10|architecture=PANCAKE_FLANGE|simplification=",simplification_level,"|profile=",profile_name,"|motor=",active_motor_frame,
             "|ratio=",ratio,":1|torque_class=",active_torque_class,"|hardware_catalog_mode=",active_hardware_catalog_mode,
             "|ring_roller_system=",use_integrated_ring_ridges ? "PRINTED_INTEGRATED_RIDGES" : active_ring_roller_system,
             "|ring_roller_part=",use_integrated_ring_ridges ? "PRINTED_CASE_FEATURE" : (ring_bearing_mode ? ring_bearing_name : "FABRICATED_SLEEVE")));
}
module spec_rear_plate() {
    env=2*plate_r;
    echo(str("SPEC|part=rear_plate|qty=1|material=",simplify_level_1?"PRINTABLE POLYMER OR ALUMINUM":"6061-T6","|finished_envelope=",env,"x",env,
             "mm|thickness=",rear_plate_t,"mm|common_inch_stock_t=",common_inch_stock_t(rear_plate_t),
             "mm|rough_blank_xy=",rough_xy(env),"x",rough_xy(env),"mm|motor_center=",
             use_input_plain_journal ? str("plain shaft journal ",input_plain_journal_bore_d,"mm + motor-side pilot pocket ",motor_pilot_clear_d,"mm depth ",active_motor_pilot_pocket_depth,"mm") : str("through pilot ",motor_pilot_clear_d,"mm"),
             "|motor_mount=4x",mount_hole_d,"mm @ ",mount_spacing,"mm square|ring_capture=",use_integrated_ring_ridges?"NONE - CONTACT RIDGES IN CASE":rear_capture_label,
             "|rear_blind_depth=",use_integrated_ring_ridges?0:rear_axle_blind_depth,"mm|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm"));
}
module spec_case_ring(){env=2*plate_r;echo(str("SPEC|part=case_ring|qty=1|material=",simplify_level_1?"PRINTABLE POLYMER OR ALUMINUM":"6061-T6","|finished_envelope=",env,"x",env,
             "mm|thickness=",cavity_h,"mm|common_inch_stock_t=",common_inch_stock_t(cavity_h),
             "mm|rough_blank_xy=",rough_xy(env),"x",rough_xy(env),"mm|nominal_inner_radius=",case_inner_r,"mm|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm",
             use_integrated_ring_ridges ? str("|INTEGRATED_RING_RIDGES=",ring_count,"x OD ",ring_roller_od,"mm @ PCD ",2*ring_pitch_r,"mm|bridge_width=",printed_ring_bridge_width,"mm") : ""));}
module spec_front_pin(){env=2*plate_r;echo(str("SPEC|part=front_pin_plate|qty=1|material=",simplify_level_1?"PRINTABLE POLYMER OR ALUMINUM":"6061-T6","|finished_envelope=",env,"x",env,
             "mm|thickness=",front_pin_plate_t,"mm|common_inch_stock_t=",common_inch_stock_t(front_pin_plate_t),
             "mm|rough_blank_xy=",rough_xy(env),"x",rough_xy(env),"mm|center_clear=",front_center_clear_d,
             use_integrated_ring_ridges ? "mm|ring_axle_blind_pockets=OMITTED - RIDGES IN CASE" : str("mm|ring_axle_blind_pockets=",ring_count,"x",front_ring_axle_hole_d,"mm @ PCD ",2*ring_pitch_r,"mm depth=",front_axle_blind_depth,"mm FROM CAVITY SIDE"),
             "|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm"));}
module spec_race_retainer(){env=2*plate_r;echo(str("SPEC|part=bearing_race_retainer|qty=",use_flange_bearing?"2 IDENTICAL":"0 - OMITTED AT LEVEL 3","|material=6061-T6|finished_envelope=",env,"x",env,
             "mm|thickness=",race_retainer_t,"mm|common_inch_stock_t=",common_inch_stock_t(race_retainer_t),
             "mm|ID=",outer_race_retainer_id,"mm|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,
             "mm|NOTE=rear and front rings axially trap bearing OUTER race"));}
module spec_bearing_carrier(){env=2*plate_r;echo(str("SPEC|part=",use_flange_bearing?"bearing_carrier":"plain_output_journal_carrier","|qty=1|material=",use_flange_bearing?"6061-T6":"PRINTABLE POLYMER OR LOW-FRICTION MATERIAL","|finished_envelope=",env,"x",env,
             "mm|thickness=",output_support_t,"mm|common_inch_stock_t=",common_inch_stock_t(output_support_t),
             use_flange_bearing ? str("mm|bearing_press_bore=",flange_bearing_pocket_d,"mm|bearing_nominal=",flange_bearing_name," ",flange_bearing_id,"x",flange_bearing_od,"x",flange_bearing_w) : str("mm|plain_journal_bore=",output_carrier_bore_d,"mm|hub_OD=",output_hub_od,"mm|radial_clearance=",print_radial_clearance,"mm per side"),
             "|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm"));}
module spec_cycloid(){env=2*disc_max_r;echo(str("SPEC|part=cycloid_disc|qty=2|material=",simplify_level_2?"PRINTABLE POLYMER / TEST MATERIAL":"7075-T6 hard-anodize recommended","|finished_envelope~=",env,"x",env,
             "mm|thickness=",disc_t,"mm|common_inch_stock_t=",common_inch_stock_t(disc_t),
             "mm|center_contact=",use_eccentric_bearings?str("bearing pocket ",ecc_bearing_pocket_d,"mm for ",ecc_bearing_name):str("direct eccentric cam bore ",cycloid_center_bore_d,"mm"),
             "|output_orbit_holes=",output_pin_count,"x",output_orbit_hole_d," @ PCD ",2*output_pin_circle_r,"mm|output_contact=",use_output_roller_bearings?"roller bearing":"direct smooth pin","|lobes=",lobes));}
module spec_output_face(){env=output_face_d;echo(str("SPEC|part=output_face_plate|qty=1|material=7075-T6 preferred|finished_envelope=",env,"x",env,
             "mm|thickness=",output_face_t,"mm|common_inch_stock_t=",common_inch_stock_t(output_face_t),
             "mm|center_bore=",output_center_bore_d,"mm|FRONT blind mounting holes=",output_mount_count,"x ",output_mount_thread,
             " tap drill ",output_mount_tap_d,"mm @ PCD ",2*output_mount_r,"mm depth=",output_mount_depth,
             "mm|REAR output-pin press pockets=",output_pin_count,"x",output_pin_face_hole_d,"mm @ PCD ",2*output_pin_circle_r,"mm depth=",output_pin_press_depth,
             "mm|REAR hub-clamp taps=",inner_retainer_screw_count,"x ",inner_retainer_thread," tap drill ",inner_retainer_tap_d,"mm @ PCD ",2*inner_retainer_screw_r,"mm"));}
module spec_output_hub(){env=output_hub_od;echo(str("SPEC|part=output_hub_ring|qty=1|material=7075-T6 preferred|finished_envelope=",env,"x",env,
             "mm|thickness=",output_hub_t,"mm|common_inch_stock_t=",common_inch_stock_t(output_hub_t),
             use_flange_bearing ? str("mm|bearing_inner_fit_OD=",output_hub_od,"mm for nominal ID ",flange_bearing_id) : str("mm|plain_journal_OD=",output_hub_od,"mm running in carrier bore ",output_carrier_bore_d),
             "mm|center_bore=",output_center_bore_d,"mm|output_pin_slip_holes=",output_pin_count,"x",output_pin_hub_hole_d," @ PCD ",2*output_pin_circle_r,
             "mm|clamp_screw_clearance=",inner_retainer_screw_count,"x",inner_retainer_clear_d," @ PCD ",2*inner_retainer_screw_r,"mm"));}
module spec_inner_retainer(){env=inner_race_retainer_od;echo(str("SPEC|part=inner_race_retainer|qty=1|material=7075-T6 or steel|finished_envelope=",env,"x",env,
             "mm|thickness=",race_retainer_t,"mm|common_inch_stock_t=",common_inch_stock_t(race_retainer_t),
             "mm|center_bore=",output_center_bore_d,"mm|output_pin_clearance=",output_pin_count,"x",output_pin_hub_hole_d+0.20," @ PCD ",2*output_pin_circle_r,
             "mm|clamp_screws=",inner_retainer_screw_count,"x",inner_retainer_clear_d," @ PCD ",2*inner_retainer_screw_r,
             "mm|NOTE=clamps bearing INNER race against output face plate through hub ring"));}
module spec_ecc(which="A") {env=ecc_bushing_od;sgn=which=="A"?1:-1;echo(str("SPEC|part=eccentric_",which,"|qty=",use_integrated_eccentric_shaft?0:1,"|material=",simplify_level_2?"PRINTABLE POLYMER OR METAL":"4140/17-4 preferred","|OD=",env,
             "mm|length=",ecc_cam_length,"mm|drive_bore=",use_integrated_eccentric_shaft?"OMITTED - INTEGRAL JOURNAL":str(ecc_drive_bore_d,"mm"),"|eccentric_offset=",sgn*eccentricity,"mm|support=",use_eccentric_bearings?str(ecc_bearing_name," ",ecc_bearing_id,"x",ecc_bearing_od,"x",ecc_bearing_w,"mm"):str("DIRECT IN CYCLOID BORE ",cycloid_center_bore_d,"mm"),"|",use_integrated_eccentric_shaft?"INTEGRATED INTO COUPLED SHAFT":"side set screw required"));}
module spec_templates(which){
    if(which=="rear_motor_pilot_pocket_template") echo(str("SPEC|operation=rear_motor_pilot_pocket_template|diameter=",motor_pilot_clear_d,"mm|depth=",active_motor_pilot_pocket_depth,"mm FROM MOTOR SIDE|only_required_at_simplification_level_3=",use_input_plain_journal));
    else if(which=="rear_pin_drill_template") echo(str("SPEC|operation=rear_pin_drill_template|",ring_count,"x ",rear_ring_axle_hole_d,"mm @ PCD ",2*ring_pitch_r,"mm|depth=",rear_axle_blind_depth,"mm from cavity side"));
    else if(which=="front_pin_drill_template") echo(str("SPEC|operation=front_pin_drill_template|",ring_count,"x ",front_ring_axle_hole_d,"mm @ PCD ",2*ring_pitch_r,"mm|depth=",front_axle_blind_depth,"mm from cavity side"));
    else if(which=="output_face_front_drill_template") echo(str("SPEC|operation=output_face_FRONT_drill_template|",output_mount_count,"x ",output_mount_thread," tap drill ",output_mount_tap_d,"mm @ PCD ",2*output_mount_r,"mm|depth=",output_mount_depth,"mm"));
    else if(which=="output_face_rear_drill_template") echo(str("SPEC|operation=output_face_REAR_drill_template|pins=",output_pin_count,"x",output_pin_face_hole_d,"mm @ PCD ",2*output_pin_circle_r,"mm depth=",output_pin_press_depth,
             "mm|hub-clamp taps=",inner_retainer_screw_count,"x",inner_retainer_thread," tap drill ",inner_retainer_tap_d,"mm @ PCD ",2*inner_retainer_screw_r,"mm"));
}
module spec_motor_standoff(){
    echo(str("SPEC|part=motor_standoff_plate|qty=",use_coupled_input_shaft?1:0,"|material=6061-T6 OR PRINTABLE POLYMER|outer=",frame_side,"x",frame_side,"mm|thickness=",motor_mount_offset,"mm|through_bore=",coupled_spacer_through_d,"mm|motor_side_pilot_pocket=",coupled_spacer_pilot_pocket_d,"mm x ",coupled_spacer_pilot_pocket_depth,"mm deep|gearbox_register_OD=",coupled_spacer_register_od,"mm|register_height=",motor_spacer_register_height,"mm|mount_holes=4x",mount_hole_d+0.4,"mm @ ",mount_spacing,"mm square"));
}
module spec_coupled_input_shaft(){
    echo(str("SPEC|part=coupled_input_shaft|qty=",use_coupled_input_shaft?1:0,"|style=",coupled_eccentric_mode,"|material=4140 prehard / 17-4 preferred|drive_d=",drive_shaft_d,"mm|hub_OD=",active_coupled_hub_od,"mm|hub_length=",coupled_hub_length,"mm|motor_socket=",coupled_socket_d,"mm x ",coupled_socket_depth_setting,"mm deep|socket_front_wall=",coupled_socket_front_wall,"mm|radial_locking=",coupled_set_screw_count,"x",coupled_set_screw_thread," tap drill ",coupled_set_screw_tap_d,"mm|forward_length_from_rear_face=",integrated_shaft_front_z,"mm",
             use_integrated_eccentric_shaft?str("|integrated_journals=2x OD ",ecc_bushing_od,"mm x ",ecc_cam_length,"mm|journal_offsets=+/-",eccentricity,"mm|journal_z=",disc1_z,",",disc2_z,"mm|blank_OD>=",integrated_shaft_blank_od,"mm|rear_assembly_passage=",integrated_rear_passage_d,"mm"):"|eccentric_journals=SEPARATE SLEEVES"));
}
module input_stack_specs(){
    if(use_coupled_input_shaft){
        echo(str("INPUT_ASSEMBLY|role=central_input_stack|shaft_source=MACHINED_COUPLED_SHAFT|shaft_style=",coupled_eccentric_mode,"|motor_shaft_d=",motor_shaft_d,"mm|drive_shaft_d=",drive_shaft_d,"mm|motor_mount_offset=",motor_mount_offset,"mm|motor_shaft_protrusion=",motor_shaft_protrusion_setting,"mm|socket_engagement=",coupled_socket_engagement,"mm|simplification=",simplification_level,
                 "|assembly_order=",use_integrated_eccentric_shaft?"press rear bearing into rear cycloid -> slide rear cycloid/bearing over coupling end onto rear journal -> slide rear plate and registered spacer over coupling end -> install front cycloid/bearing from front -> couple socket to motor shaft -> lock radial set screws":"fit registered motor spacer -> slide machined shaft socket over motor shaft -> lock radial set screws -> install eccentric sleeves/bearings -> phase sleeves 180deg"));
        spec_motor_standoff();
        spec_coupled_input_shaft();
        echo(str("HARDWARE|source_class=INTEGRATED_MOTOR|role=motor_shaft|qty=1|motor_frame=",active_motor_frame,"|nominal_d=",motor_shaft_d,"mm|configured_protrusion=",motor_shaft_protrusion_setting,"mm|NOTE=verify actual motor shaft length and pilot height before machining spacer/shaft"));
        echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=coupled_shaft_locking_screws|qty=",coupled_set_screw_count,"|thread=",coupled_set_screw_thread,"|NOTE=use opposing/orthogonal screws or a machined flat; threadlocker recommended"));
        echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=motor_mount_screws|qty=4|grip~=",rear_plate_t+motor_mount_offset,"mm plus motor thread engagement"));
    } else {
        echo(str("INPUT_ASSEMBLY|role=central_input_stack|shaft_source=INTEGRATED_NEMA_MOTOR_SHAFT|shaft_d=",motor_shaft_d,"mm|min_shaft_protrusion=",minimum_motor_shaft_from_face,"mm|simplification=",simplification_level,
                 "|assembly_order=press eccentric bearing outer race into cycloid -> press eccentric sleeve into bearing inner race -> slide onto motor shaft -> phase sleeves 180deg"));
        echo(str("HARDWARE|source_class=INTEGRATED_MOTOR|role=input_shaft|qty=1|motor_frame=",active_motor_frame,"|nominal_d=",motor_shaft_d,"mm|min_protrusion=",minimum_motor_shaft_from_face,"mm|gearbox_case_support=",use_input_plain_journal?str("PLAIN PRINTED JOURNAL bore ",input_plain_journal_bore_d,"mm after motor pilot pocket"):"NONE - MOTOR BEARINGS PROVIDE SHAFT SUPPORT","|NOTE=not a separate rod; verify actual motor shaft length/pilot height"));
    }
    if(use_integrated_eccentric_shaft){
        echo(str("FABRICATED_FEATURE|role=integrated_eccentric_journals|qty=2|parent=coupled_input_shaft|OD=",ecc_bushing_od,"mm|length=",ecc_cam_length,"mm|offsets=+/-",eccentricity,"mm|phase=180deg FIXED BY MACHINING|NOTE=no separate sleeves or eccentric set screws"));
    } else {
        echo(str("HARDWARE|source_class=",simplify_level_2?"FABRICATED_OR_PRINTED":"FABRICATED","|role=eccentric_cam_sleeves|qty=2|OD=",ecc_bushing_od,"mm|length=",ecc_cam_length,"mm|drive_bore=",ecc_drive_bore_d,"mm|offset=+/-",eccentricity,"mm|NOTE=phase sleeves 180deg; set screw on thick side recommended"));
        echo("HARDWARE|source_class=STANDARD_FASTENER|role=eccentric_set_screws|qty=2|suggested=M3 cup-point|NOTE=use threadlocker on metal cams; captured/keyed printed cams are preferable for prototypes");
    }
}

module hardware_specs(){
    tie_grip=output_front_z+(use_rear_keeper?rear_keeper_t:0);
    echo("---------------- STANDARD / CATALOG HARDWARE ----------------");
    input_stack_specs();
    if(use_integrated_ring_ridges){
        echo(str("PRINTED_FEATURE|role=ring_contacts|qty=",ring_count,"|geometry=circular ridges OD ",ring_roller_od,"mm @ PCD ",2*ring_pitch_r,"mm|height=",cavity_h,"mm|NOTE=replaces ring axles, sleeves and bearings; friction/wear substantially higher"));
    } else if(ring_bearing_mode){
        echo(str("HARDWARE|source_class=STANDARD_STOCK_CUT|role=ring_axles|qty=",ring_count,"|standard=precision ground hardened shafting h6|nominal_d=",ring_axle_d,"mm|cut_length=",ring_axle_length,"mm"));
        echo(str("HARDWARE|source_class=CATALOG|role=ring_roller_bearings|qty=",2*ring_count,"|designation=",ring_bearing_name,"|size=",ring_bearing_id,"x",ring_bearing_od,"x",ring_bearing_w,"mm|arrangement=2 per ring axle"));
    } else {
        echo(str("HARDWARE|source_class=STANDARD_STOCK_CUT|role=ring_axles|qty=",ring_count,"|standard=ISO 8734 / DIN 6325 hardened dowel or precision shaft stock|nominal_d=",ring_axle_d,"mm|cut_length=",ring_axle_length,"mm"));
        echo(str("HARDWARE|source_class=FABRICATED|role=ring_roller_sleeves|qty=",ring_count,"|finished=",ring_roller_od,"mm OD x ",ring_axle_d+0.08,"mm nominal ID x ",ring_sleeve_length,"mm"));
    }
    if(use_eccentric_bearings) echo(str("HARDWARE|source_class=CATALOG|role=eccentric_bearings|qty=2|designation=",ecc_bearing_name,"|size=",ecc_bearing_id,"x",ecc_bearing_od,"x",ecc_bearing_w,"mm"));
    else echo(str("OMITTED_HARDWARE|role=eccentric_bearings|replaced_by=direct cam in cycloid bore|cam_OD=",ecc_bushing_od,"mm|cycloid_bore=",cycloid_center_bore_d,"mm"));
    echo(str("HARDWARE|source_class=STANDARD_STOCK_CUT|role=output_pins|qty=",output_pin_count,"|standard=smooth precision rod / hardened dowel preferred|nominal_d=",output_pin_d,"mm|cut_length=",output_pin_length,"mm"));
    if(use_output_roller_bearings) echo(str("HARDWARE|source_class=CATALOG|role=output_roller_bearings|qty=",2*output_pin_count,"|designation=",output_roller_bearing_name,"|size=",output_pin_d,"x",output_roller_od,"x",output_roller_w,"mm"));
    else echo(str("OMITTED_HARDWARE|role=output_roller_bearings|replaced_by=direct ",output_pin_d,"mm output pins in orbit holes ",output_orbit_hole_d,"mm"));
    if(use_flange_bearing) echo(str("HARDWARE|source_class=CATALOG|role=pancake_output_bearing|qty=1|designation=",flange_bearing_name,"|size=",flange_bearing_id,"x",flange_bearing_od,"x",flange_bearing_w,"mm"));
    else echo(str("OMITTED_HARDWARE|role=pancake_output_bearing|replaced_by=printed plain journal|hub_OD=",output_hub_od,"mm|carrier_bore=",output_carrier_bore_d,"mm|radial_clearance=",print_radial_clearance,"mm per side|axial_clearance=",print_axial_clearance,"mm per side"));
    echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=housing_tie_bolts|qty=",tie_count,"|clearance=",tie_clear_d,"mm|stack_grip~=",tie_grip,"mm|add nut/thread engagement"));
    echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=output_hub_clamp_screws|qty=",inner_retainer_screw_count,"|thread=",inner_retainer_thread));
    echo(str("CATALOG_STATUS|input_shaft=",input_shaft_mode,"|eccentric_input=",use_integrated_eccentric_shaft?"INTEGRATED_DOUBLE_ECCENTRIC":"SEPARATE_ECCENTRIC_SLEEVES","|simplification=",simplification_level,"|eccentric=",use_eccentric_bearings?ecc_bearing_name:"OMITTED_DIRECT_CAM","|output_roller=",use_output_roller_bearings?output_roller_bearing_name:"OMITTED_DIRECT_PIN","|flange=",use_flange_bearing?flange_bearing_name:"OMITTED_PLAIN_JOURNAL","|ring_roller=",use_integrated_ring_ridges?"PRINTED_CASE_RIDGES":(ring_bearing_mode?str("CATALOG_",ring_bearing_name):"FABRICATED_SLEEVE")));
}
module all_specs(){
    spec_header("ALL PARTS"); if(use_coupled_input_shaft){spec_motor_standoff();spec_coupled_input_shaft();} spec_rear_plate();
    if(use_input_plain_journal) spec_templates("rear_motor_pilot_pocket_template");
    if(!use_rear_keeper && !use_integrated_ring_ridges) spec_templates("rear_pin_drill_template");
    spec_case_ring(); spec_front_pin(); if(!use_integrated_ring_ridges) spec_templates("front_pin_drill_template");
    if(use_flange_bearing) spec_race_retainer();
    spec_bearing_carrier(); spec_cycloid(); spec_output_face();
    spec_templates("output_face_front_drill_template"); spec_templates("output_face_rear_drill_template");
    spec_output_hub(); spec_inner_retainer(); spec_ecc("A"); spec_ecc("B");
    if(spec_include_hardware) hardware_specs(); echo("=======================================================");
}
module selected_spec(which){
    spec_header(which);
    if(which=="motor_standoff_plate") spec_motor_standoff();
    else if(which=="coupled_input_shaft") spec_coupled_input_shaft();
    else if(which=="motor_standoff_pilot_pocket_template") echo(str("SPEC|operation=motor_standoff_pilot_pocket_template|diameter=",coupled_spacer_pilot_pocket_d,"mm|depth=",coupled_spacer_pilot_pocket_depth,"mm FROM MOTOR SIDE"));
    else if(which=="rear_plate") spec_rear_plate();
    else if(which=="rear_motor_pilot_pocket_template" || which=="rear_pin_drill_template" || which=="front_pin_drill_template" || which=="output_face_front_drill_template" || which=="output_face_rear_drill_template") spec_templates(which);
    else if(which=="case_ring") spec_case_ring();
    else if(which=="front_pin_plate") spec_front_pin();
    else if(which=="bearing_race_retainer") spec_race_retainer();
    else if(which=="bearing_carrier") spec_bearing_carrier();
    else if(which=="cycloid_disc") spec_cycloid();
    else if(which=="output_face_plate") spec_output_face();
    else if(which=="output_hub_ring") spec_output_hub();
    else if(which=="inner_race_retainer") spec_inner_retainer();
    else if(which=="eccentric_A") spec_ecc("A");
    else if(which=="eccentric_B") spec_ecc("B");
    else if(which=="input_stack") input_stack_specs();
    if(spec_include_hardware && !part_is_single(which)) hardware_specs();
    echo("=======================================================");
}
if(spec_output=="All parts") all_specs();
else if(spec_output=="Hardware BOM") { spec_header("HARDWARE BOM"); hardware_specs(); echo("======================================================="); }
else if(spec_output=="Selected part") { if(part_is_single(part)) selected_spec(part); else all_specs(); }

// -----------------------------------------------------------------------------
// GEOMETRY HELPERS
// -----------------------------------------------------------------------------
module polar_holes(count,radius,dia,rot=0){
    for(i=[0:count-1]) rotate([0,0,rot+i*360/count]) translate([radius,0]) circle(d=dia);
}
module nema_mount_holes_2d(){for(sx=[-1,1],sy=[-1,1]) translate([sx*mount_spacing/2,sy*mount_spacing/2]) circle(d=mount_hole_d);}
module tie_holes_2d(){polar_holes(tie_count,tie_r,tie_clear_d,360/(2*tie_count));}
module ring_axle_holes_2d(dia){polar_holes(ring_count,ring_pitch_r,dia,0);}
module output_pin_holes_2d(dia){polar_holes(output_pin_count,output_pin_circle_r,dia,0);}
module output_mount_holes_2d(dia){polar_holes(output_mount_count,output_mount_r,dia,output_mount_rot);}
module inner_retainer_screw_holes_2d(dia){polar_holes(inner_retainer_screw_count,inner_retainer_screw_r,dia,45);}

function cycloid_point(t,A,E,Rp,N)=
    let(base_x=A*cos(t)-E*cos((N+1)*t), base_y=A*sin(t)-E*sin((N+1)*t),
        dx_dt=-A*sin(t)+E*(N+1)*sin((N+1)*t), dy_dt=A*cos(t)-E*(N+1)*cos((N+1)*t),
        n_ang=atan2(dy_dt,dx_dt))
    [base_x-Rp*sin(n_ang),base_y+Rp*cos(n_ang)];
cycloid_points=[for(i=[0:profile_resolution-1]) cycloid_point(360*i/profile_resolution,ring_pitch_r,eccentricity,ring_roller_r_for_profile,lobes)];

// -----------------------------------------------------------------------------
// 2D PRODUCTION GEOMETRY
// -----------------------------------------------------------------------------
module integrated_ring_ridges_2d(){
    // Printed stationary ring contacts. In the default case-rooted mode each
    // contact circle is hulled to a wide root that overlaps the annular wall.
    pitch_chord = 2*case_inner_r*sin(180/ring_count);
    root_w = min(pitch_chord*printed_lobe_root_fraction, ring_roller_od*1.45);
    root_inner_x = case_inner_r - printed_lobe_cavity_overlap;
    root_outer_x = min(plate_r-1.0, case_inner_r + printed_lobe_embed_depth);
    root_depth = max(0.5,root_outer_x-root_inner_x);
    bridge_len = case_inner_r - (ring_pitch_r + ring_roller_od/2) + 0.35;
    for(i=[0:ring_count-1]) rotate([0,0,i*360/ring_count]) {
        if(use_reinforced_ring_lobes)
            hull(){
                translate([ring_pitch_r,0]) circle(d=ring_roller_od);
                translate([root_inner_x,-root_w/2]) square([root_depth,root_w]);
            }
        else {
            translate([ring_pitch_r,0]) circle(d=ring_roller_od);
            translate([ring_pitch_r+ring_roller_od/2-0.15,-printed_ring_bridge_width/2])
                square([max(0.5,bridge_len+0.3),printed_ring_bridge_width]);
        }
    }
}

module motor_standoff_plate_2d(){
    difference(){
        square([frame_side,frame_side],center=true);
        circle(d=coupled_spacer_through_d);
        for(sx=[-1,1],sy=[-1,1]) translate([sx*mount_spacing/2,sy*mount_spacing/2]) circle(d=mount_hole_d+0.4);
    }
}
module motor_standoff_pilot_pocket_template_2d(){circle(d=coupled_spacer_pilot_pocket_d);}

module rear_plate_2d(){
    difference(){
        circle(r=plate_r);
        circle(d=use_input_plain_journal ? input_plain_journal_bore_d : motor_pilot_clear_d);
        nema_mount_holes_2d();
        if(use_rear_keeper && !use_integrated_ring_ridges) ring_axle_holes_2d(rear_ring_axle_hole_d);
        tie_holes_2d();
    }
}
module rear_motor_pilot_pocket_template_2d(){circle(d=motor_pilot_clear_d);}
module rear_pin_drill_template_2d(){if(!use_integrated_ring_ridges) ring_axle_holes_2d(rear_ring_axle_hole_d);}
module rear_keeper_plate_2d(){difference(){circle(r=rear_keeper_outer_r);circle(r=rear_keeper_inner_r);if(!use_integrated_ring_ridges) ring_axle_holes_2d(front_ring_axle_hole_d);tie_holes_2d();}}
module case_ring_2d(){
    difference(){
        union(){
            difference(){circle(r=plate_r);circle(r=case_inner_r);}
            if(use_integrated_ring_ridges) integrated_ring_ridges_2d();
        }
        tie_holes_2d();
    }
}
module front_pin_plate_2d(){
    // Ring axle pockets are blind and intentionally omitted from this through-cut DXF.
    difference(){circle(r=plate_r);circle(d=front_center_clear_d);tie_holes_2d();}
}
module front_pin_drill_template_2d(){if(!use_integrated_ring_ridges) ring_axle_holes_2d(front_ring_axle_hole_d);}
module bearing_race_retainer_2d(){difference(){circle(r=plate_r);circle(d=outer_race_retainer_id);tie_holes_2d();}}
module bearing_carrier_2d(){difference(){circle(r=plate_r);circle(d=output_carrier_bore_d);tie_holes_2d();}}
module cycloid_disc_2d(){difference(){polygon(points=cycloid_points);circle(d=cycloid_center_bore_d);polar_holes(output_pin_count,output_pin_circle_r,output_orbit_hole_d,0);}}
module output_face_plate_2d(){difference(){circle(d=output_face_d);circle(d=output_center_bore_d);}}
module output_face_front_drill_template_2d(){output_mount_holes_2d(output_mount_tap_d);}
module output_face_rear_drill_template_2d(){union(){output_pin_holes_2d(output_pin_face_hole_d);inner_retainer_screw_holes_2d(inner_retainer_tap_d);}}
module output_hub_ring_2d(){
    difference(){circle(d=output_hub_od);circle(d=output_center_bore_d);output_pin_holes_2d(output_pin_hub_hole_d);inner_retainer_screw_holes_2d(inner_retainer_clear_d);}
}
module inner_race_retainer_2d(){
    difference(){circle(d=inner_race_retainer_od);circle(d=output_center_bore_d);output_pin_holes_2d(output_pin_hub_hole_d+0.20);inner_retainer_screw_holes_2d(inner_retainer_clear_d);}
}
module eccentric_bushing_2d(sign=1){difference(){circle(d=ecc_bushing_od);translate([-sign*eccentricity,0]) circle(d=ecc_motor_bore_d);}}

// -----------------------------------------------------------------------------
// 3D PARTS
// -----------------------------------------------------------------------------
module motor_standoff_3d(){
    if(use_coupled_input_shaft)
    difference(){
        union(){
            linear_extrude(height=motor_mount_offset,convexity=8) motor_standoff_plate_2d();
            translate([0,0,motor_mount_offset])
                difference(){
                    cylinder(d=coupled_spacer_register_od,h=motor_spacer_register_height);
                    translate([0,0,-0.1]) cylinder(d=coupled_spacer_through_d,h=motor_spacer_register_height+0.2);
                }
        }
        translate([0,0,-0.1]) cylinder(d=coupled_spacer_pilot_pocket_d,h=coupled_spacer_pilot_pocket_depth+0.1);
    }
}
module coupled_input_shaft_3d(angle=0){
    if(use_coupled_input_shaft)
    rotate([0,0,angle])
    difference(){
        union(){
            translate([0,0,coupled_hub_rear_z]) cylinder(d=active_coupled_hub_od,h=coupled_hub_length);
            cylinder(d=drive_shaft_d,h=integrated_shaft_front_z);
            if(use_integrated_eccentric_shaft){
                // Two bearing/direct-contact journals are part of the same shaft and
                // therefore cannot lose their 180-degree phase relationship.
                translate([ eccentricity,0,disc1_z]) cylinder(d=ecc_bushing_od,h=ecc_cam_length);
                translate([-eccentricity,0,disc2_z]) cylinder(d=ecc_bushing_od,h=ecc_cam_length);
            }
        }
        translate([0,0,coupled_socket_rear_z-0.1]) cylinder(d=coupled_socket_d,h=coupled_socket_depth_setting+0.1);
        for(j=[0:coupled_set_screw_count-1])
            rotate([0,0,j*90]) translate([0,0,coupled_socket_rear_z+0.45*coupled_socket_depth_setting])
                rotate([0,90,0]) cylinder(d=coupled_set_screw_tap_d,h=active_coupled_hub_od+2,center=true);
    }
}

module rear_plate_3d(){
    difference(){
        linear_extrude(height=rear_plate_t,convexity=10) rear_plate_2d();
        // Level 3 uses a stepped motor-side pilot pocket plus a small shaft journal.
        if(use_input_plain_journal)
            translate([0,0,-0.1]) cylinder(d=motor_pilot_clear_d,h=active_motor_pilot_pocket_depth+0.1);
        if(!use_rear_keeper && !use_integrated_ring_ridges)
            for(i=[0:ring_count-1]) rotate([0,0,i*360/ring_count])
                translate([ring_pitch_r,0,rear_plate_t-rear_axle_blind_depth]) cylinder(d=rear_ring_axle_hole_d,h=rear_axle_blind_depth+0.2);
    }
}
module front_pin_plate_3d(){
    difference(){
        linear_extrude(height=front_pin_plate_t,convexity=10) front_pin_plate_2d();
        // pockets drilled from cavity/rear face, leaving a solid front skin
        if(!use_integrated_ring_ridges)
            for(i=[0:ring_count-1]) rotate([0,0,i*360/ring_count])
                translate([ring_pitch_r,0,-0.1]) cylinder(d=front_ring_axle_hole_d,h=front_axle_blind_depth+0.1);
    }
}
module output_face_plate_3d(){
    difference(){
        linear_extrude(height=output_face_t,convexity=10) output_face_plate_2d();
        // Rear blind pin pockets
        for(i=[0:output_pin_count-1]) rotate([0,0,i*360/output_pin_count]) translate([output_pin_circle_r,0,-0.1]) cylinder(d=output_pin_face_hole_d,h=output_pin_press_depth+0.1);
        // Rear blind clamp-screw taps. Preview uses tap-drill diameter.
        for(i=[0:inner_retainer_screw_count-1]) rotate([0,0,45+i*360/inner_retainer_screw_count]) translate([inner_retainer_screw_r,0,-0.1]) cylinder(d=inner_retainer_tap_d,h=min(output_face_t-1.5,8)+0.1);
        // Front blind output mounting taps
        for(i=[0:output_mount_count-1]) rotate([0,0,output_mount_rot+i*360/output_mount_count]) translate([output_mount_r,0,output_face_t-output_mount_depth]) cylinder(d=output_mount_tap_d,h=output_mount_depth+0.1);
    }
}
module plate3d(t,which){
    if(which=="rear") rear_plate_3d();
    else if(which=="front_pin") front_pin_plate_3d();
    else linear_extrude(height=t,convexity=10)
        if(which=="rear_keeper") rear_keeper_plate_2d();
        else if(which=="case") case_ring_2d();
        else if(which=="race_retainer") bearing_race_retainer_2d();
        else if(which=="bearing_carrier") bearing_carrier_2d();
        else if(which=="disc") cycloid_disc_2d();
        else if(which=="hub") output_hub_ring_2d();
        else if(which=="inner_retainer") inner_race_retainer_2d();
}
module eccentric_bushing_3d(sign=1){linear_extrude(height=ecc_cam_length,convexity=6) eccentric_bushing_2d(sign);}
module simple_bearing(id,od,w,alpha=1){
    color([0.22,0.22,0.24,alpha]) difference(){cylinder(d=od,h=w);translate([0,0,-0.1]) cylinder(d=id,h=w+0.2);}
    color([0.62,0.62,0.66,alpha]) difference(){cylinder(d=(od+id)/2,h=w);translate([0,0,-0.1]) cylinder(d=(od+id)/2-2,h=w+0.2);}
}
module rotation_marker(radius,z=0,h=1.2,size=2.2,alpha=1){
    // Visualization-only marker so rotation of cylindrical parts is obvious.
    color([0.92,0.12,0.08,alpha]) translate([radius,0,z]) cube([size,size,h],center=true);
}
module motor_shaft_3d(len=minimum_drive_shaft_from_rear_plate+3,angle=0,marker=true,start_z=0){
    translate([0,0,start_z]) rotate([0,0,angle]){
        color([0.62,0.62,0.66]) cylinder(d=motor_shaft_d,h=len);
        if(marker && show_rotation_markers) rotation_marker(max(0.25,motor_shaft_d/2-0.45), min(len-1,2.0), 1.2, max(1.2,motor_shaft_d*0.28));
    }
}
module input_drive_3d(angle=0){
    if(use_coupled_input_shaft){
        motor_shaft_3d(len=motor_shaft_protrusion_setting,angle=angle,start_z=motor_face_z);
        coupled_input_shaft_3d(angle);
    } else motor_shaft_3d(angle=angle);
}
module input_stack_3d(){
    drive_angle=animate_preview ? 360*animation_input_revolutions*$t : 0;
    if(use_coupled_input_shaft) color([0.52,0.55,0.60,0.35]) translate([0,0,-motor_mount_offset]) motor_standoff_3d();
    input_drive_3d(drive_angle);
    rotate([0,0,drive_angle]){
        translate([eccentricity,0,disc1_z]){
            if(use_separate_eccentric_sleeves) color([0.80,0.38,0.16]) eccentric_bushing_3d(+1);
            if(use_eccentric_bearings) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.48);
            if(show_rotation_markers) rotation_marker((use_eccentric_bearings?ecc_bearing_od:ecc_bushing_od)/2-1, ecc_cam_length/2, 1.0, 1.8,0.9);
        }
        translate([-eccentricity,0,disc2_z]){
            if(use_separate_eccentric_sleeves) color([0.18,0.48,0.78]) eccentric_bushing_3d(-1);
            if(use_eccentric_bearings) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.48);
            if(show_rotation_markers) rotation_marker((use_eccentric_bearings?ecc_bearing_od:ecc_bushing_od)/2-1, ecc_cam_length/2, 1.0, 1.8,0.9);
        }
    }
}
module motor_mockup(drive_angle=0){
    body_len=choose(40,56,80,56);
    face_z=motor_face_z;
    color([0.18,0.18,0.20,0.75]) translate([-frame_side/2,-frame_side/2,face_z-body_len]) cube([frame_side,frame_side,body_len]);
    color([0.35,0.35,0.37]) translate([0,0,face_z]) cylinder(d=motor_pilot_d,h=motor_pilot_height_setting);
    motor_shaft_3d(len=use_coupled_input_shaft?motor_shaft_protrusion_setting:minimum_drive_shaft_from_rear_plate+3,angle=drive_angle,start_z=face_z);
}

// -----------------------------------------------------------------------------
// ASSEMBLY
// -----------------------------------------------------------------------------
module assembly(){
    drive_angle=animate_preview ? 360*animation_input_revolutions*$t : 0;
    out_angle=-drive_angle/lobes;
    if(show_motion_debug) echo(str("ANIMATION input_deg=",drive_angle," output_deg=",out_angle," ratio=",lobes,":1"));

    if(show_motor_mockup) motor_mockup(drive_angle);
    else if(show_hardware) {
        if(use_coupled_input_shaft) motor_shaft_3d(len=motor_shaft_protrusion_setting,angle=drive_angle,start_z=motor_face_z);
        else motor_shaft_3d(angle=drive_angle);
    }
    if(use_coupled_input_shaft){
        color([0.52,0.55,0.60,0.65]) translate([0,0,-motor_mount_offset]) motor_standoff_3d();
        if(show_hardware) color([0.34,0.36,0.40]) coupled_input_shaft_3d(drive_angle);
    }
    color([0.65,0.67,0.70]) plate3d(rear_plate_t,"rear");
    if(use_rear_keeper) color([0.48,0.50,0.53]) translate([0,0,-rear_keeper_t]) plate3d(rear_keeper_t,"rear_keeper");
    color([0.55,0.58,0.62,0.30]) translate([0,0,rear_plate_t]) plate3d(cavity_h,"case");

    if(show_hardware && !use_integrated_ring_ridges){
        for(i=[0:ring_count-1]){
            a=i*360/ring_count;
            color([0.30,0.30,0.32]) rotate([0,0,a]) translate([ring_pitch_r,0,ring_axle_start_z]) cylinder(d=ring_axle_d,h=ring_axle_length);
            if(ring_bearing_mode){
                rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing1_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
                rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing2_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
            } else {
                color([0.72,0.72,0.74]) rotate([0,0,a]) translate([ring_pitch_r,0,disc1_z])
                    difference(){cylinder(d=ring_roller_od,h=ring_sleeve_length);translate([0,0,-0.1]) cylinder(d=ring_axle_d+0.08,h=ring_sleeve_length+0.2);}
            }
        }
    }

    rotate([0,0,drive_angle]) translate([eccentricity,0,0]){
        rotate([0,0,out_angle-drive_angle]){
            color([0.80,0.55,0.16]) translate([0,0,disc1_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc1_z+disc_t]) rotation_marker(max(2,ring_pitch_r-ring_roller_od-3),0,1.0,2.4);
        }
        if(show_hardware){if(use_eccentric_bearings) translate([0,0,disc1_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);if(use_separate_eccentric_sleeves) color([0.40,0.42,0.45]) translate([0,0,disc1_z]) eccentric_bushing_3d(+1);}
    }
    rotate([0,0,drive_angle]) translate([-eccentricity,0,0]){
        rotate([0,0,180+out_angle-drive_angle]){
            color([0.88,0.64,0.22]) translate([0,0,disc2_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc2_z+disc_t]) rotation_marker(max(2,ring_pitch_r-ring_roller_od-3),0,1.0,2.4);
        }
        if(show_hardware){if(use_eccentric_bearings) translate([0,0,disc2_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);if(use_separate_eccentric_sleeves) color([0.40,0.42,0.45]) translate([0,0,disc2_z]) eccentric_bushing_3d(-1);}
    }

    // Front ring-pin closure.
    color([0.68,0.70,0.73]) translate([0,0,front_pin_z]) plate3d(front_pin_plate_t,"front_pin");

    // Output support. Levels 0-2 use the catalog bearing sandwich. Level 3
    // uses the carrier itself as a printed plain journal and omits outer-race retainers.
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([0,0,race_backer_z]) plate3d(race_retainer_t,"race_retainer");
    color([0.60,0.62,0.65]) translate([0,0,bearing_carrier_z]) plate3d(output_support_t,"bearing_carrier");
    if(show_hardware && use_flange_bearing) translate([0,0,bearing_carrier_z]) simple_bearing(flange_bearing_id,flange_bearing_od,flange_bearing_w);
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([0,0,bearing_front_z]) plate3d(race_retainer_t,"race_retainer");

    // Rotating flange assembly: inner retainer + hub ring + face plate.
    rotate([0,0,out_angle]){
        color([0.36,0.50,0.66]) translate([0,0,race_backer_z]) plate3d(race_retainer_t,"inner_retainer");
        color([0.38,0.57,0.74]) translate([0,0,race_backer_z]) plate3d(output_hub_t,"hub");
        color([0.27,0.48,0.69]) translate([0,0,output_face_z]) output_face_plate_3d();
        if(show_rotation_markers) translate([0,0,output_face_z+output_face_t+0.6]) rotation_marker(output_face_d/2-5,0,1.2,3.0);

        if(show_hardware){
            for(i=[0:output_pin_count-1]){
                a=i*360/output_pin_count;
                rotate([0,0,a]) translate([output_pin_circle_r,0,0]){
                    color([0.28,0.28,0.30]) translate([0,0,output_pin_start_z]) cylinder(d=output_pin_d,h=output_pin_length);
                    if(use_output_roller_bearings) translate([0,0,disc1_z]) simple_bearing(output_pin_d,output_roller_od,output_roller_w);
                    if(use_output_roller_bearings) translate([0,0,disc2_z]) simple_bearing(output_pin_d,output_roller_od,output_roller_w);
                }
            }
        }
    }
}


module motion_demo(){
    // Kinematic teaching/cutaway view. This is prescribed geometry motion, not a
    // force/contact simulation. Stationary structure is ghosted so the drive path
    // remains visible throughout the OpenSCAD $t animation.
    drive_angle=animate_preview ? 360*animation_input_revolutions*$t : 0;
    out_angle=-drive_angle/lobes;

    // Motor body and visibly rotating shaft.
    if(show_motor_mockup){
        body_len=choose(40,56,80,56);
        color([0.18,0.18,0.20,0.30]) translate([-frame_side/2,-frame_side/2,-body_len]) cube([frame_side,frame_side,body_len]);
        color([0.35,0.35,0.37,0.45]) translate([0,0,-1.5]) cylinder(d=motor_pilot_d,h=1.5);
    }
    if(use_coupled_input_shaft){
        color([0.52,0.55,0.60,0.18]) translate([0,0,-motor_mount_offset]) motor_standoff_3d();
        motor_shaft_3d(len=motor_shaft_protrusion_setting,angle=drive_angle,start_z=motor_face_z);
        color([0.34,0.36,0.40]) coupled_input_shaft_3d(drive_angle);
    } else motor_shaft_3d(angle=drive_angle);

    // Ghost the stationary rear plate / case but keep the ring rollers obvious.
    color([0.65,0.67,0.70,0.16]) plate3d(rear_plate_t,"rear");
    color([0.55,0.58,0.62,0.10]) translate([0,0,rear_plate_t]) plate3d(cavity_h,"case");
    if(use_integrated_ring_ridges)
        color([0.64,0.66,0.70,0.62]) translate([0,0,rear_plate_t])
            linear_extrude(height=cavity_h) integrated_ring_ridges_2d();
    if(show_hardware && !use_integrated_ring_ridges){
        for(i=[0:ring_count-1]){
            a=i*360/ring_count;
            color([0.30,0.30,0.32]) rotate([0,0,a]) translate([ring_pitch_r,0,ring_axle_start_z]) cylinder(d=ring_axle_d,h=ring_axle_length);
            if(ring_bearing_mode){
                rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing1_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w,0.82);
                rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing2_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w,0.82);
            } else {
                color([0.72,0.72,0.74,0.80]) rotate([0,0,a]) translate([ring_pitch_r,0,disc1_z])
                    difference(){cylinder(d=ring_roller_od,h=ring_sleeve_length);translate([0,0,-0.1]) cylinder(d=ring_axle_d+0.08,h=ring_sleeve_length+0.2);}
            }
        }
    }

    // Disc A: eccentric center follows the input; disc orientation follows output ratio.
    rotate([0,0,drive_angle]) translate([eccentricity,0,0]){
        rotate([0,0,out_angle-drive_angle]){
            color([0.80,0.55,0.16,0.90]) translate([0,0,disc1_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc1_z+disc_t+0.4]) rotation_marker(max(3,ring_pitch_r-ring_roller_od-3),0,1.0,2.5);
        }
        if(show_hardware){
            if(use_eccentric_bearings) translate([0,0,disc1_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.52);
            if(use_separate_eccentric_sleeves) color([0.80,0.38,0.16,0.92]) translate([0,0,disc1_z]) eccentric_bushing_3d(+1);
        }
    }

    // Disc B is 180 degrees out of phase.
    rotate([0,0,drive_angle]) translate([-eccentricity,0,0]){
        rotate([0,0,180+out_angle-drive_angle]){
            color([0.88,0.64,0.22,0.78]) translate([0,0,disc2_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc2_z+disc_t+0.4]) rotation_marker(max(3,ring_pitch_r-ring_roller_od-3),0,1.0,2.5);
        }
        if(show_hardware){
            if(use_eccentric_bearings) translate([0,0,disc2_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.42);
            if(use_separate_eccentric_sleeves) color([0.18,0.48,0.78,0.92]) translate([0,0,disc2_z]) eccentric_bushing_3d(-1);
        }
    }

    // Output pins and a ghosted flange rotate at the reduced output angle.
    rotate([0,0,out_angle]){
        color([0.27,0.48,0.69,0.18]) translate([0,0,output_face_z]) output_face_plate_3d();
        color([0.38,0.57,0.74,0.28]) translate([0,0,race_backer_z]) plate3d(output_hub_t,"hub");
        if(show_rotation_markers) translate([0,0,output_face_z+output_face_t+0.8]) rotation_marker(output_face_d/2-5,0,1.2,3.0);
        if(show_hardware){
            for(i=[0:output_pin_count-1]){
                a=i*360/output_pin_count;
                rotate([0,0,a]) translate([output_pin_circle_r,0,0]){
                    color([0.28,0.28,0.30]) translate([0,0,output_pin_start_z]) cylinder(d=output_pin_d,h=output_pin_length);
                    if(use_output_roller_bearings) translate([0,0,disc1_z]) simple_bearing(output_pin_d,output_roller_od,output_roller_w,0.90);
                    if(use_output_roller_bearings) translate([0,0,disc2_z]) simple_bearing(output_pin_d,output_roller_od,output_roller_w,0.75);
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// EXPLODED VIEW
// -----------------------------------------------------------------------------
module exploded(){
    g=exploded_gap;
    body_len=choose(40,56,80,56);
    z_motor=-(body_len+2*g);
    z_keeper=-(rear_keeper_t+g);
    z_rear=0;
    z_case=z_rear+rear_plate_t+g;
    z_disc1=z_case+cavity_h+g;
    z_disc2=z_disc1+disc_t+g;
    z_frontpin=z_disc2+disc_t+g;
    z_raceback=z_frontpin+front_pin_plate_t+g;
    z_innerret=z_raceback;
    z_hub=z_raceback+race_retainer_t+g;
    z_bearing=z_hub+output_hub_t+g;
    z_carrier=z_bearing+flange_bearing_w+g;
    z_frontret=z_carrier+flange_bearing_w+g;
    z_face=z_frontret+race_retainer_t+g;

    if(show_motor_mockup){
        color([0.18,0.18,0.20,0.75]) translate([-frame_side/2,-frame_side/2,z_motor]) cube([frame_side,frame_side,body_len]);
        color([0.35,0.35,0.37]) translate([0,0,z_motor+body_len]) cylinder(d=motor_pilot_d,h=1.5);
        translate([0,0,z_motor+body_len]) motor_shaft_3d(len=use_coupled_input_shaft?motor_shaft_protrusion_setting:minimum_drive_shaft_from_rear_plate+3);
        if(use_coupled_input_shaft){
            color([0.52,0.55,0.60]) translate([0,0,z_motor+body_len+g]) motor_standoff_3d();
            color([0.34,0.36,0.40]) translate([0,0,z_motor+body_len+motor_mount_offset+2*g]) coupled_input_shaft_3d();
        }
    }
    if(use_rear_keeper) color([0.48,0.50,0.53]) translate([0,0,z_keeper]) plate3d(rear_keeper_t,"rear_keeper");
    color([0.65,0.67,0.70]) translate([0,0,z_rear]) plate3d(rear_plate_t,"rear");
    color([0.55,0.58,0.62,0.36]) translate([0,0,z_case]) plate3d(cavity_h,"case");

    if(show_hardware && !use_integrated_ring_ridges){
        for(i=[0:ring_count-1]){a=i*360/ring_count;rotate([0,0,a]) translate([ring_pitch_r,0,z_case+cavity_h+g/4]){
            color([0.30,0.30,0.32]) cylinder(d=ring_axle_d,h=ring_axle_length);
            if(ring_bearing_mode){
                translate([0,0,ring_axle_length+g/4]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
                translate([0,0,ring_axle_length+ring_bearing_w+g/2]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
            } else {
                color([0.72,0.72,0.74]) translate([0,0,ring_axle_length+g/4])
                    difference(){cylinder(d=ring_roller_od,h=ring_sleeve_length);translate([0,0,-0.1]) cylinder(d=ring_axle_d+0.08,h=ring_sleeve_length+0.2);}
            }
        }}
    }

    translate([eccentricity,0,z_disc1]){color([0.80,0.55,0.16]) plate3d(disc_t,"disc");if(show_hardware){if(use_eccentric_bearings) translate([0,0,disc_t+g/3]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);if(use_separate_eccentric_sleeves) color([0.40,0.42,0.45]) translate([0,0,disc_t+(use_eccentric_bearings?ecc_bearing_w:0)+2*g/3]) eccentric_bushing_3d(+1);}}
    translate([-eccentricity,0,z_disc2]) rotate([0,0,180]){color([0.88,0.64,0.22]) plate3d(disc_t,"disc");if(show_hardware){if(use_eccentric_bearings) translate([0,0,disc_t+g/3]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);if(use_separate_eccentric_sleeves) color([0.40,0.42,0.45]) translate([0,0,disc_t+(use_eccentric_bearings?ecc_bearing_w:0)+2*g/3]) eccentric_bushing_3d(-1);}}

    color([0.68,0.70,0.73]) translate([0,0,z_frontpin]) plate3d(front_pin_plate_t,"front_pin");
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([0,0,z_raceback]) plate3d(race_retainer_t,"race_retainer");
    color([0.36,0.50,0.66]) translate([0,0,z_innerret]) plate3d(race_retainer_t,"inner_retainer");
    color([0.38,0.57,0.74]) translate([0,0,z_hub]) plate3d(output_hub_t,"hub");
    if(show_hardware && use_flange_bearing) translate([0,0,z_bearing]) simple_bearing(flange_bearing_id,flange_bearing_od,flange_bearing_w);
    color([0.60,0.62,0.65]) translate([0,0,z_carrier]) plate3d(output_support_t,"bearing_carrier");
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([0,0,z_frontret]) plate3d(race_retainer_t,"race_retainer");
    color([0.27,0.48,0.69]) translate([0,0,z_face]) output_face_plate_3d();

    if(show_hardware){
        for(i=[0:output_pin_count-1]){a=i*360/output_pin_count;rotate([0,0,a]) translate([output_pin_circle_r,0,z_face+output_face_t+g/3]){
            color([0.28,0.28,0.30]) cylinder(d=output_pin_d,h=output_pin_length);
            if(use_output_roller_bearings) translate([0,0,output_pin_length+g/3]) simple_bearing(output_pin_d,output_roller_od,output_roller_w);
            if(use_output_roller_bearings) translate([0,0,output_pin_length+output_roller_w+2*g/3]) simple_bearing(output_pin_d,output_roller_od,output_roller_w);
        }}
    }
}

// -----------------------------------------------------------------------------
// LAYOUTS
// -----------------------------------------------------------------------------
module layout_2d(){
    s=2*plate_r+14;
    if(use_coupled_input_shaft) translate([-1.6*s,1.5*s]) motor_standoff_plate_2d();
    translate([-s,1.5*s]) rear_plate_2d();
    translate([0,1.5*s]) case_ring_2d();
    translate([s,1.5*s]) front_pin_plate_2d();
    if(use_rear_keeper) translate([1.6*s,1.5*s]) rear_keeper_plate_2d();

    if(use_flange_bearing){
        translate([-s,0.5*s]) bearing_race_retainer_2d();
        translate([0,0.5*s]) bearing_race_retainer_2d();
    }
    translate([s,0.5*s]) bearing_carrier_2d();

    translate([-s,-0.5*s]) cycloid_disc_2d();
    translate([0,-0.5*s]) cycloid_disc_2d();
    translate([s,-0.5*s]) output_face_plate_2d();

    translate([-0.65*s,-1.35*s]) output_hub_ring_2d();
    translate([0,-1.35*s]) inner_race_retainer_2d();
    if(use_separate_eccentric_sleeves){
        translate([0.65*s,-1.35*s]) eccentric_bushing_2d(+1);
        translate([0.85*s,-1.35*s]) eccentric_bushing_2d(-1);
    }
}
module layout_3d(){
    // True separated-parts layout. Every item occupies its own grid cell; the
    // cell pitch is based on the largest XY envelope plus user-selected clearance.
    largest_xy = max(2*plate_r, flange_bearing_od, output_face_d, frame_side);
    cell = largest_xy + 2*layout_3d_clearance;
    shaft_layout_len = max(minimum_motor_shaft_from_face+3, 30);

    // Row 1 — main stationary plates.
    color([0.65,0.67,0.70]) translate([-1.5*cell, 2*cell,0]) plate3d(rear_plate_t,"rear");
    color([0.55,0.58,0.62]) translate([-0.5*cell, 2*cell,0]) plate3d(cavity_h,"case");
    color([0.68,0.70,0.73]) translate([ 0.5*cell, 2*cell,0]) plate3d(front_pin_plate_t,"front_pin");
    if(use_rear_keeper) color([0.48,0.50,0.53]) translate([1.5*cell,2*cell,0]) plate3d(rear_keeper_t,"rear_keeper");

    // Row 2 — output bearing structure and face.
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([-1.5*cell, cell,0]) plate3d(race_retainer_t,"race_retainer");
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([-0.5*cell, cell,0]) plate3d(race_retainer_t,"race_retainer");
    color([0.60,0.62,0.65]) translate([ 0.5*cell, cell,0]) plate3d(output_support_t,"bearing_carrier");
    color([0.27,0.48,0.69]) translate([ 1.5*cell, cell,0]) output_face_plate_3d();

    // Row 3 — rotating internal plates.
    color([0.80,0.55,0.16]) translate([-1.5*cell,0,0]) plate3d(disc_t,"disc");
    color([0.88,0.64,0.22]) translate([-0.5*cell,0,0]) rotate([0,0,180]) plate3d(disc_t,"disc");
    color([0.38,0.57,0.74]) translate([ 0.5*cell,0,0]) plate3d(output_hub_t,"hub");
    color([0.36,0.50,0.66]) translate([ 1.5*cell,0,0]) plate3d(race_retainer_t,"inner_retainer");

    // Row 4 — input components are deliberately NOT assembled here. This makes
    // the NEMA shaft, both eccentric sleeves and both eccentric bearings obvious.
    if(use_coupled_input_shaft){
        color([0.52,0.55,0.60]) translate([-1.5*cell,-cell,0]) motor_standoff_3d();
        color([0.34,0.36,0.40]) translate([-0.5*cell,-cell,0]) coupled_input_shaft_3d();
        color([0.62,0.62,0.66]) translate([0.5*cell,-cell,0]) cylinder(d=motor_shaft_d,h=motor_shaft_protrusion_setting);
    } else color([0.62,0.62,0.66]) translate([-1.5*cell,-cell,0]) cylinder(d=motor_shaft_d,h=shaft_layout_len);
    if(use_separate_eccentric_sleeves) color([0.40,0.42,0.45]) translate([use_coupled_input_shaft?1.5*cell:-0.5*cell,-cell,0]) eccentric_bushing_3d(+1);
    if(use_separate_eccentric_sleeves) color([0.40,0.42,0.45]) translate([use_coupled_input_shaft?-1.5*cell:0.5*cell,-2*cell,0]) eccentric_bushing_3d(-1);
    if(show_hardware && use_eccentric_bearings){
        translate([ 1.5*cell,-cell,0]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);
    }

    // Row 5 — catalog hardware / stock samples. Quantities are reported in BOM;
    // one representative of each hardware type is shown here for identification.
    if(show_hardware){
        if(use_flange_bearing) translate([-1.5*cell,-2*cell,0]) simple_bearing(flange_bearing_id,flange_bearing_od,flange_bearing_w);
        if(!use_integrated_ring_ridges) translate([-0.5*cell,-2*cell,0]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_mode ? ring_bearing_w : ring_sleeve_length);
        if(use_output_roller_bearings) translate([ 0.5*cell,-2*cell,0]) simple_bearing(output_pin_d,output_roller_od,output_roller_w);
        if(!use_integrated_ring_ridges) color([0.30,0.30,0.32]) translate([1.5*cell,-2*cell,0]) cylinder(d=ring_axle_d,h=ring_axle_length);
    }

    // Row 6 — second eccentric bearing and output pin stock sample.
    if(show_hardware){
        if(use_eccentric_bearings) translate([-0.5*cell,-3*cell,0]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);
        color([0.28,0.28,0.30]) translate([0.5*cell,-3*cell,0]) cylinder(d=output_pin_d,h=output_pin_length);
    }
}

// -----------------------------------------------------------------------------
// SELECTOR
// -----------------------------------------------------------------------------
if(part=="assembly") assembly();
else if(part=="motion_demo") motion_demo();
else if(part=="exploded") exploded();
else if(part=="input_stack") input_stack_3d();
else if(part=="layout_3d") layout_3d();
else if(part=="layout_2d") layout_2d();
else if(part=="motor_standoff_plate") motor_standoff_plate_2d();
else if(part=="motor_standoff_pilot_pocket_template") motor_standoff_pilot_pocket_template_2d();
else if(part=="coupled_input_shaft") coupled_input_shaft_3d();
else if(part=="rear_plate") rear_plate_2d();
else if(part=="rear_motor_pilot_pocket_template") rear_motor_pilot_pocket_template_2d();
else if(part=="rear_pin_drill_template") rear_pin_drill_template_2d();
else if(part=="rear_keeper_plate") rear_keeper_plate_2d();
else if(part=="case_ring") case_ring_2d();
else if(part=="front_pin_plate") front_pin_plate_2d();
else if(part=="front_pin_drill_template") front_pin_drill_template_2d();
else if(part=="bearing_race_retainer") bearing_race_retainer_2d();
else if(part=="bearing_carrier") bearing_carrier_2d();
else if(part=="cycloid_disc") cycloid_disc_2d();
else if(part=="output_face_plate") output_face_plate_2d();
else if(part=="output_face_front_drill_template") output_face_front_drill_template_2d();
else if(part=="output_face_rear_drill_template") output_face_rear_drill_template_2d();
else if(part=="output_hub_ring") output_hub_ring_2d();
else if(part=="inner_race_retainer") inner_race_retainer_2d();
else if(part=="eccentric_A") { if(use_separate_eccentric_sleeves) eccentric_bushing_2d(+1); }
else if(part=="eccentric_B") { if(use_separate_eccentric_sleeves) eccentric_bushing_2d(-1); }
else assert(false,str("Unknown part selector: ",part));
