local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId

_G.LootEnabled = _G.LootEnabled or false

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function isWhitelisted(chest)
    local whitelist = chest:FindFirstChild("Whitelisted")
    if not whitelist or not whitelist:IsA("Folder") then return false end
    for _, v in ipairs(whitelist:GetChildren()) do
        if tonumber(v.Name) == UserId then
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

local function loopTPandOpen(chest)
    local prompt = chest:FindFirstChild("ProximityAttachment"):FindFirstChild("Interaction")
    if not prompt then return end

    local root = getRoot()
    local targetPos = chest.Position + Vector3.new(0, 4, 0)

    fireproximityprompt(prompt)

    while prompt:IsDescendantOf(game) do
        root.CFrame = CFrame.new(targetPos)
        task.wait()
    end
end

spawn(function()
    while true do
        task.wait(1)
        if _G.LootEnabled then
            for _, chest in ipairs(workspace:GetDescendants()) do
                if isValidChest(chest) then
                    loopTPandOpen(chest)
                    task.wait(0.1)
                end
            end
        end
    end
end)