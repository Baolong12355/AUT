-- Auto Special Grade Quest - Bật/tắt, dừng khi auto save đang hoạt động
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GetQuests = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.AdventureService.RF.GetQuests
local CheckDialogue = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.DialogueService.RF.CheckDialogue

-- Biến điều khiển từ loader
_G.SpecialGradeQuestEnabled = _G.SpecialGradeQuestEnabled or false
_G.SpecialGradeQuestDelay = _G.SpecialGradeQuestDelay or 60 -- Delay giữa mỗi lần check (giây)
_G.ItemAutoSaving = _G.ItemAutoSaving or false -- Shared với autosave script

local function resetCharacter()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end

local function checkAndDoSpecialGradeQuest()
    if not _G.SpecialGradeQuestEnabled then return end
    if _G.ItemAutoSaving then return end -- Dừng khi auto save đang hoạt động
    
    local success, quests = pcall(function()
        return GetQuests:InvokeServer()
    end)
    
    if not success or not quests or typeof(quests) ~= "table" then return end
    
    if quests["Special_Grade_Adventure"] then
        local dialogueSuccess = pcall(function()
            CheckDialogue:InvokeServer("Special_Grade_Adventure")
        end)
        
        if dialogueSuccess then
            resetCharacter()
        end
    end
end

-- Loop chính
spawn(function()
    while true do
        if _G.SpecialGradeQuestEnabled and not _G.ItemAutoSaving then
            checkAndDoSpecialGradeQuest()
            task.wait(_G.SpecialGradeQuestDelay or 60)
        else
            task.wait(1)
        end
    end
end)

-- Export function để loader có thể gọi thủ công
_G.CheckSpecialGradeQuest = checkAndDoSpecialGradeQuest