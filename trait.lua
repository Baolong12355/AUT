-- Auto Trait Selector: pick ưu tiên, lưu 5 trait đã discard gần nhất

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.ReplicatedModules.KnitPackage.Knit)
local TraitService = Knit.GetService("TraitService")

_G.TraitAutoPickEnabled = _G.TraitAutoPickEnabled or false

_G.TraitList_Legendary = _G.TraitList_Legendary or {
    "Prime","Angelic","Solar","Cursed","Vampiric","Gluttonous","Voided",
    "Gambler","Overflowing","Deferred","True","Cultivation","Economic"
}
_G.TraitList_LegendaryHexed = _G.TraitList_LegendaryHexed or {
    "Overconfident Prime","Fallen Angelic","Icarus Solar","Undying Cursed","Ancient Vampiric",
    "Festering Gluttonous","Abyssal Voided","Idle Death Gambler","Torrential Overflowing",
    "Fractured Deferred","Vitriolic True","Soul Reaping Cultivation","Greedy Economic"
}
_G.TraitList_Mythic = _G.TraitList_Mythic or {
    "Godly","Temporal","RCT","Spiritual","Ryoiki","Adaptation"
}
_G.TraitList_MythicHexed = _G.TraitList_MythicHexed or {
    "Egotistic Godly","FTL Temporal","Automatic RCT","Mastered Spiritual","Overcharged Ryoiki","Unbound Adaptation"
}

_G.TraitDiscardHistory = _G.TraitDiscardHistory or {}

local DiscardTraits = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.TraitService.RF.DiscardTraits
local PickTrait = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.TraitService.RF.PickTrait

local function isPreferredTrait(traitName)
    for _, v in ipairs(_G.TraitList_Legendary or {}) do if v == traitName then return true end end
    for _, v in ipairs(_G.TraitList_LegendaryHexed or {}) do if v == traitName then return true end end
    for _, v in ipairs(_G.TraitList_Mythic or {}) do if v == traitName then return true end end
    for _, v in ipairs(_G.TraitList_MythicHexed or {}) do if v == traitName then return true end end
    return false
end

local function recordDiscarded(traits)
    if not traits or #traits == 0 then return end
    local traitNames = {}
    for _, trait in ipairs(traits) do
        table.insert(traitNames, trait.Trait)
    end
    table.insert(_G.TraitDiscardHistory, 1, table.concat(traitNames, " | "))
    if #_G.TraitDiscardHistory > 5 then
        table.remove(_G.TraitDiscardHistory, 6)
    end
end

local function processTraits(traits)
    if not _G.TraitAutoPickEnabled then return end
    if not traits or #traits == 0 then return end

    local selectedIndex = nil
    for i, trait in ipairs(traits) do
        if isPreferredTrait(trait.Trait) then
            selectedIndex = i
            break
        end
    end

    task.wait(0.5)
    if selectedIndex then
        PickTrait:InvokeServer(selectedIndex)
    else
        recordDiscarded(traits)
        DiscardTraits:InvokeServer()
    end
end

-- Tìm trait pending ngay khi load
local function getPendingTraitTable()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and #v > 0 and type(v[1]) == "table" then
            local success, traitName = pcall(function() return v[1].Trait end)
            if success and traitName ~= nil then
                return v
            end
        end
    end
    return nil
end

spawn(function()
    task.wait(0.2)
    local traits = getPendingTraitTable()
    if traits then
        processTraits(traits)
    end
end)

TraitService.TraitHand:Connect(processTraits)