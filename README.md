# 💝 Saweria × Roblox Donation System

Sistem donasi lengkap yang menghubungkan **Saweria** dengan game **Roblox** secara real-time. Donor mendapatkan aura efek, VIP badge di atas kepala, notifikasi server, leaderboard, dan efek suara otomatis.

---

## ✨ Fitur

| Fitur | Keterangan |
|---|---|
| 🌟 Aura Efek | Partikel berkilau di sekitar karakter donor |
| 🏅 VIP Badge | Badge nama di atas kepala dengan tier berbeda |
| 🔔 Notifikasi | Popup donasi real-time ke semua pemain |
| 🏆 Leaderboard | Papan top donor otomatis terupdate |
| 🔊 Efek Suara | Suara berbeda per tier donasi |
| 💾 DataStore | Data donor tersimpan permanen |
| ⏳ Pending Aura | Aura diberikan saat donor offline |

---

## 🏆 Tier Sistem

### Aura (per donasi tunggal)
| Tier | Minimal | Efek |
|---|---|---|
| 🤍 Common | Rp 10.000 | Partikel putih |
| 💙 Rare | Rp 25.000 | Partikel biru berkilau |
| 💜 Epic | Rp 50.000 | Spiral ungu |
| ⭐ Legendary | Rp 100.000 | Api emas + glow pulse |

### Badge Kepala (total kumulatif)
| Tier | Total Donasi |
|---|---|
| 🤍 Common | Rp 15.000+ |
| 💙 Rare | Rp 75.000+ |
| 💜 Epic | Rp 200.000+ |
| ⭐ Legendary | Rp 500.000+ |

---

## 📁 Struktur File

```
saweria-roblox-system/
│
├── 📜 server.js                  ← Backend webhook (deploy ke Railway)
├── 📜 package.json               ← Dependencies Node.js
│
├── 🎮 Roblox Scripts/
│   ├── SetupEvents_v2.lua        → ServerScriptService (jalankan PERTAMA)
│   ├── DonationServer_v2.lua     → ServerScriptService
│   ├── DonationNotifClient.lua   → StarterPlayerScripts
│   ├── DonationSoundClient.lua   → StarterPlayerScripts
│   ├── AuraClient.lua            → StarterCharacterScripts
│   └── VIPBadgeClient.lua        → StarterCharacterScripts
│
└── 🌐 Frontend/
    └── SaweriaSystem.jsx         ← Dashboard React (opsional)
```

---

## 🚀 Cara Setup

### 1. Deploy Backend ke Railway

1. Buka [railway.app](https://railway.app) → Login dengan GitHub
2. **New Project** → **Deploy from GitHub repo** → pilih repo ini
3. Tambahkan **Environment Variables**:

```
ROBLOX_API_KEY=your_api_key_here
UNIVERSE_ID=your_universe_id_here
SAWERIA_TOKEN=your_saweria_token_here
PORT=3000
```

4. Railway otomatis kasih URL: `https://nama-project.up.railway.app`

### 2. Dapatkan Roblox API Key

1. Buka [create.roblox.com](https://create.roblox.com) → **Credentials** → **API Keys**
2. Klik **Create API Key**
3. Nama: `Saweria Webhook`
4. Tambah izin: `universe-messaging-service:publish`
5. Pilih universe/game kamu
6. Copy API Key → paste ke Railway variable

### 3. Dapatkan Universe ID

1. Buka [create.roblox.com](https://create.roblox.com) → pilih game kamu
2. URL akan seperti: `https://create.roblox.com/dashboard/creations/experiences/123456789/...`
3. Angka `123456789` itulah Universe ID kamu

### 4. Setup Roblox Studio

1. **Aktifkan pengaturan:**
   - Game Settings → Security → ✅ Allow HTTP Requests
   - Game Settings → Security → ✅ Enable Studio Access to API Services

2. **Taruh script sesuai lokasi:**

```
ServerScriptService/
  ├── SetupEvents_v2.lua    ← PERTAMA
  └── DonationServer_v2.lua

StarterPlayerScripts/
  ├── DonationNotifClient.lua
  └── DonationSoundClient.lua

StarterCharacterScripts/
  ├── AuraClient.lua
  └── VIPBadgeClient.lua
```

### 5. Setup Webhook di Saweria

1. Login ke [saweria.co](https://saweria.co)
2. **Pengaturan** → **Webhook**
3. URL: `https://nama-project.up.railway.app/webhook/saweria`
4. Aktifkan webhook

### 6. Test Donasi

Gunakan endpoint test untuk memastikan koneksi berjalan:

```bash
curl -X POST https://nama-project.up.railway.app/test/donation \
  -H "Content-Type: application/json" \
  -d '{"name":"TestPlayer123","amount":50000,"msg":"Test!"}'
```

---

## 🔄 Alur Kerja

```
Donor bayar di Saweria
        ↓
Saweria kirim Webhook POST
        ↓
server.js menerima & validasi
        ↓
Kirim ke Roblox MessagingService
        ↓
DonationServer_v2.lua memproses
        ↙              ↘
AuraClient.lua    VIPBadgeClient.lua
(aura partikel)   (badge kepala)
        ↘              ↙
   DonationNotifClient.lua
   (popup + leaderboard)
        ↓
DonationSoundClient.lua
(efek suara)
```

---

## 🛠️ Troubleshooting

| Masalah | Solusi |
|---|---|
| Aura tidak muncul | Cek AuraClient.lua sudah di StarterCharacterScripts |
| Badge tidak muncul | Pastikan BadgeEvent sudah dibuat via SetupEvents_v2 |
| Webhook tidak diterima | Cek URL Railway sudah benar di Saweria |
| Error 401 Roblox | API Key tidak valid atau izin kurang |
| Error 403 Roblox | Universe ID salah |
| Suara tidak bunyi | Ganti Sound ID di DonationSoundClient.lua |

---

## 📝 Lisensi

MIT License — bebas digunakan dan dimodifikasi.

---

Made with ❤️ for Amora Space Roblox Server
