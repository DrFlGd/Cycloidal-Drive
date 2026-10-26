import { SOURCE_BASE, MAIN_SCAD, PRESET_JSON } from "./config.js";
import { parseCustomizer, findIncludes, coerce, toScadLiteral } from "./scad-params.js";
import { SECTIONS, PARAMS, VIEW_PARAMS, LEVEL_CARDS, INPUT_CARDS, VIEWS, PARTS, RULE_HINTS, partApplies } from "./schema.js";
import { Channel, loadEngine } from "./engine.js";
import { parseReport, keyFigures } from "./report.js";
import { makeZip } from "./zip.js";

const $ = (sel, el = document) => el.querySelector(sel);
const $$ = (sel, el = document) => [...el.querySelectorAll(sel)];
const h = (tag, attrs = {}, ...kids) => {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (v === undefined || v === null || v === false) continue;
    if (k === "class") el.className = v;
    else if (k === "text") el.textContent = v;
    else if (k.startsWith("on")) el.addEventListener(k.slice(2), v);
    else el.setAttribute(k, v === true ? "" : v);
  }
  for (const kid of kids.flat()) if (kid !== null && kid !== undefined && kid !== false) el.append(kid);
  return el;
};
const store = {
  get(k) { try { return JSON.parse(localStorage.getItem("cyclo." + k)); } catch (_) { return null; } },
  set(k, v) { try { localStorage.setItem("cyclo." + k, JSON.stringify(v)); } catch (_) { /* private mode */ } },
};
const slug = s => String(s || "design").trim().replace(/[^A-Za-z0-9._-]+/g, "_").replace(/^_+|_+$/g, "") || "design";
const MAIN_PATH = "/src/" + MAIN_SCAD;

const S = {
  files: {},
  params: [],
  byName: new Map(),
  presets: {},
  loadedPresets: {},
  preset: null,
  baseline: {},
  values: {},
  report: null,
  checkText: "",
  view: { id: "assembly", part: null, dim: "3d" },
  showAdvanced: false,
  filter: "",
  previewKey: null,
  previewDirty: true,
  exportAbort: false,
};
const checkCh = new Channel("latest");
const previewCh = new Channel("latest");
const exportCh = new Channel("queue");
let viewer = null;

// ---------------------------------------------------------------------------------------
// loading
// ---------------------------------------------------------------------------------------
async function fetchText(rel) {
  const r = await fetch(new URL(rel, SOURCE_BASE));
  if (!r.ok) throw new Error(`Could not load ${rel} (${r.status})`);
  return r.text();
}

async function loadSources() {
  const main = await fetchText(MAIN_SCAD);
  S.files["src/" + MAIN_SCAD] = main;
  await Promise.all(findIncludes(main).map(async inc => { S.files["src/" + inc] = await fetchText(inc); }));
  S.params = parseCustomizer(main);
  for (const p of S.params) S.byName.set(p.name, p);
  const ver = main.match(/design_version\s*=\s*"([^"]+)"/);
  $("#design-version").textContent = ver ? "v" + ver[1] : "";
  try { S.presets = JSON.parse(await fetchText(PRESET_JSON)).parameterSets || {}; } catch (_) { S.presets = {}; }
}

function allPresets() { return { ...S.presets, ...S.loadedPresets }; }

function presetValues(name) {
  const set = allPresets()[name] || {};
  const v = {};
  for (const p of S.params) {
    if (VIEW_PARAMS.has(p.name) && p.name !== "profile_name") v[p.name] = p.default;
    else v[p.name] = coerce(p, set[p.name]);
  }
  if (name && !set.profile_name) v.profile_name = name;
  return v;
}

function applyPreset(name, overrides = {}) {
  S.preset = name;
  S.baseline = presetValues(name);
  S.values = { ...S.baseline };
  for (const [k, v] of Object.entries(overrides)) if (S.byName.has(k)) S.values[k] = coerce(S.byName.get(k), v);
}

function diffs() {
  const d = {};
  for (const p of S.params) {
    if (VIEW_PARAMS.has(p.name) && p.name !== "profile_name") continue;
    if (S.values[p.name] !== S.baseline[p.name]) d[p.name] = S.values[p.name];
  }
  return d;
}

function stateFromHash() {
  if (!location.hash.startsWith("#")) return null;
  const q = new URLSearchParams(location.hash.slice(1));
  if (!q.has("preset")) return null;
  const o = {};
  for (const [k, v] of q) if (k !== "preset") o[k] = v;
  return { preset: q.get("preset"), overrides: o };
}

function hashFor(preset, d) {
  const q = new URLSearchParams();
  q.set("preset", preset);
  for (const [k, v] of Object.entries(d)) q.set(k, String(v));
  return "#" + q.toString().replace(/\+/g, "%20");
}

function saveState() {
  const d = diffs();
  const hash = hashFor(S.preset, d);
  history.replaceState(null, "", hash);
  store.set("state", { preset: S.preset, overrides: d, loaded: S.loadedPresets });
}

// ---------------------------------------------------------------------------------------
// configuration form
// ---------------------------------------------------------------------------------------
function metaFor(p) {
  return PARAMS[p.name] || { section: "other", label: p.name.replace(/_/g, " ").replace(/\bsetting\b/, "").trim() };
}

function applies(p) {
  const m = metaFor(p);
  return !m.when || m.when(S.values);
}

function fmtNum(v) { return Number.isInteger(v) ? String(v) : String(+v.toFixed(6)); }

