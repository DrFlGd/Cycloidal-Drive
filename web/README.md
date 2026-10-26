# Web generator

A static page that drives `src/cycloidal_gearbox.scad` in the browser. There is no build step and no copy of the design: the page fetches the `.scad` files and the preset JSON from `src/` and runs them in OpenSCAD 2025 compiled to WebAssembly (Manifold backend), loaded from the pinned `openscad-playground@2.4.0` package on jsdelivr.

## Layout of the page

1. **Configure** starts from a preset and groups the Customizer parameters by function (motor, build method, input shaft, support bearings, bearings, gear geometry, housing, and two advanced groups). Settings that the current build does not use are hidden, changed values are marked and can be reset one at a time, and the design can be saved as a Customizer parameter set, loaded back, shared as a link, or downloaded as an OpenSCAD project.
2. **Preview** renders the assembly, exploded view, input stack, parts layout, 2D profiles or any single part, with a section cut. Draft and Normal quality use fewer curve segments than an export.
3. **Check & export** runs the design's own assertions after every change, links a failing rule to the settings worth changing, shows the build report, part specs and hardware BOM, and exports single files or packs.

## Files

| File | Contents |
| --- | --- |
| `index.html`, `css/app.css` | page structure and styles |
| `js/config.js` | pinned CDN URLs and the location of `src/` |
| `js/scad-params.js` | reads Customizer parameters, defaults, ranges and choices from the `.scad` file |
| `js/schema.js` | sections, labels, help text, when each setting applies, parts and views, rule hints |
| `js/main.js` | state, form, runs, results and export |
| `js/engine.js`, `js/openscad-worker.js` | OpenSCAD jobs in Web Workers (one each for check, preview and export) |
| `js/viewer3d.js` | three.js viewer for coloured OFF output |
| `js/report.js` | parses `ECHO`, `SPEC|`, `HARDWARE|` and assertion output |
| `js/zip.js` | small ZIP writer for packs |

## Keeping it in step with the design

New Customizer parameters show up automatically under **Other settings**. `tools/check_web_schema.py` fails until each one is given a section and label in `js/schema.js` (or listed in `VIEW_PARAMS` if the preview drives it), and until new `part` options are added to `PARTS` or `VIEWS`. If a new rule depends on a setting, add a line to `RULE_HINTS`. When a part only exists in some configurations, extend `partApplies`.

`node tools/web_smoke_test.mjs` (after `npm install --no-save playwright && npx playwright install chromium`) serves the repository, opens the page in headless Chromium, and checks the design check, the preview, a DXF and an STL export, and a failing rule.
