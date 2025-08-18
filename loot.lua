local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local function isPlayerWhitelisted(chest)
    local whitelisted = chest:FindFirstChild("Whitelisted")
    if not whitelisted then
        return false
    end
    
    local children = whitelisted:GetChildren()
    for _, child in pairs(children) do
        if child.Name == tostring(player.UserId) then
            return true
        end
    end
    return false
end

local function hasProximityInteraction(chest)
    local proximityAttachment = chest:FindFirstChild("ProximityAttachment")
    if not proximityAttachment then
        return false
    end
    
    local interaction = proximityAttachment:FindFirstChild("Interaction")
    return interaction ~= nil
end

local function teleportToChest(chest)
    if chest and chest:FindFirstChild("ProximityAttachment") then
        local proximityPos = chest.ProximityAttachment.WorldPosition
        humanoidRootPart.CFrame = CFrame.new(proximityPos + Vector3.new(0, 5, 0))
        wait(0.1)
        
        local proximityAttachment = chest:FindFirstChild("ProximityAttachment")
        if proximityAttachment and proximityAttachment:FindFirstChild("Interaction") then
            local interaction = proximityAttachment.Interaction
            if interaction:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(interaction.ProximityPrompt)
            end
        end
    end
end

local function local function startContinuousScanning()
    while true do
        findAndProcessChests()
        wait(1)
    end
end

startContinuousScanning()
    for _, obj in pairs(workspace:GetDescendants()) do
        if string.find(obj.Name, "Chest") then
            if hasProximityInteraction(obj) and isPlayerWhitelisted(obj) then
                teleportToChest(obj)
            end
        end
    end
end

findAndProcessChests()
