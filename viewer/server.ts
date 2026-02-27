import { readdir, readFile } from "node:fs/promises";
import { join, resolve } from "node:path";

const repoRoot = resolve(import.meta.dir, "..");
const outputDir = join(repoRoot, "output");
const legacyOutputDir = repoRoot;
const htmlPath = join(import.meta.dir, "index.html");
const stylePath = join(import.meta.dir, "styles.css");
const port = 8787;

const DIGEST_FILE_RE = /^digest-\d{8}\.md$/;

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

function html(text: string, status = 200): Response {
  return new Response(text, {
    status,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function text(data: string, status = 200): Response {
  return new Response(data, {
    status,
    headers: { "content-type": "text/plain; charset=utf-8" },
  });
}

function normalizeName(name: string): string | null {
  if (!DIGEST_FILE_RE.test(name)) return null;
  if (name.includes("/") || name.includes("\\")) return null;
  return name;
}

async function listReports() {
  const dirs = [outputDir, legacyOutputDir];
  const all = new Set<string>();

  for (const dir of dirs) {
    const entries = await readdir(dir, { withFileTypes: true }).catch(() => []);
    for (const entry of entries) {
      if (entry.isFile() && DIGEST_FILE_RE.test(entry.name)) {
        all.add(entry.name);
      }
    }
  }

  return [...all].sort((a, b) => b.localeCompare(a));
}

async function readReport(name: string): Promise<string | null> {
  const candidatePaths = [join(outputDir, name), join(legacyOutputDir, name)];
  for (const filePath of candidatePaths) {
    const fileData = await readFile(filePath, "utf8").catch(() => null);
    if (fileData) return fileData;
  }
  return null;
}

Bun.serve({
  port,
  async fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === "/") {
      const page = await readFile(htmlPath, "utf8");
      return html(page);
    }

    if (url.pathname === "/styles.css") {
      const css = await readFile(stylePath, "utf8");
      return new Response(css, {
        headers: { "content-type": "text/css; charset=utf-8" },
      });
    }

    if (url.pathname === "/api/reports") {
      const reports = await listReports();
      return json({ reports });
    }

    if (url.pathname === "/api/report") {
      const name = normalizeName(url.searchParams.get("name") ?? "");
      if (!name) return json({ error: "Invalid report name" }, 400);
      const fileData = await readReport(name);
      if (!fileData) return json({ error: "Report not found" }, 404);
      return text(fileData);
    }

    return new Response("Not Found", { status: 404 });
  },
});

console.log(`[viewer] AI Daily Digest Viewer: http://localhost:${port}`);
