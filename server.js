const express = require("express");
const axios   = require("axios");

const app = express();
app.use(express.json());

const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY || "";
const UNIVERSE_ID    = process.env.UNIVERSE_ID    || "";
const PORT           = process.env.PORT           || 3000;

async function sendToRoblox(topic, data) {
  const url = `https://apis.roblox.com/messaging-service/v1/universes/${UNIVERSE_ID}/topics/${topic}`;
  try {
    const res = await axios.post(
      url,
      { message: JSON.stringify(data) },
      {
        headers: {
          "x-api-key": ROBLOX_API_KEY,
          "Content-Type": "application/json",
        },
        timeout: 8000,
      }
    );
    console.log(`[Roblox] Terkirim:`, res.status);
    return true;
  } catch (err) {
    console.error(`[Roblox] Gagal:`, err.response?.status, err.response?.data || err.message);
    return false;
  }
}

app.get("/", (req, res) => {
  res.json({ status: "ok", universe: UNIVERSE_ID });
});

app.post("/webhook/saweria", async (req, res) => {
  console.log("[Webhook] Menerima donasi:", JSON.stringify(req.body));

  const { donator_name, amount, message } = req.body;

  if (!donator_name || !amount) {
    return res.status(400).json({ error: "donator_name dan amount wajib ada" });
  }

  const donationData = {
    name:   donator_name.trim(),
    amount: parseInt(amount) || 0,
    msg:    message || "",
    time:   Date.now(),
  };

  const success = await sendToRoblox("DonationReceived", donationData);

  res.json({ success });
});

app.post("/test/donation", async (req, res) => {
  const testData = {
    name:   req.body.name   || "TestPlayer123",
    amount: req.body.amount || 10000,
    msg:    req.body.msg    || "Test donasi",
    time:   Date.now(),
  };
  const success = await sendToRoblox("DonationReceived", testData);
  res.json({ success, sent: testData });
});

app.listen(PORT, () => {
  console.log("==========================================");
  console.log(`  🚀 Server berjalan di port ${PORT}`);
  console.log(`  🎮 Universe ID : ${UNIVERSE_ID || "BELUM DISET"}`);
  console.log(`  🔑 API Key     : ${ROBLOX_API_KEY ? "✓ sudah diset" : "✗ BELUM DISET"}`);
  console.log("==========================================");
});
