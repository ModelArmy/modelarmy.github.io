import { spawn, spawnSync } from "node:child_process";
import { readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import * as vega from "vega";
import * as vl from "vega-lite";

const [command, ...args] = process.argv.slice(2);

if (command === "vega") renderVega(...args);
else if (command === "fit") fitToViewBox(...args);
else if (command === "watch") watchSources();
else if (command === "dev") dev();
else fail("usage: diagrams.mjs vega <spec.vl.json> <config.json> <out.svg> | fit <file.svg> | watch | dev");

function fail(message) {
  console.error(message);
  process.exit(1);
}

// Compiles a Vega-Lite spec with the theme config and writes a static SVG.
async function renderVega(specPath, configPath, outPath) {
  const spec = JSON.parse(readFileSync(specPath, "utf8"));
  const config = JSON.parse(readFileSync(configPath, "utf8"));
  const compiled = vl.compile(spec, { config }).spec;
  const loader = vega.loader({ baseURL: dirname(resolve(specPath)) + "/", mode: "file" });
  const view = new vega.View(vega.parse(compiled), { renderer: "none", loader });
  writeFileSync(outPath, await view.toSVG());
}

// Gives the root <svg> a fixed width, height and viewBox so <img> sizes it correctly.
function fitToViewBox(file) {
  const svg = readFileSync(file, "utf8");
  const tag = svg.match(/<svg\b[^>]*>/)?.[0];
  if (!tag) fail(`${file}: no <svg> element`);
  const attr = (name) => tag.match(new RegExp(`\\s${name}="([^"]*)"`))?.[1];
  let box = attr("viewBox")?.trim().split(/\s+/).map(Number);
  if (!box && attr("width") && attr("height") && !attr("width").endsWith("%")) {
    box = [0, 0, parseFloat(attr("width")), parseFloat(attr("height"))];
  }
  if (!box || box.length !== 4 || box.some(Number.isNaN)) fail(`${file}: cannot determine size`);
  const bare = tag.replace(/\s(?:width|height|viewBox)="[^"]*"/g, "");
  const fixed = bare.replace(/^<svg\b/, `<svg width="${box[2]}" height="${box[3]}" viewBox="${box.join(" ")}"`);
  writeFileSync(file, svg.replace(tag, fixed));
}

// Polls content/ and re-renders any diagram source whose modification time changes.
// Polling keeps it reliable across editors that save by replacing the file.
function watchSources() {
  const seen = new Map();
  const scan = () => {
    for (const name of readdirSync("content", { recursive: true })) {
      if (!/\.(mmd|vl\.json)$/.test(name)) continue;
      const file = join("content", name);
      let mtime;
      try { mtime = statSync(file).mtimeMs; } catch { continue; }
      if (seen.get(file) === mtime) continue;
      const known = seen.has(file);
      seen.set(file, mtime);
      if (known) spawnSync("scripts/render-diagrams.sh", [file], { stdio: "inherit" });
    }
  };
  scan();
  setInterval(scan, 500);
  console.log("Watching content/ for diagram changes");
}

// Renders every diagram, then runs `hugo server -D` while watching the sources.
function dev() {
  const first = spawnSync("scripts/render-diagrams.sh", { stdio: "inherit" });
  if (first.status !== 0) console.error("Some diagrams failed to render; continuing.");
  watchSources();
  const hugo = spawn("hugo", ["server", "-D"], { stdio: "inherit" });
  hugo.on("error", () => fail("Could not start hugo. Install it with: brew install hugo"));
  hugo.on("exit", (code) => process.exit(code ?? 0));
  for (const signal of ["SIGINT", "SIGTERM"]) process.on(signal, () => hugo.kill(signal));
}
