-- Auto Save Item Script - Load item list từ GitHub và cho phép chọn items

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")
local ItemInventory = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.InventoryService.RE.ItemInventory
local GetCapacity = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.InventoryService.RF.GetCapacity

-- Global variables cho external control
_G.AutoSaveEnabled = _G.AutoSaveEnabled or false
_G.AutoSaveSelectedItems = _G.AutoSaveSelectedItems or {} -- Items được chọn để save
_G.ItemAutoSaving = _G.ItemAutoSaving or false
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

local function getInventoryCapacity()
    local success, result = pcall(function()
        return GetCapacity:InvokeServer("ItemInventory")
    end)
    if success and result and result[1] then
        return result[1].CurrentCapacity, result[1].MaxCapacity
    end
    return 0, 20
end

local function isCombatTagVisible()
    local combatTag = PlayerGui:FindFirstChild("UI")
    if combatTag then
        combatTag = combatTag:FindFirstChild("Gameplay")
        if combatTag then
            combatTag = combatTag:FindFirstChild("Character")
            if combatTag then
                combatTag = combatTag:FindFirstChild("Info")
                if combatTag then
                    combatTag = combatTag:FindFirstChild("CombatTag")
                    if combatTag then
                        return combatTag.Visible
                    end
                end
            end
        end
    end
    return false
end

local function findItemInBackpack(itemName)
    return Backpack:FindFirstChild(itemName)
end

local function findItemInCharacter(itemName)
    local character = Player.Character
    if character then
        return character:FindFirstChild(itemName)
    end
    return nil
end

local function equipItem(item)
    if item and item.Parent == Backpack then
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(item)
            return true
        end
    end
    return false
end

local function addItemToInventory()
    pcall(function()
        ItemInventory:FireServer({ AddItems = true })
    end)
end

local function teleportToEscape()
    local escapePosition = Vector3.new(-1484.960205078125, 35.84999084472656, -848.3723754882812)
    local character = Player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(escapePosition)
    end
end

local function resetCharacter()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.Health = 0
    end
end

local function hasPreventSave(item)
    return item:GetAttribute("PreventSave") == true
end

local function processAutoSaveForItem(itemName, onFinish)
    if not itemName or itemName == "" then
        if onFinish then onFinish() end
        return
    end
    local currentCapacity, maxCapacity = getInventoryCapacity()
    if currentCapacity >= maxCapacity then
        if onFinish then onFinish() end
        return
    end

    local targetItem = findItemInBackpack(itemName) or findItemInCharacter(itemName)
    if not targetItem then
        if onFinish then onFinish() end
        return
    end

    if targetItem.Parent == Backpack then
        if not equipItem(targetItem) then
            if onFinish then onFinish() end
            return
        end
        task.wait(0.02)
    end

    targetItem = findItemInCharacter(itemName)
    if not targetItem then
        if onFinish then onFinish() end
        return
    end

    if isCombatTagVisible() then
        if hasPreventSave(targetItem) then
            local escapeLoop
            escapeLoop = RunService.Heartbeat:Connect(function()
                teleportToEscape()
                local itemCheck = findItemInBackpack(itemName) or findItemInCharacter(itemName)
                if not itemCheck then
                    escapeLoop:Disconnect()
                    if onFinish then onFinish() end
                end
            end)
            return
        else
            local respawnConnection
            respawnConnection = Player.CharacterAdded:Connect(function(newCharacter)
                task.wait(1.5)
                addItemToInventory()
                respawnConnection:Disconnect()
                if onFinish then onFinish() end
            end)
            resetCharacter()
            return
        end
    else
        addItemToInventory()
        task.wait(0.1)
        if onFinish then onFinish() end
    end
end

-- Main auto save function
function _G.TriggerAutoSave()
    if not _G.AutoSaveEnabled or #_G.AutoSaveSelectedItems == 0 then return end
    
    _G.ItemAutoSaving = true
    local n = #_G.AutoSaveSelectedItems
    local i = 1
    
    local function nextItem()
        if i > n then
            _G.ItemAutoSaving = false
            return
        end
        processAutoSaveForItem(_G.AutoSaveSelectedItems[i], function()
            i = i + 1
            nextItem()
        end)
    end
    nextItem()
end

-- Auto save loop
spawn(function()
    while true do
        if _G.AutoSaveEnabled then
            _G.TriggerAutoSave()
            task.wait(5) -- Check every 5 seconds
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
