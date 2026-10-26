// Design rule assertions and the build report echoed in preview.
// Included by cycloidal_gearbox.scad after lib/derived.scad and lib/cycloid.scad.

assert(selected_ratio==floor(selected_ratio) && selected_ratio>=7,
       "Reduction ratio must be an integer >= 7.");
assert(lobes%2==1,
       "Reduction ratio (lobe count) must be odd: the second cycloid disc is the first disc turned 180 degrees, and that only meshes with the ring when the lobe count is odd. Use 15, 17, 19, 21 ... instead.");
assert(output_pin_count%2==0,
       "Output pin count must be even so the 180-degree second disc shares the same pin pattern.");
assert(cycloid_min_convex_rho > ring_roller_r_for_profile + 0.25,
       str("Cycloid profile undercuts: roller radius ",ring_roller_r_for_profile," mm exceeds the base curve's smallest convex radius ",cycloid_min_convex_rho," mm. Reduce eccentricity, reduce ring roller OD or increase ring pitch radius."));
assert(ring_system_radial_growth <= max_ring_pitch_growth,
       str("Ring roller packing moved the pitch radius ",ring_system_radial_growth," mm beyond the preset value (ring_pitch_base_r_setting). The preset's housing, tie and output values are sized for the smaller circle. Raise ring_pitch_base_r_setting to at least ",ring_pitch_r,", choose a smaller ring bearing, or raise max_ring_pitch_growth to accept the larger housing."));
assert(use_coupled_input_shaft || motor_shaft_protrusion_setting >= minimum_drive_shaft_from_rear_plate,
       str("Motor shaft is too short for the direct-shaft input: ",minimum_drive_shaft_from_rear_plate," mm is needed from the motor face and motor_shaft_protrusion_setting is ",motor_shaft_protrusion_setting," mm. Use a longer-shaft motor, thinner discs/rear plate, or the machined coupled shaft."));
assert(!use_separate_eccentric_sleeves || use_double_sleeve || use_d_flat_bore,
       "Two separate eccentric sleeves are fully covered by their bearings and have no room for a set screw. Choose eccentric_bore_style=D-flat or eccentric_sleeve_style=One-piece double eccentric.");
assert(!use_d_flat_bore || motor_shaft_flat_depth > 0.2,
       "D-flat bore selected but motor_shaft_flat_depth is too small to carry torque; measure the motor shaft flat.");
assert(!use_front_pilot || front_journal_exists,
       "Front pilot bearing needs a forward journal: use the one-piece double eccentric sleeve or the machined coupled shaft (two separate sleeves end at their bearings).");
assert(!use_front_pilot || front_pilot_nominal > 0,
       str("No front pilot bearing fits: the hub pocket must stay inside the clamp-screw circle (limit radius ",front_pilot_pocket_limit_r," mm) and the journal must pass the output centre bore (",output_center_bore_d," mm). Enlarge output_center_bore_d_setting / output_pin_circle_r_setting, or set input_front_support=None."));
assert(!use_front_pilot_bearing || front_pilot_w + 1.5 <= output_hub_t,
       str("Front pilot bearing (",front_pilot_w," mm wide) does not fit in the ",output_hub_t," mm hub ring with a 1.5 mm shoulder; choose a thinner bearing."));
assert(!use_front_pilot || front_pilot_journal_d + 1.0 < output_center_bore_d,
       "Front pilot journal does not pass the output centre bore of the inner retainer and face plate.");
assert(!use_front_pilot || front_pilot_journal_d >= sleeve_pilot_min_journal,
       str("Front pilot journal (",front_pilot_journal_d," mm) leaves less than 0.8 mm of wall around the ",ecc_drive_bore_d," mm sleeve bore; choose a larger front_pilot_bearing_select."));
assert(!use_front_pilot || front_pilot_journal_d <= front_passage_d,
       str("Front pilot journal (",front_pilot_journal_d," mm) is too large: the front eccentric bearing/disc (bore ",front_passage_d+2*eccentricity+0.1," mm, offset ",eccentricity," mm) must slide over it during assembly, so the journal must be at most ",front_passage_d," mm. Choose a smaller front_pilot_bearing_select."));
assert(!(use_sleeve_collar && use_front_pilot && use_double_sleeve) || sleeve_collar_end_z <= front_pilot_z - 0.5,
       str("Set-screw collar (ends at z=",sleeve_collar_end_z,") runs into the front pilot bearing (z=",front_pilot_z,"); shorten eccentric_collar_length or use the D-flat bore."));
