// External runtime pieces, pinned to exact versions. Everything else is served from this repo.
//
// OpenSCAD 2025.03.25 compiled to WebAssembly (Manifold backend), as published in the
// openscad-playground package. GPL-2.0, same as OpenSCAD itself.
export const OPENSCAD_JS = "https://cdn.jsdelivr.net/npm/openscad-playground@2.4.0/dist/wasm/openscad.js";
export const OPENSCAD_WASM = "https://cdn.jsdelivr.net/npm/openscad-playground@2.4.0/dist/wasm/openscad.wasm";

// Design sources, relative to this file: web/js/ -> src/
export const SOURCE_BASE = new URL("../../src/", import.meta.url).href;
export const MAIN_SCAD = "cycloidal_gearbox.scad";
export const PRESET_JSON = "cycloidal_gearbox.json";
