// 2D production geometry: through-cut plate outlines for DXF/CAM and the blind-operation
// drill templates. Included by cycloidal_gearbox.scad.

module polar_holes(count,radius,dia,rot=0){
    for(i=[0:count-1]) rotate([0,0,rot+i*360/count]) translate([radius,0]) circle(d=dia);
}
module nema_mount_holes_2d(){for(sx=[-1,1],sy=[-1,1]) translate([sx*mount_spacing/2,sy*mount_spacing/2]) circle(d=mount_hole_d);}
module tie_holes_2d(){polar_holes(tie_count,tie_r,tie_clear_d,360/(2*tie_count));}
module ring_axle_holes_2d(dia){polar_holes(ring_count,ring_pitch_r,dia,0);}
module output_pin_holes_2d(dia){polar_holes(output_pin_count,output_pin_circle_r,dia,0);}
module output_mount_holes_2d(dia){polar_holes(output_mount_count,output_mount_r,dia,output_mount_rot);}
module inner_retainer_screw_holes_2d(dia){polar_holes(inner_retainer_screw_count,inner_retainer_screw_r,dia,45);}

// -----------------------------------------------------------------------------
// 2D PRODUCTION GEOMETRY
// -----------------------------------------------------------------------------
module integrated_ring_ridges_2d(){
    // Printed stationary ring contacts: each contact circle is hulled to a wide root
    // that overlaps the annular wall (case-rooted lobes, no thin stems).
    pitch_chord = 2*case_inner_r*sin(180/ring_count);
    root_w = min(pitch_chord*printed_lobe_root_fraction, ring_roller_od*1.45);
    root_inner_x = case_inner_r - printed_lobe_cavity_overlap;
    root_outer_x = min(plate_r-1.0, case_inner_r + printed_lobe_embed_depth);
    root_depth = max(0.5,root_outer_x-root_inner_x);
    for(i=[0:ring_count-1]) rotate([0,0,i*360/ring_count])
        hull(){
            translate([ring_pitch_r,0]) circle(d=ring_roller_od);
            translate([root_inner_x,-root_w/2]) square([root_depth,root_w]);
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
module case_ring_body_2d(){
    // Ring plus lobes. A closing offset (grow, then shrink) fills the sharp internal corner
    // where each lobe meets the wall with a fillet of printed_lobe_root_fillet; convex
    // edges and the circular bore are unchanged by it.
    f = (use_integrated_ring_ridges && printed_lobe_root_fillet>0) ? printed_lobe_root_fillet : 0;
    if(f>0) offset(r=-f) offset(r=f) case_ring_raw_2d();
    else case_ring_raw_2d();
}
module case_ring_raw_2d(){
    union(){
        difference(){circle(r=plate_r);circle(r=case_inner_r);}
        if(use_integrated_ring_ridges) integrated_ring_ridges_2d();
    }
}
module case_ring_2d(){
    difference(){
        case_ring_body_2d();
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
// Drive bore for the eccentric sleeves: round, or D-shaped with the flat on the +Y side
// of the shaft axis so both sleeves (and the motor shaft flat) share one orientation.
module drive_bore_2d(){
    if(use_d_flat_bore)
        intersection(){
            circle(d=ecc_drive_bore_d);
            translate([-ecc_drive_bore_d, -ecc_drive_bore_d]) square([2*ecc_drive_bore_d, ecc_drive_bore_d + drive_flat_dist]);
        }
    else circle(d=ecc_drive_bore_d);
}
module eccentric_bushing_2d(sign=1){difference(){circle(d=ecc_bushing_od);translate([-sign*eccentricity,0]) drive_bore_2d();}}
