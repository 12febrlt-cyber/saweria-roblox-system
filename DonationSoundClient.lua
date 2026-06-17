-- ============================================================
--  DonationSoundClient.lua
--  Taruh di: StarterPlayerScripts
--  Fungsi : Mainkan efek suara saat donasi masuk
--           Tier berbeda = suara berbeda
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService      = game:GetService("SoundService")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local DonationEvent = Events:WaitForChild("DonationEvent")

-- ── Sound IDs per tier ────────────────────────────────────
--  Semua ID di bawah adalah sound gratis dari Roblox Library
--  Ganti dengan sound ID pilihanmu jika perlu
local SOUND_CONFIG = {
	legendary = {
		-- Fanfare / trumpet emas
		ids      = { 9125402735, 9125402735 },  -- ganti dengan ID pilihanmu
		volume   = 1.0,
		pitch    = 1.1,
		-- Suara bonus: coin shower
		bonus    = 9125402900,
	},
	epic = {
		-- Magic chime ungu
		ids      = { 9125402735 },
		volume   = 0.85,
		pitch    = 1.0,
		bonus    = nil,
	},
	rare = {
		-- Bell biru
		ids      = { 9125402735 },
		volume   = 0.75,
		pitch    = 0.95,
		bonus    = nil,
	},
	common = {
		-- Ding sederhana
		ids      = { 9125402735 },
		volume   = 0.6,
		pitch    = 0.9,
		bonus    = nil,
	},
	default = {
		ids      = { 9125402735 },
		volume   = 0.5,
		pitch    = 1.0,
		bonus    = nil,
	},
}

--[[
  ── CARA GANTI SOUND ID ────────────────────────────────────
  1. Buka Roblox Studio → Toolbox → Audio
  2. Cari sound yang kamu suka (contoh: "coin", "fanfare", "chime")
  3. Klik kanan → Copy Asset ID
  4. Paste ID-nya ke konfigurasi di atas

  Contoh sound gratis populer di Roblox:
  - Coin collect  : 4590662766
  - Level up bell : 4917641735
  - Magic sparkle : 6518811702
  - Fanfare short : 3539888138
  - Ding positive : 4337543902
]]

-- ── Container suara di SoundService ──────────────────────
local soundFolder = Instance.new("Folder")
soundFolder.Name   = "DonationSounds"
soundFolder.Parent = SoundService

-- ── Cache sound objects ───────────────────────────────────
local soundCache = {}

local function getSound(id, volume, pitch)
	local key = tostring(id)
	if soundCache[key] then
		soundCache[key].Volume    = volume
		soundCache[key].PlaybackSpeed = pitch
		return soundCache[key]
	end
	local s = Instance.new("Sound")
	s.SoundId      = "rbxassetid://" .. tostring(id)
	s.Volume       = volume
	s.PlaybackSpeed = pitch
	s.RollOffMaxDistance = 0   -- suara 2D, tidak terpengaruh jarak
	s.Parent       = soundFolder
	soundCache[key] = s
	return s
end

-- ── Mainkan suara ─────────────────────────────────────────
local function playDonationSound(tier)
	local cfg = SOUND_CONFIG[tier] or SOUND_CONFIG["default"]

	-- Pilih sound ID acak dari daftar
	local id = cfg.ids[math.random(1, #cfg.ids)]
	local sound = getSound(id, cfg.volume, cfg.pitch)

	-- Stop jika masih main, lalu play ulang
	sound:Stop()
	sound:Play()

	-- Suara bonus untuk legendary
	if cfg.bonus then
		task.delay(0.3, function()
			local bonusSound = getSound(cfg.bonus, cfg.volume * 0.7, cfg.pitch)
			bonusSound:Stop()
			bonusSound:Play()
		end)
	end
end

-- ── Efek suara khusus: coin rain untuk legendary ──────────
local function playCoinRain(count)
	count = count or 5
	for i = 1, count do
		task.delay(i * 0.08, function()
			local s = Instance.new("Sound")
			s.SoundId      = "rbxassetid://4590662766"  -- coin sound
			s.Volume       = 0.3 + (math.random() * 0.3)
			s.PlaybackSpeed = 0.9 + (math.random() * 0.3)
			s.Parent       = soundFolder
			s:Play()
			game:GetService("Debris"):AddItem(s, 3)
		end)
	end
end

-- ── Efek suara ambient: loop pelan saat aura aktif ────────
local ambientSound = nil

local function startAmbientLoop(tier)
	-- Stop ambient sebelumnya
	if ambientSound then
		ambientSound:Stop()
		ambientSound:Destroy()
		ambientSound = nil
	end

	if tier == "legendary" or tier == "epic" then
		local s = Instance.new("Sound")
		-- Ambient magical hum (ganti ID sesuai selera)
		s.SoundId      = "rbxassetid://1843671275"
		s.Volume       = 0.08
		s.PlaybackSpeed = tier == "legendary" and 1.0 or 0.85
		s.Looped       = true
		s.Parent       = soundFolder
		s:Play()
		ambientSound = s
	end
end

local function stopAmbientLoop()
	if ambientSound then
		-- Fade out ambient
		TweenService:Create(ambientSound, TweenInfo.new(2), {Volume = 0}):Play()
		task.delay(2.1, function()
			if ambientSound then
				ambientSound:Stop()
				ambientSound:Destroy()
				ambientSound = nil
			end
		end)
	end
end

-- ── Dengarkan event donasi ────────────────────────────────
DonationEvent.OnClientEvent:Connect(function(data)
	local tier = data.tier or "default"

	-- Main suara utama
	playDonationSound(tier)

	-- Coin rain untuk legendary
	if tier == "legendary" then
		task.delay(0.5, function()
			playCoinRain(8)
		end)
	end

	-- Ambient loop untuk donor sendiri (hanya jika donor = player ini)
	if data.name == player.Name then
		startAmbientLoop(tier)
		-- Stop ambient setelah durasi aura
		task.delay(300, stopAmbientLoop)
	end

	print("[Sound] Suara", tier, "dimainkan untuk donasi dari", data.name)
end)

-- ── Suara notifikasi ringan saat leaderboard update ───────
local LeaderboardEvent = Events:WaitForChild("LeaderboardEvent")
LeaderboardEvent.OnClientEvent:Connect(function()
	-- Ding kecil saat leaderboard refresh
	local s = Instance.new("Sound")
	s.SoundId      = "rbxassetid://4337543902"  -- soft ding
	s.Volume       = 0.15
	s.PlaybackSpeed = 1.2
	s.Parent       = soundFolder
	s:Play()
	game:GetService("Debris"):AddItem(s, 3)
end)

print("[DonationSound] Sound system aktif ✓")
