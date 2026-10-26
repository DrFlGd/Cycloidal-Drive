// Turns OpenSCAD console output into the design check, build report, part specs and BOM.

function echoText(line) {
  const m = line.match(/^ECHO:\s*(.*)$/);
  if (!m) return null;
  let t = m[1].trim();
  if (t.startsWith('"') && t.endsWith('"')) {
    try { t = JSON.parse(t); } catch (_) { t = t.slice(1, -1); }
  }
  return t;
}

function fields(line) {
  const out = {};
  for (const part of line.split("|").slice(1)) {
    const i = part.indexOf("=");
    if (i < 0) out[part] = "";
    else out[part.slice(0, i)] = part.slice(i + 1);
  }
  return out;
}

export function parseReport(log) {
  const r = { errors: [], warnings: [], build: {}, buildOrder: [], specs: [], operations: [], hardware: [], omitted: [], header: null };
  for (const line of log) {
    const assertion = line.match(/Assertion '.*?' failed: "(.*)"/s) || line.match(/Assertion .* failed: "(.*?)"/s);
    if (assertion) { r.errors.push(assertion[1]); continue; }
    if (/^ERROR:/.test(line)) { r.errors.push(line.replace(/^ERROR:\s*/, "")); continue; }
    if (/^WARNING:/.test(line)) {
      const w = line.replace(/^WARNING:\s*/, "");
      if (!/Could not initialize localization|Viewall and autocenter/.test(w)) r.warnings.push(w);
      continue;
    }
    const t = echoText(line);
    if (t === null) continue;
    if (/^=+/.test(t)) continue;
    if (t.startsWith("WARNING:")) { r.warnings.push(t.replace(/^WARNING:\s*/, "")); continue; }
    if (t.startsWith("SPEC|")) {
      const f = fields(t);
      if (f.scope) r.header = f;
      else if (f.part) r.specs.push(f);
      else if (f.operation) r.operations.push(f);
      continue;
    }
    if (t.startsWith("HARDWARE|")) { r.hardware.push(fields(t)); continue; }
    if (t.startsWith("OMITTED_HARDWARE|")) { r.omitted.push(fields(t)); continue; }
    if (t.startsWith("CATALOG_STATUS|")) continue;
    const i = t.indexOf(": ");
    if (i > 0) {
      const k = t.slice(0, i), v = t.slice(i + 2);
      if (!(k in r.build)) r.buildOrder.push(k);
      r.build[k] = v;
    }
  }
  return r;
}

const num = (s, re) => { const m = s && s.match(re); return m ? Number(m[1]) : null; };

// Headline numbers for the summary cards.
export function keyFigures(r, params) {
  const b = r.build;
  const fig = [];
  const ratio = num(b["Ratio"], /^(\d+)/);
  if (ratio) fig.push({ label: "Ratio", value: `${ratio}:1` });
  const od = num(b["Housing OD"], /([\d.]+)/);
  if (od) fig.push({ label: "Housing OD", value: `${od} mm` });
  const depth = num(b["Overall gearbox depth from motor face to output face"], /([\d.]+)/);
  if (depth) fig.push({ label: "Depth", value: `${depth} mm` });
  const face = num(b["Output face OD"], /([\d.]+)/);
  if (face) fig.push({ label: "Output face", value: `${face} mm` });
  const minShaft = num(b["Minimum motor shaft protrusion"], /([\d.]+)/);
  if (minShaft !== null) {
    const have = params && params.motor_shaft_protrusion_setting;
    fig.push({ label: "Shaft needed", value: `${minShaft} mm`, note: have ? `motor has ${have} mm` : "", warn: have && have < minShaft });
  }
  const prof = b["Cycloid profile"];
  const undercut = num(prof, /undercut margin ([\d.e-]+)/);
  if (undercut !== null) fig.push({ label: "Undercut margin", value: `${undercut.toFixed(2)} mm`, warn: undercut < 0.5 });
  const facet = num(prof, /facet error ([\d.e-]+)/);
  if (facet !== null) fig.push({ label: "Facet error", value: `${(facet * 1000).toFixed(2)} µm` });
  return fig;
}
