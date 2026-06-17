import { useState, useEffect } from "react";

// ─── Data awal ────────────────────────────────────────────────────────────────
const INITIAL_DONORS = [
  { name: "AFROxLxXx", amount: 450000, avatar: "AF" },
  { name: "TWCxDJ_Angel", amount: 380000, avatar: "TW" },
  { name: "IpingxOwn_LUNE", amount: 220000, avatar: "IP" },
  { name: "CCHxLexxBF", amount: 175000, avatar: "CC" },
  { name: "OwnxOSCxRaasa", amount: 120000, avatar: "OW" },
  { name: "RiKxAdm_LUNE", amount: 95000, avatar: "RI" },
  { name: "NoahLY_LUNE", amount: 80000, avatar: "NO" },
];

const INITIAL_NOTIFS = [
  { id: 1, name: "TWCxDJ_Angel", amount: 20000, msg: "Makasih server nya keren!", time: "2 menit lalu", isNew: true },
  { id: 2, name: "Meyntos_LUNE", amount: 15000, msg: "Semangat admin!", time: "18 menit lalu", isNew: true },
  { id: 3, name: "OwnxOSCxRaasa", amount: 50000, msg: "", time: "1 jam lalu", isNew: true },
  { id: 4, name: "AFROxLxXx", amount: 100000, msg: "Top server!", time: "3 jam lalu", isNew: false },
  { id: 5, name: "IpingxOwn_LUNE", amount: 25000, msg: "GG", time: "kemarin", isNew: false },
];

const PRESET_AMOUNTS = [5000, 10000, 25000, 50000, 100000];

const rupiahFormat = (n) =>
  "Rp " + n.toLocaleString("id-ID");

// ─── Toast ────────────────────────────────────────────────────────────────────
function Toast({ message, visible }) {
  return (
    <div
      style={{
        position: "fixed",
        bottom: 24,
        right: 24,
        background: "#1D9E75",
        color: "#fff",
        padding: "10px 18px",
        borderRadius: 8,
        fontSize: 13,
        fontWeight: 500,
        boxShadow: "0 4px 16px rgba(0,0,0,0.15)",
        transition: "opacity 0.3s, transform 0.3s",
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : "translateY(12px)",
        pointerEvents: "none",
        zIndex: 999,
      }}
    >
      {message}
    </div>
  );
}

// ─── Toggle Switch ────────────────────────────────────────────────────────────
function Toggle({ on, onChange }) {
  return (
    <button
      onClick={onChange}
      aria-pressed={on}
      style={{
        width: 38,
        height: 22,
        borderRadius: 20,
        border: "none",
        background: on ? "#534AB7" : "#ccc",
        cursor: "pointer",
        position: "relative",
        transition: "background 0.2s",
        flexShrink: 0,
      }}
    >
      <span
        style={{
          position: "absolute",
          top: 3,
          left: on ? 18 : 3,
          width: 16,
          height: 16,
          borderRadius: "50%",
          background: "#fff",
          transition: "left 0.2s",
          display: "block",
        }}
      />
    </button>
  );
}

// ─── Sidebar Nav ──────────────────────────────────────────────────────────────
const NAV = [
  { id: "benefit", label: "Benefit", icon: "🎁" },
  { id: "donate", label: "Donasi", icon: "💰" },
  { id: "leaderboard", label: "Top Donor", icon: "🏆" },
  { id: "notif", label: "Notifikasi", icon: "🔔" },
  { id: "settings", label: "Pengaturan", icon: "⚙️" },
];

