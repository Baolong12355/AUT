-- Auto Sell Script - Không dừng khi chiết, luôn chờ hồi sinh để tiếp tục

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

_G.AutoSellEnabled = _G.AutoSellEnabled or false
_G.AutoSellDelay = _G.AutoSellDelay or 30
_G.AutoSellExcludeList = _G.AutoSellExcludeList or {}
_G.AvailableItems = _G.AvailableItems or {}

local function getCharacterOrWait()
    return player.Character or player.CharacterAdded:Wait()
end

local function shouldSell(itemName)
    for _, name in ipairs(_G.AutoSellExcludeList) do
        if name == itemName then return false end
    end
    return true
end

function _G.SellAll()
    -- Đợi character hồi sinh nếu bị chiết (đảm bảo Backpack tồn tại)
    local char = getCharacterOrWait()
    local bp = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")

    local itemsToSell = {}
    for _, tool in pairs(bp:GetChildren()) do
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

spawn(function()
    while true do
        if _G.AutoSellEnabled then
            _G.SellAll()
            task.wait(_G.AutoSellDelay)
        else
            task.wait(1)
        end
    end
end)