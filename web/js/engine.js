import { OPENSCAD_JS, OPENSCAD_WASM } from "./config.js";

// The 10 MB engine is downloaded and compiled once, then handed to every worker.
let modulePromise = null;
export function loadEngine() {
  if (!modulePromise) {
    modulePromise = WebAssembly.compileStreaming(fetch(OPENSCAD_WASM)).catch(async () => {
      const r = await fetch(OPENSCAD_WASM);
      if (!r.ok) throw new Error(`OpenSCAD engine download failed (${r.status})`);
      return WebAssembly.compile(await r.arrayBuffer());
    });
    modulePromise.catch(() => { modulePromise = null; });
  }
  return modulePromise;
}

// One Web Worker per channel. "latest" channels (preview, check) drop a running job when a
// newer one arrives; "queue" channels (export) run jobs in order.
export class Channel {
  constructor(mode = "latest") {
    this.mode = mode;
    this.worker = null;
    this.pending = null;
    this.queue = Promise.resolve();
    this.seq = 0;
    this.ticket = 0;
  }

  spawn() {
    this.worker = new Worker(new URL("./openscad-worker.js", import.meta.url), { type: "module" });
  }

  cancel() {
    if (this.pending) {
      this.worker.terminate();
      this.worker = null;
      this.pending.reject(Object.assign(new Error("cancelled"), { cancelled: true }));
      this.pending = null;
    }
  }

  run(job) {
    const ticket = ++this.ticket;
    if (this.mode === "latest") { this.cancel(); return this.exec(job, ticket); }
    const p = this.queue.then(() => this.exec(job, ticket));
    this.queue = p.catch(() => {});
    return p;
  }

  async exec(job, ticket) {
    const wasmModule = await loadEngine();
    if (this.mode === "latest" && ticket !== this.ticket) throw Object.assign(new Error("cancelled"), { cancelled: true });
    if (!this.worker) this.spawn();
    const id = ++this.seq;
    return new Promise((resolve, reject) => {
      this.pending = { resolve, reject };
      this.worker.onmessage = (e) => {
        if (e.data.id !== id) return;
        this.pending = null;
        if (e.data.ok) resolve(e.data); else reject(Object.assign(new Error(e.data.error), { log: e.data.log }));
      };
      this.worker.onerror = (e) => { this.pending = null; this.worker = null; reject(new Error(e.message || "worker error")); };
      this.worker.postMessage({ id, jsUrl: OPENSCAD_JS, wasmUrl: OPENSCAD_WASM, wasmModule, ...job });
    });
  }
}