// ─── Panel: Benefit ───────────────────────────────────────────────────────────
function PanelBenefit({ stats }) {
  const benefits = [
    { icon: "✨", name: "Special Aura Effect", desc: "Aura eksklusif di sekitar karakter", badge: "Aktif otomatis", color: "#EEEDFE", textColor: "#534AB7" },
    { icon: "🏆", name: "Top Donor Leaderboard", desc: "Nama muncul di papan skor server", badge: "Nama muncul", color: "#E1F5EE", textColor: "#0F6E56" },
    { icon: "💬", name: "Chat Notifikasi Server", desc: "Pengumuman saat kamu donasi", badge: "Server wide", color: "#E1F5EE", textColor: "#0F6E56" },
    { icon: "👤", name: "Username Roblox Wajib", desc: "Isi saat donasi agar benefit aktif", badge: "Saat donasi", color: "#EEEDFE", textColor: "#534AB7" },
  ];

  return (
    <div>
      {/* Stats */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: 12, marginBottom: 20 }}>
        {[
          { label: "Total Donasi", value: rupiahFormat(stats.totalAmount), sub: `+${rupiahFormat(stats.weeklyAmount)} minggu ini` },
          { label: "Total Donor", value: stats.totalDonors, sub: `+${stats.todayDonors} hari ini` },
          { label: "Server Uptime", value: "99.8%", sub: "30 hari terakhir" },
        ].map((s) => (
          <div key={s.label} style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 8, padding: "14px 16px" }}>
            <div style={{ fontSize: 11, color: "#888", marginBottom: 4 }}>{s.label}</div>
            <div style={{ fontSize: 22, fontWeight: 600, color: "#1a1a1a" }}>{s.value}</div>
            <div style={{ fontSize: 11, color: "#1D9E75", marginTop: 2 }}>{s.sub}</div>
          </div>
        ))}
      </div>

      {/* Benefits */}
      <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px", marginBottom: 16 }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 14, textTransform: "uppercase" }}>Yang kamu dapat</div>
        {benefits.map((b, i) => (
          <div key={b.name} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 0", borderBottom: i < benefits.length - 1 ? "0.5px solid #f0f0f0" : "none" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <div style={{ width: 34, height: 34, borderRadius: "50%", background: b.color, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16 }}>{b.icon}</div>
              <div>
                <div style={{ fontSize: 13, fontWeight: 500 }}>{b.name}</div>
                <div style={{ fontSize: 11, color: "#888", marginTop: 1 }}>{b.desc}</div>
              </div>
            </div>
            <span style={{ fontSize: 11, padding: "3px 10px", borderRadius: 20, background: b.color, color: b.textColor, fontWeight: 500, whiteSpace: "nowrap" }}>{b.badge}</span>
          </div>
        ))}
      </div>

      {/* Cara donasi */}
      <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px" }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 14, textTransform: "uppercase" }}>Cara donasi</div>
        <ol style={{ paddingLeft: 18, display: "flex", flexDirection: "column", gap: 8 }}>
          {["Copy link Saweria di tab Donasi", "Buka browser dan paste link", "Isi nama dengan username Roblox kamu", "Salah username? Hubungi Admin segera!"].map((step) => (
            <li key={step} style={{ fontSize: 13, color: "#555", lineHeight: 1.5 }}>{step}</li>
          ))}
        </ol>
      </div>
    </div>
  );
}

