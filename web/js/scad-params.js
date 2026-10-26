// Reads the OpenSCAD Customizer parameters straight from the design file, so the web
// generator always offers exactly the parameters, defaults, ranges and choices that the
// desktop Customizer shows. Curated labels and layout live in schema.js.

function parseLiteral(text) {
  const t = text.trim();
  if (t === "true" || t === "false") return { type: "boolean", value: t === "true" };
  if (/^".*"$/.test(t)) return { type: "string", value: JSON.parse(t) };
  if (/^[-+]?(\d+\.?\d*|\.\d+)(e[-+]?\d+)?$/i.test(t)) return { type: "number", value: Number(t) };
  return null; // an expression: not a Customizer parameter
}

function parseSpec(spec, type) {
  const s = spec.trim();
  const range = s.match(/^([-+]?[\d.]+)\s*:\s*([-+]?[\d.]+)(?:\s*:\s*([-+]?[\d.]+))?$/);
  if (range && type === "number") {
    const [a, b, c] = [range[1], range[2], range[3]].map(x => (x === undefined ? undefined : Number(x)));
    return c === undefined ? { min: a, max: b } : { min: a, step: b, max: c };
  }
  const options = s.split(",").map(o => {
    const [value, label] = o.split(":").map(x => x.trim());
    const v = type === "number" ? Number(value) : value;
    return { value: v, label: label ?? value };
  });
  return { options };
}

export function parseCustomizer(source) {
  const params = [];
  let group = null;
  let comments = [];
  for (const raw of source.split(/\r?\n/)) {
    const line = raw.trim();
    const g = line.match(/^\/\*\s*\[([^\]]+)\]\s*\*\/$/);
    if (g) {
      group = g[1].trim();
      comments = [];
      if (group === "Hidden") break;
      continue;
    }
    if (group === null) continue; // file header
    if (/^(include|use)\s*</.test(line)) break;
    if (line.startsWith("//")) { comments.push(line.replace(/^\/\/\s?/, "")); continue; }
    if (!line) { comments = []; continue; }
    const m = line.match(/^(\$?[A-Za-z_]\w*)\s*=\s*(.+?);\s*(?:\/\/\s*\[(.*)\]\s*)?$/);
    if (m) {
      const lit = parseLiteral(m[2]);
      if (lit) {
        const p = { name: m[1], group, type: lit.type, default: lit.value, description: comments.join(" ") };
        if (m[3] !== undefined) Object.assign(p, parseSpec(m[3], lit.type));
        params.push(p);
      }
    }
    comments = [];
  }
  return params;
}

// Libraries pulled in by include/use, relative to the main file.
export function findIncludes(source) {
  return [...source.matchAll(/^\s*(?:include|use)\s*<([^>]+)>/gm)].map(m => m[1]);
}

// Customizer preset files store every value as a string; convert to the parameter's type.
export function coerce(param, value) {
  if (value === undefined || value === null) return param.default;
  if (param.type === "number") { const n = Number(value); return Number.isFinite(n) ? n : param.default; }
  if (param.type === "boolean") return value === true || value === "true";
  return String(value);
}

// OpenSCAD literal for a -D definition.
export function toScadLiteral(param, value) {
  if (param.type === "number") return String(Number(value));
  if (param.type === "boolean") return value ? "true" : "false";
  return JSON.stringify(String(value));
}
