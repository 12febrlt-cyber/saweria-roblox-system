-- ============================================================
--  DonationNotifClient.lua
--  Taruh di: StarterPlayerScripts  (atau StarterGui)
--  Fungsi : Tampilkan popup notifikasi saat ada donasi masuk
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ── RemoteEvents ────────────────────────────────────────────
local Events        = ReplicatedStorage:WaitForChild("Events")
local DonationEvent = Events:WaitForChild("DonationEvent")
local LeaderboardEvent = Events:WaitForChild("LeaderboardEvent")

-- ── Warna per tier ───────────────────────────────────────────
local TIER_COLOR = {
	legendary = Color3.fromRGB(255, 195, 0),   -- emas
	epic      = Color3.fromRGB(138, 43, 226),  -- ungu
	rare      = Color3.fromRGB(30, 144, 255),  -- biru
	common    = Color3.fromRGB(200, 200, 200), -- putih
	none      = Color3.fromRGB(100, 200, 120), -- hijau default
}

local TIER_LABEL = {
	legendary = "⭐ LEGENDARY DONOR",
	epic      = "💜 EPIC DONOR",
	rare      = "💙 RARE DONOR",
	common    = "🤍 DONOR",
	none      = "❤️ DONOR",
}

-- ── Buat ScreenGui utama ─────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name             = "DonationUI"
screenGui.ResetOnSpawn     = false
screenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
screenGui.Parent           = playerGui