// ─── Panel: Donasi ────────────────────────────────────────────────────────────
function PanelDonate({ saweriaLink, onDonate, showToast }) {
  const [user, setUser] = useState("");
  const [amount, setAmount] = useState("");
  const [msg, setMsg] = useState("");
  const [preset, setPreset] = useState(null);
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(saweriaLink).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
    showToast("Link disalin!");
  };

  const handleDonate = () => {
    if (!user.trim()) { showToast("Username Roblox wajib diisi!"); return; }
    const amt = parseInt(amount);
    if (!amt || amt < 5000) { showToast("Minimal donasi Rp 5.000"); return; }
    onDonate({ name: user.trim(), amount: amt, msg: msg.trim() });
    setUser(""); setAmount(""); setMsg(""); setPreset(null);
    showToast("Donasi berhasil! Benefit aktif otomatis.");
  };

  return (
    <div>
      {/* Link */}
      <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px", marginBottom: 16 }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 12, textTransform: "uppercase" }}>Link donasi</div>
        <div style={{ display: "flex", alignItems: "center", gap: 10, background: "#f7f7f7", borderRadius: 8, padding: "9px 12px", border: "0.5px solid #e5e5e5" }}>
          <span style={{ fontSize: 14 }}>🔗</span>
          <span style={{ flex: 1, fontSize: 13, color: "#555", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{saweriaLink}</span>
          <button onClick={handleCopy} style={{ border: "none", background: "none", cursor: "pointer", color: "#534AB7", fontSize: 13, fontWeight: 500, padding: 0 }}>
            {copied ? "✓ Disalin" : "Salin"}
          </button>
        </div>
        <p style={{ fontSize: 11, color: "#aaa", marginTop: 8 }}>Donasi dikirim via Saweria.co. Pastikan username Roblox kamu benar!</p>
      </div>

      {/* Form */}
      <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px" }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 16, textTransform: "uppercase" }}>Simulasi donasi</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <div>
            <label style={{ fontSize: 12, color: "#888", display: "block", marginBottom: 5 }}>Username Roblox</label>
            <input
              value={user} onChange={e => setUser(e.target.value)}
              placeholder="Masukkan username Roblox..."
              style={{ width: "100%", padding: "9px 12px", borderRadius: 8, border: "0.5px solid #ddd", fontSize: 13, outline: "none", fontFamily: "inherit", boxSizing: "border-box" }}
            />
          </div>
          <div>
            <label style={{ fontSize: 12, color: "#888", display: "block", marginBottom: 5 }}>Nominal (Rp)</label>
            <input
              type="number" value={amount} onChange={e => { setAmount(e.target.value); setPreset(null); }}
              placeholder="Minimal Rp 5.000"
              style={{ width: "100%", padding: "9px 12px", borderRadius: 8, border: "0.5px solid #ddd", fontSize: 13, outline: "none", fontFamily: "inherit", boxSizing: "border-box" }}
            />
            <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginTop: 8 }}>
              {PRESET_AMOUNTS.map(p => (
                <button key={p} onClick={() => { setAmount(String(p)); setPreset(p); }}
                  style={{ padding: "5px 14px", borderRadius: 20, border: `0.5px solid ${preset === p ? "#7F77DD" : "#ddd"}`, background: preset === p ? "#EEEDFE" : "#fff", color: preset === p ? "#534AB7" : "#555", fontSize: 12, cursor: "pointer", fontFamily: "inherit" }}>
                  {p >= 1000 ? (p / 1000) + "k" : p}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label style={{ fontSize: 12, color: "#888", display: "block", marginBottom: 5 }}>Pesan (opsional)</label>
            <input
              value={msg} onChange={e => setMsg(e.target.value)}
              placeholder="Tulis pesan..."
              style={{ width: "100%", padding: "9px 12px", borderRadius: 8, border: "0.5px solid #ddd", fontSize: 13, outline: "none", fontFamily: "inherit", boxSizing: "border-box" }}
            />
          </div>
          <button onClick={handleDonate}
            style={{ width: "100%", padding: 12, borderRadius: 8, background: "#534AB7", color: "#fff", border: "none", fontSize: 14, fontWeight: 600, cursor: "pointer", fontFamily: "inherit" }}>
            ❤️ Donasi Sekarang
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Panel: Leaderboard ───────────────────────────────────────────────────────
function PanelLeaderboard({ donors }) {
  const sorted = [...donors].sort((a, b) => b.amount - a.amount);
  const medals = ["🥇", "🥈", "🥉"];
  return (
    <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px" }}>
      <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 14, textTransform: "uppercase" }}>Top Donor bulan ini</div>
      {sorted.map((d, i) => (
        <div key={d.name} style={{ display: "flex", alignItems: "center", padding: "9px 0", borderBottom: i < sorted.length - 1 ? "0.5px solid #f0f0f0" : "none" }}>
          <span style={{ width: 28, fontSize: 16 }}>{medals[i] || `${i + 1}`}</span>
          <div style={{ width: 30, height: 30, borderRadius: "50%", background: "#EEEDFE", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontWeight: 600, color: "#534AB7", marginRight: 10 }}>{d.avatar}</div>
          <span style={{ flex: 1, fontSize: 13, fontWeight: 500 }}>{d.name}</span>
          <span style={{ fontSize: 13, fontWeight: 600, color: "#534AB7" }}>{rupiahFormat(d.amount)}</span>
        </div>
      ))}
    </div>
  );
}

// ─── Panel: Notifikasi ────────────────────────────────────────────────────────
function PanelNotif({ notifs, newCount }) {
  return (
    <div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
        <span style={{ fontSize: 14, fontWeight: 500 }}>Feed donasi real-time</span>
        {newCount > 0 && (
          <span style={{ fontSize: 11, padding: "3px 10px", borderRadius: 20, background: "#EEEDFE", color: "#534AB7", fontWeight: 500 }}>{newCount} baru</span>
        )}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        {notifs.map((n) => (
          <div key={n.id} style={{ display: "flex", alignItems: "flex-start", gap: 10, padding: "10px 14px", borderRadius: 8, background: n.isNew ? "#EEEDFE" : "#f7f7f7", border: "0.5px solid #e5e5e5" }}>
            <span style={{ fontSize: 16, marginTop: 1 }}>❤️</span>
            <div style={{ flex: 1 }}>
              <span style={{ fontSize: 13, lineHeight: 1.5 }}>
                <strong>{n.name}</strong> berdonasi <strong>{rupiahFormat(n.amount)}</strong>
                {n.msg && ` — "${n.msg}"`}
              </span>
              <div style={{ fontSize: 11, color: "#aaa", marginTop: 3 }}>{n.time}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Panel: Pengaturan ────────────────────────────────────────────────────────
function PanelSettings({ settings, onToggle, serverName, setServerName, saweriaLink, setSaweriaLink }) {
  const settingsList = [
    { key: "notifChat", label: "Notifikasi chat server", desc: "Umumkan donasi ke semua pemain" },
    { key: "auraOtomatis", label: "Aura otomatis", desc: "Aktifkan aura donor langsung" },
    { key: "leaderboard", label: "Top donor leaderboard", desc: "Tampilkan papan top donor" },
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
      <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px" }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 14, textTransform: "uppercase" }}>Fitur server</div>
        {settingsList.map((s, i) => (
          <div key={s.key} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 0", borderBottom: i < settingsList.length - 1 ? "0.5px solid #f0f0f0" : "none" }}>
            <div>
              <div style={{ fontSize: 13, fontWeight: 500 }}>{s.label}</div>
              <div style={{ fontSize: 11, color: "#aaa", marginTop: 2 }}>{s.desc}</div>
            </div>
            <Toggle on={settings[s.key]} onChange={() => onToggle(s.key)} />
          </div>
        ))}
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 0" }}>
          <div>
            <div style={{ fontSize: 13, fontWeight: 500 }}>Minimal donasi</div>
            <div style={{ fontSize: 11, color: "#aaa", marginTop: 2 }}>Nominal minimum untuk benefit</div>
          </div>
          <select style={{ padding: "5px 10px", borderRadius: 8, border: "0.5px solid #ddd", fontSize: 12, fontFamily: "inherit" }}>
            <option>Rp 5.000</option>
            <option>Rp 10.000</option>
            <option selected>Rp 15.000</option>
            <option>Rp 25.000</option>
          </select>
        </div>
      </div>

      <div style={{ background: "#fff", border: "0.5px solid #e5e5e5", borderRadius: 12, padding: "16px 20px" }}>
        <div style={{ fontSize: 11, fontWeight: 600, color: "#aaa", letterSpacing: "0.06em", marginBottom: 14, textTransform: "uppercase" }}>Info server</div>
        {[
          { label: "Nama server", value: serverName, onChange: setServerName },
          { label: "Link Saweria", value: saweriaLink, onChange: setSaweriaLink },
        ].map((f, i, arr) => (
          <div key={f.label} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "10px 0", borderBottom: i < arr.length - 1 ? "0.5px solid #f0f0f0" : "none" }}>
            <div style={{ fontSize: 13, fontWeight: 500 }}>{f.label}</div>
            <input
              value={f.value} onChange={e => f.onChange(e.target.value)}
              style={{ width: 180, padding: "6px 10px", borderRadius: 8, border: "0.5px solid #ddd", fontSize: 12, fontFamily: "inherit", outline: "none" }}
            />
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── App utama ────────────────────────────────────────────────────────────────
export default function SaweriaSystem() {
  const [activeTab, setActiveTab] = useState("benefit");
  const [donors, setDonors] = useState(INITIAL_DONORS);
  const [notifs, setNotifs] = useState(INITIAL_NOTIFS);
  const [notifId, setNotifId] = useState(100);
  const [toast, setToast] = useState({ msg: "", visible: false });
  const [serverName, setServerName] = useState("Amora Sector A");
  const [saweriaLink, setSaweriaLink] = useState("linktr.ee/amoraspace99");
  const [settings, setSettings] = useState({ notifChat: true, auraOtomatis: true, leaderboard: true });

  const showToast = (msg) => {
    setToast({ msg, visible: true });
    setTimeout(() => setToast(t => ({ ...t, visible: false })), 2500);
  };

  const handleToggle = (key) => setSettings(s => ({ ...s, [key]: !s[key] }));

  const handleDonate = ({ name, amount, msg }) => {
    // Update leaderboard
    setDonors(prev => {
      const existing = prev.find(d => d.name === name);
      if (existing) {
        return prev.map(d => d.name === name ? { ...d, amount: d.amount + amount } : d);
      }
      return [...prev, { name, amount, avatar: name.slice(0, 2).toUpperCase() }];
    });
    // Add notification
    const newId = notifId + 1;
    setNotifId(newId);
    setNotifs(prev => [{ id: newId, name, amount, msg, time: "baru saja", isNew: true }, ...prev]);
  };

  const stats = {
    totalAmount: donors.reduce((s, d) => s + d.amount, 0),
    weeklyAmount: 120000,
    totalDonors: donors.length,
    todayDonors: 3,
  };

  const newCount = notifs.filter(n => n.isNew).length;

  const panelLabels = {
    benefit: "Benefit Donor",
    donate: "Donasi",
    leaderboard: "Top Donor",
    notif: "Notifikasi",
    settings: "Pengaturan",
  };

  return (
    <div style={{ fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif", background: "#f5f5f5", minHeight: "100vh", padding: 0 }}>
      <div style={{ display: "flex", height: "100vh", overflow: "hidden" }}>

        {/* Sidebar */}
        <div style={{ width: 210, background: "#fff", borderRight: "0.5px solid #e5e5e5", display: "flex", flexDirection: "column", flexShrink: 0 }}>
          <div style={{ padding: "18px 18px 14px", borderBottom: "0.5px solid #e5e5e5" }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: "#1a1a1a" }}>❤️ Amora Space</div>
            <div style={{ fontSize: 11, color: "#aaa", marginTop: 2 }}>Saweria Donation System</div>
          </div>
          <nav style={{ flex: 1, padding: "8px 0" }}>
            {NAV.map(n => (
              <button key={n.id} onClick={() => setActiveTab(n.id)}
                style={{
                  display: "flex", alignItems: "center", gap: 10,
                  padding: "10px 18px", width: "100%", border: "none",
                  background: activeTab === n.id ? "#EEEDFE" : "transparent",
                  color: activeTab === n.id ? "#534AB7" : "#555",
                  fontWeight: activeTab === n.id ? 600 : 400,
                  fontSize: 13, cursor: "pointer", textAlign: "left", fontFamily: "inherit",
                  transition: "background 0.15s",
                }}>
                <span>{n.icon}</span>
                {n.label}
                {n.id === "notif" && newCount > 0 && (
                  <span style={{ marginLeft: "auto", background: "#534AB7", color: "#fff", borderRadius: 10, fontSize: 10, padding: "1px 6px" }}>{newCount}</span>
                )}
              </button>
            ))}
          </nav>
          <div style={{ padding: "12px 18px", borderTop: "0.5px solid #e5e5e5", fontSize: 11, color: "#aaa" }}>
            <span style={{ display: "inline-block", width: 8, height: 8, borderRadius: "50%", background: "#1D9E75", marginRight: 6 }} />
            Server aktif
          </div>
        </div>

        {/* Main */}
        <div style={{ flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" }}>
          {/* Topbar */}
          <div style={{ padding: "13px 24px", background: "#fff", borderBottom: "0.5px solid #e5e5e5", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <span style={{ fontSize: 15, fontWeight: 600 }}>{panelLabels[activeTab]}</span>
            <span style={{ fontSize: 12, color: "#aaa" }}>SUPPORT US — {serverName}</span>
          </div>

          {/* Content */}
          <div style={{ flex: 1, padding: 24, overflowY: "auto", background: "#f5f5f5" }}>
            {activeTab === "benefit" && <PanelBenefit stats={stats} />}
            {activeTab === "donate" && <PanelDonate saweriaLink={saweriaLink} onDonate={handleDonate} showToast={showToast} />}
            {activeTab === "leaderboard" && <PanelLeaderboard donors={donors} />}
            {activeTab === "notif" && <PanelNotif notifs={notifs} newCount={newCount} />}
            {activeTab === "settings" && (
              <PanelSettings
                settings={settings} onToggle={handleToggle}
                serverName={serverName} setServerName={setServerName}
                saweriaLink={saweriaLink} setSaweriaLink={setSaweriaLink}
              />
            )}
          </div>
        </div>
      </div>

      <Toast message={toast.msg} visible={toast.visible} />
    </div>
  );
}
