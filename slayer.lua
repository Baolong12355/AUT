-- Auto Quest Accept Script (Bật/tắt + chọn nhiều quest)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.ReplicatedModules.KnitPackage.Knit)
local QuestLineService = Knit.GetService("QuestLineService")
local DialogueService = Knit.GetService("DialogueService")

-- Biến bật/tắt và danh sách quest ưu tiên (có thể chỉnh qua GUI/loader)
_G.SlayerQuestEnabled = _G.SlayerQuestEnabled or false
_G.PreferredSlayerQuests = _G.PreferredSlayerQuests or {"Finger Bearer", "Gojo", "Xeno", "Bur", "Dragon knight", "Oni"}

local QUEST_LINE_NAME = "Slayer_Quest"

local function getPlayerAbilityLevel()
    return player.Data.Ability:GetAttribute("AbilityLevel") or 0
end

local function findAndAcceptQuest()
    local questInfo = QuestLineService:GetQuestlineInfo(QUEST_LINE_NAME):expect()
    if not questInfo.Metadata or not questInfo.Metadata.Slayers then return false end

    local playerLevel = getPlayerAbilityLevel()

    -- Skip if already have active quest
    if questInfo.Step and questInfo.Step > 1 then return false end

    -- Duyệt qua danh sách quest user chọn
    for _, questName in ipairs(_G.PreferredSlayerQuests) do
        local slayerInfo = questInfo.Metadata.Slayers[questName]
        if slayerInfo and playerLevel >= slayerInfo.Level then
            local result = DialogueService:CheckDialogue(QUEST_LINE_NAME, questName):expect()
            if result ~= false and type(result) ~= "number" then
                DialogueService:CheckDialogue(QUEST_LINE_NAME, questName):expect()
                return true
            end
        end
    end

    return false
end

spawn(function()
    while true do
        if _G.SlayerQuestEnabled then
            pcall(findAndAcceptQuest)
        end
        task.wait(1)
    end
end)

_G.AcceptQuest = findAndAcceptQuest