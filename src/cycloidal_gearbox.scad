/*
 PANCAKE NEMA CYCLOIDAL GEARBOX - FLANGE OUTPUT
 ==============================================
 Compact dual-disc cycloidal reducer for NEMA stepper motors, designed for CNC-machined
 aluminium plate (level 0) with progressively simplified 3D-printable variants (levels 1-3).
 The output carrier is the external face flange: no projecting output shaft and no
 small-diameter bearing tower. A large-diameter 68-series bearing supports the rotating
 flange/hub directly, giving a short "pancake" package.

 Architecture
 ------------
 MOTOR -> eccentric sleeve (or coupled shaft) with front pilot bearing -> two cycloid discs
 180 degrees apart -> roller-covered output pins -> OUTPUT FACE PLATE.

 Nearly every custom piece is 2D plate of constant thickness. Blind operations are
 exported as separate drill templates so a DXF profile cannot turn a depth-controlled
 feature into a through cut; export_mode="3D solid" gives the finished part for STL.

 Files
 -----
 cycloidal_gearbox.scad   this file: Customizer parameters and the part selector
 cycloidal_gearbox.json   Customizer presets (NEMA17/23/34, light/medium/heavy)
 lib/catalog.scad         bearing catalog and NEMA frame tables
 lib/derived.scad         derived geometry, fits and the axial stack
 lib/cycloid.scad         cycloid profile mathematics
 lib/checks.scad          design rule assertions and the preview build report
 lib/report.scad          manufacturing report and hardware BOM (echo output)
 lib/parts_2d.scad        DXF outlines and drill templates
 lib/parts_3d.scad        solids, lathe parts and hardware mock-ups
 lib/views.scad           assembly, motion demo, exploded view and layouts

 Only this file is parsed by the OpenSCAD Customizer, so every user parameter lives here.
 Version history: git tags v1.10, v1.11, v1.12 ... and docs/RELEASE_NOTES_*.md.

 IMPORTANT ENGINEERING NOTE
 --------------------------
 Level 0 is the manufacturing-oriented bearing-supported reference design. Levels 1-3
 intentionally trade efficiency, wear life and stiffness for part-count reduction and
 printability. This is not a certified gearbox. Bearing life, contact stress, fastener
 preload, fatigue, lubrication, fits, thermal growth and safe torque/speed must be checked
 for the real application. The large output bearing dimensions are standard 68-series
 nominal sizes, but verify the exact bearing drawing and race/fillet geometry from your
 chosen manufacturer before final production machining.
*/

/* [Build / Export] */
part = "assembly"; // [assembly,motion_demo,exploded,input_stack,layout_3d,layout_2d,motor_standoff_plate,motor_standoff_pilot_pocket_template,coupled_input_shaft,eccentric_sleeve,rear_plate,rear_motor_pilot_pocket_template,rear_pin_drill_template,rear_keeper_plate,case_ring,front_pin_plate,front_pin_drill_template,bearing_race_retainer,bearing_carrier,cycloid_disc,output_face_plate,output_face_front_drill_template,output_face_rear_drill_template,output_hub_ring,inner_race_retainer,eccentric_A,eccentric_B]
// 2D profile exports the through-cut outline for DXF/CAM (blind operations come from the
// separate drill templates). 3D solid exports the finished part with its blind pockets,
// steps and tapped-hole pilots for STL/3D printing. Lathe parts are always 3D.
export_mode = "2D profile"; // [2D profile,3D solid]
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
printed_lobe_root_fraction = 0.68; // [0.40:0.02:0.90]
printed_lobe_embed_depth = 3.0; // [1.0:0.25:8.0]
printed_lobe_cavity_overlap = 0.8; // [0.2:0.1:2.0]
plain_output_journal_t = 8.0; // [4:1:14]
motor_pilot_pocket_depth = 1.8; // [0.8:0.2:3.0]
// Diametral clearance added to every bearing pocket in a printed build (levels 1-3)
// in place of the machined press-fit interference. Printed bores shrink; glue or
// a heat-set fit is expected.
print_bearing_pocket_clearance = 0.15; // [0:0.05:0.60]
// Levels 2-3 run the eccentric directly in the cycloid bore. The cam no longer has to
// match a bearing bore, so it gets its own diameter: bigger is stronger and lower pressure.
direct_cam_od_setting = 20.0; // [8:0.5:60]
// Fillet radius where printed case lobes meet the case wall (removes the sharp internal
// corner so the Level 1 case can also be milled). 0 disables.
printed_lobe_root_fillet = 1.5; // [0:0.25:4]
// Chamfer on the top and bottom edge of each printed lobe contact face (3D solids only).
// Costs ~35 s per case render in OpenSCAD 2021 (CGAL); cheap with the Manifold backend. 0 disables.
printed_lobe_end_chamfer = 0.0; // [0:0.25:2]

