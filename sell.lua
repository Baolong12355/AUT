-- Auto Sell Script - Bật/tắt với delay được loader truyền vào
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- Biến điều khiển từ loader
_G.AutoSellEnabled = _G.AutoSellEnabled or false
_G.AutoSellDelay = _G.AutoSellDelay or 10 -- Delay giữa mỗi lần sell (giây)
_G.AutoSellExcludeList = _G.AutoSellExcludeList or {} -- List item không sell

local function shouldSell(itemName)
    for _, name in ipairs(_G.AutoSellExcludeList) do
        if name == itemName then return false end
    end
    return true
end

local function sellAllItems()
    if not _G.AutoSellEnabled then return end
    
    local itemsToSell = {}
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and shouldSell(tool.Name) then
            local itemId = tool:GetAttribute("ItemId")
            local uuid = tool:GetAttribute("UUID")
            if itemId and uuid then
                table.insert(itemsToSell, {itemId, uuid, 1})
            end
        end
    end
    
    if #itemsToSell == 0 then return end
    
    local success = pcall(function()
        local knit = require(ReplicatedStorage.ReplicatedModules.KnitPackage.Knit)
        local shopService = knit.GetService("ShopService")
        if shopService and shopService.Signal then
            shopService.Signal:Fire("BlackMarketBulkSellItems", itemsToSell)
        end
    end)
    
    if not success then
        pcall(function()
            local services = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services
            if services then
                local shopService = services:FindFirstChild("ShopService")
                if shopService then
                    local signal = shopService:FindFirstChild("Signal")
                    if signal and signal:IsA("RemoteEvent") then
                        signal:FireServer("BlackMarketBulkSellItems", itemsToSell)
                    end
                end
            end
        end)
    end
end

-- Loop chính
spawn(function()
    while true do
        if _G.AutoSellEnabled then
            sellAllItems()
            task.wait(_G.AutoSellDelay or 10)
        else
            task.wait(1)
        end
    end
end)

-- Export function để loader có thể gọi thủ công
_G.SellAll = sellAllItems