function buildControl(p, m) {
  const name = p.name;
  const commit = (v) => setValue(name, v);
  if (m.control === "cards") {
    const cards = name === "simplification_level" ? LEVEL_CARDS : INPUT_CARDS;
    const wrap = h("div", { class: "cards", role: "radiogroup", "aria-label": m.label });
    for (const c of cards) {
      wrap.append(h("button", { type: "button", class: "card", role: "radio", "data-value": c.value, onclick: () => commit(c.value) },
        c.tag ? h("span", { class: "c-tag", text: c.tag }) : null,
        h("span", { class: "c-title", text: c.title }),
        h("span", { class: "c-text", text: c.text })));
    }
    wrap.sync = (v) => $$(".card", wrap).forEach(b => { const on = b.dataset.value === v; b.classList.toggle("active", on); b.setAttribute("aria-checked", on); });
    return wrap;
  }
  if (p.options) {
    const opts = p.options.map(o => ({ value: p.type === "number" ? o.value : String(o.value), label: String(o.label) }));
    const short = opts.length <= 4 && opts.reduce((s, o) => s + o.label.length, 0) <= 34;
    if (short) {
      const seg = h("div", { class: "segmented", role: "radiogroup", "aria-label": m.label });
      for (const o of opts) seg.append(h("button", { type: "button", "data-value": String(o.value), onclick: () => commit(o.value), text: o.label }));
      seg.sync = (v) => $$("button", seg).forEach(b => b.classList.toggle("active", b.dataset.value === String(v)));
      return seg;
    }
    const sel = h("select", { id: "f-" + name, onchange: () => commit(p.type === "number" ? Number(sel.value) : sel.value) });
    sel.sync = (v) => {
      if (![...sel.options].some(o => o.value === String(v))) sel.append(h("option", { value: String(v), text: String(v) + " (preset value)" }));
      for (const o of opts) if (![...sel.options].some(x => x.value === String(o.value))) sel.append(h("option", { value: String(o.value), text: o.label }));
      sel.value = String(v);
    };
    for (const o of opts) sel.append(h("option", { value: String(o.value), text: o.label }));
    return sel;
  }
  if (p.type === "boolean") {
    const box = h("input", { type: "checkbox", id: "f-" + name, onchange: () => commit(box.checked) });
    const lab = h("label", { class: "switch" }, box, h("span"), "On");
    lab.sync = (v) => { box.checked = !!v; };
    return lab;
  }
  if (p.type === "number") {
    const numIn = h("input", { type: "number", id: "f-" + name, step: p.step ?? "any", min: p.min, max: p.max,
      onchange: () => { if (numIn.value !== "") commit(Number(numIn.value)); } });
    if (p.min !== undefined && p.max !== undefined) {
      const rng = h("input", { type: "range", min: p.min, max: p.max, step: p.step ?? "any", "aria-label": m.label,
        oninput: () => { numIn.value = rng.value; }, onchange: () => commit(Number(rng.value)) });
      const wrap = h("div", { class: "ctl-range" }, rng, numIn);
      wrap.sync = (v) => { rng.value = v; numIn.value = fmtNum(v); };
      return wrap;
    }
    numIn.sync = (v) => { numIn.value = fmtNum(v); };
    return numIn;
  }
  const txt = h("input", { type: "text", id: "f-" + name, onchange: () => commit(txt.value) });
  txt.sync = (v) => { txt.value = v; };
  return txt;
}

function buildSections() {
  const root = $("#sections");
  root.innerHTML = "";
  const open = store.get("openSections") || ["motor", "build"];
  let n = 0;
  for (const sec of SECTIONS) {
    const params = S.params.filter(p => !VIEW_PARAMS.has(p.name) && metaFor(p).section === sec.id);
    if (!params.length) continue;
    const num = sec.advanced ? "Adv" : String(++n);
    const det = h("details", { class: "section", "data-section": sec.id, "data-advanced": sec.advanced ? "1" : null });
    if (open.includes(sec.id)) det.open = true;
    det.addEventListener("toggle", () => {
      const ids = $$("details.section[open]").map(d => d.dataset.section);
      if (!S.filter) store.set("openSections", ids);
    });
    const badges = h("span", { class: "s-badges" });
    det.append(h("summary", {}, h("span", { class: "s-num", text: num }), h("span", { class: "s-title", text: sec.title }), badges));
    const body = h("div", { class: "s-body" }, h("p", { class: "s-blurb", text: sec.blurb }));
    let sub = null;
    for (const p of params) {
      const m = metaFor(p);
      if (m.sub && m.sub !== sub) { sub = m.sub; body.append(h("h4", { class: "subhead", "data-sub": sub, text: sub })); }
      const ctl = buildControl(p, m);
      const help = m.help || (PARAMS[p.name] ? "" : p.description);
      const field = h("div", { class: "field", "data-name": p.name, "data-sub": m.sub || "" },
        h("div", { class: "field-head" },
          h("span", { class: "dot", title: "Changed from the preset" }),
          h("label", { for: "f-" + p.name, text: m.label }),
          m.unit ? h("span", { class: "unit", text: m.unit }) : null,
          h("button", { type: "button", class: "reset", title: "Back to the preset value", "aria-label": "Reset " + m.label, onclick: () => setValue(p.name, S.baseline[p.name]), text: "↺" }),
          h("code", { class: "pname", title: "OpenSCAD parameter name", text: p.name })),
        h("div", { class: "ctl" }, ctl),
        help ? h("p", { class: "help", text: help }) : null);
      field.ctl = ctl;
      body.append(field);
    }
    body.append(h("p", { class: "s-hidden-note" }));
    det.append(body);
    root.append(det);
  }
  refreshFields();
}

function refreshFields() {
  const q = S.filter.toLowerCase();
  let modified = 0;
  for (const det of $$("details.section")) {
    const isAdv = det.dataset.advanced === "1";
    let shown = 0, hidden = 0, mods = 0;
    for (const field of $$(".field", det)) {
      const p = S.byName.get(field.dataset.name);
      const m = metaFor(p);
      const v = S.values[p.name];
      field.ctl.sync(v);
      const isMod = v !== S.baseline[p.name];
      field.classList.toggle("modified", isMod);
      if (isMod) { mods++; modified++; }
      const out = p.type === "number" && p.min !== undefined && (v < p.min || v > p.max);
      field.classList.toggle("out-of-range", !!out);
      const ok = applies(p);
      const match = !q || [m.label, p.name, m.help || "", m.sub || ""].join(" ").toLowerCase().includes(q);
      const vis = ok && match;
      field.hidden = !vis;
      if (vis) shown++;
      else if (!ok && match) hidden++;
    }
    for (const sh of $$(".subhead", det)) {
      sh.hidden = !$$(`.field[data-sub="${CSS.escape(sh.dataset.sub)}"]`, det).some(f => !f.hidden);
    }
    const note = $(".s-hidden-note", det);
    note.textContent = hidden ? `${hidden} more setting${hidden > 1 ? "s" : ""} apply only to other build or input choices.` : "";
    note.hidden = !hidden || shown === 0 && !!q;
    det.hidden = (isAdv && !S.showAdvanced && !q) || (!!q && shown === 0);
    if (q && shown) det.open = true;
    const badges = $(".s-badges", det);
    badges.innerHTML = "";
    if (mods) badges.append(h("span", { class: "badge mod", text: `${mods} changed` }));
    if (isAdv) badges.append(h("span", { class: "badge adv", text: "advanced" }));
  }
  const mc = $("#modified-count");
  mc.textContent = modified ? `${modified} change${modified > 1 ? "s" : ""} from preset` : "No changes from preset";
  mc.classList.toggle("has", modified > 0);
  $("#profile-name").value = S.values.profile_name ?? "";
}

