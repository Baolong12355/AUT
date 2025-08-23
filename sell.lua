-- Auto Sell Script - Dùng cho list truyền vào, không lấy skip list từ item.txt

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- List này phải được truyền từ ngoài vào (loader/GUI)
_G.ExcludeList = _G.ExcludeList or {} -- ví dụ: {"Rare Sword", "Epic Wand"}

local function shouldSell(itemName)
    for _, name in ipairs(_G.ExcludeList) do
        if name == itemName then return false end
    end
    return true
end

function _G.SellAll()
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

-- Loader hoặc GUI bên ngoài tự gọi _G.SellAll() sau mỗi lần delay mong muốn.