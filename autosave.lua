-- Auto Save Item Script - Mẫu mới: Không log, không print, không callback

local ITEM_LIST_URL = "https://raw.githubusercontent.com/Baolong12355/AUT/refs/heads/main/item.txt"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")
local ItemInventory = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.InventoryService.RE.ItemInventory
local GetCapacity = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.InventoryService.RF.GetCapacity

local AutoSaveList = {}

local function fetchItemList(url)
    local list = {}
    local success, data = pcall(function() return game:HttpGet(url) end)
    if success and data then
        for _, line in ipairs(string.split(data, "\n")) do
            local name = string.gsub(line, "\r", ""):match("^%s*(.-)%s*$")
            if name ~= "" then table.insert(list, name) end
        end
    end
    return list
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

local function processAutoSaveForItem(itemName)
    if not itemName or itemName == "" then return end
    local currentCapacity, maxCapacity = getInventoryCapacity()
    if currentCapacity >= maxCapacity then return end

    local targetItem = findItemInBackpack(itemName) or findItemInCharacter(itemName)
    if not targetItem then return end

    if targetItem.Parent == Backpack then
        if not equipItem(targetItem) then return end
        wait()
    end

    targetItem = findItemInCharacter(itemName)
    if not targetItem then return end

    if isCombatTagVisible() then
        if hasPreventSave(targetItem) then
            local escapeLoop
            escapeLoop = RunService.Heartbeat:Connect(function()
                teleportToEscape()
                local itemCheck = findItemInBackpack(itemName) or findItemInCharacter(itemName)
                if not itemCheck then
                    escapeLoop:Disconnect()
                end
            end)
            return
        else
            local respawnConnection
            respawnConnection = Player.CharacterAdded:Connect(function(newCharacter)
                wait(1.5)
                addItemToInventory()
                respawnConnection:Disconnect()
            end)
            resetCharacter()
            return
        end
    else
        addItemToInventory()
        wait(0.1)
    end
end

local function processAutoSaveAll()
    for _, itemName in ipairs(AutoSaveList) do
        processAutoSaveForItem(itemName)
    end
end

spawn(function()
    AutoSaveList = fetchItemList(ITEM_LIST_URL)
    wait(2)
    processAutoSaveAll()
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        processAutoSaveAll()
    end
end)

_G.AutoSaveTrigger = processAutoSaveAll