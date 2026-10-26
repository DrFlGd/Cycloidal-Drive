#!/usr/bin/env python3
"""Regenerate docs/data/PROFILE_GUIDE.csv from the Customizer presets and the validation CSV."""
import csv, json, os
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
presets = json.load(open(os.path.join(root, "src", "cycloidal_gearbox.json")))["parameterSets"]
val = {}
for r in csv.DictReader(open(os.path.join(root, "docs", "data", "validation_matrix.csv"))):
    p = presets[r["preset"]]
    coupled = p["input_shaft_mode"] == "Machined coupled shaft"
    if r["simplification_level"] == "Full hardware" and r["input_shaft_mode"] == p["input_shaft_mode"] \
            and r["coupled_eccentric_mode"] == (p["coupled_eccentric_mode"] if coupled else "Separate eccentric sleeves"):
        val[r["preset"]] = r
cols = ["profile", "motor_frame", "ratio", "torque_class", "ring_bearing", "ring_pitch_r_mm", "eccentricity_mm", "eccentric_bearing",
        "output_roller", "flange_bearing", "housing_od_mm", "depth_mm", "input_shaft_mode", "eccentric_input", "front_support", "rear_support",
        "motor_shaft_protrusion_mm", "direct_cam_od_mm", "locking_thread"]
with open(os.path.join(root, "docs", "data", "PROFILE_GUIDE.csv"), "w", newline="") as f:
    w = csv.writer(f); w.writerow(cols)
    for name, p in presets.items():
        v = val.get(name, {})
        coupled = p["input_shaft_mode"] == "Machined coupled shaft"
        ecc_input = (p["coupled_eccentric_mode"] if coupled else f'{p["eccentric_sleeve_style"]} / {p["eccentric_bore_style"]}')
        w.writerow([name, p["motor_frame"], p["reduction_ratio"], p["torque_class"], p["ring_bearing_select"], p["ring_pitch_base_r_setting"],
                    p["eccentricity_setting"], p["ecc_bearing_select"], p["output_roller_bearing_select"], p["flange_bearing_select"],
                    v.get("housing_od_mm", ""), v.get("depth_mm", ""), p["input_shaft_mode"], ecc_input, v.get("front_support", "").split(" in ")[0],
                    v.get("rear_support", "").split(" in ")[0], p["motor_shaft_protrusion_setting"], p["direct_cam_od_setting"],
                    p["coupled_set_screw_thread"] if coupled else p["eccentric_set_screw_thread"]])
print("wrote docs/data/PROFILE_GUIDE.csv")
