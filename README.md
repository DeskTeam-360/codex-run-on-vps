# Codex ChatGPT Pro → OpenAI API Proxy

Gunakan subscription **ChatGPT Pro** Anda sebagai **OpenAI-compatible API** di VPS. Proxy ini meneruskan request ke backend Codex (`chatgpt.com`) menggunakan session login ChatGPT Pro — tanpa perlu API key OpenAI Platform terpisah.

## Arsitektur

```
Client (my-app, Cursor, curl)
        │
        ▼
  Proxy API :8787/v1          ← proyek ini
        │
        ▼
  chatgpt.com/backend-api/codex/*
        │
        ▼
  ChatGPT Pro subscription (quota Codex)
```

## Prasyarat

- VPS Linux (Ubuntu/Debian direkomendasikan)
- Node.js 18+
- Akun **ChatGPT Pro** (atau Plus/Team/Enterprise dengan akses Codex)
- Aktifkan **Device Code Login** di [ChatGPT → Settings → Security](https://chatgpt.com/#settings/Security)

---

## Instalasi di VPS

### 1. Clone / upload proyek

```bash
# Contoh: upload ke /opt
sudo mkdir -p /opt/codex-chatgpt-for-api
cd /opt/codex-chatgpt-for-api
# salin semua file proyek ke sini
```

### 2. Jalankan setup script

```bash
chmod +x scripts/setup-vps.sh
sudo ./scripts/setup-vps.sh
```

Atau manual:

```bash
# Install Node.js 20 (Ubuntu)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Codex CLI
npm install -g @openai/codex

# Install dependency proyek
npm install
```

### 3. Login ChatGPT Pro (headless VPS)

**Metode A — Device Code (direkomendasikan untuk VPS tanpa browser):**

```bash
codex login --device-auth
```

1. Buka link yang muncul di browser lokal (PC/laptop Anda)
2. Login dengan akun ChatGPT Pro
3. Masukkan kode one-time ke terminal VPS

**Metode B — Copy auth.json dari PC lokal:**

Jika sudah login Codex di PC Windows/Mac:

```bash
# Dari PC lokal, kirim ke VPS:
ssh user@VPS_IP 'mkdir -p ~/.codex'
scp %USERPROFILE%\.codex\auth.json user@VPS_IP:~/.codex/auth.json
# Linux/Mac: scp ~/.codex/auth.json user@VPS_IP:~/.codex/auth.json
```

**Metode C — SSH tunnel (browser login di PC, callback ke VPS):**

```bash
# Di PC lokal:
ssh -L 1455:localhost:1455 user@VPS_IP

# Di session SSH VPS:
codex login
# Buka URL yang muncul di browser PC lokal
```

Verifikasi login:

```bash
codex login status
ls ~/.codex/auth.json
```

### 4. Jalankan proxy API

```bash
npm run serve
# atau dengan env file:
cp .env.example .env
npm run serve:env
```

Proxy berjalan di `http://0.0.0.0:8787`

### 5. (Opsional) Systemd — auto-start

```bash
sudo cp systemd/codex-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable codex-api
sudo systemctl start codex-api
sudo systemctl status codex-api
```

---

## Endpoint API

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/health` | Health check |
| GET | `/v1/models` | Daftar model |
| POST | `/v1/chat/completions` | Chat (OpenAI-compatible) |
| POST | `/v1/responses` | Responses API |

**Model yang umum dipakai:** `gpt-5-codex`, `gpt-5.3-codex`, `gpt-5`, `gpt-5.2-codex`

**API Key:** Isi dengan nilai dummy (mis. `dummy`) — autentikasi sebenarnya dari session ChatGPT Pro.

---

## Contoh penggunaan

### curl

```bash
curl http://VPS_IP:8787/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer dummy" \
  -d '{
    "model": "gpt-5-codex",
    "messages": [{"role": "user", "content": "Halo, jelaskan apa itu proxy API"}]
  }'
```

### OpenAI SDK (Node.js / Python)

```javascript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: "dummy",
  baseURL: "http://VPS_IP:8787/v1",
});

const res = await client.chat.completions.create({
  model: "gpt-5-codex",
  messages: [{ role: "user", content: "Hello" }],
});
console.log(res.choices[0].message.content);
```

### Integrasi ke my-app

Set di `.env` aplikasi Anda:

```env
OPENAI_API_KEY=dummy
OPENAI_BASE_URL=http://VPS_IP:8787/v1
```

---

## Keamanan VPS

Proxy ini **tidak** punya API key downstream bawaan. Jangan expose port 8787 ke internet publik tanpa proteksi.

**Rekomendasi:**

1. **Firewall** — batasi IP yang boleh akses:
   ```bash
   sudo ufw allow from YOUR_IP to any port 8787
   sudo ufw deny 8787
   ```

2. **Nginx reverse proxy + Basic Auth** di depan proxy

3. **Bind localhost saja** (`HOST=127.0.0.1`) jika hanya dipakai oleh app di VPS yang sama

4. **Jangan commit** `~/.codex/auth.json` — file ini setara password

---

## Docker (alternatif)

Login dulu di host VPS, lalu:

```bash
cp .env.example .env
docker compose up -d
```

Volume `~/.codex/auth.json` dari host di-mount ke container.

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `auth.json not found` | Jalankan `codex login --device-auth` atau copy file auth |
| `/health` OK tapi `/v1/models` gagal | Token expired — login ulang |
| Device code tidak muncul | Aktifkan Device Code Login di ChatGPT Security settings |
| Rate limit | Quota mengikuti plan ChatGPT Pro (bukan API Platform) |
| Port sudah dipakai | Ganti `PORT` di `.env` |

---

## Catatan penting

- Ini memakai **quota subscription ChatGPT Pro**, bukan billing OpenAI API Platform
- Untuk production/automation skala besar, OpenAI merekomendasikan API key resmi
- Token di `auth.json` di-refresh otomatis selama proxy/Codex CLI aktif
- Fitur cloud Codex mungkin terbatas dibanding login langsung di CLI

## Referensi

- [Codex Authentication (OpenAI)](https://developers.openai.com/codex/auth)
- [@thkdog/codex-openai-proxy](https://github.com/thkdog/codex-openai-proxy)
- [@openai/codex CLI](https://www.npmjs.com/package/@openai/codex)
