-- ============================================================
--  DonationServer_v2.lua  (UPDATE dari DonationServer.lua)
--  Taruh di: ServerScriptService  — GANTI file DonationServer lama
--  Perubahan: tambah BadgeEvent untuk VIP badge di kepala
-- ============================================================

local MessagingService  = game:GetService("MessagingService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService  = game:GetService("DataStoreService")

local DonorStore = DataStoreService:GetDataStore("DonorData_v1")

local Events           = ReplicatedStorage:WaitForChild("Events")
local DonationEvent    = Events:WaitForChild("DonationEvent")
local AuraEvent        = Events:WaitForChild("AuraEvent")
local LeaderboardEvent = Events:WaitForChild("LeaderboardEvent")
local BadgeEvent       = Events:WaitForChild("BadgeEvent")   -- ← BARU

local leaderboard = {}

local function formatRupiah(n)
	if n >= 1000000 then return string.format("Rp %.1fjt", n / 1000000)
	elseif n >= 1000 then return string.format("Rp %dk", math.floor(n / 1000))
	end
	return "Rp " .. tostring(n)
end

local function getAuraTier(amount)
	if amount >= 100000 then return "legendary"
	elseif amount >= 50000 then return "epic"
	elseif amount >= 25000 then return "rare"
	elseif amount >= 10000 then return "common"
	else return "none"
	end
end

-- ── Hitung tier berdasarkan total donasi kumulatif ────────
--  (berbeda dari tier per-donasi; ini untuk badge permanen)
local function getBadgeTier(totalAmount)
	if totalAmount >= 500000 then return "legendary"
	elseif totalAmount >= 200000 then return "epic"
	elseif totalAmount >= 75000 then return "rare"
	elseif totalAmount >= 15000 then return "common"
	else return "none"
	end
end

local function loadLeaderboard()
	local ok, data = pcall(function() return DonorStore:GetAsync("Leaderboard") end)
	if ok and data then leaderboard = HttpService:JSONDecode(data) end
	print("[Donation] Leaderboard dimuat:", #leaderboard, "donor")
end

local function saveLeaderboard()
	pcall(function()
		DonorStore:SetAsync("Leaderboard", HttpService:JSONEncode(leaderboard))
	end)
end

local function updateLeaderboard(donorName, amount)
	local totalAmount = amount
	local found = false
	for _, entry in ipairs(leaderboard) do
		if entry.name == donorName then
			entry.amount = entry.amount + amount
			totalAmount = entry.amount
			found = true
			break
		end
	end
	if not found then
		table.insert(leaderboard, {
			name = donorName, amount = amount,
			avatar = string.upper(string.sub(donorName, 1, 2))
		})
	end
	table.sort(leaderboard, function(a, b) return a.amount > b.amount end)
	saveLeaderboard()
	LeaderboardEvent:FireAllClients(leaderboard)
	return totalAmount
end

local function findPlayer(username)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name == username then return p end
	end
	return nil
end

local function processDonation(data)
	local donorName = data.name
	local amount    = tonumber(data.amount) or 0
	local msg       = data.msg or ""
	local tierAura  = getAuraTier(amount)

	print(string.format("[Donation] %s donasi %s", donorName, formatRupiah(amount)))

	-- Update leaderboard & dapat total kumulatif
	local totalAmount = updateLeaderboard(donorName, amount)
	local tierBadge   = getBadgeTier(totalAmount)

	-- Broadcast notifikasi
	DonationEvent:FireAllClients({
		name      = donorName,
		amount    = amount,
		amountStr = formatRupiah(amount),
		msg       = msg,
		tier      = tierAura,
	})

	local player = findPlayer(donorName)

	-- Beri aura (berbasis donasi sekali)
	if tierAura ~= "none" then
		if player then
			AuraEvent:FireClient(player, { tier = tierAura, duration = 300 })
		else
			pcall(function()
				DonorStore:SetAsync("PendingAura_" .. donorName, {
					tier = tierAura, duration = 300,
					expires = os.time() + 86400,
				})
			end)
		end
	end

	-- Beri / update badge (berbasis total kumulatif)
	if tierBadge ~= "none" then
		if player then
			BadgeEvent:FireClient(player, {
				tier        = tierBadge,
				donorName   = donorName,
				totalAmount = totalAmount,
			})
		else
			-- Simpan badge pending
			pcall(function()
				DonorStore:SetAsync("PendingBadge_" .. donorName, {
					tier        = tierBadge,
					totalAmount = totalAmount,
					expires     = os.time() + 604800,  -- 7 hari
				})
			end)
		end
	end
end

-- ── Cek pending aura + badge saat player join ─────────────
Players.PlayerAdded:Connect(function(player)
	-- Pending aura
	local okA, dataA = pcall(function()
		return DonorStore:GetAsync("PendingAura_" .. player.Name)
	end)
	if okA and dataA and os.time() < (dataA.expires or 0) then
		player.CharacterAdded:Wait()
		task.wait(2)
		AuraEvent:FireClient(player, dataA)
		pcall(function() DonorStore:RemoveAsync("PendingAura_" .. player.Name) end)
	end

	-- Pending badge
	local okB, dataB = pcall(function()
		return DonorStore:GetAsync("PendingBadge_" .. player.Name)
	end)
	if okB and dataB and os.time() < (dataB.expires or 0) then
		player.CharacterAdded:Wait()
		task.wait(2.5)
		BadgeEvent:FireClient(player, {
			tier        = dataB.tier,
			donorName   = player.Name,
			totalAmount = dataB.totalAmount,
		})
		pcall(function() DonorStore:RemoveAsync("PendingBadge_" .. player.Name) end)
	end

	-- Kirim leaderboard ke player baru
	task.wait(3)
	LeaderboardEvent:FireClient(player, leaderboard)
end)

local function startListening()
	local ok, err = pcall(function()
		MessagingService:SubscribeAsync("DonationReceived", function(message)
			local ok2, data = pcall(function()
				return HttpService:JSONDecode(message.Data)
			end)
			if ok2 and data then processDonation(data) end
		end)
	end)
	if not ok then warn("[Donation] Gagal subscribe:", err) end
end

loadLeaderboard()
startListening()

print("[Donation] DonationServer v2 aktif ✓  (dengan VIP Badge support)")