let changeTimer = null;
function setValue(name, value) {
  const p = S.byName.get(name);
  S.values[name] = coerce(p, value);
  refreshFields();
  saveState();
  scheduleRuns();
}

function scheduleRuns() {
  S.previewDirty = true;
  markPreviewStale();
  setCheckPending();
  clearTimeout(changeTimer);
  changeTimer = setTimeout(() => {
    runCheck();
    if ($("#auto-preview").checked) runPreview();
  }, 450);
}

function focusParam(name) {
  const field = $(`.field[data-name="${CSS.escape(name)}"]`);
  if (!field) return;
  const det = field.closest("details");
  if (det.dataset.advanced === "1" && !S.showAdvanced) { S.showAdvanced = true; $("#show-advanced").checked = true; }
  if (S.filter) { S.filter = ""; $("#param-search").value = ""; }
  refreshFields();
  det.open = true;
  showPane("config");
  field.scrollIntoView({ behavior: "smooth", block: "center" });
  field.classList.remove("flash"); void field.offsetWidth; field.classList.add("flash");
  const input = $("input, select, button.card, .segmented button", field);
  if (input) input.focus({ preventScroll: true });
}

// ---------------------------------------------------------------------------------------
// OpenSCAD runs
// ---------------------------------------------------------------------------------------
function defs(over) {
  const out = [];
  for (const p of S.params) {
    const v = p.name in over ? over[p.name] : S.values[p.name];
    out.push(`-D${p.name}=${toScadLiteral(p, v)}`);
  }
  return out;
}

function workerFiles() { return S.files; }

let engineState = "loading";
function setEngine(state, text) {
  engineState = state;
  const pill = $("#engine-status");
  pill.className = "pill " + state;
  pill.textContent = text;
}
let busy = { check: false, preview: false, export: false };
function updateBusy() {
  if (engineState === "error") return;
  const parts = [];
  if (busy.check) parts.push("checking");
  if (busy.preview) parts.push("rendering");
  if (busy.export) parts.push("exporting");
  if (parts.length) setEngine("busy", "OpenSCAD: " + parts.join(", ") + "…");
  else setEngine("ready", "OpenSCAD ready");
}

const consoleLines = [];
function logConsole(title, res) {
  consoleLines.push(`▶ ${title}${res && res.ms ? ` (${(res.ms / 1000).toFixed(1)} s)` : ""}`);
  for (const l of (res && res.log) || []) if (!/Could not initialize localization/.test(l)) consoleLines.push("  " + l);
  while (consoleLines.length > 1500) consoleLines.shift();
  $("#console-log").textContent = consoleLines.join("\n");
}

function setCheckPending() {
  const card = $("#check-card");
  card.className = "check-card pending";
  $("#check-title").textContent = "Checking the design…";
}

let checkGen = 0, previewGen = 0;
async function runCheck() {
  const gen = ++checkGen;
  busy.check = true; updateBusy();
  setCheckPending();
  const args = [MAIN_PATH, "-o", "/out.echo", "--export-format=echo",
    ...defs({ part: "assembly", spec_output: "All parts", spec_include_hardware: true })];
  try {
    const res = await checkCh.run({ files: workerFiles(), args, output: "/out.echo" });
    const text = res.data ? new TextDecoder().decode(res.data) : "";
    S.checkText = text;
    S.report = parseReport([...text.split("\n"), ...res.log]);
    S.report.errors = [...new Set(S.report.errors)];
    logConsole("Design check", res);
    renderCheck();
    renderResults();
  } catch (e) {
    if (e.cancelled) return;
    S.report = { errors: [String(e.message || e)], warnings: [], build: {}, buildOrder: [], specs: [], operations: [], hardware: [], omitted: [] };
    renderCheck();
    engineFailed(e);
  } finally {
    if (gen === checkGen) { busy.check = false; updateBusy(); }
  }
}

function linkify(text) {
  const frag = document.createDocumentFragment();
  const re = /\b([a-z][a-z0-9_]*_[a-z0-9_]+)\b/g;
  let last = 0, m;
  while ((m = re.exec(text))) {
    if (!S.byName.has(m[1]) || VIEW_PARAMS.has(m[1])) continue;
    frag.append(text.slice(last, m.index));
    const name = m[1];
    frag.append(h("button", { type: "button", class: "param-link", title: "Go to " + metaFor(S.byName.get(name)).label, onclick: () => focusParam(name), text: name }));
    last = m.index + name.length;
  }
  frag.append(text.slice(last));
  return frag;
}

function renderCheck() {
  const r = S.report;
  const card = $("#check-card");
  const detail = $("#check-detail");
  detail.innerHTML = "";
  if (r.errors.length) {
    card.className = "check-card bad";
    $("#check-title").textContent = r.errors.length > 1 ? `${r.errors.length} design rules fail` : "A design rule fails";
    detail.append(h("ul", {}, r.errors.map(e => h("li", {}, linkify(e)))));
    const hints = [...new Set(r.errors.flatMap(e => RULE_HINTS.filter(([re]) => re.test(e)).flatMap(([, names]) => names)))]
      .filter(n => S.byName.has(n) && applies(S.byName.get(n)));
    if (hints.length) {
      detail.append(h("div", { class: "hints" }, h("span", { class: "small muted", text: "Settings to look at:" }),
        hints.map(n => h("button", { type: "button", class: "chip", onclick: () => focusParam(n), text: metaFor(S.byName.get(n)).label }))));
    }
  } else {
    card.className = "check-card ok";
    $("#check-title").textContent = "All design rules pass";
    detail.append(h("div", { class: "muted small", text: "Geometry and assembly-clearance checks only, not a load rating." }));
  }
  if (r.warnings.length) detail.append(h("ul", {}, r.warnings.map(w => h("li", { class: "warn" }, linkify(w)))));
  const figs = $("#figures");
  figs.innerHTML = "";
  for (const f of keyFigures(r, S.values)) {
    figs.append(h("div", { class: "figure" + (f.warn ? " warn" : "") },
      h("div", { class: "f-label", text: f.label }), h("div", { class: "f-value", text: f.value }),
      f.note ? h("div", { class: "f-note", text: f.note }) : null));
  }
}

