// Derived geometry for the pancake cycloidal gearbox: simplification state, catalog
// lookups, fits and the axial stack. Included by cycloidal_gearbox.scad.

// -----------------------------------------------------------------------------
// SIMPLIFICATION STATE
// -----------------------------------------------------------------------------
simplify_level_1 = simplification_level!="Full hardware";
simplify_level_2 = simplification_level=="Direct pin and cam contact" || simplification_level=="Bearingless printed journals";
simplify_level_3 = simplification_level=="Bearingless printed journals";
use_integrated_ring_ridges = simplify_level_1;
use_eccentric_bearings = !simplify_level_2;
use_output_roller_bearings = !simplify_level_2;
use_flange_bearing = !simplify_level_3;
use_input_plain_journal = simplify_level_3;
use_coupled_input_shaft = input_shaft_mode=="Machined coupled shaft";
use_integrated_eccentric_shaft = use_coupled_input_shaft && coupled_eccentric_mode=="Integrated double eccentric";
use_separate_eccentric_sleeves = !use_integrated_eccentric_shaft;
use_double_sleeve = use_separate_eccentric_sleeves && eccentric_sleeve_style=="One-piece double eccentric";
use_d_flat_bore = use_separate_eccentric_sleeves && eccentric_bore_style=="D-flat";
use_sleeve_collar = use_separate_eccentric_sleeves && !use_d_flat_bore;
// Levels 1-3 are printed builds: fits on printed parts use print clearances.
printed_build = simplify_level_1;
export_3d = export_mode=="3D solid";

// -----------------------------------------------------------------------------
// MOTOR FRAME AND DUTY
// -----------------------------------------------------------------------------
function duty(light,medium,heavy) =
    torque_class=="Light" ? light : torque_class=="Heavy" ? heavy : medium;

frame_table      = nema_frame(motor_frame);
frame_side       = frame_table==undef ? custom_frame_side   : frame_table[0];
mount_spacing    = frame_table==undef ? custom_mount_spacing : frame_table[1];
motor_pilot_d    = frame_table==undef ? custom_motor_pilot_d : frame_table[2];
mount_hole_d     = frame_table==undef ? custom_mount_hole_d  : frame_table[3];
motor_shaft_d    = frame_table==undef ? custom_motor_shaft_d : frame_table[4];
motor_body_length = nema_body_length(motor_frame);
drive_shaft_d = use_coupled_input_shaft ? coupled_drive_shaft_d_setting : motor_shaft_d;
motor_mount_offset = use_coupled_input_shaft ? motor_mount_offset_setting : 0;
active_coupled_hub_od = use_integrated_eccentric_shaft ? integrated_coupling_hub_od_setting : coupled_hub_od_setting;

selected_ratio = reduction_ratio;
ring_count = selected_ratio + 1;
lobes = ring_count - 1;
ratio = lobes;

base_ring_pitch_r = ring_pitch_base_r_setting;

// Ring rollers: two catalog bearings per axle. The pitch circle grows only if the chosen
// bearings cannot pack on the preset circle (asserted against max_ring_pitch_growth).
ring_bearing_code = ring_bearing_select;
ring_bearing_id = ring_bearing_code=="Custom" ? custom_ring_bearing_id : bd(ring_bearing_code);
ring_bearing_od = ring_bearing_code=="Custom" ? custom_ring_bearing_od : bD(ring_bearing_code);
ring_bearing_w  = ring_bearing_code=="Custom" ? custom_ring_bearing_w  : bB(ring_bearing_code);
ring_bearing_name = ring_bearing_code=="Custom" ? "CUSTOM" : ring_bearing_code;

ring_axle_d = ring_bearing_id;
ring_roller_od = ring_bearing_od;
ring_pitch_required_for_packing = (ring_roller_od+0.50)/(2*sin(180/ring_count));
ring_pitch_r = max(base_ring_pitch_r,ring_pitch_required_for_packing);

eccentricity = eccentricity_setting;

ecc_bearing_code = ecc_bearing_select;
ecc_bearing_id = ecc_bearing_code=="Custom" ? custom_ecc_bearing_id : bd(ecc_bearing_code);
ecc_bearing_od = ecc_bearing_code=="Custom" ? custom_ecc_bearing_od : bD(ecc_bearing_code);
ecc_bearing_w  = ecc_bearing_code=="Custom" ? custom_ecc_bearing_w  : bB(ecc_bearing_code);
ecc_bearing_name = ecc_bearing_code=="Custom" ? "CUSTOM" : ecc_bearing_code;

disc_t = cycloid_disc_t_setting;

