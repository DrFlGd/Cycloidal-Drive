// Manufacturing report: per-part SPEC lines, hardware BOM and fit hints, echoed to the
// console. Included by cycloidal_gearbox.scad; manufacturing_report() is called from there.

function rough_xy(envelope)=envelope+2*stock_margin_xy;
// ISO-style fit hints printed beside numeric bores so a machinist can substitute a standard
// reamer/tolerance class. Numeric values remain the design intent.
function fit_press(nominal,bore)=str(bore,"mm (",nominal," nominal, light press, ~N7/h6 class)");
function fit_slip(nominal,bore)=str(bore,"mm (",nominal," nominal, slip, ~H7/h6 class)");
function fit_bearing_pocket(nominal,bore)=printed_build ? str(bore,"mm (",nominal," bearing OD, printed +",print_bearing_pocket_clearance,"mm clearance, glue/heat-set)") : str(bore,"mm (",nominal," bearing OD, light press, ~N7 class)");
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
    which=="inner_race_retainer" || which=="eccentric_A" || which=="eccentric_B" || which=="eccentric_sleeve" || which=="input_stack";

module spec_header(scope="ALL") {
    echo("================ MANUFACTURING SPECS ================");
    echo(str("SPEC|scope=",scope,"|version=",design_version,"|architecture=PANCAKE_FLANGE|simplification=",simplification_level,"|profile=",profile_name,"|motor=",motor_frame,
             "|ratio=",ratio,":1|torque_class=",torque_class,
             "|ring_roller_part=",use_integrated_ring_ridges ? "PRINTED_CASE_FEATURE" : ring_bearing_name));
}
module spec_rear_plate() {
    env=2*plate_r;
    echo(str("SPEC|part=rear_plate|qty=1|material=",simplify_level_1?"PRINTABLE POLYMER OR ALUMINUM":"6061-T6","|finished_envelope=",env,"x",env,
             "mm|thickness=",rear_plate_t,"mm|common_inch_stock_t=",common_inch_stock_t(rear_plate_t),
             "mm|rough_blank_xy=",rough_xy(env),"x",rough_xy(env),"mm|motor_center=",
             use_input_plain_journal ? str("plain shaft journal ",input_plain_journal_bore_d,"mm + motor-side pilot pocket ",motor_pilot_clear_d,"mm depth ",active_motor_pilot_pocket_depth,"mm") : str("through pilot ",motor_pilot_clear_d,"mm"),
             "|motor_mount=4x",mount_hole_d,"mm @ ",mount_spacing,"mm square|ring_capture=",use_integrated_ring_ridges?"NONE - CONTACT RIDGES IN CASE":rear_capture_label,
             use_integrated_ring_ridges||use_rear_keeper ? "" : str("|rear_axle_pockets=",ring_count,"x ",fit_press(ring_axle_d,rear_ring_axle_hole_d)," depth ",rear_axle_blind_depth,"mm floor ",rear_plate_t-rear_axle_blind_depth,"mm"),
             "|rear_blind_depth=",use_integrated_ring_ridges?0:rear_axle_blind_depth,"mm|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm"));
}
module spec_case_ring(){env=2*plate_r;echo(str("SPEC|part=case_ring|qty=1|material=",simplify_level_1?"PRINTABLE POLYMER OR ALUMINUM":"6061-T6","|finished_envelope=",env,"x",env,
             "mm|thickness=",cavity_h,"mm|common_inch_stock_t=",common_inch_stock_t(cavity_h),
             "mm|rough_blank_xy=",rough_xy(env),"x",rough_xy(env),"mm|nominal_inner_radius=",case_inner_r,"mm|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm",
             use_integrated_ring_ridges ? str("|INTEGRATED_RING_RIDGES=",ring_count,"x OD ",ring_roller_od,"mm @ PCD ",2*ring_pitch_r,"mm|root_fillet=",printed_lobe_root_fillet,"mm|end_chamfer=",printed_lobe_end_chamfer,"mm|flank_clearance=",active_profile_clearance,"mm") : ""));}
