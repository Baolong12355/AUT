local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.ReplicatedModules.KnitPackage.Knit)
local TraitService = Knit.GetService("TraitService")

_G.TraitAutoPickEnabled = _G.TraitAutoPickEnabled or false
_G.TraitList_Legendary = _G.TraitList_Legendary or {}
_G.TraitList_LegendaryHexed = _G.TraitList_LegendaryHexed or {}
_G.TraitList_Mythic = _G.TraitList_Mythic or {}
_G.TraitList_MythicHexed = _G.TraitList_MythicHexed or {}
_G.TraitDiscardHistory = _G.TraitDiscardHistory or {}

local DiscardTraits = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.TraitService.RF.DiscardTraits
local PickTrait = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.TraitService.RF.PickTrait

local function isPreferredTrait(traitName)
    for _, v in ipairs(_G.TraitList_Legendary) do if v == traitName then return true end end
    for _, v in ipairs(_G.TraitList_LegendaryHexed) do if v == traitName then return true end end
    for _, v in ipairs(_G.TraitList_Mythic) do if v == traitName then return true end end
    for _, v in ipairs(_G.TraitList_MythicHexed) do if v == traitName then return true end end
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

-- Kết nối event chỉ một lần
if not getgenv()._TraitAutoPick_Connection then
    getgenv()._TraitAutoPick_Connection = TraitService.TraitHand:Connect(processTraits)
end

-- Hàm public để loader gọi lại khi bật/tắt toggle
function _G.TriggerAutoPickTrait()
    if _G.TraitAutoPickEnabled then
        -- Kiểm tra trait pending và xử lý nếu có
        local traits = getPendingTraitTable()
        if traits then
            processTraits(traits)
        end
    end
end

-- Tự động kiểm tra lần đầu khi script được load
task.spawn(_G.TriggerAutoPickTrait)