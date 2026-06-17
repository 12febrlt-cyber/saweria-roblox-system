app.post("/webhook/saweria", async (req, res) => {
  console.log("[Webhook] Menerima donasi:", JSON.stringify(req.body));

  const {
    donator_name,
    amount_raw,   // ← Saweria pakai amount_raw
    amount,       // fallback
    message,
  } = req.body;

  const finalAmount = amount_raw || amount;

  if (!donator_name || !finalAmount) {
    console.warn("[Webhook] Data tidak lengkap:", req.body);
    return res.status(400).json({ error: "donator_name dan amount wajib ada" });
  }

  const donationData = {
    name:   donator_name.trim(),
    amount: parseInt(finalAmount) || 0,
    msg:    message || "",
    time:   Date.now(),
  };

  console.log("[Webhook] Mengirim ke Roblox:", donationData);
  const success = await sendToRoblox("DonationReceived", donationData);
  console.log("[Webhook] Hasil kirim Roblox:", success);

  res.json({ success });
});