output_pin_count = 6;
output_pin_circle_r = output_pin_circle_r_setting;
output_roller_bearing_code = output_roller_bearing_select;
output_pin_d = output_roller_bearing_code=="Custom" ? custom_output_roller_id : bd(output_roller_bearing_code);
output_roller_od = output_roller_bearing_code=="Custom" ? custom_output_roller_od : bD(output_roller_bearing_code);
output_roller_w = output_roller_bearing_code=="Custom" ? custom_output_roller_w : bB(output_roller_bearing_code);
output_roller_bearing_name = output_roller_bearing_code=="Custom" ? "CUSTOM" : output_roller_bearing_code;

rear_plate_t = rear_plate_t_setting;
front_pin_plate_t = rear_plate_t;
output_face_t = output_face_t_setting;
base_plate_r = housing_base_r_setting;
base_tie_r = tie_base_r_setting;
tie_clear_d = tie_clear_d_setting;

// Large pancake output bearing (ISO/SKF 618-series designations in the presets).
flange_bearing_code = flange_bearing_select;
flange_bearing_id = flange_bearing_code=="Custom" ? custom_flange_bearing_id : bd(flange_bearing_code);
flange_bearing_od = flange_bearing_code=="Custom" ? custom_flange_bearing_od : bD(flange_bearing_code);
flange_bearing_w = flange_bearing_code=="Custom" ? custom_flange_bearing_w : bB(flange_bearing_code);
flange_bearing_name = flange_bearing_code=="Custom" ? "CUSTOM" : flange_bearing_code;

// Housing and tie circle follow any packing growth of the ring pitch circle.
ring_system_radial_growth = max(0,ring_pitch_r-base_ring_pitch_r);
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
// Auto uses the keeper for Heavy builds and whenever blind pockets would leave under
// 2 mm of plate floor behind the ring axles.
rear_keeper_auto_floor = 2.0;
use_rear_keeper = !use_integrated_ring_ridges && (rear_pin_capture=="Rear keeper" ||
                  (rear_pin_capture=="Auto" && (torque_class=="Heavy" ||
                   rear_plate_t - max(2.0,min(0.75*ring_axle_d,rear_plate_t-1.5)) < rear_keeper_auto_floor)));
rear_capture_label = use_rear_keeper ? "Rear keeper" : "Blind pockets";
rear_keeper_inner_r = max(frame_side*sqrt(2)/2 + 2.0, motor_pilot_d/2 + 6.0);
rear_keeper_outer_r = plate_r;

// -----------------------------------------------------------------------------
// DERIVED GEOMETRY
// -----------------------------------------------------------------------------
active_profile_clearance = printed_build ? max(profile_clearance_radial,print_radial_clearance) : profile_clearance_radial;
ring_roller_r_for_profile = ring_roller_od/2 + active_profile_clearance;
output_contact_od = use_output_roller_bearings ? output_roller_od : output_pin_d;
output_orbit_hole_d = output_contact_od + 2*eccentricity + (use_output_roller_bearings ? output_orbit_clearance_d : 2*print_radial_clearance);
disc_min_r = ring_pitch_r - eccentricity - ring_roller_r_for_profile;
disc_max_r = ring_pitch_r + eccentricity - ring_roller_r_for_profile;
case_inner_r = ring_pitch_r + ring_roller_od/2 + case_wall_clearance;

rear_axle_blind_depth = max(2.0,min(0.75*ring_axle_d,rear_plate_t-1.5));
front_axle_blind_depth = max(2.0,min(0.75*ring_axle_d,front_pin_plate_t-1.5));

motor_pilot_clear_d = motor_pilot_d + 0.20 + (printed_build ? 2*print_radial_clearance : 0);
rear_ring_axle_hole_d = ring_axle_d - ring_axle_press;
front_ring_axle_hole_d = ring_axle_d + ring_axle_slip;
// Bearing pockets: machined press fit, or printed clearance in a printed build.
bearing_pocket_adjust = printed_build ? print_bearing_pocket_clearance : -bearing_pocket_interference;
ecc_bearing_pocket_d = ecc_bearing_od + bearing_pocket_adjust;
ecc_bushing_od = use_eccentric_bearings ? ecc_bearing_id + eccentric_bearing_inner_interference : direct_cam_od_setting;
ecc_cam_length = use_eccentric_bearings ? ecc_bearing_w : disc_t;
cycloid_center_bore_d = use_eccentric_bearings ? ecc_bearing_pocket_d : ecc_bushing_od + 2*print_radial_clearance;
ecc_drive_bore_d = drive_shaft_d + motor_shaft_slip;
output_pin_face_hole_d = output_pin_d - output_pin_press;
output_pin_hub_hole_d = output_pin_d + output_pin_hub_slip;

