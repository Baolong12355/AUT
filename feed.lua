-- Feed All Shards Script - Dạng bật/tắt qua _G.FeedShardsEnabled

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local GetAllAbilityShards = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.CraftingService.RF.GetAllAbilityShards
local ConsumeShardsForXP = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.LevelService.RF.ConsumeShardsForXP

_G.FeedShardsEnabled = _G.FeedShardsEnabled or false

local function getCurrentAbilityLevel()
    local label = LocalPlayer.PlayerGui.UI.Menus.Ability.Tabs.Ascensions.AscendSection.Requirements.Level.AmountLabel
    local text = label and label.ContentText or ""
    return tonumber(text:match("%d+"))
end

function _G.FeedAllShards()
    local level = getCurrentAbilityLevel()
    if not level or level >= 200 then return end

    local shards = GetAllAbilityShards:InvokeServer()
    local toFeed = {}
    for id, info in pairs(shards) do
        if info.Shards and info.Shards > 0 then
            toFeed[id] = info.Shards
        end
    end
    if next(toFeed) then
        pcall(function()
            ConsumeShardsForXP:InvokeServer(toFeed)
        end)
    end
end

local lastTick = 0

RunService.Heartbeat:Connect(function(dt)
    lastTick += dt
    if _G.FeedShardsEnabled and lastTick >= 0.25 then
        lastTick = 0
        _G.FeedAllShards()
    end
end)