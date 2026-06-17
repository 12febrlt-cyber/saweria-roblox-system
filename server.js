// ── Webhook utama dari Saweria ──────────────────────────────
app.post("/webhook/saweria", async (req, res) => {
  console.log("[Webhook] Menerima donasi:", JSON.stringify(req.body));

  // ✅ FIX: Saweria pakai header "x-callback-token"
  if (SAWERIA_TOKEN) {
    const signature = req.headers["x-callback-token"] || "";
    if (signature !== SAWERIA_TOKEN) {
      console.warn("[Webhook] Token tidak valid, request ditolak");
      console.warn("[Webhook] Header diterima:", JSON.stringify(req.headers)); // untuk debug
      return res.status(401).json({ error: "Unauthorized" });
    }
  }
  // ... sisa kode tetap sama
