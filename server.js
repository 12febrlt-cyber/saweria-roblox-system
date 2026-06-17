const express = require("express");
const axios   = require("axios");

const app  = express();
app.use(express.json());

const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY || "";
const UNIVERSE_ID    = process.env.UNIVERSE_ID    || "";
const SAWERIA_TOKEN  = process.env.SAWERIA_TOKEN  || "";
const PORT           = process.env.PORT           || 3000;

if (!ROBLOX_API_KEY || !UNIVERSE_ID) {
  console.warn("⚠️  ROBLOX_API_KEY atau UNIVERSE_ID belum diset!");
}

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

app.get("/", (req, res) => {
  res.json({
    status:    "ok",
    service:   "Saweria × Roblox Webhook",
    universe:  UNIVERSE_ID || "belum diset",
    timestamp: new Date().toISOString(),
  });
});

app.post("/webhook/saweria", async (req, res) => {
  console.log("[Webhook] Menerima donasi:", JSON.stringify(req.body));

  // ✅ FIX: pakai "x-callback-token" bukan "x-saweria-token"
  //if (SAWERIA_TOKEN) {
  //  const signature = req.headers["x-callback-token"] || "";
  //  if (signature !== SAWERIA_TOKEN) {
  //   console.warn("[Webhook] Token tidak valid, request ditolak");
  //    console.warn("[Webhook] Headers:", JSON.stringify(req.headers));
  //    return res.status(401).json({ error: "Unauthorized" });
    }
  }

  const { donator_name, amount, message } = req.body;

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

  const success = await sendToRoblox("DonationReceived", donationData);

  res.json({
    success,
    message: success
      ? `Donasi dari ${donationData.name} (Rp ${donationData.amount}) diteruskan ke Roblox`
      : "Gagal kirim ke Roblox, cek log server",
  });
});

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

app.listen(PORT, () => {
  console.log("============================================");
  console.log(`  🚀 Server berjalan di port ${PORT}`);
  console.log(`  🎮 Universe ID : ${UNIVERSE_ID || "BELUM DISET"}`);
  console.log(`  🔑 API Key     : ${ROBLOX_API_KEY ? "✓ sudah diset" : "✗ BELUM DISET"}`);
  console.log("============================================");
});