assert(!use_rear_support || rear_support_possible,
       "Rear support bearing in the spacer needs the machined coupled shaft with separate sleeves: the integrated shaft's hub must stay smaller than the rear eccentric bearing bore, so it cannot carry a bearing.");
assert(!use_rear_support || (rear_support_code!="Custom" && rear_support_id>0 && abs(rear_support_id-active_coupled_hub_od)<0.05) || (rear_support_code=="Custom" && abs(rear_support_id-active_coupled_hub_od)<0.05),
       str("coupled_hub_od_setting (",active_coupled_hub_od," mm) must equal the rear support bearing bore (10, 12, 15, 17, 20, 25 or 30 mm), or set coupled_rear_support=None."));
assert(!use_rear_support || rear_support_pocket_d/2 + 1.5 < mount_spacing/2 - (mount_hole_d+0.4)/2,
       "Rear support bearing pocket breaks into the motor mounting holes of the spacer.");
assert(!use_rear_support || rear_support_w + 1.0 + coupled_spacer_pilot_pocket_depth < motor_mount_offset,
       "Motor spacer is too thin for the rear support bearing pocket plus the motor pilot pocket.");
assert(!use_rear_support || -rear_support_z <= coupled_hub_length - 0.5,
       str("Coupling hub (",coupled_hub_length," mm long) does not reach the rear support bearing at z=",rear_support_z,"; deepen the socket or shorten the bearing."));
assert(!use_sleeve_collar || (sleeve_collar_od - ecc_drive_bore_d)/2 >= 1.2,
       str("Set-screw collar wall is only ",(sleeve_collar_od - ecc_drive_bore_d)/2," mm (collar OD ",sleeve_collar_od," mm is limited by the front bearing bore minus 2x eccentricity); use the D-flat bore instead."));
assert(!use_sleeve_collar || sleeve_front_z <= front_pin_z || sleeve_collar_od + 2*print_radial_clearance < output_center_bore_d,
       str("Eccentric sleeve collar (OD ",sleeve_collar_od," mm) extends past the front plate and does not clear the output centre bore (",output_center_bore_d," mm). Shorten eccentric_collar_length, enlarge output_center_bore_d_setting or use the D-flat bore."));
assert(ecc_bearing_code=="Custom" || bd(ecc_bearing_code)>0, "Unknown eccentric bearing designation.");
assert(output_roller_bearing_code=="Custom" || bd(output_roller_bearing_code)>0, "Unknown output roller bearing designation.");
assert(flange_bearing_code=="Custom" || bd(flange_bearing_code)>0, "Unknown flange bearing designation.");
assert(ring_bearing_code=="Custom" || bd(ring_bearing_code)>0, "Unknown ring bearing designation.");
assert(ring_bearing_w <= disc_t+0.25,
       "Selected ring bearing is wider than the cycloid disc; choose a thinner bearing or thicker disc.");
assert(!use_eccentric_bearings || ecc_bearing_w <= disc_t+0.25,
       "Eccentric bearings overlap axially; use thicker cycloid discs or a narrower eccentric bearing.");

assert(2*ring_pitch_r*sin(180/ring_count) > ring_roller_od + 0.35,
       "Ring rollers are too tightly packed for this frame/ratio.");
assert(disc_min_r>0,"Cycloid parameters create an invalid disc.");
assert(output_pin_circle_r + output_orbit_hole_d/2 < disc_min_r-min_design_web,
       "Output orbital holes break through cycloid perimeter or leave too little web.");
assert(output_pin_circle_r-output_orbit_hole_d/2 > cycloid_center_bore_d/2+min_design_web,
       "Output orbital holes are too close to the cycloid centre bore (eccentric bearing pocket or direct cam bore).");
