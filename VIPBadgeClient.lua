-- ============================================================
--  VIPBadgeClient.lua
--  Taruh di: StarterCharacterScripts
--  Fungsi : Tampilkan badge VIP di atas kepala donor
--           berdasarkan tier donasi mereka
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local head      = character:WaitForChild("Head")

local Events    = ReplicatedStorage:WaitForChild("Events")
local AuraEvent = Events:WaitForChild("AuraEvent")
local BadgeEvent = Events:WaitForChild("BadgeEvent")

-- ── Konfigurasi badge per tier ────────────────────────────
local BADGE_CONFIG = {
	legendary = {
		icon        = "⭐",
		label       = "LEGENDARY DONOR",
		bgColor     = Color3.fromRGB(30, 20, 0),
		borderColor = Color3.fromRGB(255, 195, 0),
		textColor   = Color3.fromRGB(255, 215, 0),
		iconColor   = Color3.fromRGB(255, 220, 50),
		glowColor   = Color3.fromRGB(255, 180, 0),
		frameSize   = UDim2.new(0, 180, 0, 44),
	},
	epic = {
		icon        = "💜",
		label       = "EPIC DONOR",
		bgColor     = Color3.fromRGB(20, 0, 40),
		borderColor = Color3.fromRGB(180, 0, 255),
		textColor   = Color3.fromRGB(200, 120, 255),
		iconColor   = Color3.fromRGB(180, 0, 255),
		glowColor   = Color3.fromRGB(160, 0, 255),
		frameSize   = UDim2.new(0, 160, 0, 44),
	},
	rare = {
		icon        = "💙",
		label       = "RARE DONOR",
		bgColor     = Color3.fromRGB(0, 10, 35),
		borderColor = Color3.fromRGB(30, 144, 255),
		textColor   = Color3.fromRGB(100, 180, 255),
		iconColor   = Color3.fromRGB(30, 144, 255),
		glowColor   = Color3.fromRGB(0, 120, 255),
		frameSize   = UDim2.new(0, 150, 0, 44),
	},
	common = {
		icon        = "🤍",
		label       = "DONOR",
		bgColor     = Color3.fromRGB(15, 15, 25),
		borderColor = Color3.fromRGB(180, 180, 220),
		textColor   = Color3.fromRGB(200, 200, 230),
		iconColor   = Color3.fromRGB(220, 220, 255),
		glowColor   = Color3.fromRGB(180, 180, 255),
		frameSize   = UDim2.new(0, 120, 0, 44),
	},
}

-- ── Hapus badge lama ──────────────────────────────────────
local function removeBadge()
	local old = head:FindFirstChild("VIPBadge")
	if old then old:Destroy() end
end

-- ── Buat badge BillboardGui ───────────────────────────────
local function applyBadge(tier, donorName, totalAmount)
	removeBadge()

	local cfg = BADGE_CONFIG[tier]
	if not cfg then return end

	-- BillboardGui menempel di kepala
	local billboard = Instance.new("BillboardGui")
	billboard.Name            = "VIPBadge"
	billboard.Size            = UDim2.new(0, 200, 0, 80)
	billboard.StudsOffset     = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop     = false
	billboard.MaxDistance     = 60
	billboard.ResetOnSpawn    = false
	billboard.Parent          = head

	-- Frame utama badge
	local frame = Instance.new("Frame")
	frame.Name                = "BadgeFrame"
	frame.Size                = cfg.frameSize
	frame.AnchorPoint         = Vector2.new(0.5, 1)
	frame.Position            = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundColor3    = cfg.bgColor
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel     = 0
	frame.Parent              = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	-- Border stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color     = cfg.borderColor
	stroke.Thickness = 1.5
	stroke.Transparency = 0
	stroke.Parent = frame

	-- Icon
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size               = UDim2.new(0, 28, 1, 0)
	iconLabel.Position           = UDim2.new(0, 6, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text               = cfg.icon
	iconLabel.TextSize           = 18
	iconLabel.Font               = Enum.Font.GothamBold
	iconLabel.TextColor3         = cfg.iconColor
	iconLabel.Parent             = frame

	-- Label tier
	local tierLabel = Instance.new("TextLabel")
	tierLabel.Size               = UDim2.new(1, -40, 0, 18)
	tierLabel.Position           = UDim2.new(0, 36, 0, 4)
	tierLabel.BackgroundTransparency = 1
	tierLabel.Text               = cfg.label
	tierLabel.TextSize           = 10
	tierLabel.Font               = Enum.Font.GothamBold
	tierLabel.TextColor3         = cfg.textColor
	tierLabel.TextXAlignment     = Enum.TextXAlignment.Left
	tierLabel.Parent             = frame

	-- Nama donor
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size               = UDim2.new(1, -40, 0, 16)
	nameLabel.Position           = UDim2.new(0, 36, 0, 22)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text               = donorName or player.Name
	nameLabel.TextSize           = 11
	nameLabel.Font               = Enum.Font.Gotham
	nameLabel.TextColor3         = Color3.fromRGB(220, 220, 220)
	nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
	nameLabel.TextTruncate       = Enum.TextTruncate.AtEnd
	nameLabel.Parent             = frame

	-- Total donasi kecil di bawah nama
	if totalAmount and totalAmount > 0 then
		local amtDisplay = totalAmount >= 1000000
			and string.format("Rp %.1fjt", totalAmount / 1000000)
			or string.format("Rp %dk", math.floor(totalAmount / 1000))

		local amtLabel = Instance.new("TextLabel")
		amtLabel.Size               = UDim2.new(1, -40, 0, 12)
		amtLabel.Position           = UDim2.new(0, 36, 1, -14)
		amtLabel.BackgroundTransparency = 1
		amtLabel.Text               = "Total: " .. amtDisplay
		amtLabel.TextSize           = 9
		amtLabel.Font               = Enum.Font.Gotham
		amtLabel.TextColor3         = cfg.textColor
		amtLabel.TextXAlignment     = Enum.TextXAlignment.Left
		amtLabel.Parent             = frame
	end

	-- ── Animasi pulse border ─────────────────────────────
	task.spawn(function()
		while stroke and stroke.Parent do
			TweenService:Create(stroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0.6
			}):Play()
			task.wait(1)
			TweenService:Create(stroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Transparency = 0
			}):Play()
			task.wait(1)
		end
	end)

	-- ── Animasi masuk (scale dari kecil) ─────────────────
	frame.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = cfg.frameSize
	}):Play()

	print("[VIPBadge] Badge", tier, "dipasang untuk", donorName or player.Name)
end

-- ── Dengarkan event badge dari server ────────────────────
BadgeEvent.OnClientEvent:Connect(function(data)
	if data and data.tier then
		applyBadge(data.tier, data.donorName, data.totalAmount)
	end
end)

-- ── Reset badge saat respawn ──────────────────────────────
character.AncestryChanged:Connect(function()
	-- Badge akan otomatis hilang karena ResetOnSpawn = false
	-- tapi character baru akan re-request dari server
end)

print("[VIPBadge] Badge system aktif ✓")