function currentTarget() {
  const v = S.view;
  if (v.part) {
    const part = PARTS.find(x => x.id === v.part);
    const dim = part.kind === "template" ? "2d" : part.kind === "lathe" ? "3d" : v.dim;
    return { part: v.part, dim, label: part.label };
  }
  const view = VIEWS.find(x => x.id === v.id);
  return { part: view.id, dim: view.kind, label: view.label };
}

function viewOverrides(part, dim, fn) {
  return {
    part, export_mode: dim === "3d" ? "3D solid" : "2D profile", spec_output: "Off", $fn: fn,
    show_motor_mockup: $("#opt-motor").checked, show_hardware: $("#opt-hardware").checked,
    exploded_gap: Number($("#opt-gap").value) || S.values.exploded_gap,
    layout_3d_clearance: Number($("#opt-clear").value) || S.values.layout_3d_clearance,
  };
}

function exportFn() { return Number($("#export-fn").value) || S.values.$fn; }

function markPreviewStale() {
  $("#btn-render").textContent = $("#auto-preview").checked ? "Update preview" : "Update preview •";
}

async function runPreview(force = false) {
  const t = currentTarget();
  const q = $("#opt-quality").value;
  const fn = q === "full" ? exportFn() : Number(q);
  const over = viewOverrides(t.part, t.dim, fn);
  const out = t.dim === "3d" ? "/out.off" : "/out.svg";
  const args = [MAIN_PATH, "-o", out, `--export-format=${t.dim === "3d" ? "off" : "svg"}`, "--backend=manifold", "--enable=lazy-union", ...defs(over)];
  const key = JSON.stringify(args);
  if (!force && key === S.previewKey && !S.previewDirty) return;
  const gen = ++previewGen;
  showOverlay(`Rendering ${t.label}…`);
  busy.preview = true; updateBusy();
  hideMessage();
  try {
    const res = await previewCh.run({ files: workerFiles(), args, output: out, parse: t.dim === "3d" ? "off" : null });
    logConsole(`Preview: ${t.label}`, res);
    S.previewKey = key; S.previewDirty = false;
    $("#btn-render").textContent = "Update preview";
    const rep = parseReport(res.log);
    if (t.dim === "3d") {
      if (!res.groups || !res.groups.length) return showEmpty(t, rep);
      showViewer("3d");
      const frameKey = t.part + "|" + t.dim;
      viewer.setModel(res.groups, [0.45, 0.55, 0.7], frameKey !== S.framedFor);
      S.framedFor = frameKey;
      const tris = res.groups.reduce((s, g) => s + g.positions.length / 9, 0);
      const size = viewer.size();
      $("#render-info").textContent = `${(res.ms / 1000).toFixed(1)} s · ${Math.round(tris).toLocaleString()} triangles · ${size.x.toFixed(0)} × ${size.y.toFixed(0)} × ${size.z.toFixed(0)} mm`;
    } else {
      if (!res.data) return showEmpty(t, rep);
      showViewer("2d");
      show2D(new TextDecoder().decode(res.data));
      $("#render-info").textContent = `${(res.ms / 1000).toFixed(1)} s`;
    }
  } catch (e) {
    if (e.cancelled) return;
    engineFailed(e);
  } finally {
    if (gen === previewGen) { hideOverlay(); busy.preview = false; updateBusy(); }
  }
}

function showEmpty(t, rep) {
  if (rep.errors.length) {
    showMessage(h("div", {}, h("strong", { text: "Preview unavailable: a design rule fails." }), h("p", { class: "small", text: "See the design check in panel 3." })), true);
  } else {
    showMessage(h("div", {}, h("strong", { text: `${t.label} is not used by this configuration.` }),
      h("p", { class: "small muted", text: "Pick another part, or change the build method or input shaft." })));
  }
}

function showOverlay(text) { $("#overlay-text").textContent = text; $("#viewer-overlay").hidden = false; }
function hideOverlay() { $("#viewer-overlay").hidden = true; }
function showMessage(node, error = false) { const m = $("#viewer-message"); m.innerHTML = ""; m.append(node); m.classList.toggle("error", error); m.hidden = false; }
function hideMessage() { $("#viewer-message").hidden = true; }
function showViewer(dim) {
  $("#viewer3d").hidden = dim !== "3d";
  $("#viewer2d").hidden = dim !== "2d";
  $("#tools3d").hidden = dim !== "3d";
}

// 2D: inline SVG with wheel zoom and drag pan.
function show2D(svgText) {
  const box = $("#viewer2d");
  box.innerHTML = svgText.replace(/<\?xml[^>]*>|<!DOCTYPE[^>]*>/g, "");
  const svg = $("svg", box);
  if (!svg) return;
  svg.removeAttribute("width"); svg.removeAttribute("height");
  const vb = svg.viewBox.baseVal;
  const pad = Math.max(vb.width, vb.height) * 0.06;
  let view = { x: vb.x - pad, y: vb.y - pad, w: vb.width + 2 * pad, h: vb.height + 2 * pad };
  const apply = () => svg.setAttribute("viewBox", `${view.x} ${view.y} ${view.w} ${view.h}`);
  apply();
  svg.addEventListener("wheel", (e) => {
    e.preventDefault();
    const k = e.deltaY > 0 ? 1.15 : 1 / 1.15;
    const r = svg.getBoundingClientRect();
    const scale = Math.max(view.w / r.width, view.h / r.height);
    const cx = view.x + (e.clientX - r.left - (r.width - view.w / scale) / 2) * scale;
    const cy = view.y + (e.clientY - r.top - (r.height - view.h / scale) / 2) * scale;
    view = { x: cx - (cx - view.x) * k, y: cy - (cy - view.y) * k, w: view.w * k, h: view.h * k };
    apply();
  }, { passive: false });
  let drag = null;
  svg.addEventListener("pointerdown", (e) => { drag = { x: e.clientX, y: e.clientY, v: { ...view } }; svg.setPointerCapture(e.pointerId); });
  svg.addEventListener("pointermove", (e) => {
    if (!drag) return;
    const r = svg.getBoundingClientRect();
    const scale = Math.max(view.w / r.width, view.h / r.height);
    view = { ...view, x: drag.v.x - (e.clientX - drag.x) * scale, y: drag.v.y - (e.clientY - drag.y) * scale };
    apply();
  });
  svg.addEventListener("pointerup", () => { drag = null; });
}

