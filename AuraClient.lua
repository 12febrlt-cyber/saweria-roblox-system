-- ============================================================
--  AuraClient.lua
--  Taruh di: StarterCharacterScripts
--  Fungsi : Tampilkan aura partikel di karakter berdasarkan tier
-- ============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp       = character:WaitForChild("HumanoidRootPart")

local Events    = ReplicatedStorage:WaitForChild("Events")
local AuraEvent = Events:WaitForChild("AuraEvent")

-- ── Konfigurasi tiap tier ─────────────────────────────────
local AURA_CONFIG = {
	legendary = {
		color1       = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 220, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 140, 0)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 60,  0)),
		}),
		lightColor   = Color3.fromRGB(255, 180, 0),
		size         = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 1.4),
			NumberSequenceKeypoint.new(1, 0),
		}),
		rate         = 40,
		speed        = 3,
		spread       = 25,
		rotation     = 180,
		lifetime     = NumberRange.new(1.5, 2.5),
		glowRange    = 14,
		glowBright   = 2.5,
	},
	epic = {
		color1       = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 0, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 0, 200)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(50,  0, 150)),
		}),
		lightColor   = Color3.fromRGB(160, 0, 255),
		size         = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 1.0),
			NumberSequenceKeypoint.new(1, 0),
		}),
		rate         = 28,
		speed        = 2.5,
		spread       = 20,
		rotation     = 120,
		lifetime     = NumberRange.new(1.2, 2.0),
		glowRange    = 10,
		glowBright   = 1.8,
	},
	rare = {
		color1       = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 120, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 80,  180)),
		}),
		lightColor   = Color3.fromRGB(0, 160, 255),
		size         = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.8),
			NumberSequenceKeypoint.new(1, 0),
		}),
		rate         = 18,
		speed        = 2,
		spread       = 15,
		rotation     = 80,
		lifetime     = NumberRange.new(1.0, 1.8),
		glowRange    = 8,
		glowBright   = 1.2,
	},
	common = {
		color1       = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(220, 220, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 180, 220)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(150, 150, 200)),
		}),
		lightColor   = Color3.fromRGB(200, 200, 255),
		size         = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 0),
		}),
		rate         = 10,
		speed        = 1.5,
		spread       = 12,
		rotation     = 50,
		lifetime     = NumberRange.new(0.8, 1.5),
		glowRange    = 5,
		glowBright   = 0.8,
	},
}

-- ── State aura saat ini ───────────────────────────────────
local activeAura = nil   -- folder container aura

-- ── Hapus aura yang ada ───────────────────────────────────
local function removeAura()
	if activeAura and activeAura.Parent then
		-- Fade out partikel
		for _, obj in ipairs(activeAura:GetDescendants()) do
			if obj:IsA("ParticleEmitter") then
				obj.Enabled = false
			end
		end
		task.wait(2)  -- tunggu partikel yang ada habis
		activeAura:Destroy()
		activeAura = nil
	end
end

-- ── Buat aura sesuai tier ─────────────────────────────────
local function applyAura(tier, duration)
	-- Hapus aura lama
	removeAura()

	local cfg = AURA_CONFIG[tier]
	if not cfg then return end

	-- Pastikan HRP masih ada
	if not hrp or not hrp.Parent then return end

	-- Folder container
	local auraFolder = Instance.new("Model")
	auraFolder.Name = "AuraEffect"
	auraFolder.Parent = hrp
	activeAura = auraFolder

	-- ── Partikel utama (spiral ke atas) ──────────────────
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color           = cfg.color1
	emitter.LightEmission   = 0.8
	emitter.LightInfluence  = 0.2
	emitter.Size            = cfg.size
	emitter.Transparency    = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.5),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(0.8, 0.3),
		NumberSequenceKeypoint.new(1,   1),
	})
	emitter.Rate            = cfg.rate
	emitter.Speed           = NumberRange.new(cfg.speed, cfg.speed * 1.5)
	emitter.SpreadAngle     = Vector2.new(cfg.spread, cfg.spread)
	emitter.RotSpeed        = NumberRange.new(-cfg.rotation, cfg.rotation)
	emitter.Rotation        = NumberRange.new(0, 360)
	emitter.Lifetime        = cfg.lifetime
	emitter.VelocityInheritance = 0.2
	emitter.LockedToPart    = false
	emitter.Parent          = hrp

	-- ── Partikel ring di kaki ─────────────────────────────
	local ringAttachment = Instance.new("Attachment")
	ringAttachment.Position = Vector3.new(0, -3, 0)
	ringAttachment.Parent   = hrp

	local ringEmitter = Instance.new("ParticleEmitter")
	ringEmitter.Color         = cfg.color1
	ringEmitter.LightEmission = 1
	ringEmitter.LightInfluence = 0.1
	ringEmitter.Size          = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0),
	})
	ringEmitter.Transparency  = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.6, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	ringEmitter.Rate          = math.floor(cfg.rate * 0.6)
	ringEmitter.Speed         = NumberRange.new(2, 5)
	ringEmitter.SpreadAngle   = Vector2.new(90, 0)
	ringEmitter.RotSpeed      = NumberRange.new(-200, 200)
	ringEmitter.Lifetime      = NumberRange.new(0.5, 1.2)
	ringEmitter.Parent        = ringAttachment

	-- Masukkan attachment ke folder agar bisa dihapus
	ringAttachment.Parent = auraFolder
	emitter.Parent        = auraFolder

	-- ── Point light ───────────────────────────────────────
	local light = Instance.new("PointLight")
	light.Color      = cfg.lightColor
	light.Range      = cfg.glowRange
	light.Brightness = cfg.glowBright
	light.Shadows    = false
	light.Parent     = hrp

	-- Pulse glow
	local function pulseLight()
		while light and light.Parent do
			TweenService:Create(light, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				Brightness = cfg.glowBright * 0.5
			}):Play()
			task.wait(1.6)
		end
	end
	task.spawn(pulseLight)

	-- Masukkan light ke folder
	light.Parent = auraFolder

	-- ── Auto remove setelah durasi ────────────────────────
	if duration and duration > 0 then
		task.delay(duration, function()
			if activeAura == auraFolder then
				removeAura()
				print("[Aura] Aura", tier, "selesai setelah", duration, "detik")
			end
		end)
	end

	print("[Aura] Aura", tier, "aktif selama", duration or "∞", "detik")
end

-- ── Dengarkan event dari server ───────────────────────────
AuraEvent.OnClientEvent:Connect(function(data)
	if data and data.tier then
		applyAura(data.tier, data.duration)
	end
end)

-- ── Bersihkan aura saat karakter respawn ─────────────────
character.AncestryChanged:Connect(function()
	if not character.Parent then
		activeAura = nil
	end
end)

print("[AuraClient] Aura system aktif ✓")