// Output support. Full mode uses the large ball bearing; Level 3 converts the same
// hub/carrier interface into a printed plain journal with adjustable running clearance.
race_retainer_t = bearing_retainer_t;
race_section_d = flange_bearing_od - flange_bearing_id;
race_overlap_d = output_bearing_race_overlap_fraction * race_section_d;
outer_race_retainer_id = flange_bearing_od - race_overlap_d;
inner_race_retainer_od = flange_bearing_id + race_overlap_d;
flange_bearing_pocket_d = flange_bearing_od + bearing_pocket_adjust;
output_hub_od = flange_bearing_id + flange_hub_interference;
output_support_t = use_flange_bearing ? flange_bearing_w : plain_output_journal_t;
output_carrier_bore_d = use_flange_bearing ? flange_bearing_pocket_d : output_hub_od + 2*print_radial_clearance;
// The hub ring sits in front of the inner race retainer (which clamps the bearing inner race
// from behind through the hub) and spans exactly the output support: the bearing width, or
// the plain journal length plus its axial clearances.
output_hub_t = use_flange_bearing ? flange_bearing_w : output_support_t + 2*print_axial_clearance;
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

// ---- Input shaft support -------------------------------------------------------------
front_journal_exists = use_double_sleeve || use_coupled_input_shaft;
use_front_pilot = input_front_support=="Pilot bearing" ? true : input_front_support=="None" ? false : front_journal_exists;
use_front_pilot_bearing = use_front_pilot && !simplify_level_2;
// A sleeve pilot journal is bored through for the motor shaft and must keep a wall around it
// (the motor shaft itself ends well before the pilot, so the wall only carries the bearing).
sleeve_pilot_min_journal = use_double_sleeve ? ecc_drive_bore_d + 2*0.8 : 0;
// Largest journal the front end can offer: the sleeve's own bearing journal size, or the
// coupled shaft core turned to the nearest metric size.
// The front eccentric bearing (or the disc bore at levels 2-3) is installed from the front over
// the concentric pilot, so the pilot must be smaller than that bore by twice the eccentricity.
front_passage_d = (use_eccentric_bearings ? ecc_bearing_id : cycloid_center_bore_d) - 2*eccentricity - 0.1;
front_pilot_nominal_max = use_double_sleeve ? metric_journal(front_passage_d) : min(metric_journal(drive_shaft_d), metric_journal(front_passage_d));
rear_support_possible = use_coupled_input_shaft && !use_integrated_eccentric_shaft;
use_rear_support = coupled_rear_support=="Bearing in spacer" ? true : coupled_rear_support=="None" ? false : rear_support_possible;
rear_support_code = rear_support_bearing_select=="Auto" ? auto_pilot_code(round(active_coupled_hub_od)) : rear_support_bearing_select;
rear_support_id = rear_support_code=="Custom" ? custom_rear_support_bearing_id : bd(rear_support_code);
rear_support_od = rear_support_code=="Custom" ? custom_rear_support_bearing_od : bD(rear_support_code);
rear_support_w  = rear_support_code=="Custom" ? custom_rear_support_bearing_w  : bB(rear_support_code);
rear_support_name = rear_support_code=="Custom" ? "CUSTOM" : rear_support_code;
rear_support_pocket_d = rear_support_od + bearing_pocket_adjust;
rear_support_shoulder_z = -1.0;                       // bearing front face, just behind the rear plate
rear_support_z = rear_support_shoulder_z - rear_support_w;
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

// Front pilot bearing/journal: pocket in the rear face of the hub ring must clear the clamp
// screws and the journal must pass the output centre bore of the retainer and face plate.
front_pilot_pocket_limit_r = inner_retainer_screw_r - inner_retainer_clear_d/2 - 1.5;
function pilot_pocket_d(n)= use_front_pilot_bearing ? bD(auto_pilot_code(n)) + bearing_pocket_adjust : n + eccentric_bearing_inner_interference + 2*print_radial_clearance;
function pilot_fits(n)= n<=front_pilot_nominal_max && n + eccentric_bearing_inner_interference >= sleeve_pilot_min_journal && auto_pilot_code(n)!="Custom" && pilot_pocket_d(n)/2 < front_pilot_pocket_limit_r && n + 2.0 <= output_center_bore_d;
function pick_pilot(i=0)= i>=len(pilot_sizes) ? 0 : pilot_fits(pilot_sizes[i]) ? pilot_sizes[i] : pick_pilot(i+1);
front_pilot_nominal = front_pilot_bearing_select=="Auto" ? pick_pilot() : (front_pilot_bearing_select=="Custom" ? custom_front_pilot_bearing_id : bd(front_pilot_bearing_select));
front_pilot_code = front_pilot_bearing_select=="Auto" ? auto_pilot_code(front_pilot_nominal) : front_pilot_bearing_select;
front_pilot_id = front_pilot_code=="Custom" ? custom_front_pilot_bearing_id : bd(front_pilot_code);
front_pilot_od = front_pilot_code=="Custom" ? custom_front_pilot_bearing_od : bD(front_pilot_code);
front_pilot_w  = front_pilot_code=="Custom" ? custom_front_pilot_bearing_w  : bB(front_pilot_code);
front_pilot_name = front_pilot_code=="Custom" ? "CUSTOM" : front_pilot_code;
front_pilot_journal_d = (use_front_pilot_bearing ? front_pilot_id : front_pilot_nominal) + eccentric_bearing_inner_interference;
front_pilot_pocket_d = use_front_pilot_bearing ? front_pilot_od + bearing_pocket_adjust : front_pilot_journal_d + 2*print_radial_clearance;

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