function engineFailed(e) {
  const msg = String(e && e.message || e);
  if (/cancelled/.test(msg)) return;
  if (/fetch|download|Failed to|NetworkError|import/i.test(msg)) {
    setEngine("error", "Engine unavailable");
    showMessage(h("div", {}, h("strong", { text: "The OpenSCAD engine could not be loaded." }),
      h("p", { class: "small", text: "It is downloaded once from cdn.jsdelivr.net (about 10 MB). Check the connection and reload. Settings still work and can be saved as a parameter set." })), true);
  } else {
    showMessage(h("div", {}, h("strong", { text: "OpenSCAD stopped with an error." }), h("p", { class: "small", text: msg.slice(0, 300) })), true);
  }
}

// ---------------------------------------------------------------------------------------
// results: export list, report, parts, BOM
// ---------------------------------------------------------------------------------------
function formatsFor(part) {
  if (part.kind === "template") return ["dxf", "svg"];
  if (part.kind === "lathe") return ["stl"];
  return ["dxf", "svg", "stl"];
}
function defaultFormat(part, pack = "machining") {
  if (part.kind === "lathe") return "stl";
  if (part.kind === "template") return "dxf";
  return pack === "printing" ? "stl" : "dxf";
}

function specFor(id) {
  if (!S.report) return null;
  const alias = { bearing_carrier: ["bearing_carrier", "plain_output_journal_carrier"] }[id] || [id];
  return S.report.specs.find(s => alias.includes(s.part)) ||
    S.report.operations.find(o => o.operation && o.operation.toLowerCase() === id.toLowerCase()) || null;
}

const exportChoice = new Map(); // id -> { checked, format }

function renderResults() {
  renderPartList();
  renderReportTab();
  renderSpecTab();
  renderBomTab();
  renderPartSelect();
}

function renderPartList() {
  const root = $("#part-list");
  root.innerHTML = "";
  const failing = !!(S.report && S.report.errors.length);
  $("#export-blocked").hidden = !failing;
  for (const b of ["#pack-machining", "#pack-printing", "#btn-export-selected"]) $(b).disabled = failing;
  const showUnused = $("#show-unused").checked;
  let group = null;
  for (const part of PARTS) {
    const used = partApplies(part.id, S.values, S.report);
    if (!used && !showUnused) continue;
    if (part.group !== group) { group = part.group; root.append(h("div", { class: "part-group", text: group })); }
    let ch = exportChoice.get(part.id);
    if (!ch) { ch = { checked: true, format: defaultFormat(part) }; exportChoice.set(part.id, ch); }
    const spec = specFor(part.id);
    const qty = spec && spec.qty ? spec.qty : null;
    const box = h("input", { type: "checkbox", "aria-label": "Include " + part.label, onchange: () => { ch.checked = box.checked; } });
    box.checked = ch.checked && used;
    box.disabled = !used;
    const fmt = h("select", { class: "small", "aria-label": "File format for " + part.label, onchange: () => { ch.format = fmt.value; } },
      formatsFor(part).map(f => h("option", { value: f, text: f.toUpperCase() })));
    fmt.value = ch.format;
    fmt.disabled = !used;
    root.append(h("div", { class: "part-row" + (used ? "" : " unused") },
      box,
      h("div", {},
        h("button", { type: "button", class: "show-btn", title: "Show in preview", onclick: () => selectPart(part.id), text: part.label }),
        qty && qty !== "1" ? h("span", { class: "p-qty", text: "× " + qty.toLowerCase() }) : null,
        used ? null : h("span", { class: "p-qty", text: "not used" })),
      h("div", { class: "p-actions" }, fmt,
        h("button", { type: "button", disabled: !used || failing, title: "Download this part", onclick: () => exportParts([{ part, format: fmt.value }], false), text: "↓" })),
      h("div", { class: "p-desc", text: part.desc })));
  }
}

function renderReportTab() {
  const t = $("#report-table");
  t.innerHTML = "";
  const r = S.report;
  for (const k of r.buildOrder) t.append(h("tr", {}, h("th", { text: k }), h("td", { text: r.build[k] })));
  if (!r.buildOrder.length) t.append(h("tr", {}, h("td", { class: "muted", text: "No report: the design check did not complete." })));
}

const prettyKey = k => k.replace(/_/g, " ").replace(/\bOD\b/g, "OD").replace(/^./, c => c.toUpperCase());

function renderSpecTab() {
  const root = $("#spec-list");
  root.innerHTML = "";
  const r = S.report;
  const card = (title, sub, f, skip) => h("div", { class: "spec-card" },
    h("h4", {}, title, sub ? h("span", { text: sub }) : null),
    h("table", { class: "kv" }, Object.entries(f).filter(([k]) => !skip.includes(k)).map(([k, v]) => h("tr", {}, h("th", { text: prettyKey(k) }), h("td", { text: v })))));
  for (const s of r.specs) {
    if (/^0\b/.test(s.qty || "")) continue;
    const part = PARTS.find(p => p.id === s.part) || PARTS.find(p => p.id === "bearing_carrier" && s.part === "plain_output_journal_carrier");
    root.append(card(part ? part.label : s.part, s.qty ? "qty " + s.qty.toLowerCase() : "", s, ["part", "qty"]));
  }
  if (r.operations.length) root.append(h("div", { class: "part-group", text: "Drill templates and blind operations" }));
  for (const o of r.operations) {
    const part = PARTS.find(p => p.id.toLowerCase() === o.operation.toLowerCase());
    root.append(card(part ? part.label : o.operation, "", o, ["operation"]));
  }
  if (!r.specs.length) root.append(h("p", { class: "muted", text: "No part specs: the design check did not complete." }));
}

const BOM_COLS = ["role", "qty", "designation", "size", "standard", "nominal_d", "cut_length", "thread", "source_class"];
function bomNotes(row) {
  return Object.entries(row).filter(([k]) => !BOM_COLS.includes(k)).map(([k, v]) => (k === "NOTE" ? v : `${prettyKey(k)}: ${v}`)).join("; ");
}
function bomWhat(row) {
  return [row.designation, row.size, row.standard, row.nominal_d && "Ø" + row.nominal_d, row.cut_length && "cut " + row.cut_length, row.thread].filter(Boolean).join(" · ");
}