module spec_front_pin(){env=2*plate_r;echo(str("SPEC|part=front_pin_plate|qty=1|material=",simplify_level_1?"PRINTABLE POLYMER OR ALUMINUM":"6061-T6","|finished_envelope=",env,"x",env,
             "mm|thickness=",front_pin_plate_t,"mm|common_inch_stock_t=",common_inch_stock_t(front_pin_plate_t),
             "mm|rough_blank_xy=",rough_xy(env),"x",rough_xy(env),"mm|center_clear=",front_center_clear_d,
             use_integrated_ring_ridges ? "mm|ring_axle_blind_pockets=OMITTED - RIDGES IN CASE" : str("mm|ring_axle_blind_pockets=",ring_count,"x ",fit_slip(ring_axle_d,front_ring_axle_hole_d)," @ PCD ",2*ring_pitch_r,"mm depth=",front_axle_blind_depth,"mm FROM CAVITY SIDE"),
             "|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm"));}
module spec_race_retainer(){env=2*plate_r;echo(str("SPEC|part=bearing_race_retainer|qty=",use_flange_bearing?"2 IDENTICAL":"0 - OMITTED AT LEVEL 3","|material=6061-T6|finished_envelope=",env,"x",env,
             "mm|thickness=",race_retainer_t,"mm|common_inch_stock_t=",common_inch_stock_t(race_retainer_t),
             "mm|ID=",outer_race_retainer_id,"mm|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,
             "mm|NOTE=rear and front rings axially trap bearing OUTER race"));}
module spec_bearing_carrier(){env=2*plate_r;echo(str("SPEC|part=",use_flange_bearing?"bearing_carrier":"plain_output_journal_carrier","|qty=1|material=",use_flange_bearing?(printed_build?"PRINTABLE POLYMER OR 6061-T6":"6061-T6"):"PRINTABLE POLYMER OR LOW-FRICTION MATERIAL","|finished_envelope=",env,"x",env,
             "mm|thickness=",output_support_t,"mm|common_inch_stock_t=",common_inch_stock_t(output_support_t),
             use_flange_bearing ? str("mm|bearing_bore=",fit_bearing_pocket(flange_bearing_od,flange_bearing_pocket_d),"|bearing_nominal=",flange_bearing_name," ",flange_bearing_id,"x",flange_bearing_od,"x",flange_bearing_w) : str("mm|plain_journal_bore=",output_carrier_bore_d,"mm|hub_OD=",output_hub_od,"mm|radial_clearance=",print_radial_clearance,"mm per side"),
             "|tie=",tie_count,"x",tie_clear_d," @ PCD ",2*tie_r,"mm"));}
module spec_cycloid(){env=2*disc_max_r;echo(str("SPEC|part=cycloid_disc|qty=2|material=",simplify_level_2?"PRINTABLE POLYMER (PETG/nylon) / TEST MATERIAL":printed_build?"PRINTABLE POLYMER (PETG/nylon) OR 7075-T6":"7075-T6 hard-anodize recommended","|finished_envelope~=",env,"x",env,
             "mm|thickness=",disc_t,"mm|common_inch_stock_t=",common_inch_stock_t(disc_t),
             "mm|profile_points=",profile_resolution,"|facet_error~=",cycloid_facet_error,"mm|flank_clearance=",active_profile_clearance,"mm|center_contact=",use_eccentric_bearings?str("bearing pocket ",fit_bearing_pocket(ecc_bearing_od,ecc_bearing_pocket_d)," for ",ecc_bearing_name):str("direct eccentric cam bore ",cycloid_center_bore_d,"mm for ",ecc_bushing_od,"mm cam"),
             "|output_orbit_holes=",output_pin_count,"x",output_orbit_hole_d," @ PCD ",2*output_pin_circle_r,"mm|output_contact=",use_output_roller_bearings?"roller bearing":"direct smooth pin","|lobes=",lobes));}
module spec_output_face(){env=output_face_d;echo(str("SPEC|part=output_face_plate|qty=1|material=7075-T6 preferred|finished_envelope=",env,"x",env,
             "mm|thickness=",output_face_t,"mm|common_inch_stock_t=",common_inch_stock_t(output_face_t),
             "mm|center_bore=",output_center_bore_d,"mm|FRONT blind mounting holes=",output_mount_count,"x ",output_mount_thread,
             " tap drill ",output_mount_tap_d,"mm @ PCD ",2*output_mount_r,"mm depth=",output_mount_depth,
             "mm|REAR output-pin press pockets=",output_pin_count,"x ",fit_press(output_pin_d,output_pin_face_hole_d)," @ PCD ",2*output_pin_circle_r,"mm depth=",output_pin_press_depth,
             "mm|REAR hub-clamp taps=",inner_retainer_screw_count,"x ",inner_retainer_thread," tap drill ",inner_retainer_tap_d,"mm @ PCD ",2*inner_retainer_screw_r,"mm"));}