/* [Manufacturing report] */
spec_output = "Selected part"; // [Off,Selected part,All parts,Hardware BOM]
spec_include_hardware = true;
stock_margin_xy = 2.0; // [0:0.5:10]

/* [Preset status] */
// Informational. Choose a named profile from the Customizer Preset menu.
// The companion cycloidal_gearbox.json writes the editable fields below; every value stays editable.
profile_name = "NEMA17 Commodity R15";

/* [Standard hardware catalog] */
// Bearing boundary dimensions come from the selected catalog designation (lib/catalog.scad).
// The presets choose matching sizes; pick Custom to enter your own boundary dimensions.
ecc_bearing_select = "6000ZZ"; // [608ZZ,6000ZZ,61801,61901,61902,61903,61805,61806,Custom]
output_roller_bearing_select = "625ZZ"; // [623ZZ,624ZZ,625ZZ,626ZZ,608ZZ,6000ZZ,6001,Custom]
flange_bearing_select = "6814ZZ"; // [6813ZZ,6814ZZ,61813,61816,61817,61818,61821,61822,61824,61828,Custom]
// Ring rollers: two catalog bearings per ring axle, one aligned with each cycloid disc.
ring_bearing_select = "624ZZ"; // [623ZZ,624ZZ,625ZZ,685VV,625,686AVV,626,688AVV,608ZZ,608,6800VV,6000ZZ,6000,6801VV,6001,Custom]

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
// Reduction ratio = lobe count. It must be odd: the second disc is the first disc turned
// 180 degrees, which only meshes with the ring when the lobe count is odd.
reduction_ratio = 15; // [7:2:41]
torque_class = "Medium"; // [Light,Medium,Heavy]
rear_pin_capture = "Auto"; // [Auto,Blind pockets,Rear keeper]

// Motor dimensions (mm) used when motor_frame is CUSTOM; the NEMA frames use built-in values.
custom_frame_side = 42.30; // [30:0.05:100]
custom_mount_spacing = 31.00; // [20:0.05:80]
custom_motor_pilot_d = 22.00; // [10:0.05:80]
custom_mount_hole_d = 3.50; // [2:0.05:10]
custom_motor_shaft_d = 5.00; // [3:0.05:16]

