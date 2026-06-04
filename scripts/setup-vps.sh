#!/usr/bin/env bash
set -euo pipefail

echo "==> Memeriksa Node.js..."
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js belum terinstall. Install Node.js 18+ dulu:"
  echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
  echo "  sudo apt-get install -y nodejs"
  exit 1
fi

node -v
npm -v

echo "==> Install Codex CLI (global)..."
npm install -g @openai/codex

echo "==> Install dependency proyek..."
cd "$(dirname "$0")/.."
npm install

echo ""
echo "Setup selesai."
echo ""
echo "Langkah berikutnya:"
echo "  1. Aktifkan Device Code Login di ChatGPT → Settings → Security"
echo "  2. Login: npm run login   (atau: codex login --device-auth)"
echo "  3. Jalankan proxy: npm run serve"
echo ""
echo "Cek status login: codex login status"