module spec_output_hub(){env=output_hub_od;echo(str("SPEC|part=output_hub_ring|qty=1|material=7075-T6 preferred|finished_envelope=",env,"x",env,
             "mm|thickness=",output_hub_t,"mm|common_inch_stock_t=",common_inch_stock_t(output_hub_t),
             use_flange_bearing ? str("mm|bearing_inner_fit_OD=",output_hub_od,"mm for nominal ID ",flange_bearing_id) : str("mm|plain_journal_OD=",output_hub_od,"mm running in carrier bore ",output_carrier_bore_d),
             "mm|center_bore=",output_center_bore_d,"mm|output_pin_slip_holes=",output_pin_count,"x",output_pin_hub_hole_d," @ PCD ",2*output_pin_circle_r,
             "mm|clamp_screw_clearance=",inner_retainer_screw_count,"x",inner_retainer_clear_d," @ PCD ",2*inner_retainer_screw_r,"mm",
             use_front_pilot ? str("|REAR pilot pocket=",use_front_pilot_bearing ? str(fit_bearing_pocket(front_pilot_od,front_pilot_pocket_d)," depth ",front_pilot_pocket_depth,"mm for ",front_pilot_name) : str("plain journal bore ",front_pilot_pocket_d,"mm THROUGH")) : ""));}
module spec_inner_retainer(){env=inner_race_retainer_od;echo(str("SPEC|part=inner_race_retainer|qty=1|material=7075-T6 or steel|finished_envelope=",env,"x",env,
             "mm|thickness=",race_retainer_t,"mm|common_inch_stock_t=",common_inch_stock_t(race_retainer_t),
             "mm|center_bore=",output_center_bore_d,"mm|output_pin_clearance=",output_pin_count,"x",output_pin_hub_hole_d+0.20," @ PCD ",2*output_pin_circle_r,
             "mm|clamp_screws=",inner_retainer_screw_count,"x",inner_retainer_clear_d," @ PCD ",2*inner_retainer_screw_r,
             "mm|NOTE=clamps bearing INNER race against output face plate through hub ring"));}
module spec_ecc(which="A") {env=ecc_bushing_od;sgn=which=="A"?1:-1;echo(str("SPEC|part=eccentric_",which,"|qty=",(use_separate_eccentric_sleeves && !use_double_sleeve)?1:0,"|material=",simplify_level_2?"PRINTABLE POLYMER OR METAL":"4140/17-4 preferred","|OD=",env,
             "mm|length=",ecc_cam_length,"mm|drive_bore=",use_integrated_eccentric_shaft?"OMITTED - INTEGRAL JOURNAL":str(ecc_drive_bore_d,"mm",use_d_flat_bore?str(" D-flat at ",drive_flat_dist,"mm from axis (+Y)"):""),"|eccentric_offset=",sgn*eccentricity,"mm|support=",use_eccentric_bearings?str(ecc_bearing_name," ",ecc_bearing_id,"x",ecc_bearing_od,"x",ecc_bearing_w,"mm"):str("DIRECT IN CYCLOID BORE ",cycloid_center_bore_d,"mm"),"|",use_integrated_eccentric_shaft?"INTEGRATED INTO COUPLED SHAFT":use_double_sleeve?"REPLACED BY ONE-PIECE SLEEVE":"D-flat bore; A and B are mirror parts; axially captured by plates"));}
