-- Auto Stats Script (nâng cấp: chọn loại và số lượng stats, có thể bật/tắt)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local PathShortcuts = require(ReplicatedStorage.ReplicatedModules.PathShortcuts)
local Knit = require(PathShortcuts.KnitPath.Knit)
local StatService = Knit.GetService("StatService")

-- Cấu hình ngoài (cho GUI/loader set)
_G.AutoStatsEnabled = _G.AutoStatsEnabled or false
_G.AutoStatsType = _G.AutoStatsType or "Attack"     -- "Attack", "Defense", "Health", "Special"
_G.AutoStatsAmount = _G.AutoStatsAmount or 1        -- Số điểm cộng mỗi lần

local function getAbilityId()
    return LocalPlayer.Data.Ability.Value
end

local function getAvailableStats(abilityId)
    local success, result = pcall(function()
        local abilityStats = StatService:GetAbilityStats(abilityId):expect()
        return abilityStats and abilityStats.StatPoints or 0
    end)
    return success and result or 0
end

local function applyStats(abilityId, statType, amount)
    local ApplyStats = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.StatService.RF.ApplyStats
    local statsTable = {
        Special = 0,
        Defense = 0,
        Health  = 0,
        Attack  = 0
    }
    statsTable[statType] = amount
    pcall(function()
        ApplyStats:InvokeServer(abilityId, statsTable)
    end)
end

local function autoStats()
    if not _G.AutoStatsEnabled then return end
    local abilityId = getAbilityId()
    if not abilityId then return end

    local availableStats = getAvailableStats(abilityId)
    if availableStats > 0 then
        local amount = math.min(_G.AutoStatsAmount or 1, availableStats)
        applyStats(abilityId, _G.AutoStatsType or "Attack", amount)
        task.wait(0.1)
    end
end

spawn(function()
    Knit.OnStart():await()
    while true do
        task.wait(1)
        pcall(autoStats)
    end
end)