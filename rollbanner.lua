local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RollBanner = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.ShopService.RF.RollBanner

local player = Players.LocalPlayer
local currency = player:WaitForChild("Data"):WaitForChild("Currency")

_G.RollBannerEnabled = _G.RollBannerEnabled or false

spawn(function()
    while true do
        task.wait(0.25)
        if _G.RollBannerEnabled and currency.Value >= 10000 then
            RollBanner:InvokeServer(1, "UShards", 10)
        end
    end
end)