module spec_eccentric_sleeve(){echo(str("SPEC|part=eccentric_sleeve|qty=",use_double_sleeve?1:0,"|material=",simplify_level_2?"PRINTABLE POLYMER OR METAL":"4140/17-4 preferred","|style=ONE-PIECE DOUBLE ECCENTRIC|journal_OD=",ecc_bushing_od,"mm x ",ecc_cam_length,"mm each|journal_offsets=+/-",eccentricity,"mm (180deg, fixed by machining)|journal_z_from_rear_face=",disc1_z,",",disc2_z,"mm|overall_length=",sleeve_front_z-disc1_z,"mm",use_front_pilot?str("|front_pilot_journal=",front_pilot_journal_d,"mm from z=",max(sleeve_collar_end_z,sleeve_journal_end_z)," to ",front_journal_end_z,"mm for ",use_front_pilot_bearing?front_pilot_name:"printed plain journal"):"","|drive_bore=",ecc_drive_bore_d,"mm ",use_d_flat_bore?str("D-flat at ",drive_flat_dist,"mm from axis, flat depth ",motor_shaft_flat_depth,"mm, no set screw, axially captured by plates"):str("round + collar OD ",sleeve_collar_od,"mm x ",eccentric_collar_length,"mm with 2x ",eccentric_set_screw_thread," radial set screws (tap drill ",sleeve_set_screw_tap_d,"mm)"),"|blank_OD>=",ecc_bushing_od+2*eccentricity,"mm|support=",use_eccentric_bearings?str("2x ",ecc_bearing_name):str("DIRECT IN CYCLOID BORES ",cycloid_center_bore_d,"mm")));}
module spec_templates(which){
    if(which=="rear_motor_pilot_pocket_template") echo(str("SPEC|operation=rear_motor_pilot_pocket_template|diameter=",motor_pilot_clear_d,"mm|depth=",active_motor_pilot_pocket_depth,"mm FROM MOTOR SIDE|only_required_at_simplification_level_3=",use_input_plain_journal));
    else if(which=="rear_pin_drill_template") echo(str("SPEC|operation=rear_pin_drill_template|",ring_count,"x ",rear_ring_axle_hole_d,"mm @ PCD ",2*ring_pitch_r,"mm|depth=",rear_axle_blind_depth,"mm from cavity side"));
    else if(which=="front_pin_drill_template") echo(str("SPEC|operation=front_pin_drill_template|",ring_count,"x ",front_ring_axle_hole_d,"mm @ PCD ",2*ring_pitch_r,"mm|depth=",front_axle_blind_depth,"mm from cavity side"));
    else if(which=="output_face_front_drill_template") echo(str("SPEC|operation=output_face_FRONT_drill_template|",output_mount_count,"x ",output_mount_thread," tap drill ",output_mount_tap_d,"mm @ PCD ",2*output_mount_r,"mm|depth=",output_mount_depth,"mm"));
    else if(which=="output_face_rear_drill_template") echo(str("SPEC|operation=output_face_REAR_drill_template|pins=",output_pin_count,"x",output_pin_face_hole_d,"mm @ PCD ",2*output_pin_circle_r,"mm depth=",output_pin_press_depth,
             "mm|hub-clamp taps=",inner_retainer_screw_count,"x",inner_retainer_thread," tap drill ",inner_retainer_tap_d,"mm @ PCD ",2*inner_retainer_screw_r,"mm"));
}
module spec_motor_standoff(){
    echo(str("SPEC|part=motor_standoff_plate|qty=",use_coupled_input_shaft?1:0,"|material=6061-T6 OR PRINTABLE POLYMER|outer=",frame_side,"x",frame_side,"mm|thickness=",motor_mount_offset,"mm|through_bore=",coupled_spacer_through_d,"mm",
             use_rear_support ? str(" (shoulder ",-rear_support_shoulder_z,"mm behind gearbox face)|rear_support_bearing_bore=",fit_bearing_pocket(rear_support_od,rear_support_pocket_d)," from motor side to shoulder, for ",rear_support_name) : "",
             "|motor_side_pilot_pocket=",coupled_spacer_pilot_pocket_d,"mm x ",coupled_spacer_pilot_pocket_depth,"mm deep|gearbox_register_OD=",coupled_spacer_register_od,"mm|register_height=",motor_spacer_register_height,"mm|mount_holes=4x",mount_hole_d+0.4,"mm @ ",mount_spacing,"mm square"));
}
module spec_coupled_input_shaft(){
    echo(str("SPEC|part=coupled_input_shaft|qty=",use_coupled_input_shaft?1:0,"|style=",coupled_eccentric_mode,"|material=4140 prehard / 17-4 preferred|drive_d=",drive_shaft_d,"mm|hub_OD=",active_coupled_hub_od,"mm|hub_length=",coupled_hub_length,"mm|motor_socket=",coupled_socket_d,"mm x ",coupled_socket_depth_setting,"mm deep|socket_front_wall=",coupled_socket_front_wall,"mm|radial_locking=",coupled_set_screw_count,"x",coupled_set_screw_thread," tap drill ",coupled_set_screw_tap_d,"mm|forward_length_from_rear_face=",coupled_shaft_front_z,"mm",
             coupled_core_pilot ? str("|front_pilot_journal=",front_pilot_journal_d,"mm from z=",coupled_pilot_start_z," to ",front_journal_end_z,"mm for ",use_front_pilot_bearing?front_pilot_name:"printed plain journal") : "",
             use_integrated_eccentric_shaft?str("|integrated_journals=2x OD ",ecc_bushing_od,"mm x ",ecc_cam_length,"mm|journal_offsets=+/-",eccentricity,"mm|journal_z=",disc1_z,",",disc2_z,"mm|blank_OD>=",integrated_shaft_blank_od,"mm|rear_assembly_passage=",integrated_rear_passage_d,"mm"):"|eccentric_journals=SEPARATE SLEEVES"));
}
module input_stack_specs(){
    if(use_coupled_input_shaft){
        echo(str("INPUT_ASSEMBLY|role=central_input_stack|shaft_source=MACHINED_COUPLED_SHAFT|shaft_style=",coupled_eccentric_mode,"|motor_shaft_d=",motor_shaft_d,"mm|drive_shaft_d=",drive_shaft_d,"mm|motor_mount_offset=",motor_mount_offset,"mm|motor_shaft_protrusion=",motor_shaft_protrusion_setting,"mm|socket_engagement=",coupled_socket_engagement,"mm|simplification=",simplification_level,
                 "|assembly_order=",use_integrated_eccentric_shaft?"press rear bearing into rear cycloid -> slide rear cycloid/bearing over coupling end onto rear journal -> slide rear plate and registered spacer over coupling end -> install front cycloid/bearing from front -> couple socket to motor shaft -> lock radial set screws":"fit registered motor spacer -> slide machined shaft socket over motor shaft -> lock radial set screws -> install eccentric sleeves/bearings -> phase sleeves 180deg"));
        spec_motor_standoff();
        spec_coupled_input_shaft();
        echo(str("HARDWARE|source_class=INTEGRATED_MOTOR|role=motor_shaft|qty=1|motor_frame=",motor_frame,"|nominal_d=",motor_shaft_d,"mm|configured_protrusion=",motor_shaft_protrusion_setting,"mm|NOTE=verify actual motor shaft length and pilot height before machining spacer/shaft"));
        echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=coupled_shaft_locking_screws|qty=",coupled_set_screw_count,"|thread=",coupled_set_screw_thread,"|NOTE=use opposing/orthogonal screws or a machined flat; threadlocker recommended"));
        echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=motor_mount_screws|qty=4|grip~=",rear_plate_t+motor_mount_offset,"mm plus motor thread engagement"));
    } else {
        echo(str("INPUT_ASSEMBLY|role=central_input_stack|shaft_source=INTEGRATED_NEMA_MOTOR_SHAFT|shaft_d=",motor_shaft_d,"mm|min_shaft_protrusion=",minimum_motor_shaft_from_face,"mm|simplification=",simplification_level,
                 "|assembly_order=",use_double_sleeve?"press eccentric bearings into both cycloids -> slide rear cycloid/bearing over the sleeve's front journal onto the rear journal -> slide front cycloid/bearing onto the front journal -> slide sleeve onto motor shaft (D-flat sets phase and torque)":"press eccentric bearing outer race into cycloid -> press eccentric sleeve into bearing inner race -> slide onto motor shaft with D-flats aligned (A and B are mirror parts, phase is fixed by the flats)"));
        echo(str("HARDWARE|source_class=INTEGRATED_MOTOR|role=input_shaft|qty=1|motor_frame=",motor_frame,"|nominal_d=",motor_shaft_d,"mm|min_protrusion=",minimum_motor_shaft_from_face,"mm|gearbox_case_support=",use_input_plain_journal?str("PLAIN PRINTED JOURNAL bore ",input_plain_journal_bore_d,"mm after motor pilot pocket"):"NONE - MOTOR BEARINGS PROVIDE SHAFT SUPPORT","|NOTE=not a separate rod; verify actual motor shaft length/pilot height"));
    }
    if(use_integrated_eccentric_shaft){
        echo(str("FABRICATED_FEATURE|role=integrated_eccentric_journals|qty=2|parent=coupled_input_shaft|OD=",ecc_bushing_od,"mm|length=",ecc_cam_length,"mm|offsets=+/-",eccentricity,"mm|phase=180deg FIXED BY MACHINING|NOTE=no separate sleeves or eccentric set screws"));
    } else {
        if(use_double_sleeve) echo(str("HARDWARE|source_class=",simplify_level_2?"FABRICATED_OR_PRINTED":"FABRICATED","|role=eccentric_double_sleeve|qty=1|journal_OD=",ecc_bushing_od,"mm|journal_length=",ecc_cam_length,"mm|drive_bore=",ecc_drive_bore_d,"mm ",use_d_flat_bore?"D-flat":"round+collar","|offset=+/-",eccentricity,"mm|NOTE=phase fixed by machining"));
        else echo(str("HARDWARE|source_class=",simplify_level_2?"FABRICATED_OR_PRINTED":"FABRICATED","|role=eccentric_cam_sleeves|qty=2 (mirror parts A/B)|OD=",ecc_bushing_od,"mm|length=",ecc_cam_length,"mm|drive_bore=",ecc_drive_bore_d,"mm D-flat|offset=+/-",eccentricity,"mm|NOTE=phase fixed by the D-flats; axially captured by rear/front plates"));
        if(use_sleeve_collar) echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=eccentric_set_screws|qty=2|thread=",eccentric_set_screw_thread," cup-point|NOTE=in the forward collar; threadlocker recommended"));
    }
}

