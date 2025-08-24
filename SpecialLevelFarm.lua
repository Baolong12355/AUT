-- Auto Special Level Farm: Gọi CheckDialogue("Joseph's Informant") mỗi 0.5s (Max Item Bank, Hamon base, đã làm quest)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckDialogue = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.DialogueService.RF.CheckDialogue

_G.SpecialLevelFarmEnabled = _G.SpecialLevelFarmEnabled or false

spawn(function()
    while true do
        if _G.SpecialLevelFarmEnabled then
            pcall(function()
                CheckDialogue:InvokeServer("Joseph's Informant")
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)