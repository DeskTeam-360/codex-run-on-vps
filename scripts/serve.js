const { spawn } = require("node:child_process");
const path = require("node:path");
const os = require("node:os");

const host = process.env.HOST || "0.0.0.0";
const port = process.env.PORT || "8787";
const authFile =
  process.env.CODEX_AUTH_FILE ||
  path.join(os.homedir(), ".codex", "auth.json");

const bin = path.join(
  path.dirname(require.resolve("@thkdog/codex-openai-proxy")),
  "cli.js"
);
const wsPolyfill = path.join(__dirname, "ws-polyfill.cjs");

const child = spawn(
  process.execPath,
  ["-r", wsPolyfill, bin, "--host", host, "--port", port, "--auth-file", authFile],
  { stdio: "inherit", env: process.env }
);

child.on("exit", (code) => process.exit(code ?? 1));
