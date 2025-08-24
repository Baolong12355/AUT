-- Auto Sell Script - Load item list từ GitHub và cho phép chọn items bỏ qua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- Global variables cho external control
_G.AutoSellEnabled = _G.AutoSellEnabled or false
_G.AutoSellDelay = _G.AutoSellDelay or 30
_G.AutoSellExcludeList = _G.AutoSellExcludeList or {} -- Items được chọn để KHÔNG bán
_G.AvailableItems = _G.AvailableItems or {} -- Danh sách items từ GitHub

-- Load item list từ GitHub
local function loadItemListFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/Baolong12355/AUT/refs/heads/main/item.txt")
    end)
    
    if success then
        _G.AvailableItems = {}
        for line in result:gmatch("[^\r\n]+") do
            local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
            if trimmed ~= "" then
                table.insert(_G.AvailableItems, trimmed)
            end
        end
        return true
    end
    return false
end

local function shouldSell(itemName)
    for _, name in ipairs(_G.AutoSellExcludeList) do
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

-- Auto sell loop
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

-- Load item list khi khởi động
spawn(function()
    task.wait(1)
    loadItemListFromGitHub()
end)
