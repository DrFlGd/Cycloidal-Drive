// Assembly, motion demo, exploded view and the 2D/3D part layouts.
// Included by cycloidal_gearbox.scad.

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
            rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing1_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
            rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing2_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
        }
    }

    rotate([0,0,drive_angle]) translate([eccentricity,0,0]){
        rotate([0,0,out_angle-drive_angle]){
            color([0.80,0.55,0.16]) translate([0,0,disc1_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc1_z+disc_t]) rotation_marker(max(2,ring_pitch_r-ring_roller_od-3),0,1.0,2.4);
        }
        if(show_hardware && use_eccentric_bearings) translate([0,0,disc1_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);
    }
    rotate([0,0,drive_angle]) translate([-eccentricity,0,0]){
        rotate([0,0,180+out_angle-drive_angle]){
            color([0.88,0.64,0.22]) translate([0,0,disc2_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc2_z+disc_t]) rotation_marker(max(2,ring_pitch_r-ring_roller_od-3),0,1.0,2.4);
        }
        if(show_hardware && use_eccentric_bearings) translate([0,0,disc2_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);
    }
    if(show_hardware) rotate([0,0,drive_angle]) eccentric_sleeves_3d();
    if(show_hardware) input_support_bearings_3d();

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
        color([0.38,0.57,0.74]) translate([0,0,output_hub_z]) plate3d(output_hub_t,"hub");
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
        body_len=motor_body_length;
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
            rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing1_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w,0.82);
            rotate([0,0,a]) translate([ring_pitch_r,0,ring_bearing2_z]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w,0.82);
        }
    }

    // Disc A: eccentric center follows the input; disc orientation follows output ratio.
    rotate([0,0,drive_angle]) translate([eccentricity,0,0]){
        rotate([0,0,out_angle-drive_angle]){
            color([0.80,0.55,0.16,0.90]) translate([0,0,disc1_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc1_z+disc_t+0.4]) rotation_marker(max(3,ring_pitch_r-ring_roller_od-3),0,1.0,2.5);
        }
        if(show_hardware && use_eccentric_bearings) translate([0,0,disc1_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.52);
    }

    // Disc B is 180 degrees out of phase.
    rotate([0,0,drive_angle]) translate([-eccentricity,0,0]){
        rotate([0,0,180+out_angle-drive_angle]){
            color([0.88,0.64,0.22,0.78]) translate([0,0,disc2_z]) plate3d(disc_t,"disc");
            if(show_rotation_markers) translate([0,0,disc2_z+disc_t+0.4]) rotation_marker(max(3,ring_pitch_r-ring_roller_od-3),0,1.0,2.5);
        }
        if(show_hardware && use_eccentric_bearings) translate([0,0,disc2_z]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.42);
    }
    if(show_hardware) rotate([0,0,drive_angle]) eccentric_sleeves_3d(0.92);
    if(show_hardware) input_support_bearings_3d(0.6);

    // Output pins and a ghosted flange rotate at the reduced output angle.
    rotate([0,0,out_angle]){
        color([0.27,0.48,0.69,0.18]) translate([0,0,output_face_z]) output_face_plate_3d();
        color([0.38,0.57,0.74,0.28]) translate([0,0,output_hub_z]) plate3d(output_hub_t,"hub");
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
    body_len=motor_body_length;
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
            if(use_rear_support) translate([plate_r*0.55,0,z_motor+body_len+g]) simple_bearing(rear_support_id,rear_support_od,rear_support_w);
        }
    }
    if(use_rear_keeper) color([0.48,0.50,0.53]) translate([0,0,z_keeper]) plate3d(rear_keeper_t,"rear_keeper");
    color([0.65,0.67,0.70]) translate([0,0,z_rear]) plate3d(rear_plate_t,"rear");
    color([0.55,0.58,0.62,0.36]) translate([0,0,z_case]) plate3d(cavity_h,"case");

    if(show_hardware && !use_integrated_ring_ridges){
        for(i=[0:ring_count-1]){a=i*360/ring_count;rotate([0,0,a]) translate([ring_pitch_r,0,z_case+cavity_h+g/4]){
            color([0.30,0.30,0.32]) cylinder(d=ring_axle_d,h=ring_axle_length);
            translate([0,0,ring_axle_length+g/4]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
            translate([0,0,ring_axle_length+ring_bearing_w+g/2]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
        }}
    }

    translate([eccentricity,0,z_disc1]){color([0.80,0.55,0.16]) plate3d(disc_t,"disc");if(show_hardware){if(use_eccentric_bearings) translate([0,0,disc_t+g/3]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);if(use_separate_eccentric_sleeves && !use_double_sleeve) color([0.40,0.42,0.45]) translate([0,0,disc_t+(use_eccentric_bearings?ecc_bearing_w:0)+2*g/3]) eccentric_bushing_3d(+1);}}
    translate([-eccentricity,0,z_disc2]) rotate([0,0,180]){color([0.88,0.64,0.22]) plate3d(disc_t,"disc");if(show_hardware){if(use_eccentric_bearings) translate([0,0,disc_t+g/3]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);if(use_separate_eccentric_sleeves && !use_double_sleeve) color([0.40,0.42,0.45]) translate([0,0,disc_t+(use_eccentric_bearings?ecc_bearing_w:0)+2*g/3]) eccentric_bushing_3d(-1);}}
    // One-piece sleeve shown beside the disc stack, shifted off the axis so it is visible.
    if(show_hardware && use_double_sleeve) translate([plate_r*0.55,0,z_disc1-disc1_z]) double_eccentric_sleeve_3d();

    color([0.68,0.70,0.73]) translate([0,0,z_frontpin]) plate3d(front_pin_plate_t,"front_pin");
    if(use_flange_bearing) color([0.46,0.48,0.51]) translate([0,0,z_raceback]) plate3d(race_retainer_t,"race_retainer");
    color([0.36,0.50,0.66]) translate([0,0,z_innerret]) plate3d(race_retainer_t,"inner_retainer");
    color([0.38,0.57,0.74]) translate([0,0,z_hub]) plate3d(output_hub_t,"hub");
    if(show_hardware && use_front_pilot_bearing) translate([plate_r*0.55,0,z_hub]) simple_bearing(front_pilot_id,front_pilot_od,front_pilot_w);
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
    if(use_separate_eccentric_sleeves && !use_double_sleeve){
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
    if(use_separate_eccentric_sleeves && !use_double_sleeve) color([0.40,0.42,0.45]) translate([use_coupled_input_shaft?1.5*cell:-0.5*cell,-cell,0]) eccentric_bushing_3d(+1);
    if(use_separate_eccentric_sleeves && !use_double_sleeve) color([0.40,0.42,0.45]) translate([use_coupled_input_shaft?-1.5*cell:0.5*cell,-2*cell,0]) eccentric_bushing_3d(-1);
    if(use_double_sleeve) color([0.40,0.42,0.45]) translate([use_coupled_input_shaft?1.5*cell:-0.5*cell,-cell,-disc1_z]) double_eccentric_sleeve_3d();
    if(show_hardware && use_eccentric_bearings){
        translate([ 1.5*cell,-cell,0]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);
    }

    // Row 5 — catalog hardware / stock samples. Quantities are reported in BOM;
    // one representative of each hardware type is shown here for identification.
    if(show_hardware){
        if(use_flange_bearing) translate([-1.5*cell,-2*cell,0]) simple_bearing(flange_bearing_id,flange_bearing_od,flange_bearing_w);
        if(!use_integrated_ring_ridges) translate([-0.5*cell,-2*cell,0]) simple_bearing(ring_axle_d,ring_roller_od,ring_bearing_w);
        if(use_output_roller_bearings) translate([ 0.5*cell,-2*cell,0]) simple_bearing(output_pin_d,output_roller_od,output_roller_w);
        if(!use_integrated_ring_ridges) color([0.30,0.30,0.32]) translate([1.5*cell,-2*cell,0]) cylinder(d=ring_axle_d,h=ring_axle_length);
    }

    // Row 6 — second eccentric bearing and output pin stock sample.
    if(show_hardware){
        if(use_eccentric_bearings) translate([-0.5*cell,-3*cell,0]) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w);
        color([0.28,0.28,0.30]) translate([0.5*cell,-3*cell,0]) cylinder(d=output_pin_d,h=output_pin_length);
        if(use_front_pilot_bearing) translate([-1.5*cell,-3*cell,0]) simple_bearing(front_pilot_id,front_pilot_od,front_pilot_w);
        if(use_rear_support) translate([1.5*cell,-3*cell,0]) simple_bearing(rear_support_id,rear_support_od,rear_support_w);
    }
}
