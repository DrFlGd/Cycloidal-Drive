// 3D solids: lathe parts, plates with their blind pockets, hardware mock-ups and the
// input stack. Included by cycloidal_gearbox.scad.

module case_ring_3d(h){
    // Printed lobe contact faces get a chamfer at both ends so the first-layer flare
    // cannot bind on the disc. Each lobe circle is convex, so a hull of three stacked
    // discs gives the chamfered post; the 2D body supplies everything else.
    c = (use_integrated_ring_ridges && printed_lobe_end_chamfer>0 && printed_lobe_end_chamfer<ring_roller_od/4 && 2*printed_lobe_end_chamfer<h) ? printed_lobe_end_chamfer : 0;
    if(c==0) linear_extrude(height=h,convexity=10) case_ring_2d();
    else union(){
        linear_extrude(height=h,convexity=10) difference(){
            case_ring_body_2d();
            tie_holes_2d();
            for(i=[0:ring_count-1]) rotate([0,0,i*360/ring_count]) translate([ring_pitch_r,0]) circle(d=ring_roller_od+0.02);
        }
        for(i=[0:ring_count-1]) rotate([0,0,i*360/ring_count]) translate([ring_pitch_r,0,0])
            hull(){
                cylinder(d=ring_roller_od-2*c,h=0.01);
                translate([0,0,c]) cylinder(d=ring_roller_od,h=h-2*c);
                translate([0,0,h-0.01]) cylinder(d=ring_roller_od-2*c,h=0.01);
            }
    }
}
module output_hub_ring_3d(){
    difference(){
        linear_extrude(height=output_hub_t,convexity=10) output_hub_ring_2d();
        if(use_front_pilot) translate([0,0,-0.1]) cylinder(d=front_pilot_pocket_d,h=front_pilot_pocket_depth+0.1);
    }
}
// One-piece double eccentric sleeve, drawn in the shaft frame (bore on the Z axis):
// rear journal offset +X at disc 1, front journal offset -X at disc 2, an optional
// concentric set-screw collar in front.
module double_eccentric_sleeve_3d(){
    core_d = ecc_bushing_od - 2*eccentricity; // cylinder common to both journals
    difference(){
        union(){
            translate([ eccentricity,0,disc1_z]) cylinder(d=ecc_bushing_od,h=ecc_cam_length);
            translate([-eccentricity,0,disc2_z]) cylinder(d=ecc_bushing_od,h=ecc_cam_length);
            translate([0,0,disc1_z]) cylinder(d=core_d,h=sleeve_journal_end_z-disc1_z);
            if(use_sleeve_collar) translate([0,0,sleeve_journal_end_z-0.01]) cylinder(d=sleeve_collar_od,h=sleeve_collar_length+0.01);
            if(use_front_pilot) translate([0,0,max(sleeve_collar_end_z,sleeve_journal_end_z)-0.01]) cylinder(d=front_pilot_journal_d,h=front_journal_end_z-max(sleeve_collar_end_z,sleeve_journal_end_z)+0.01);
        }
        translate([0,0,disc1_z-1]) linear_extrude(height=sleeve_front_z-disc1_z+2) drive_bore_2d();
        if(use_sleeve_collar)
            for(j=[0,1]) rotate([0,0,90+j*90]) translate([0,0,sleeve_journal_end_z+sleeve_collar_length/2])
                rotate([0,90,0]) cylinder(d=sleeve_set_screw_tap_d,h=sleeve_collar_od+2,center=true);
    }
}
// All eccentric sleeve hardware for the current style, in the shaft frame at true z.
module eccentric_sleeves_3d(alpha=1){
    if(use_separate_eccentric_sleeves){
        if(use_double_sleeve) color([0.40,0.42,0.45,alpha]) double_eccentric_sleeve_3d();
        else {
            color([0.80,0.38,0.16,alpha]) translate([ eccentricity,0,disc1_z]) eccentric_bushing_3d(+1);
            color([0.18,0.48,0.78,alpha]) translate([-eccentricity,0,disc2_z]) eccentric_bushing_3d(-1);
        }
    }
}

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
        // Rear support bearing bore from the motor side up to a shoulder behind the rear plate.
        // (Spacer is drawn with its gearbox face at z=motor_mount_offset.)
        if(use_rear_support) translate([0,0,-0.1]) cylinder(d=rear_support_pocket_d,h=motor_mount_offset+rear_support_shoulder_z+0.1);
    }
}
module coupled_input_shaft_3d(angle=0){
    if(use_coupled_input_shaft)
    rotate([0,0,angle])
    difference(){
        union(){
            translate([0,0,coupled_hub_rear_z]) cylinder(d=active_coupled_hub_od,h=coupled_hub_length);
            cylinder(d=drive_shaft_d,h=integrated_shaft_front_z);
            if(coupled_core_pilot) translate([0,0,coupled_pilot_start_z-0.01]) cylinder(d=min(front_pilot_journal_d,drive_shaft_d+0.02),h=front_journal_end_z-coupled_pilot_start_z+0.01);
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

// Blind operations are cut by extruding the same 2D drill templates that are exported for
// CAM, so the 3D solid and the templates cannot disagree, and each pocket set is one boolean.
module rear_plate_3d(){
    difference(){
        linear_extrude(height=rear_plate_t,convexity=10) rear_plate_2d();
        // Level 3 uses a stepped motor-side pilot pocket plus a small shaft journal.
        if(use_input_plain_journal)
            translate([0,0,-0.1]) linear_extrude(height=active_motor_pilot_pocket_depth+0.1) rear_motor_pilot_pocket_template_2d();
        if(!use_rear_keeper && !use_integrated_ring_ridges)
            translate([0,0,rear_plate_t-rear_axle_blind_depth]) linear_extrude(height=rear_axle_blind_depth+0.2) rear_pin_drill_template_2d();
    }
}
module front_pin_plate_3d(){
    difference(){
        linear_extrude(height=front_pin_plate_t,convexity=10) front_pin_plate_2d();
        // pockets drilled from cavity/rear face, leaving a solid front skin
        if(!use_integrated_ring_ridges)
            translate([0,0,-0.1]) linear_extrude(height=front_axle_blind_depth+0.1) front_pin_drill_template_2d();
    }
}
module output_face_plate_3d(){
    difference(){
        linear_extrude(height=output_face_t,convexity=10) output_face_plate_2d();
        // Rear blind pin pockets
        translate([0,0,-0.1]) linear_extrude(height=output_pin_press_depth+0.1) output_pin_holes_2d(output_pin_face_hole_d);
        // Rear blind clamp-screw taps. Preview uses tap-drill diameter.
        translate([0,0,-0.1]) linear_extrude(height=min(output_face_t-1.5,8)+0.1) inner_retainer_screw_holes_2d(inner_retainer_tap_d);
        // Front blind output mounting taps
        translate([0,0,output_face_t-output_mount_depth]) linear_extrude(height=output_mount_depth+0.1) output_face_front_drill_template_2d();
    }
}
module plate3d(t,which){
    if(which=="rear") rear_plate_3d();
    else if(which=="front_pin") front_pin_plate_3d();
    else if(which=="case") case_ring_3d(t);
    else if(which=="hub") output_hub_ring_3d();
    else linear_extrude(height=t,convexity=10)
        if(which=="rear_keeper") rear_keeper_plate_2d();
        else if(which=="race_retainer") bearing_race_retainer_2d();
        else if(which=="bearing_carrier") bearing_carrier_2d();
        else if(which=="disc") cycloid_disc_2d();
        else if(which=="inner_retainer") inner_race_retainer_2d();
}
module eccentric_bushing_3d(sign=1){linear_extrude(height=ecc_cam_length,convexity=6) eccentric_bushing_2d(sign);}
module simple_bearing(id,od,w,alpha=1){
    color([0.22,0.22,0.24,alpha]) difference(){cylinder(d=od,h=w);translate([0,0,-0.1]) cylinder(d=id,h=w+0.2);}
    color([0.62,0.62,0.66,alpha]) difference(){cylinder(d=(od+id)/2,h=w);translate([0,0,-0.1]) cylinder(d=(od+id)/2-2,h=w+0.2);}
}
// Input support bearings at their true z (front pilot in the hub, rear support in the spacer).
module input_support_bearings_3d(alpha=1){
    if(use_front_pilot_bearing) translate([0,0,front_pilot_z]) simple_bearing(front_pilot_id,front_pilot_od,front_pilot_w,alpha);
    if(use_rear_support) translate([0,0,rear_support_z]) simple_bearing(rear_support_id,rear_support_od,rear_support_w,alpha);
}
module rotation_marker(radius,z=0,h=1.2,size=2.2,alpha=1){
    // Visualization-only marker so rotation of cylindrical parts is obvious.
    color([0.92,0.12,0.08,alpha]) translate([radius,0,z]) cube([size,size,h],center=true);
}
module motor_shaft_3d(len=minimum_drive_shaft_from_rear_plate+3,angle=0,marker=true,start_z=0){
    translate([0,0,start_z]) rotate([0,0,angle]){
        color([0.62,0.62,0.66]) difference(){
            cylinder(d=motor_shaft_d,h=len);
            // D-flat on the +Y side over the exposed shaft (visualisation only).
            if(motor_shaft_flat_depth>0) translate([-motor_shaft_d,motor_shaft_d/2-motor_shaft_flat_depth,2]) cube([2*motor_shaft_d,motor_shaft_d,len]);
        }
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
    input_support_bearings_3d(0.6);
    rotate([0,0,drive_angle]){
        eccentric_sleeves_3d();
        translate([eccentricity,0,disc1_z]){
            if(use_eccentric_bearings) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.48);
            if(show_rotation_markers) rotation_marker((use_eccentric_bearings?ecc_bearing_od:ecc_bushing_od)/2-1, ecc_cam_length/2, 1.0, 1.8,0.9);
        }
        translate([-eccentricity,0,disc2_z]){
            if(use_eccentric_bearings) simple_bearing(ecc_bearing_id,ecc_bearing_od,ecc_bearing_w,0.48);
            if(show_rotation_markers) rotation_marker((use_eccentric_bearings?ecc_bearing_od:ecc_bushing_od)/2-1, ecc_cam_length/2, 1.0, 1.8,0.9);
        }
    }
}
module motor_mockup(drive_angle=0){
    body_len=motor_body_length;
    face_z=motor_face_z;
    color([0.18,0.18,0.20,0.75]) translate([-frame_side/2,-frame_side/2,face_z-body_len]) cube([frame_side,frame_side,body_len]);
    color([0.35,0.35,0.37]) translate([0,0,face_z]) cylinder(d=motor_pilot_d,h=motor_pilot_height_setting);
    motor_shaft_3d(len=use_coupled_input_shaft?motor_shaft_protrusion_setting:minimum_drive_shaft_from_rear_plate+3,angle=drive_angle,start_z=face_z);
}