assert(!use_separate_eccentric_sleeves || (ecc_bushing_od-ecc_drive_bore_d)/2-eccentricity>1.0,
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
assert(tie_r-tie_clear_d/2 > case_inner_r+1.0,
       str("Housing tie holes break into the cycloid cavity: tie PCD radius ",tie_r," mm minus half the ",tie_clear_d," mm clearance hole leaves under 1 mm of case wall inside radius ",case_inner_r," mm. Raise tie_base_r_setting (and housing_base_r_setting)."));
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
    echo(str("Design version: ",design_version));
    echo(str("Motor frame: ",motor_frame));
    echo(str("Ratio: ",ratio,":1 | torque class: ",torque_class));
    echo(str("Ring rollers / lobes: ",ring_count," / ",lobes));
    echo(str("Simplification: ",simplification_level));
    echo(str("Ring roller system: ",use_integrated_ring_ridges ? "PRINTED INTEGRATED RIDGES" : "Catalog miniature bearings"));
    if(!use_integrated_ring_ridges) echo(str("Ring bearing: ",ring_bearing_name," = ",ring_bearing_id,"x",ring_bearing_od,"x",ring_bearing_w," mm | qty ",2*ring_count));
    if(use_integrated_ring_ridges) echo(str("Printed ring ridges: ",ring_count,"x OD ",ring_roller_od," mm, full cavity height ",cavity_h," mm"));
    echo(str("Ring pitch radius: ",ring_pitch_r," mm | packing growth over preset: ",ring_system_radial_growth," mm"));
    echo(str("Housing OD: ",2*plate_r," mm"));
    echo(str("Output face OD: ",output_face_d," mm"));
    echo(str("Eccentric support: ",use_eccentric_bearings ? str(ecc_bearing_name," = ",ecc_bearing_id,"x",ecc_bearing_od,"x",ecc_bearing_w," mm") : str("DIRECT CAM IN CYCLOID, bore ",cycloid_center_bore_d," mm")));
    echo(str("Output pin contact: ",use_output_roller_bearings ? str(output_roller_bearing_name," = ",output_pin_d,"x",output_roller_od,"x",output_roller_w," mm") : str("DIRECT ",output_pin_d," mm PIN IN CYCLOID")));
    echo(str("Output support: ",use_flange_bearing ? str(flange_bearing_name," = ",flange_bearing_id,"x",flange_bearing_od,"x",flange_bearing_w," mm") : str("PRINTED PLAIN JOURNAL OD ",output_hub_od," / bore ",output_carrier_bore_d," mm")));
    echo(str("Overall gearbox depth from motor face to output face: ",overall_motor_to_output_depth," mm"));
    echo(str("Input shaft system: ",input_shaft_mode,use_coupled_input_shaft?str(" | ",coupled_eccentric_mode," | motor offset ",motor_mount_offset," mm | drive shaft ",drive_shaft_d," mm"):""));
    echo(str("Cycloid chamber height: ",cavity_h," mm"));
    echo(str("Cycloid profile: ",profile_resolution," points, est. max facet error ",cycloid_facet_error," mm | flank clearance ",active_profile_clearance," mm | undercut margin ",cycloid_min_convex_rho-ring_roller_r_for_profile," mm"));
    if(ring_system_radial_growth>0.5) echo(str("WARNING: ring roller packing grew the pitch radius by ",ring_system_radial_growth," mm over ring_pitch_base_r_setting; housing and disc are larger than the preset intended."));
    if(printed_build) echo(str("Printed build: bearing pockets +",print_bearing_pocket_clearance," mm clearance | pilot bore ",motor_pilot_clear_d," mm | direct cam OD ",use_eccentric_bearings?"n/a":str(ecc_bushing_od)," mm"));
    if(use_separate_eccentric_sleeves) echo(str("Eccentric sleeve: ",use_double_sleeve?"ONE-PIECE double eccentric":"two separate sleeves"," | bore ",use_d_flat_bore?str("D-flat, flat depth ",motor_shaft_flat_depth," mm, no set screw"):str("round + ",eccentric_collar_length," mm set-screw collar")," | journal OD ",ecc_bushing_od," mm"));
    echo(str("Output bolt pattern: ",output_mount_count,"x ",output_mount_thread," blind @ PCD ",2*output_mount_r," mm"));
    echo(str("Output center bore: ",output_center_bore_d," mm"));
    echo(str("Input front support: ",use_front_pilot ? (use_front_pilot_bearing ? str(front_pilot_name," = ",front_pilot_id,"x",front_pilot_od,"x",front_pilot_w," mm in hub pocket ",front_pilot_pocket_d," mm | journal ",front_pilot_journal_d," mm to z=",front_journal_end_z) : str("PRINTED PLAIN JOURNAL ",front_pilot_journal_d," mm in hub bore ",front_pilot_pocket_d," mm")) : "NONE - motor bearings carry the eccentric load"));
    if(use_coupled_input_shaft) echo(str("Input rear support: ",use_rear_support ? str(rear_support_name," = ",rear_support_id,"x",rear_support_od,"x",rear_support_w," mm in spacer pocket ",rear_support_pocket_d," mm at z=",rear_support_z) : "NONE"));
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
