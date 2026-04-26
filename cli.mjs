#!/usr/bin/env node

/**
 * GBaby CLI — cross-platform entry point.
 *
 * Usage:
 *   npx gbaby setup    # auto-detects OS, runs the right setup script
 *   npx gbaby doctor   # health check
 *   npx gbaby graph    # sync knowledge graph
 */

import { execSync } from "node:child_process";
import { platform } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const scriptsDir = join(__dirname, "scripts");
const isWindows = platform() === "win32";

const commands = {
  setup: isWindows
    ? `powershell -ExecutionPolicy Bypass -File "${join(scriptsDir, "setup.ps1")}"`
    : `bash "${join(scriptsDir, "setup.sh")}"`,

  doctor: isWindows
    ? `powershell -ExecutionPolicy Bypass -File "${join(scriptsDir, "doctor.ps1")}"`
    : `bash "${join(scriptsDir, "doctor.sh")}"`,

  graph: "npm run graph:sync",

  "graph:init": "npm run graph:init",

  "graph:watch": "npm run graph:watch",
};

const [cmd] = process.argv.slice(2);

if (!cmd || cmd === "--help" || cmd === "-h") {
  console.log(`
  ██████  ██████   █████  ██████  ██    ██
 ██       ██   ██ ██   ██ ██   ██  ██  ██
 ██   ███ ██████  ███████ ██████    ████
 ██    ██ ██   ██ ██   ██ ██   ██    ██
  ██████  ██████  ██   ██ ██████     ██

 The Frankenstein of AI Coding

 Usage:
   npx gbaby setup         Install & configure everything
   npx gbaby doctor        Health check
   npx gbaby graph         Sync knowledge graph
   npx gbaby graph:init    Initialize knowledge graph
   npx gbaby graph:watch   Watch mode for knowledge graph
   npx gbaby --help        Show this help
`);
  process.exit(0);
}

if (!commands[cmd]) {
  console.error(`Unknown command: ${cmd}`);
  console.error(`Run 'npx gbaby --help' for usage.`);
  process.exit(1);
}

try {
  execSync(commands[cmd], { stdio: "inherit", cwd: __dirname });
} catch (e) {
  process.exit(e.status || 1);
}
