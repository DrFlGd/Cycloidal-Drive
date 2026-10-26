#!/usr/bin/env node
// End-to-end check of the web generator in headless Chromium: serves the repository, opens
// web/, waits for the design check and the assembly preview, then exports a DXF and an STL
// and checks that a failing rule is reported with its settings.
//
//   npm install --no-save playwright && npx playwright install chromium
//   node tools/web_smoke_test.mjs
//
// CDN_MIRROR=dir serves https://cdn.jsdelivr.net/npm/<pkg>@<version>/... from
// dir/<pkg>@<version>/... for machines without access to the CDN.
import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { chromium } from "playwright";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const types = { ".html": "text/html", ".js": "text/javascript", ".css": "text/css", ".json": "application/json", ".scad": "text/plain", ".wasm": "application/wasm" };

async function serveFile(base, rel) {
  let file = path.join(base, decodeURIComponent(rel));
  if (!file.startsWith(base)) return null;
  try { if ((await stat(file)).isDirectory()) file = path.join(file, "index.html"); return { body: await readFile(file), type: types[path.extname(file)] || "application/octet-stream" }; }
  catch (_) { return null; }
}

const server = createServer(async (req, res) => {
  const f = await serveFile(root, new URL(req.url, "http://x").pathname);
  if (!f) { res.writeHead(404); res.end("not found"); return; }
  res.writeHead(200, { "content-type": f.type });
  res.end(f.body);
});
await new Promise(r => server.listen(0, "127.0.0.1", r));
const origin = `http://127.0.0.1:${server.address().port}`;

const browser = await chromium.launch();
const context = await browser.newContext({ acceptDownloads: true, viewport: { width: 1500, height: 950 } });
if (process.env.CDN_MIRROR) {
  const mirror = path.resolve(process.env.CDN_MIRROR);
  await context.route("https://cdn.jsdelivr.net/npm/**", async route => {
    const f = await serveFile(mirror, new URL(route.request().url()).pathname.replace(/^\/npm\//, ""));
    if (!f) return route.fulfill({ status: 404, body: "not mirrored" });
    route.fulfill({ status: 200, body: f.body, headers: { "content-type": f.type, "access-control-allow-origin": "*" } });
  });
}
const page = await context.newPage();
const pageErrors = [];
page.on("pageerror", e => pageErrors.push(e.message));

let failures = 0;
const check = (ok, what) => { console.log(`${ok ? "ok  " : "FAIL"} ${what}`); if (!ok) failures++; };
const idle = async () => {
  await page.waitForTimeout(800);
  await page.waitForFunction(() => document.querySelector("#viewer-overlay").hidden &&
    !document.querySelector("#check-card").classList.contains("pending"), null, { timeout: 300000 });
};

try {
  await page.goto(origin + "/web/");
  await idle();
  check(await page.$("#check-card.ok") !== null, "default preset passes the design check: " + await page.textContent("#check-title"));
  const info = await page.textContent("#render-info");
  check(/triangles/.test(info), "assembly preview rendered: " + info);
  check((await page.$$(".field:not([hidden])")).length > 20, "configuration form built");

  const [dxf] = await Promise.all([page.waitForEvent("download", { timeout: 120000 }),
    page.click('.part-row:has(.show-btn:text-is("Cycloid disc")) .p-actions button')]);
  const dxfText = await readFile(await dxf.path(), "utf8");
  check(dxf.suggestedFilename().endsWith("_cycloid_disc.dxf") && dxfText.includes("SECTION"), "cycloid disc DXF export: " + dxf.suggestedFilename());

  await page.selectOption('.part-row:has(.show-btn:text-is("Output face plate")) select', "stl");
  const [stl] = await Promise.all([page.waitForEvent("download", { timeout: 120000 }),
    page.click('.part-row:has(.show-btn:text-is("Output face plate")) .p-actions button')]);
  const stlBytes = await readFile(await stl.path());
  const tris = stlBytes.readUInt32LE(80);
  check(tris > 100 && stlBytes.length === 84 + 50 * tris, `output face plate STL export: ${tris} triangles`);

  await page.goto(origin + "/web/#preset=NEMA17%20Commodity%20R15&reduction_ratio=16");
  await page.reload();
  await idle();
  check(/odd/.test(await page.textContent("#check-detail")), "even ratio is reported as a failing rule");
  check(await page.$('.chip:text-is("Reduction ratio (n : 1)")') !== null, "failing rule links to the reduction ratio setting");
  check(await page.$("#pack-machining[disabled]") !== null, "exports are paused while a rule fails");
} catch (e) {
  console.log("FAIL", e.message);
  failures++;
}
check(pageErrors.length === 0, "no page errors" + (pageErrors.length ? ": " + pageErrors.join(" | ") : ""));
await browser.close();
server.close();
process.exit(failures ? 1 : 0);