function renderBomTab() {
  const t = $("#bom-table");
  t.innerHTML = "";
  const r = S.report;
  t.append(h("tr", {}, h("th", { text: "Item" }), h("th", { text: "Qty" }), h("th", { text: "Specification" })));
  for (const row of r.hardware) {
    t.append(h("tr", {}, h("td", {}, h("strong", { text: prettyKey(row.role || "") }), h("div", { class: "muted small", text: bomNotes(row) })),
      h("td", { class: "q", text: row.qty || "" }), h("td", { text: bomWhat(row) })));
  }
  const om = $("#omitted-list");
  om.innerHTML = "";
  if (r.omitted.length) {
    om.append(h("div", { class: "omitted" }, h("strong", { text: "Not needed in this build" }),
      h("ul", {}, r.omitted.map(o => h("li", { text: `${prettyKey(o.role || "")}: ${o.replaced_by ? "replaced by " + o.replaced_by : o.NOTE || ""}` })))));
  }
}

function bomCsv() {
  const r = S.report;
  const esc = v => `"${String(v ?? "").replace(/"/g, '""')}"`;
  const lines = [["item", "qty", "specification", "source", "notes"].join(",")];
  for (const row of r.hardware) lines.push([prettyKey(row.role || ""), row.qty, bomWhat(row), row.source_class, bomNotes(row)].map(esc).join(","));
  return lines.join("\n") + "\n";
}

function reportTxt() {
  const lines = [`${S.values.profile_name} (${S.preset} with ${Object.keys(diffs()).length} changes)`, ""];
  for (const k of S.report.buildOrder) lines.push(`${k}: ${S.report.build[k]}`);
  lines.push("");
  for (const l of S.checkText.split("\n")) {
    const m = l.match(/^ECHO:\s*"((?:SPEC|HARDWARE|OMITTED_HARDWARE)\|.*)"$/);
    if (m) lines.push(m[1]);
  }
  return lines.join("\n") + "\n";
}

// ---------------------------------------------------------------------------------------
// export
// ---------------------------------------------------------------------------------------
function download(blob, name) {
  const a = h("a", { href: URL.createObjectURL(blob), download: name });
  document.body.append(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 4000);
}

async function renderFile(partId, format, fn, overrides = {}) {
  const dim = format === "stl" ? "3d" : "2d";
  const out = "/out." + format;
  const over = { ...viewOverrides(partId, dim, fn), ...overrides };
  const args = [MAIN_PATH, "-o", out, `--export-format=${format === "stl" ? "binstl" : format}`, "--backend=manifold", ...defs(over)];
  const res = await exportCh.run({ files: workerFiles(), args, output: out });
  logConsole(`Export ${partId}.${format}`, res);
  if (!res.data) {
    const rep = parseReport(res.log);
    throw new Error(rep.errors[0] || `${partId} produced no geometry in this configuration`);
  }
  return res.data;
}

function parameterSetJson(name) {
  const set = {};
  for (const p of S.params) {
    if (VIEW_PARAMS.has(p.name) && p.name !== "profile_name") continue;
    set[p.name] = String(S.values[p.name]);
  }
  set.profile_name = name;
  return { fileFormatVersion: "1", parameterSets: { [name]: set } };
}

async function exportParts(list, zip = true, extras = true, zipName = null) {
  if (!list.length) return toast("Nothing selected to export.");
  const base = slug(S.values.profile_name);
  const fn = exportFn();
  S.exportAbort = false;
  const prog = $("#export-progress");
  prog.hidden = false;
  busy.export = true; updateBusy();
  const entries = [];
  const failed = [];
  try {
    for (let i = 0; i < list.length; i++) {
      if (S.exportAbort) throw Object.assign(new Error("cancelled"), { cancelled: true });
      const { part, format } = list[i];
      $("#export-progress-text").textContent = `Rendering ${part.label} (${format.toUpperCase()}) · ${i + 1} of ${list.length}`;
      $(".bar span", prog).style.width = `${(i / list.length) * 100}%`;
      try {
        const data = await renderFile(part.id, format, fn);
        entries.push({ name: `${base}_${part.id}.${format}`, data });
      } catch (e) {
        if (e.cancelled) throw e;
        failed.push(`${part.label}: ${e.message}`);
      }
    }
    $(".bar span", prog).style.width = "100%";
    if (!zip && entries.length === 1) {
      download(new Blob([entries[0].data]), entries[0].name);
    } else if (entries.length) {
      if (extras && S.report) {
        entries.push({ name: `${base}_specs.txt`, data: reportTxt() });
        entries.push({ name: `${base}_hardware_bom.csv`, data: bomCsv() });
        entries.push({ name: `${base}_parameters.json`, data: JSON.stringify(parameterSetJson(S.values.profile_name), null, 2) });
      }
      download(makeZip(entries), `${zipName || base}.zip`);
    }
    if (failed.length) toast(`${failed.length} file${failed.length > 1 ? "s" : ""} failed: ${failed[0]}`, 8000);
    else toast(`Downloaded ${entries.length} file${entries.length > 1 ? "s" : ""}.`);
  } catch (e) {
    if (e.cancelled) toast("Export cancelled.");
    else toast("Export failed: " + e.message, 8000);
  } finally {
    prog.hidden = true;
    busy.export = false; updateBusy();
  }
}

function packList(kind) {
  const list = [];
  for (const part of PARTS) {
    if (!partApplies(part.id, S.values, S.report)) continue;
    if (kind === "printing" && part.kind === "template") continue;
    list.push({ part, format: defaultFormat(part, kind) });
  }
  return list;
}

// ---------------------------------------------------------------------------------------
// preview controls
// ---------------------------------------------------------------------------------------
function renderViewTabs() {
  const root = $("#view-tabs");
  root.innerHTML = "";
  for (const v of VIEWS) {
    root.append(h("button", { type: "button", role: "tab", "data-view": v.id, onclick: () => selectView(v.id), text: v.label }));
  }
  syncViewControls();
}

function renderPartSelect() {
  const sel = $("#part-select");
  const cur = S.view.part || "";
  sel.innerHTML = "";
  sel.append(h("option", { value: "", text: "Single part…" }));
  let group = null, og = null;
  for (const part of PARTS) {
    if (part.group !== group) { group = part.group; og = h("optgroup", { label: group }); sel.append(og); }
    const used = partApplies(part.id, S.values, S.report);
    og.append(h("option", { value: part.id, text: part.label + (used ? "" : " (not used)") }));
  }
  sel.value = cur;
}

