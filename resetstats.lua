-- resetstats.lua
-- Auto Reset Stats Module

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer

-- Remote Function
local ResetStats = ReplicatedStorage:WaitForChild("ReplicatedModules")
    :WaitForChild("KnitPackage")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("StatService")
    :WaitForChild("RF")
    :WaitForChild("ResetStats")

-- Get current ability ID
local function getCurrentAbilityID()
    local ability = player:WaitForChild("Data"):FindFirstChild("Ability")
    return ability and ability.Value or nil
end

-- Main reset stats function
local function resetStatsLoop()
    if not _G.AutoResetStatsEnabled then return end
    
    local id = getCurrentAbilityID()
    if id then
        pcall(function()
            ResetStats:InvokeServer(id)
        end)
    end
end

-- Connect to heartbeat when enabled
_G.ResetStatsConnection = RunService.Heartbeat:Connect(function()
    resetStatsLoop()
end)

-- Cleanup function
local function cleanup()
    if _G.ResetStatsConnection then
        _G.ResetStatsConnection:Disconnect()
        _G.ResetStatsConnection = nil
    end
end

-- Handle disable
game.Players.PlayerRemoving:Connect(cleanup)

return true