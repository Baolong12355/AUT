-- Auto Loot Script - Nhặt TẤT CẢ chest mỗi lần, TP bằng Heartbeat tới từng chest (ưu tiên đúng GUI)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

_G.LootEnabled = _G.LootEnabled or false
_G.LootCollecting = _G.LootCollecting or false

-- Lấy root của player
local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Kiểm tra chest có đúng whitelist không
local function isWhitelisted(chest)
    local whitelist = chest:FindFirstChild("Whitelisted")
    if not whitelist or not whitelist:IsA("Folder") then return false end
    for _, v in ipairs(whitelist:GetChildren()) do
        if tonumber(v.Name) == LocalPlayer.UserId then
            return true
        end
    end
    return false
end

-- Kiểm tra chest hợp lệ
local function isValidChest(chest)
    if not chest:IsA("BasePart") then return false end
    if not chest.Name:lower():find("chest") then return false end
    local pa = chest:FindFirstChild("ProximityAttachment")
    if not pa then return false end
    local prompt = pa:FindFirstChild("Interaction")
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    if not isWhitelisted(chest) then return false end
    return prompt.Enabled
end

-- TP tới vị trí chest và nhặt
local function tpAndCollectChest(chest)
    local prompt = chest:FindFirstChild("ProximityAttachment") and chest.ProximityAttachment:FindFirstChild("Interaction")
    if not prompt then return end
    local root = getRoot()
    local targetPos = chest.Position + Vector3.new(0, 4, 0)
    root.CFrame = CFrame.new(targetPos)
    fireproximityprompt(prompt)
    -- Giữ vị trí cho đến khi nhặt xong hoặc chest biến mất
    while prompt:IsDescendantOf(game) and prompt.Enabled and _G.LootEnabled do
        root.CFrame = CFrame.new(targetPos)
        fireproximityprompt(prompt)
        RunService.Heartbeat:Wait()
    end
end

-- Lấy danh sách toàn bộ chest hợp lệ
local function getAllValidChests()
    local chests = {}
    for _, chest in ipairs(workspace:GetDescendants()) do
        if isValidChest(chest) then
            table.insert(chests, chest)
        end
    end
    return chests
end

-- Main heartbeat loop: TP liên tục tới từng chest và nhặt TẤT CẢ (không bỏ sót)
local active = false
local heartbeatConn = nil
local currentChestIdx = 1
local chestList = {}

local function startLootHeartbeat()
    if heartbeatConn then heartbeatConn:Disconnect() end
    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not _G.LootEnabled or _G.LootCollecting then return end
        _G.LootCollecting = true

        -- Nếu hết list hoặc vừa bật lại, reload danh sách chest
        if #chestList == 0 or currentChestIdx > #chestList then
            chestList = getAllValidChests()
            currentChestIdx = 1
            -- Nếu không có chest thì dừng
            if #chestList == 0 then
                _G.LootCollecting = false
                return
            end
        end

        -- TP tới chest hiện tại và nhặt
        local chest = chestList[currentChestIdx]
        if chest and isValidChest(chest) then
            tpAndCollectChest(chest)
        end
        currentChestIdx = currentChestIdx + 1
        -- Nếu đã hết, sẽ reload ở frame sau
        _G.LootCollecting = false
    end)
end

local function stopLootHeartbeat()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    _G.LootCollecting = false
end

-- Theo dõi bật/tắt loot
spawn(function()
    while true do
        if _G.LootEnabled then
            if not heartbeatConn then
                startLootHeartbeat()
            end
        else
            stopLootHeartbeat()
        end
        wait(0.25)
    end
end)

-- Manual trigger để gọi từ ngoài
_G.TriggerLootCollection = function()
    if not _G.LootEnabled or _G.LootCollecting then return false end
    chestList = getAllValidChests()
    currentChestIdx = 1
    return #chestList > 0
end