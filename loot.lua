-- Auto Loot Script - Integrated with Combat System (delay check mỗi 0.1 giây)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.LootEnabled = _G.LootEnabled or false
_G.LootCollecting = _G.LootCollecting or false

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

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

local function isValidChest(chest)
    if not chest:IsA("BasePart") then return false end
    if not chest.Name:lower():find("chest") then return false end
    local pa = chest:FindFirstChild("ProximityAttachment")
    if not pa then return false end
    local prompt = pa:FindFirstChild("Interaction")
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    if not isWhitelisted(chest) then return false end
    return true
end

local function collectChest(chest)
    local prompt = chest:FindFirstChild("ProximityAttachment"):FindFirstChild("Interaction")
    if not prompt then return end

    local root = getRoot()
    local targetPos = chest.Position + Vector3.new(0, 4, 0)
    
    -- Set collecting state
    _G.LootCollecting = true

    fireproximityprompt(prompt)

    while prompt:IsDescendantOf(game) and _G.LootEnabled do
        root.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
    end
    
    -- Reset collecting state
    _G.LootCollecting = false
end

-- Standalone loot function (for when combat is disabled)
spawn(function()
    while true do
        task.wait(0.1) -- Delay mỗi lần check chest là 0.1 giây
        -- Only run standalone loot if combat is disabled or loot is specifically enabled
        if _G.LootEnabled and not _G.CombatEnabled and not _G.LootCollecting then
            for _, chest in ipairs(workspace:GetDescendants()) do
                if isValidChest(chest) then
                    collectChest(chest)
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- Manual trigger function for combat integration
_G.TriggerLootCollection = function()
    if not _G.LootEnabled or _G.LootCollecting then return false end
    
    local chestsFound = false
    for _, chest in ipairs(workspace:GetDescendants()) do
        if isValidChest(chest) then
            chestsFound = true
            collectChest(chest)
        end
    end
    return chestsFound
end