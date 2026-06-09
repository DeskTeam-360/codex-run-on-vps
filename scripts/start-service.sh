#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export HOME="${HOME:-/home/ubuntu}"
export CODEX_AUTH_FILE="${CODEX_AUTH_FILE:-$HOME/.codex/auth.json}"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-8787}"

exec "$(command -v node)" "$DIR/scripts/serve.js"
