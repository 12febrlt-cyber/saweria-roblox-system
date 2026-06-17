-- ============================================================
--  SetupEvents_v2.lua  (UPDATE — ganti SetupEvents lama)
--  Taruh di: ServerScriptService
--  Jalankan PERTAMA sebelum script lain
-- ============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name   = name
	obj.Parent = parent
	return obj
end

local Events = getOrCreate(ReplicatedStorage, "Folder", "Events")

getOrCreate(Events, "RemoteEvent", "DonationEvent")
getOrCreate(Events, "RemoteEvent", "AuraEvent")
getOrCreate(Events, "RemoteEvent", "LeaderboardEvent")
getOrCreate(Events, "RemoteEvent", "BadgeEvent")        -- ← BARU

print("===========================================")
print("  [Setup v2] Semua RemoteEvent siap")
print("  Events/")
print("    ├─ DonationEvent    ✓")
print("    ├─ AuraEvent        ✓")
print("    ├─ LeaderboardEvent ✓")
print("    └─ BadgeEvent       ✓  (VIP Badge)")
print("===========================================")

--[[
  STRUKTUR LENGKAP ROBLOX STUDIO (v2):

  📁 ReplicatedStorage
     └── 📁 Events
           ├── 🔵 DonationEvent
           ├── 🔵 AuraEvent
           ├── 🔵 LeaderboardEvent
           └── 🔵 BadgeEvent           ← BARU

  📁 ServerScriptService
     ├── 📜 SetupEvents_v2.lua         ← jalankan pertama
     └── 📜 DonationServer_v2.lua      ← ganti versi lama

  📁 StarterPlayerScripts
     ├── 📜 DonationNotifClient.lua    ← tidak berubah
     └── 📜 DonationSoundClient.lua    ← BARU (efek suara)

  📁 StarterCharacterScripts
     ├── 📜 AuraClient.lua             ← tidak berubah
     └── 📜 VIPBadgeClient.lua         ← BARU (badge kepala)


  TIER SISTEM — DUA LAPIS:
  ─────────────────────────
  🎯 Tier Aura  (per donasi tunggal):
     common    → Rp 10.000+
     rare      → Rp 25.000+
     epic      → Rp 50.000+
     legendary → Rp 100.000+

  🏅 Tier Badge (total kumulatif semua donasi):
     common    → Total Rp 15.000+
     rare      → Total Rp 75.000+
     epic      → Total Rp 200.000+
     legendary → Total Rp 500.000+

  Donor yang terus berdonasi naik tier badge-nya!
]]
