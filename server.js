// ============================================================
//  server.js
//  Backend webhook: Saweria → Roblox MessagingService
//  Deploy ke Railway.app / Render.com / VPS
// ============================================================

const express = require("express");
const axios   = require("axios");
const crypto  = require("crypto");

const app  = express();
app.use(express.json());

// ── Environment Variables (isi di Railway dashboard) ────────
const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY || "";
const UNIVERSE_ID    = process.env.UNIVERSE_ID    || "";
const SAWERIA_TOKEN  = process.env.SAWERIA_TOKEN  || ""; // opsional, untuk verifikasi
const PORT           = process.env.PORT           || 3000;

// ── Validasi env saat startup ───────────────────────────────
if (!ROBLOX_API_KEY || !UNIVERSE_ID) {
  console.warn("⚠️  ROBLOX_API_KEY atau UNIVERSE_ID belum diset!");
}

// ── Helper: kirim pesan ke Roblox MessagingService ─────────
async function sendToRoblox(topic, data) {
  const url = `https://apis.roblox.com/messaging-service/v1/universes/${UNIVERSE_ID}/topics/${topic}`;
  try {
    const res = await axios.post(
      url,
      { message: JSON.stringify(data) },
      {
        headers: {
          "x-api-key":    ROBLOX_API_KEY,
          "Content-Type": "application/json",
        },
        timeout: 8000,
      }
    );
    console.log(`[Roblox] Topic "${topic}" terkirim:`, res.status);
    return true;
  } catch (err) {
    const status = err.response?.status;
    const msg    = err.response?.data || err.message;
    console.error(`[Roblox] Gagal kirim ke topic "${topic}": ${status}`, msg);
    return false;
  }
}

// ── Health check endpoint ───────────────────────────────────
app.get("/", (req, res) => {
  res.json({
    status:    "ok",
    service:   "Saweria × Roblox Webhook",
    universe:  UNIVERSE_ID || "belum diset",
    timestamp: new Date().toISOString(),
  });
});

// ── Webhook utama dari Saweria ──────────────────────────────
app.post("/webhook/saweria", async (req, res) => {
  console.log("[Webhook] Menerima donasi:", JSON.stringify(req.body));

  // Verifikasi signature Saweria (jika token diset)
  if (SAWERIA_TOKEN) {
    const signature = req.headers["x-saweria-token"] || "";
    if (signature !== SAWERIA_TOKEN) {
      console.warn("[Webhook] Token tidak valid, request ditolak");
      return res.status(401).json({ error: "Unauthorized" });
    }
  }

  // Ambil data dari body Saweria
  // Format Saweria: { donator_name, amount, message, ... }
  const {
    donator_name,   // username Roblox (diminta saat donasi)
    amount,         // nominal dalam Rupiah
    message,        // pesan dari donor
    type,           // "donation"
  } = req.body;

  // Validasi field wajib
  if (!donator_name || !amount) {
    console.warn("[Webhook] Data tidak lengkap:", req.body);
    return res.status(400).json({ error: "Field donator_name dan amount wajib ada" });
  }

  const donationData = {
    name:   donator_name.trim(),
    amount: parseInt(amount) || 0,
    msg:    message || "",
    time:   Date.now(),
  };

  // Kirim ke Roblox
  const success = await sendToRoblox("DonationReceived", donationData);

  if (success) {
    res.json({
      success: true,
      message: `Donasi dari ${donationData.name} (Rp ${donationData.amount}) diteruskan ke Roblox`,
    });
  } else {
    // Tetap 200 agar Saweria tidak retry terus-menerus
    res.json({
      success: false,
      message: "Gagal kirim ke Roblox, cek log server",
    });
  }
});

// ── Endpoint test manual (untuk debugging) ─────────────────
app.post("/test/donation", async (req, res) => {
  const testData = {
    name:   req.body.name   || "TestPlayer123",
    amount: req.body.amount || 10000,
    msg:    req.body.msg    || "Test donasi dari server",
    time:   Date.now(),
  };

  console.log("[Test] Mengirim test donasi:", testData);
  const success = await sendToRoblox("DonationReceived", testData);

  res.json({
    success,
    sent: testData,
    message: success ? "Test berhasil dikirim ke Roblox!" : "Gagal, cek API key & Universe ID",
  });
});

// ── Start server ────────────────────────────────────────────
app.listen(PORT, () => {
  console.log("============================================");
  console.log(`  🚀 Server berjalan di port ${PORT}`);
  console.log(`  🎮 Universe ID : ${UNIVERSE_ID || "BELUM DISET"}`);
  console.log(`  🔑 API Key     : ${ROBLOX_API_KEY ? "✓ sudah diset" : "✗ BELUM DISET"}`);
  console.log("============================================");
});