-- ── Container notifikasi (tumpuk dari bawah) ─────────────────
local notifContainer = Instance.new("Frame")
notifContainer.Name            = "NotifContainer"
notifContainer.Size            = UDim2.new(0, 340, 1, 0)
notifContainer.Position        = UDim2.new(1, -360, 0, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent          = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder       = Enum.SortOrder.LayoutOrder
listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listLayout.Padding         = UDim.new(0, 8)
listLayout.Parent          = notifContainer

-- ── Buat satu kartu notifikasi ───────────────────────────────
local function createNotifCard(data)
	local color = TIER_COLOR[data.tier] or TIER_COLOR["none"]
	local label = TIER_LABEL[data.tier] or TIER_LABEL["none"]

	-- Frame kartu
	local card = Instance.new("Frame")
	card.Name              = "NotifCard"
	card.Size              = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3  = Color3.fromRGB(15, 15, 20)
	card.BackgroundTransparency = 0.1
	card.BorderSizePixel   = 0
	card.LayoutOrder       = tick()
	card.Parent            = notifContainer

	-- Rounded corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	-- Garis aksen kiri berwarna tier
	local accent = Instance.new("Frame")
	accent.Name             = "Accent"
	accent.Size             = UDim2.new(0, 4, 1, 0)
	accent.Position         = UDim2.new(0, 0, 0, 0)
	accent.BackgroundColor3 = color
	accent.BorderSizePixel  = 0
	accent.Parent           = card
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 4)
	accentCorner.Parent = accent

	-- Label tier
	local tierLabel = Instance.new("TextLabel")
	tierLabel.Name              = "TierLabel"
	tierLabel.Size              = UDim2.new(1, -20, 0, 18)
	tierLabel.Position          = UDim2.new(0, 14, 0, 8)
	tierLabel.BackgroundTransparency = 1
	tierLabel.Text              = label
	tierLabel.TextColor3        = color
	tierLabel.TextSize          = 11
	tierLabel.Font              = Enum.Font.GothamBold
	tierLabel.TextXAlignment    = Enum.TextXAlignment.Left
	tierLabel.Parent            = card

	-- Nama donor
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name              = "NameLabel"
	nameLabel.Size              = UDim2.new(1, -20, 0, 22)
	nameLabel.Position          = UDim2.new(0, 14, 0, 26)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text              = data.name .. " berdonasi " .. data.amountStr
	nameLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize          = 14
	nameLabel.Font              = Enum.Font.GothamBold
	nameLabel.TextXAlignment    = Enum.TextXAlignment.Left
	nameLabel.Parent            = card

	-- Pesan (jika ada)
	if data.msg and data.msg ~= "" then
		local msgLabel = Instance.new("TextLabel")
		msgLabel.Name              = "MsgLabel"
		msgLabel.Size              = UDim2.new(1, -20, 0, 18)
		msgLabel.Position          = UDim2.new(0, 14, 0, 50)
		msgLabel.BackgroundTransparency = 1
		msgLabel.Text              = "\"" .. data.msg .. "\""
		msgLabel.TextColor3        = Color3.fromRGB(180, 180, 180)
		msgLabel.TextSize          = 12
		msgLabel.Font              = Enum.Font.Gotham
		msgLabel.TextXAlignment    = Enum.TextXAlignment.Left
		msgLabel.TextTruncate      = Enum.TextTruncate.AtEnd
		msgLabel.Parent            = card
	end

	-- Progress bar (timer hilang)
	local progressBg = Instance.new("Frame")
	progressBg.Name             = "ProgressBg"
	progressBg.Size             = UDim2.new(1, -14, 0, 2)
	progressBg.Position         = UDim2.new(0, 14, 1, -6)
	progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	progressBg.BorderSizePixel  = 0
	progressBg.Parent           = card
	local pgCorner = Instance.new("UICorner")
	pgCorner.CornerRadius = UDim.new(0, 2)
	pgCorner.Parent = progressBg

	local progressBar = Instance.new("Frame")
	progressBar.Name             = "ProgressBar"
	progressBar.Size             = UDim2.new(1, 0, 1, 0)
	progressBar.BackgroundColor3 = color
	progressBar.BorderSizePixel  = 0
	progressBar.Parent           = progressBg
	local pbCorner = Instance.new("UICorner")
	pbCorner.CornerRadius = UDim.new(0, 2)
	pbCorner.Parent = progressBar

	-- Animasi masuk (slide dari kanan)
	card.Position = UDim2.new(1, 20, 0, 0)
	card.AnchorPoint = Vector2.new(0, 0)
	-- (posisi dikelola UIListLayout, jadi kita pakai transparansi)
	card.BackgroundTransparency = 1
	for _, obj in ipairs(card:GetDescendants()) do
		if obj:IsA("TextLabel") then obj.TextTransparency = 1 end
		if obj:IsA("Frame") and obj.Name ~= "NotifCard" then obj.BackgroundTransparency = 1 end
	end

	-- Fade in
	local fadeIn = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1})
	fadeIn:Play()
	for _, obj in ipairs(card:GetDescendants()) do
		if obj:IsA("TextLabel") then
			TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
		end
		if obj:IsA("Frame") and obj ~= card and obj.Name ~= "Accent" and obj.Name ~= "ProgressBg" and obj.Name ~= "ProgressBar" then
			TweenService:Create(obj, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
		end
	end

	-- Progress bar mengecil selama 6 detik
	local shrink = TweenService:Create(progressBar, TweenInfo.new(6, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
	shrink:Play()

	-- Fade out dan destroy setelah 6 detik
	task.delay(6, function()
		local fadeOut = TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
		fadeOut:Play()
		for _, obj in ipairs(card:GetDescendants()) do
			if obj:IsA("TextLabel") then
				TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
			end
		end
		task.wait(0.4)
		card:Destroy()
	end)

	return card
end

-- ── Leaderboard GUI di sisi kiri ─────────────────────────────
local lbFrame = Instance.new("Frame")
lbFrame.Name              = "LeaderboardFrame"
lbFrame.Size              = UDim2.new(0, 220, 0, 300)
lbFrame.Position          = UDim2.new(0, 16, 0.5, -150)
lbFrame.BackgroundColor3  = Color3.fromRGB(10, 10, 15)
lbFrame.BackgroundTransparency = 0.2
lbFrame.BorderSizePixel   = 0
lbFrame.Parent            = screenGui

local lbCorner = Instance.new("UICorner")
lbCorner.CornerRadius = UDim.new(0, 12)
lbCorner.Parent = lbFrame

-- Header leaderboard
local lbTitle = Instance.new("TextLabel")
lbTitle.Size             = UDim2.new(1, 0, 0, 36)
lbTitle.BackgroundTransparency = 1
lbTitle.Text             = "🏆  TOP DONOR"
lbTitle.TextColor3       = Color3.fromRGB(255, 195, 0)
lbTitle.TextSize         = 13
lbTitle.Font             = Enum.Font.GothamBold
lbTitle.Parent           = lbFrame

-- Scroll untuk list donor
local lbScroll = Instance.new("ScrollingFrame")
lbScroll.Name                  = "LbScroll"
lbScroll.Size                  = UDim2.new(1, 0, 1, -36)
lbScroll.Position              = UDim2.new(0, 0, 0, 36)
lbScroll.BackgroundTransparency = 1
lbScroll.BorderSizePixel       = 0
lbScroll.ScrollBarThickness    = 0
lbScroll.Parent                = lbFrame

local lbList = Instance.new("UIListLayout")
lbList.SortOrder  = Enum.SortOrder.LayoutOrder
lbList.Padding    = UDim.new(0, 0)
lbList.Parent     = lbScroll

local MEDALS = {"🥇","🥈","🥉"}

local function updateLeaderboardUI(data)
	-- Hapus baris lama
	for _, child in ipairs(lbScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for i, entry in ipairs(data) do
		if i > 7 then break end

		local row = Instance.new("Frame")
		row.Name             = "Row" .. i
		row.Size             = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(20, 20, 28) or Color3.fromRGB(15, 15, 20)
		row.BackgroundTransparency = 0.3
		row.BorderSizePixel  = 0
		row.LayoutOrder      = i
		row.Parent           = lbScroll

		-- Rank/medal
		local rankLbl = Instance.new("TextLabel")
		rankLbl.Size             = UDim2.new(0, 30, 1, 0)
		rankLbl.Position         = UDim2.new(0, 6, 0, 0)
		rankLbl.BackgroundTransparency = 1
		rankLbl.Text             = MEDALS[i] or tostring(i)
		rankLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
		rankLbl.TextSize         = 13
		rankLbl.Font             = Enum.Font.GothamBold
		rankLbl.Parent           = row

		-- Nama
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size             = UDim2.new(0, 110, 1, 0)
		nameLbl.Position         = UDim2.new(0, 38, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text             = entry.name
		nameLbl.TextColor3       = Color3.fromRGB(220, 220, 220)
		nameLbl.TextSize         = 11
		nameLbl.Font             = Enum.Font.Gotham
		nameLbl.TextXAlignment   = Enum.TextXAlignment.Left
		nameLbl.TextTruncate     = Enum.TextTruncate.AtEnd
		nameLbl.Parent           = row

		-- Jumlah
		local amtLbl = Instance.new("TextLabel")
		amtLbl.Size             = UDim2.new(0, 70, 1, 0)
		amtLbl.Position         = UDim2.new(1, -74, 0, 0)
		amtLbl.BackgroundTransparency = 1
		local amt = entry.amount
		local display = amt >= 1000000 and string.format("%.1fjt", amt/1000000)
			or amt >= 1000 and string.format("%dk", math.floor(amt/1000))
			or tostring(amt)
		amtLbl.Text             = "Rp " .. display
		amtLbl.TextColor3       = Color3.fromRGB(255, 195, 0)
		amtLbl.TextSize         = 11
		amtLbl.Font             = Enum.Font.GothamBold
		amtLbl.TextXAlignment   = Enum.TextXAlignment.Right
		amtLbl.Parent           = row
	end

	lbScroll.CanvasSize = UDim2.new(0, 0, 0, lbList.AbsoluteContentSize.Y)
end

-- ── Event listeners ──────────────────────────────────────────
DonationEvent.OnClientEvent:Connect(function(data)
	createNotifCard(data)
end)

LeaderboardEvent.OnClientEvent:Connect(function(data)
	updateLeaderboardUI(data)
end)

print("[DonationUI] Client UI aktif ✓")
