import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// Three.js viewer for OpenSCAD OFF output (one mesh per colour), with a section plane.
export class Viewer3D {
  constructor(container) {
    this.container = container;
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.localClippingEnabled = true;
    container.appendChild(this.renderer.domElement);

    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(35, 1, 0.1, 10000);
    this.camera.up.set(0, 0, 1);
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;

    this.scene.add(new THREE.HemisphereLight(0xffffff, 0x8890a0, 1.6));
    const key = new THREE.DirectionalLight(0xffffff, 1.6);
    key.position.set(1, -1.5, 2);
    this.camera.add(key);
    this.scene.add(this.camera);

    this.model = new THREE.Group();
    this.scene.add(this.model);
    // Cuts away the half nearest the default camera (negative Y) to show the inside.
    this.clip = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);
    this.sectionOn = false;
    this.grid = null;

    new ResizeObserver(() => this.resize()).observe(container);
    this.resize();
    const loop = () => { this.controls.update(); this.renderer.render(this.scene, this.camera); requestAnimationFrame(loop); };
    loop();
  }

  resize() {
    const w = this.container.clientWidth || 1, h = this.container.clientHeight || 1;
    this.renderer.setSize(w, h, false);
    this.camera.aspect = w / h;
    this.camera.updateProjectionMatrix();
  }

  setModel(groups, defaultColor, reframe = false) {
    for (const c of [...this.model.children]) { this.model.remove(c); c.geometry.dispose(); c.material.dispose(); }
    for (const g of groups) {
      const geom = new THREE.BufferGeometry();
      geom.setAttribute("position", new THREE.BufferAttribute(g.positions, 3));
      geom.computeVertexNormals();
      const [r, gr, b, a] = g.color || [...defaultColor, 1];
      const mat = new THREE.MeshStandardMaterial({
        color: new THREE.Color(r, gr, b), metalness: 0.15, roughness: 0.55,
        transparent: a < 0.99, opacity: Math.max(a, 0.12), depthWrite: a >= 0.99,
        side: THREE.DoubleSide, clippingPlanes: this.sectionOn ? [this.clip] : [],
      });
      const mesh = new THREE.Mesh(geom, mat);
      mesh.renderOrder = a < 0.99 ? 1 : 0;
      this.model.add(mesh);
    }
    this.bounds = new THREE.Box3().setFromObject(this.model);
    this.updateGrid();
    if (reframe || !this.hasFramed) { this.view("iso"); this.hasFramed = true; }
    if (this.sectionOn) this.setSection(true, this.sectionFraction);
  }

  updateGrid() {
    if (this.grid) { this.scene.remove(this.grid); this.grid.geometry.dispose(); }
    const size = this.bounds.getSize(new THREE.Vector3());
    const span = Math.max(50, Math.ceil(Math.max(size.x, size.y) * 1.4 / 10) * 10);
    this.grid = new THREE.GridHelper(span, span / 10, 0x8a93a3, 0xc5ccd6);
    this.grid.rotation.x = Math.PI / 2;
    this.grid.position.z = this.bounds.min.z - 0.01;
    this.grid.material.transparent = true;
    this.grid.material.opacity = 0.35;
    this.scene.add(this.grid);
  }

  view(which) {
    if (!this.bounds || this.bounds.isEmpty()) return;
    const c = this.bounds.getCenter(new THREE.Vector3());
    const r = this.bounds.getSize(new THREE.Vector3()).length() / 2;
    const d = r / Math.sin((this.camera.fov * Math.PI) / 360) * 1.05;
    const dir = { iso: [1, -1.3, 1], top: [0, -0.0001, 1], front: [0, -1, 0.0001], side: [1, 0, 0.0001], bottom: [0, 0.0001, -1] }[which] || [1, -1.3, 1];
    const v = new THREE.Vector3(...dir).normalize().multiplyScalar(d);
    this.camera.position.copy(c).add(v);
    this.controls.target.copy(c);
    this.camera.near = d / 100; this.camera.far = d * 100;
    this.camera.updateProjectionMatrix();
  }

  setSection(on, fraction = 0.5) {
    this.sectionOn = on;
    this.sectionFraction = fraction;
    if (this.bounds && !this.bounds.isEmpty()) {
      const y = this.bounds.min.y + (this.bounds.max.y - this.bounds.min.y) * fraction;
      this.clip.constant = -y;
    }
    for (const m of this.model.children) { m.material.clippingPlanes = on ? [this.clip] : []; m.material.needsUpdate = true; }
  }

  size() { return this.bounds.getSize(new THREE.Vector3()); }

  snapshot() { return this.renderer.domElement.toDataURL("image/png"); }
}
