// Runs one OpenSCAD job per message. Emscripten's callMain can only run once per module
// instance, so every job gets a fresh instance; the compiled WebAssembly module is reused.

let factory = null;
let compiled = null;

async function load(jsUrl, wasmUrl, wasmModule) {
  if (!factory) factory = (await import(jsUrl)).default;
  if (!compiled) compiled = wasmModule || await WebAssembly.compileStreaming(fetch(wasmUrl));
}

// OFF with per-face RGB(A) colours -> one flat triangle list per colour.
function offToGroups(text) {
  const lines = text.split("\n");
  let li = 0;
  const next = () => { while (li < lines.length) { const s = lines[li++].trim(); if (s && !s.startsWith("#")) return s; } return null; };
  let head = next();
  let counts;
  if (head.startsWith("OFF")) {
    const rest = head.slice(3).trim();
    counts = (rest ? rest : next()).split(/\s+/).map(Number);
  } else counts = head.split(/\s+/).map(Number);
  const [nv, nf] = counts;
  const verts = new Float64Array(nv * 3);
  for (let v = 0; v < nv; v++) {
    const p = next().split(/\s+/);
    verts[3 * v] = +p[0]; verts[3 * v + 1] = +p[1]; verts[3 * v + 2] = +p[2];
  }
  const groups = new Map();
  for (let f = 0; f < nf; f++) {
    const p = next().split(/\s+/).map(Number);
    const n = p[0];
    const idx = p.slice(1, 1 + n);
    const c = p.slice(1 + n);
    let key = "default";
    if (c.length >= 3) {
      const scale = c.some(x => x > 1) ? 255 : 1;
      key = [c[0] / scale, c[1] / scale, c[2] / scale, c.length > 3 ? c[3] / scale : 1].map(x => x.toFixed(3)).join(",");
    }
    let g = groups.get(key);
    if (!g) { g = []; groups.set(key, g); }
    for (let k = 1; k + 1 < n; k++) {
      for (const vi of [idx[0], idx[k], idx[k + 1]]) g.push(verts[3 * vi], verts[3 * vi + 1], verts[3 * vi + 2]);
    }
  }
  const out = [];
  for (const [key, arr] of groups) {
    out.push({ color: key === "default" ? null : key.split(",").map(Number), positions: new Float32Array(arr) });
  }
  return out;
}

self.onmessage = async (e) => {
  const { id, jsUrl, wasmUrl, wasmModule, files, args, output, parse } = e.data;
  const log = [];
  const t0 = performance.now();
  try {
    await load(jsUrl, wasmUrl, wasmModule);
    const mod = await factory({
      noInitialRun: true,
      print: s => log.push(s),
      printErr: s => log.push(s),
      instantiateWasm(imports, done) {
        WebAssembly.instantiate(compiled, imports).then(inst => done(inst, compiled));
        return {};
      },
    });
    for (const [path, text] of Object.entries(files)) {
      const parts = path.split("/");
      let dir = "";
      for (const d of parts.slice(0, -1)) {
        dir += "/" + d;
        try { mod.FS.mkdir(dir); } catch (_) { /* exists */ }
      }
      mod.FS.writeFile("/" + path, text);
    }
    let code;
    try { code = mod.callMain(args); } catch (err) { log.push(String(err)); code = -1; }
    let data = null;
    if (output) {
      try { data = mod.FS.readFile(output); } catch (_) { data = null; }
    }
    const ms = Math.round(performance.now() - t0);
    if (data && parse === "off") {
      const groups = offToGroups(new TextDecoder().decode(data));
      self.postMessage({ id, ok: true, code, log, ms, groups }, groups.map(g => g.positions.buffer));
    } else if (data) {
      self.postMessage({ id, ok: true, code, log, ms, data }, [data.buffer]);
    } else {
      self.postMessage({ id, ok: true, code, log, ms, data: null });
    }
  } catch (err) {
    self.postMessage({ id, ok: false, error: String(err && err.stack || err), log, ms: Math.round(performance.now() - t0) });
  }
};