function syncViewControls() {
  const v = S.view;
  $$("#view-tabs button").forEach(b => b.classList.toggle("active", !v.part && b.dataset.view === v.id));
  const sel = $("#part-select");
  sel.value = v.part || "";
  sel.classList.toggle("active", !!v.part);
  const part = v.part && PARTS.find(p => p.id === v.part);
  $("#dim-toggle").hidden = !(part && part.kind === "plate");
  $$("#dim-toggle button").forEach(b => b.classList.toggle("active", b.dataset.dim === v.dim));
  const id = v.part ? null : v.id;
  $("#opt-gap-wrap").hidden = id !== "exploded";
  $("#opt-clear-wrap").hidden = id !== "layout_3d";
  const assemblyLike = ["assembly", "exploded", "input_stack"].includes(id);
  $("#opt-motor").closest("label").hidden = !assemblyLike;
  $("#opt-hardware").closest("label").hidden = !assemblyLike;
  store.set("view", v);
}

function selectView(id) { S.view = { ...S.view, id, part: null }; syncViewControls(); runPreview(); }
function selectPart(id) {
  if (!id) return selectView(S.view.id);
  S.view = { ...S.view, part: id };
  syncViewControls();
  showPane("preview");
  runPreview();
}

function showPane(name) {
  $$(".mobile-tabs button").forEach(b => b.classList.toggle("active", b.dataset.pane === name));
  $$(".pane").forEach(p => p.classList.toggle("active", p.id === "pane-" + name));
}

let toastTimer = null;
function toast(text, ms = 3500, actionLabel = null, action = null) {
  const t = $("#toast");
  t.textContent = text;
  if (actionLabel) t.append(h("button", { type: "button", class: "toast-action", onclick: () => { t.hidden = true; action(); }, text: actionLabel }));
  t.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { t.hidden = true; }, ms);
}

function renderPresetSelect() {
  const sel = $("#preset-select");
  sel.innerHTML = "";
  const add = (label, names) => {
    if (!names.length) return;
    const og = h("optgroup", { label });
    for (const n of names) og.append(h("option", { value: n, text: n }));
    sel.append(og);
  };
  const names = Object.keys(S.presets);
  for (const frame of ["NEMA17", "NEMA23", "NEMA34"]) add(frame, names.filter(n => n.startsWith(frame)));
  add("Other presets", names.filter(n => !/^NEMA(17|23|34)/.test(n)));
  add("Loaded from file", Object.keys(S.loadedPresets));
  sel.value = S.preset;
}

async function loadParameterFile(file) {
  let data;
  try { data = JSON.parse(await file.text()); } catch (_) { return toast("That file is not valid JSON."); }
  const sets = data.parameterSets || { [file.name.replace(/\.json$/i, "")]: data };
  const names = Object.keys(sets);
  if (!names.length) return toast("No parameter sets in that file.");
  for (const n of names) S.loadedPresets[n] = sets[n];
  applyPreset(names[0]);
  renderPresetSelect();
  refreshFields();
  saveState();
  scheduleRuns();
  toast(names.length > 1 ? `Loaded ${names.length} parameter sets; showing "${names[0]}".` : `Loaded "${names[0]}".`);
}

