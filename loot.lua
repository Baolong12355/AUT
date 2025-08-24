-- Auto Loot Script - Sửa: Nếu đang nhặt chest mà bị chiết thì ĐỢI hồi sinh rồi tiếp tục nhặt

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
    local pa = chest:FindFirstChild("ProximityAttachment")
    local prompt = pa and pa:FindFirstChild("Interaction")
    if not prompt then return end

    _G.LootCollecting = true
    local targetPos = chest.Position + Vector3.new(0, 4, 0)

    while prompt:IsDescendantOf(game) and _G.LootEnabled do
        local root
        -- Nếu bị chiết thì đợi hồi sinh
        while true do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                root = char.HumanoidRootPart
                break
            end
            LocalPlayer.CharacterAdded:Wait()
        end

        root.CFrame = CFrame.new(targetPos)
        fireproximityprompt(prompt)
        task.wait(0.1)
    end

    _G.LootCollecting = false
end

spawn(function()
    while true do
        task.wait(0.1)
        if _G.LootEnabled and not _G.LootCollecting then
            for _, chest in ipairs(workspace:GetDescendants()) do
                if isValidChest(chest) then
                    collectChest(chest)
                    task.wait(0.1)
                end
            end
        end
    end
end)

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