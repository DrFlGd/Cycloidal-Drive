#!/usr/bin/env python3
"""Compile every Customizer preset across all simplification levels and input architectures.

OpenSCAD applies values from a -p/-P parameter set *after* -D definitions, so a -D override of a
key that the preset also stores (input_shaft_mode, coupled_eccentric_mode, ...) is silently
ignored. This script therefore writes one derived parameter set per combination into a
temporary JSON file and selects each with -P, so every override really applies.

Usage:
    tools/validate_presets.py [--scad src/file.scad] [--json src/file.json] [--csv out.csv]
                              [--levels ...] [--modes ...] [--quick]

Exit status is non-zero when any combination fails an assertion.
"""
import argparse, csv, json, os, re, subprocess, sys, tempfile

LEVELS = ["Full hardware", "Integrated case lobes", "Direct pin and cam contact", "Bearingless printed journals"]
MODES = [("Direct motor shaft", "Separate eccentric sleeves"),
         ("Machined coupled shaft", "Separate eccentric sleeves"),
         ("Machined coupled shaft", "Integrated double eccentric")]
ECHO_KEYS = {
    "housing_od_mm": r'Housing OD: ([\d.]+) mm',
    "ring_pitch_r_mm": r'Ring pitch radius: ([\d.]+) mm',
    "pitch_growth_mm": r'packing growth over preset: ([\d.]+) mm',
    "output_face_od_mm": r'Output face OD: ([\d.]+) mm',
    "depth_mm": r'Overall gearbox depth from motor face to output face: ([\d.]+) mm',
    "facet_error_mm": r'est\. max facet error ([\d.e-]+) mm',
    "undercut_margin_mm": r'undercut margin ([\d.e-]+) mm',
    "min_shaft_mm": r'Minimum motor shaft protrusion: ([\d.]+) mm',
    "front_support": r'Input front support: ([^"|]*?)\s*(?:\||")',
    "rear_support": r'Input rear support: ([^"|]*?)\s*(?:\||")',
}


def main():
    ap = argparse.ArgumentParser()
    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(here)
    ap.add_argument("--scad", default=os.path.join(root, "src", "cycloidal_gearbox.scad"))
    ap.add_argument("--json", default=None, help="preset file (default: same basename as --scad)")
    ap.add_argument("--csv", default=None, help="write results to this CSV")
    ap.add_argument("--levels", nargs="*", default=LEVELS)
    ap.add_argument("--modes", nargs="*", default=None, help='"input|eccentric" pairs')
    ap.add_argument("--quick", action="store_true", help="Full hardware + direct shaft only")
    ap.add_argument("--openscad", default=os.environ.get("OPENSCAD", "openscad"))
    args = ap.parse_args()
    json_path = args.json or os.path.splitext(args.scad)[0] + ".json"
    presets = json.load(open(json_path))["parameterSets"]
    modes = MODES if args.modes is None else [tuple(m.split("|")) for m in args.modes]
    levels = args.levels
    if args.quick:
        levels, modes = [LEVELS[0]], [MODES[0]]

    combos = {"fileFormatVersion": "1", "parameterSets": {}}
    for name, p in presets.items():
        for lvl in levels:
            for im, em in modes:
                q = dict(p)
                q.update({"simplification_level": lvl, "input_shaft_mode": im, "coupled_eccentric_mode": em,
                          "part": "layout_2d", "spec_output": "Off"})
                combos["parameterSets"][f"{name}|{lvl}|{im}|{em}"] = q
    fd, tmp = tempfile.mkstemp(suffix=".json")
    with os.fdopen(fd, "w") as f:
        json.dump(combos, f)

    rows, failures = [], 0
    try:
        for key in combos["parameterSets"]:
            name, lvl, im, em = key.split("|")
            out = subprocess.run([args.openscad, "-o", "/dev/stdout", "--export-format", "echo",
                                  "-p", tmp, "-P", key, args.scad],
                                 capture_output=True, text=True).stdout + ""
            m = re.search(r'Assertion .*? failed: "(.*?)"', out, re.S)
            status = "FAIL" if m else "PASS"
            # A preset that itself specifies the machined coupled shaft does so because the
            # motor shaft is too short for the direct-shaft stack; forcing direct mode on it is
            # not a configuration anyone would build, so that one assertion counts as N/A.
            if m and presets[name].get("input_shaft_mode") == "Machined coupled shaft" \
                    and im == "Direct motor shaft" and m.group(1).startswith("Motor shaft is too short"):
                status = "N/A"
            row = {"preset": name, "simplification_level": lvl, "input_shaft_mode": im,
                   "coupled_eccentric_mode": em, "status": status,
                   "message": m.group(1) if m else ""}
            for k, pat in ECHO_KEYS.items():
                mm = re.search(pat, out)
                row[k] = mm.group(1) if mm else ""
            warn = re.findall(r'WARNING: (.*?)"', out)
            row["warnings"] = " / ".join(warn)
            rows.append(row)
            failures += row["status"] == "FAIL"
            flag = {"FAIL": "FAIL", "PASS": "ok  ", "N/A": "n/a "}[status]
            print(f"{flag} {name:22s} | {lvl:28s} | {im:22s} | {em:27s} | OD {row['housing_od_mm']:>7s} | growth {row['pitch_growth_mm']:>5s} | facet {row['facet_error_mm'][:7]:>7s}"
                  + (f" | {row['message'][:90]}" if m else "") + (f" | WARN {row['warnings'][:80]}" if warn else ""))
    finally:
        os.unlink(tmp)

    if args.csv:
        with open(args.csv, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            w.writeheader(); w.writerows(rows)
    na = sum(r["status"] == "N/A" for r in rows)
    print(f"\n{len(rows) - failures - na}/{len(rows) - na} applicable combinations pass ({na} not applicable)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