module hardware_specs(){
    tie_grip=output_front_z+(use_rear_keeper?rear_keeper_t:0);
    echo("---------------- STANDARD / CATALOG HARDWARE ----------------");
    input_stack_specs();
    if(use_integrated_ring_ridges){
        echo(str("PRINTED_FEATURE|role=ring_contacts|qty=",ring_count,"|geometry=circular ridges OD ",ring_roller_od,"mm @ PCD ",2*ring_pitch_r,"mm|height=",cavity_h,"mm|NOTE=replaces ring axles, sleeves and bearings; friction/wear substantially higher"));
    } else {
        echo(str("HARDWARE|source_class=STANDARD_STOCK_CUT|role=ring_axles|qty=",ring_count,"|standard=precision ground hardened shafting h6|nominal_d=",ring_axle_d,"mm|cut_length=",ring_axle_length,"mm"));
        echo(str("HARDWARE|source_class=CATALOG|role=ring_roller_bearings|qty=",2*ring_count,"|designation=",ring_bearing_name,"|size=",ring_bearing_id,"x",ring_bearing_od,"x",ring_bearing_w,"mm|arrangement=2 per ring axle"));
    }
    if(use_eccentric_bearings) echo(str("HARDWARE|source_class=CATALOG|role=eccentric_bearings|qty=2|designation=",ecc_bearing_name,"|size=",ecc_bearing_id,"x",ecc_bearing_od,"x",ecc_bearing_w,"mm"));
    else echo(str("OMITTED_HARDWARE|role=eccentric_bearings|replaced_by=direct cam in cycloid bore|cam_OD=",ecc_bushing_od,"mm|cycloid_bore=",cycloid_center_bore_d,"mm"));
    echo(str("HARDWARE|source_class=STANDARD_STOCK_CUT|role=output_pins|qty=",output_pin_count,"|standard=smooth precision rod / hardened dowel preferred|nominal_d=",output_pin_d,"mm|cut_length=",output_pin_length,"mm"));
    if(use_output_roller_bearings) echo(str("HARDWARE|source_class=CATALOG|role=output_roller_bearings|qty=",2*output_pin_count,"|designation=",output_roller_bearing_name,"|size=",output_pin_d,"x",output_roller_od,"x",output_roller_w,"mm"));
    else echo(str("OMITTED_HARDWARE|role=output_roller_bearings|replaced_by=direct ",output_pin_d,"mm output pins in orbit holes ",output_orbit_hole_d,"mm"));
    if(use_flange_bearing) echo(str("HARDWARE|source_class=CATALOG|role=pancake_output_bearing|qty=1|designation=",flange_bearing_name,"|size=",flange_bearing_id,"x",flange_bearing_od,"x",flange_bearing_w,"mm"));
    else echo(str("OMITTED_HARDWARE|role=pancake_output_bearing|replaced_by=printed plain journal|hub_OD=",output_hub_od,"mm|carrier_bore=",output_carrier_bore_d,"mm|radial_clearance=",print_radial_clearance,"mm per side|axial_clearance=",print_axial_clearance,"mm per side"));
    if(use_front_pilot_bearing) echo(str("HARDWARE|source_class=CATALOG|role=input_front_pilot_bearing|qty=1|designation=",front_pilot_name,"|size=",front_pilot_id,"x",front_pilot_od,"x",front_pilot_w,"mm|NOTE=seated in output hub rear pocket, retained by the inner race retainer; journal on the ",use_double_sleeve?"eccentric sleeve":"coupled shaft"));
    else if(use_front_pilot) echo(str("OMITTED_HARDWARE|role=input_front_pilot_bearing|replaced_by=printed plain journal ",front_pilot_journal_d,"mm in hub bore ",front_pilot_pocket_d,"mm"));
    else echo("OMITTED_HARDWARE|role=input_front_pilot_bearing|NOTE=no forward journal; motor bearings carry the eccentric reaction load");
    if(use_rear_support) echo(str("HARDWARE|source_class=CATALOG|role=input_rear_support_bearing|qty=1|designation=",rear_support_name,"|size=",rear_support_id,"x",rear_support_od,"x",rear_support_w,"mm|NOTE=on the coupling hub, inserted into the spacer from the motor side against the shoulder; retain with a spacer tube or circlip on the motor side"));
    else if(use_coupled_input_shaft && use_separate_eccentric_sleeves) echo("OMITTED_HARDWARE|role=input_rear_support_bearing|NOTE=coupled shaft runs on the motor bearings only");
    echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=housing_tie_bolts|qty=",tie_count,"|clearance=",tie_clear_d,"mm|stack_grip~=",tie_grip,"mm|add nut/thread engagement"));
    echo(str("HARDWARE|source_class=STANDARD_FASTENER|role=output_hub_clamp_screws|qty=",inner_retainer_screw_count,"|thread=",inner_retainer_thread));
    echo(str("CATALOG_STATUS|input_shaft=",input_shaft_mode,"|eccentric_input=",use_integrated_eccentric_shaft?"INTEGRATED_DOUBLE_ECCENTRIC":"SEPARATE_ECCENTRIC_SLEEVES","|simplification=",simplification_level,"|eccentric=",use_eccentric_bearings?ecc_bearing_name:"OMITTED_DIRECT_CAM","|output_roller=",use_output_roller_bearings?output_roller_bearing_name:"OMITTED_DIRECT_PIN","|flange=",use_flange_bearing?flange_bearing_name:"OMITTED_PLAIN_JOURNAL","|ring_roller=",use_integrated_ring_ridges?"PRINTED_CASE_RIDGES":str("CATALOG_",ring_bearing_name)));
}
module all_specs(){
    spec_header("ALL PARTS"); if(use_coupled_input_shaft){spec_motor_standoff();spec_coupled_input_shaft();} spec_rear_plate();
    if(use_input_plain_journal) spec_templates("rear_motor_pilot_pocket_template");
    if(!use_rear_keeper && !use_integrated_ring_ridges) spec_templates("rear_pin_drill_template");
    spec_case_ring(); spec_front_pin(); if(!use_integrated_ring_ridges) spec_templates("front_pin_drill_template");
    if(use_flange_bearing) spec_race_retainer();
    spec_bearing_carrier(); spec_cycloid(); spec_output_face();
    spec_templates("output_face_front_drill_template"); spec_templates("output_face_rear_drill_template");
    spec_output_hub(); spec_inner_retainer(); if(use_double_sleeve) spec_eccentric_sleeve(); else {spec_ecc("A"); spec_ecc("B");}
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
    else if(which=="eccentric_sleeve") spec_eccentric_sleeve();
    else if(which=="input_stack") input_stack_specs();
    if(spec_include_hardware && !part_is_single(which)) hardware_specs();
    echo("=======================================================");
}
module manufacturing_report(){
    if(spec_output=="All parts") all_specs();
    else if(spec_output=="Hardware BOM") { spec_header("HARDWARE BOM"); hardware_specs(); echo("======================================================="); }
    else if(spec_output=="Selected part") { if(part_is_single(part)) selected_spec(part); else all_specs(); }
}