function scadProjectZip() {
  let name = S.values.profile_name || "My design";
  if (allPresets()[name] && Object.keys(diffs()).length) name += " (custom)";
  const presets = JSON.parse(JSON.stringify({ fileFormatVersion: "1", parameterSets: allPresets() }));
  presets.parameterSets[name] = parameterSetJson(name).parameterSets[name];
  const entries = Object.entries(S.files).map(([path, text]) => ({ name: path.replace(/^src\//, "cycloidal_gearbox/"), data: text }));
  entries.push({ name: "cycloidal_gearbox/" + PRESET_JSON, data: JSON.stringify(presets, null, 4) });
  entries.push({ name: "cycloidal_gearbox/README.txt", data: `Open cycloidal_gearbox.scad in OpenSCAD and choose "${name}" in the Customizer preset menu.\n` });
  download(makeZip(entries), slug(name) + "_openscad.zip");
}

// ---------------------------------------------------------------------------------------
// wiring
// ---------------------------------------------------------------------------------------
function wireMenus() {
  for (const btn of $$(".menu > button")) {
    const list = btn.nextElementSibling;
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      const open = list.hidden;
      $$(".menu-list").forEach(l => { l.hidden = true; l.previousElementSibling.setAttribute("aria-expanded", "false"); });
      list.hidden = !open;
      btn.setAttribute("aria-expanded", String(open));
    });
    list.addEventListener("click", () => { list.hidden = true; btn.setAttribute("aria-expanded", "false"); });
  }
  document.addEventListener("click", () => $$(".menu-list").forEach(l => { l.hidden = true; }));
  document.addEventListener("keydown", (e) => { if (e.key === "Escape") $$(".menu-list").forEach(l => { l.hidden = true; }); });
}

function wire() {
  wireMenus();
  $$(".mobile-tabs button").forEach(b => b.addEventListener("click", () => showPane(b.dataset.pane)));
  $("#btn-help").addEventListener("click", () => $("#help-dialog").showModal());

  $("#preset-select").addEventListener("change", (e) => {
    const undo = { preset: S.preset, overrides: diffs() };
    const n = Object.keys(undo.overrides).length;
    applyPreset(e.target.value);
    refreshFields(); saveState(); scheduleRuns();
    if (n) toast(`Switched to ${S.preset}; your ${n} change${n > 1 ? "s were" : " was"} cleared.`, 8000, "Undo", () => restore(undo));
  });
  $("#btn-reset-all").addEventListener("click", () => {
    const undo = { preset: S.preset, overrides: diffs() };
    const n = Object.keys(undo.overrides).length;
    applyPreset(S.preset); refreshFields(); saveState(); scheduleRuns();
    toast(n ? `Cleared ${n} change${n > 1 ? "s" : ""}.` : "Already at the preset values.", 8000, n ? "Undo" : null, () => restore(undo));
  });
  $("#profile-name").addEventListener("change", (e) => setValue("profile_name", e.target.value));
  $("#param-search").addEventListener("input", (e) => { S.filter = e.target.value.trim(); refreshFields(); });
  $("#show-advanced").addEventListener("change", (e) => { S.showAdvanced = e.target.checked; store.set("advanced", S.showAdvanced); refreshFields(); });

  $("#act-save-json").addEventListener("click", () => {
    const name = S.values.profile_name || S.preset;
    download(new Blob([JSON.stringify(parameterSetJson(name), null, 2)], { type: "application/json" }), slug(name) + ".json");
  });
  $("#act-load-json").addEventListener("click", () => $("#file-load").click());
  $("#file-load").addEventListener("change", (e) => { if (e.target.files[0]) loadParameterFile(e.target.files[0]); e.target.value = ""; });
  $("#act-copy-link").addEventListener("click", async () => {
    try { await navigator.clipboard.writeText(location.href); toast("Link copied. It opens this exact design."); }
    catch (_) { toast("Copy failed; the address bar holds the link."); }
  });
  $("#act-download-scad").addEventListener("click", scadProjectZip);

  $("#auto-preview").addEventListener("change", (e) => { store.set("autoPreview", e.target.checked); if (e.target.checked) runPreview(); else markPreviewStale(); });
  $("#btn-render").addEventListener("click", () => runPreview(true));
  $("#btn-cancel-render").addEventListener("click", () => { previewCh.cancel(); hideOverlay(); busy.preview = false; updateBusy(); S.previewDirty = true; markPreviewStale(); });
  $("#part-select").addEventListener("change", (e) => selectPart(e.target.value));
  $$("#dim-toggle button").forEach(b => b.addEventListener("click", () => { S.view = { ...S.view, dim: b.dataset.dim }; syncViewControls(); runPreview(); }));
  for (const id of ["#opt-motor", "#opt-hardware", "#opt-gap", "#opt-clear", "#opt-quality"]) $(id).addEventListener("change", () => runPreview());
  $$("#tools3d [data-cam]").forEach(b => b.addEventListener("click", () => viewer && viewer.view(b.dataset.cam)));
  $("#section-toggle").addEventListener("change", (e) => { $("#section-pos").disabled = !e.target.checked; viewer.setSection(e.target.checked, Number($("#section-pos").value)); });
  $("#section-pos").addEventListener("input", (e) => viewer.setSection(true, Number(e.target.value)));

  $("#act-view-png").addEventListener("click", () => {
    if ($("#viewer3d").hidden) return toast("Screenshots are for 3D views.");
    fetch(viewer.snapshot()).then(r => r.blob()).then(b => download(b, `${slug(S.values.profile_name)}_${currentTarget().part}.png`));
  });
  $("#act-view-stl").addEventListener("click", () => {
    const t = currentTarget();
    if (t.dim !== "3d") return toast("This view is 2D: use SVG.");
    exportParts([{ part: { id: t.part, label: t.label }, format: "stl" }], false);
  });
  $("#act-view-svg").addEventListener("click", () => {
    const t = currentTarget();
    if (t.dim !== "2d") return toast("This view is 3D: use STL, or pick 2D profile.");
    exportParts([{ part: { id: t.part, label: t.label }, format: "svg" }], false);
  });

  $$(".tabs button").forEach(b => b.addEventListener("click", () => {
    $$(".tabs button").forEach(x => x.classList.toggle("active", x === b));
    $$(".tab-panel").forEach(p => { p.hidden = p.dataset.panel !== b.dataset.tab; });
  }));
  $("#show-unused").addEventListener("change", renderPartList);
  $("#pack-machining").addEventListener("click", () => exportParts(packList("machining"), true, true, slug(S.values.profile_name) + "_machining"));
  $("#pack-printing").addEventListener("click", () => exportParts(packList("printing"), true, true, slug(S.values.profile_name) + "_printing"));
  $("#btn-export-selected").addEventListener("click", () => {
    const list = PARTS.filter(p => partApplies(p.id, S.values, S.report) && exportChoice.get(p.id)?.checked)
      .map(part => ({ part, format: exportChoice.get(part.id).format }));
    exportParts(list, true);
  });
  $("#btn-cancel-export").addEventListener("click", () => { S.exportAbort = true; exportCh.cancel(); });
  $("#btn-dl-report").addEventListener("click", () => S.report && download(new Blob([reportTxt()], { type: "text/plain" }), slug(S.values.profile_name) + "_specs.txt"));
  $("#btn-dl-bom").addEventListener("click", () => S.report && download(new Blob([bomCsv()], { type: "text/csv" }), slug(S.values.profile_name) + "_hardware_bom.csv"));

  window.addEventListener("hashchange", () => {
    const st = stateFromHash();
    if (st && hashFor(st.preset, st.overrides) !== hashFor(S.preset, diffs())) {
      applyPreset(allPresets()[st.preset] ? st.preset : S.preset, st.overrides);
      renderPresetSelect(); refreshFields(); scheduleRuns();
    }
  });
}

function restore(state) {
  applyPreset(state.preset, state.overrides);
  renderPresetSelect(); refreshFields(); saveState(); scheduleRuns();
}

async function init() {
  wire();
  try {
    await loadSources();
  } catch (e) {
    setEngine("error", "Design files missing");
    showMessage(h("div", {}, h("strong", { text: "The design files could not be loaded." }),
      h("p", { class: "small", text: "Serve the repository root over HTTP (for example python3 -m http.server) and open /web/. Opening index.html straight from disk does not work." })), true);
    return;
  }
  const saved = store.get("state");
  if (saved && saved.loaded) S.loadedPresets = saved.loaded;
  const fromHash = stateFromHash();
  const start = fromHash || saved;
  const first = Object.keys(S.presets)[0] || null;
  const presetName = start && allPresets()[start.preset] ? start.preset : first;
  applyPreset(presetName, start && allPresets()[start.preset] ? start.overrides : {});

  S.showAdvanced = !!store.get("advanced");
  $("#show-advanced").checked = S.showAdvanced;
  const ap = store.get("autoPreview");
  if (ap === false) $("#auto-preview").checked = false;
  const v = store.get("view");
  if (v && (VIEWS.some(x => x.id === v.id))) S.view = { id: v.id, part: PARTS.some(p => p.id === v.part) ? v.part : null, dim: v.dim === "2d" ? "2d" : "3d" };
  $("#opt-gap").value = S.values.exploded_gap;
  $("#opt-clear").value = S.values.layout_3d_clearance;
  $("#export-fn").value = S.values.$fn;

  renderPresetSelect();
  buildSections();
  renderViewTabs();
  renderPartSelect();
  saveState();

  const { Viewer3D } = await import("./viewer3d.js").catch((e) => { console.error(e); return {}; });
  if (Viewer3D) viewer = new Viewer3D($("#viewer3d"));

  setEngine("busy", "Loading OpenSCAD (10 MB)…");
  showOverlay("Loading the OpenSCAD engine…");
  try {
    await loadEngine();
  } catch (e) {
    hideOverlay();
    engineFailed(new Error("download failed: " + e.message));
    return;
  }
  runCheck();
  runPreview(true);
}

init();
