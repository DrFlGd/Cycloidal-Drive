#!/usr/bin/env python3
"""Check that the web generator's layout (web/js/schema.js) matches the design's Customizer.

Every Customizer parameter in src/cycloidal_gearbox.scad must be placed in a section of the
web form or be driven by the preview/export panels, every name the web form lists must
still exist, and the web part and view lists must match the `part` selector options.
A parameter the form does not place still appears on the page under "Other settings", so a
failure here is a reminder to give it a proper home rather than a broken page.
"""
import os, re, sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
scad = open(os.path.join(root, "src", "cycloidal_gearbox.scad")).read()
schema = open(os.path.join(root, "web", "js", "schema.js")).read()

params, part_options = [], []
group = None
for line in scad.splitlines():
    s = line.strip()
    g = re.match(r"^/\*\s*\[([^\]]+)\]\s*\*/$", s)
    if g:
        group = g.group(1).strip()
        if group == "Hidden":
            break
        continue
    if group is None or s.startswith("//"):
        continue
    m = re.match(r'^(\$?[A-Za-z_]\w*)\s*=\s*("[^"]*"|true|false|[-+]?[\d.]+(?:e[-+]?\d+)?)\s*;\s*(?://\s*\[(.*)\])?', s)
    if m:
        params.append(m.group(1))
        if m.group(1) == "part":
            part_options = [o.strip() for o in m.group(3).split(",")]

def js_block(name, open_ch, close_ch):
    start = schema.index(name)
    i = schema.index(open_ch, start)
    depth = 0
    for j in range(i, len(schema)):
        if schema[j] == open_ch:
            depth += 1
        elif schema[j] == close_ch:
            depth -= 1
            if depth == 0:
                return schema[i:j + 1]
    raise ValueError(name)

placed = set(re.findall(r"^\s{2}(\$?\w+):\s*\{", js_block("export const PARAMS", "{", "}"), re.M))
view_params = set(re.findall(r'"(\$?\w+)"', js_block("export const VIEW_PARAMS", "[", "]")))
web_parts = re.findall(r'\{\s*id:\s*"(\w+)"', js_block("export const PARTS", "[", "]"))
web_views = re.findall(r'\{\s*id:\s*"(\w+)"', js_block("export const VIEWS", "[", "]"))

errors = []
for p in params:
    if p not in placed and p not in view_params:
        errors.append(f"parameter {p} has no place in the web form (add it to PARAMS or VIEW_PARAMS in web/js/schema.js)")
for p in sorted((placed | view_params) - set(params)):
    errors.append(f"web/js/schema.js lists {p}, which is no longer a Customizer parameter")
for p in part_options:
    if p not in web_parts and p not in web_views and p != "motion_demo":
        errors.append(f"part option {p} is not offered by the web generator (add it to PARTS or VIEWS)")
for p in web_parts + web_views:
    if p not in part_options:
        errors.append(f"web part/view {p} is not a `part` option in the design")

for e in errors:
    print("FAIL", e)
print(f"{len(params)} Customizer parameters, {len(web_parts)} parts, {len(web_views)} views: "
      + ("OK" if not errors else f"{len(errors)} problem(s)"))
sys.exit(1 if errors else 0)