/* [Input Shaft / Motor Offset] */
// Direct preserves the original compact layout. Coupled uses a fabricated stepped shaft
// with a female socket over the existing motor shaft and a registered motor spacer.
input_shaft_mode = "Direct motor shaft"; // [Direct motor shaft,Machined coupled shaft]
// Usable shaft length from the motor mounting face. Verify against the motor drawing: NEMA17 shafts
// are commonly 20, 22 or 24 mm; the direct-shaft build asserts this against the stack it needs.
motor_shaft_protrusion_setting = 22.0; // [8:0.5:50]
motor_pilot_height_setting = 2.0; // [0.5:0.25:6]
coupled_drive_shaft_d_setting = 5.0; // [4:0.05:20]
coupled_hub_od_setting = 12.0; // [8:0.25:32]
coupled_socket_depth_setting = 10.0; // [5:0.5:25]
coupled_socket_diametral_clearance = 0.05; // [0.01:0.01:0.25]
coupled_socket_front_wall = 2.0; // [1:0.25:5]
coupled_shaft_end_clearance = 0.5; // [0.2:0.1:2]
coupled_min_engagement = 8.0; // [4:0.5:20]
motor_mount_offset_setting = 24.5; // [0:0.5:50]
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
// Eccentric sleeves (direct motor shaft, or coupled shaft with separate sleeves).
// One-piece: a single sleeve carries both journals, so the 180-degree phase is fixed by
// machining. D-flat: the bore is D-shaped to match the motor shaft flat and needs no set
// screw; the sleeve is captured axially by the rear and front plates. Round bore: a collar
// extends forward through the front plate and output hub bore to carry radial set screws.
eccentric_sleeve_style = "One-piece double eccentric"; // [One-piece double eccentric,Two separate sleeves]
eccentric_bore_style = "D-flat"; // [D-flat,Round with set-screw collar]
motor_shaft_flat_depth = 0.5; // [0:0.05:3]
eccentric_collar_length = 5.0; // [3:0.5:12]
eccentric_set_screw_thread = "M3"; // [M3,M4,M5]

/* [Input shaft support] */
// Front pilot: the eccentric sleeve or coupled shaft extends forward into a bearing seated in
// the rear face of the output hub ring, so the eccentric is supported on both sides and the
// motor bearings carry no eccentric reaction load. Auto enables it whenever a forward journal
// exists (one-piece sleeve or machined coupled shaft). At simplification levels 2-3 the pilot
// is a printed plain journal. The journal occupies the hollow output centre.
input_front_support = "Auto"; // [Auto,Pilot bearing,None]
// Auto picks the largest journal/bearing whose hub pocket clears the clamp screws and
// whose journal passes the output centre bore; the chosen size is echoed.
front_pilot_bearing_select = "Auto"; // [Auto,625ZZ,626ZZ,607ZZ,688AVV,6800VV,6801VV,6802VV,6803VV,6804VV,6805VV,6806VV,Custom]
custom_front_pilot_bearing_id = 10;
custom_front_pilot_bearing_od = 19;
custom_front_pilot_bearing_w = 5;
front_pilot_journal_extra = 0.5; // [0:0.5:10]
// Rear support (machined coupled shaft with separate sleeves only): a bearing on the
// coupling hub seated in the motor spacer, inserted from the motor side against a shoulder
// just behind the rear plate. coupled_hub_od_setting must equal the bearing bore.
coupled_rear_support = "Auto"; // [Auto,Bearing in spacer,None]
rear_support_bearing_select = "Auto"; // [Auto,6800VV,6801VV,6802VV,6803VV,6804VV,6805VV,6806VV,Custom]
custom_rear_support_bearing_id = 12;
custom_rear_support_bearing_od = 21;
custom_rear_support_bearing_w = 5;

/* [Editable preset geometry] */
// These are populated by the Customizer presets and remain directly editable afterwards.
ring_pitch_base_r_setting = 44.5; // [20:0.25:120]
eccentricity_setting = 1.0; // [0.4:0.05:4.0]
cycloid_disc_t_setting = 8.0; // [3:0.25:16]
output_pin_circle_r_setting = 25.0; // [15:0.25:70]
rear_plate_t_setting = 4.0; // [3:0.25:14]
output_face_t_setting = 8.0; // [4:0.25:18]
housing_base_r_setting = 60.0; // [35:0.5:130]
tie_base_r_setting = 55.5; // [30:0.5:120]
tie_clear_d_setting = 4.5; // [3:0.1:10]
output_center_bore_d_setting = 14.0; // [8:0.5:50]

/* [Cycloidal tuning] */
// Points on the exported cycloid polygon. Points are placed by curvature-weighted arc
// length, so facet error is uniform around the profile; the build report echoes it.
profile_resolution = 1200; // [300:100:4000]
// Dense samples per output point used by the resampler.
profile_dense_multiplier = 16; // [4:2:40]
// Machined backlash clearance per side between cycloid flank and ring roller. Printed
// builds use print_radial_clearance instead when it is larger.
profile_clearance_radial = 0.04;
// Largest radial growth of the ring pitch circle the packing rule may add over the preset
// value before the build stops; growth means the preset's housing/disc values are stale.
max_ring_pitch_growth = 10.0; // [0:0.5:60]
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