output_hub_z = race_backer_z + race_retainer_t;
front_pilot_pocket_depth = use_front_pilot_bearing ? front_pilot_w : output_hub_t + 0.2;
front_pilot_z = output_hub_z;
front_pilot_front_z = front_pilot_z + (use_front_pilot_bearing ? front_pilot_w : output_hub_t);
front_journal_end_z = use_front_pilot ? front_pilot_front_z + front_pilot_journal_extra : 0;

disc1_z = rear_plate_t + rear_running_gap;
disc2_z = disc1_z + disc_t + disc_gap;
// Each catalog ring bearing is centered on its corresponding cycloid disc.
ring_bearing1_z = disc1_z + (disc_t-ring_bearing_w)/2;
ring_bearing2_z = disc2_z + (disc_t-ring_bearing_w)/2;
ring_axle_start_z = use_rear_keeper ? -rear_keeper_t : rear_plate_t-rear_axle_blind_depth;
ring_axle_end_z = front_pin_z + front_axle_blind_depth;
ring_axle_length = ring_axle_end_z-ring_axle_start_z;

output_pin_rear_extension = 1.0;
output_pin_start_z = disc1_z-output_pin_rear_extension;
output_pin_end_z = output_face_z + output_pin_press_depth;
output_pin_length = output_pin_end_z-output_pin_start_z;
sleeve_journal_end_z = disc2_z + ecc_cam_length;
sleeve_collar_length = use_sleeve_collar ? eccentric_collar_length : 0;
sleeve_collar_end_z = sleeve_journal_end_z + sleeve_collar_length;
// The one-piece sleeve carries the front pilot journal; two separate sleeves cannot.
sleeve_front_z = (use_front_pilot && use_double_sleeve) ? max(sleeve_collar_end_z, front_journal_end_z) : sleeve_collar_end_z;
// The collar is in front of the front eccentric journal and the front bearing/disc must pass
// over it, so it is limited to the bearing bore minus twice the eccentricity.
sleeve_collar_od = floor(2*(min(ecc_bushing_od, (use_eccentric_bearings ? ecc_bearing_id : cycloid_center_bore_d) - 2*eccentricity - 0.1)))/2;
// D-flat: distance from shaft axis to the flat, with the slip clearance split on both sides.
drive_flat_dist = drive_shaft_d/2 - motor_shaft_flat_depth + motor_shaft_slip/2;
sleeve_set_screw_tap_d = eccentric_set_screw_thread=="M5" ? 4.2 : eccentric_set_screw_thread=="M4" ? 3.3 : 2.5;
// Motor shaft only has to reach the end of the D-flat drive length (journals plus any
// collar); a pilot journal beyond that is carried by the pilot bearing.
minimum_drive_shaft_from_rear_plate = use_separate_eccentric_sleeves ? sleeve_collar_end_z : sleeve_journal_end_z;
// Coupled shaft: the core runs to the pilot journal (or a short extension without pilot).
// With a one-piece sleeve on the core, the sleeve carries the pilot and the core stops inside it.
coupled_core_pilot = use_front_pilot && !use_double_sleeve;
coupled_pilot_start_z = use_integrated_eccentric_shaft ? sleeve_journal_end_z : sleeve_collar_end_z;
integrated_shaft_front_z = coupled_core_pilot ? coupled_pilot_start_z : (use_double_sleeve ? sleeve_front_z - 1.0 : minimum_drive_shaft_from_rear_plate + integrated_front_extension);
coupled_shaft_front_z = coupled_core_pilot ? front_journal_end_z : integrated_shaft_front_z;
minimum_motor_shaft_from_face = use_coupled_input_shaft ?
    (motor_mount_offset - coupled_socket_depth_setting - coupled_socket_front_wall + coupled_min_engagement) :
    minimum_drive_shaft_from_rear_plate;
overall_motor_to_output_depth = output_front_z + motor_mount_offset;