/* [Hidden] */
design_version = "1.13";

// -----------------------------------------------------------------------------
// LIBRARIES (order matters: each file builds on the values of the previous ones)
// -----------------------------------------------------------------------------
include <lib/catalog.scad>
include <lib/derived.scad>
include <lib/cycloid.scad>
include <lib/checks.scad>
include <lib/report.scad>
include <lib/parts_2d.scad>
include <lib/parts_3d.scad>
include <lib/views.scad>

manufacturing_report();

// -----------------------------------------------------------------------------
// SELECTOR
// -----------------------------------------------------------------------------
if(part=="assembly") assembly();
else if(part=="motion_demo") motion_demo();
else if(part=="exploded") exploded();
else if(part=="input_stack") input_stack_3d();
else if(part=="layout_3d") layout_3d();
else if(part=="layout_2d") layout_2d();
// Plate parts: 2D profile for DXF/CAM, or 3D solid (with blind features) for STL.
// Drill templates are always 2D. Lathe parts are always 3D.
else if(part=="motor_standoff_plate") { if(export_3d) motor_standoff_3d(); else motor_standoff_plate_2d(); }
else if(part=="motor_standoff_pilot_pocket_template") motor_standoff_pilot_pocket_template_2d();
else if(part=="coupled_input_shaft") coupled_input_shaft_3d();
else if(part=="eccentric_sleeve") { if(use_double_sleeve) double_eccentric_sleeve_3d(); }
else if(part=="rear_plate") { if(export_3d) rear_plate_3d(); else rear_plate_2d(); }
else if(part=="rear_motor_pilot_pocket_template") rear_motor_pilot_pocket_template_2d();
else if(part=="rear_pin_drill_template") rear_pin_drill_template_2d();
else if(part=="rear_keeper_plate") { if(export_3d) plate3d(rear_keeper_t,"rear_keeper"); else rear_keeper_plate_2d(); }
else if(part=="case_ring") { if(export_3d) plate3d(cavity_h,"case"); else case_ring_2d(); }
else if(part=="front_pin_plate") { if(export_3d) front_pin_plate_3d(); else front_pin_plate_2d(); }
else if(part=="front_pin_drill_template") front_pin_drill_template_2d();
else if(part=="bearing_race_retainer") { if(export_3d) plate3d(race_retainer_t,"race_retainer"); else bearing_race_retainer_2d(); }
else if(part=="bearing_carrier") { if(export_3d) plate3d(output_support_t,"bearing_carrier"); else bearing_carrier_2d(); }
else if(part=="cycloid_disc") { if(export_3d) plate3d(disc_t,"disc"); else cycloid_disc_2d(); }
else if(part=="output_face_plate") { if(export_3d) output_face_plate_3d(); else output_face_plate_2d(); }
else if(part=="output_face_front_drill_template") output_face_front_drill_template_2d();
else if(part=="output_face_rear_drill_template") output_face_rear_drill_template_2d();
else if(part=="output_hub_ring") { if(export_3d) plate3d(output_hub_t,"hub"); else output_hub_ring_2d(); }
else if(part=="inner_race_retainer") { if(export_3d) plate3d(race_retainer_t,"inner_retainer"); else inner_race_retainer_2d(); }
else if(part=="eccentric_A") { if(use_separate_eccentric_sleeves && !use_double_sleeve) { if(export_3d) eccentric_bushing_3d(+1); else eccentric_bushing_2d(+1); } }
else if(part=="eccentric_B") { if(use_separate_eccentric_sleeves && !use_double_sleeve) { if(export_3d) eccentric_bushing_3d(-1); else eccentric_bushing_2d(-1); } }
else assert(false,str("Unknown part selector: ",part));
