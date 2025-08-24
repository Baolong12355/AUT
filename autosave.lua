-- Auto Save Item Script - Fixed version with item selection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")
local ItemInventory = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.InventoryService.RE.ItemInventory
local GetCapacity = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.InventoryService.RF.GetCapacity

-- Global variables for external control
_G.AutoSaveEnabled = _G.AutoSaveEnabled or false
_G.AutoSaveSelectedItems = _G.AutoSaveSelectedItems or {} -- Items được chọn để save
_G.ItemAutoSaving = _G.ItemAutoSaving or false

-- Item list from item.txt
_G.AvailableItems = _G.AvailableItems or {
    "Mining Laser", "Phoenix Gemstone", "Jonathan's Signal", "Coal Loot", "Medic's Equipment",
    "A New Fable", "Cursed Orb", "Blood of Joseph", "The Total Force Of Calamity", "Spin Energy Fragment",
    "Umbra's Calamity Force", "Inverted Spear of Heaven", "Light of Hope", "Arrow", "Chest Key",
    "Bone", "Heart", "Shaper's Essence", "Ban Hammer", "Chargin' Targe", "Yo-Yo",
    "Mysterious Fragment", "Shanks' Calamity Force", "Clackers", "Joestar Blood Vial",
    "Heavenly Restriction Awakening", "Knife", "Claw Fragment", "Gojo's Blindfold", "Stocking",
    "Sorcerer's Scarf", "Green Baby", "Busoshoku Manual", "Azakana Mask", "Sovereign's Sword",
    "West Blue Juice", "Heart of the Saint", "Paintball Gun", "Candy Bag", "Camellite",
    "Nanotech Fragments", "Limitless Technique Scroll", "Sukuna's Calamity Force", "Requiem Arrow",
    "Dio's Charm", "Superball", "Death Painting", "Candy Cutlass Blade", "Demonic Scroll",
    "Dragon Ball", "NUCLEAR-CORE", "Watch", "Kuma's Book", "Saints Skull", "Vampirism Mastery",
    "Stone Mask", "Saints Arms", "Soul Gemstone", "Sorcerer Killer Shard", "Saints Eyes",
    "Corrupted Arrow", "Mero Devil Fruit", "Dragon Slayer", "Remembrance of the Sorcerer Killer",
    "Split Soul Katana", "Refined Camellite", "Golden Hook", "Rocket Launcher",
    "Remembrance of the Fallen", "Anshen's Leg Plates", "Tales Of The Universe", "Caesar's Headband",
    "DIO's Bone", "Mahoraga's Calamity Force", "Flamethrower", "Evil Fragments", "Worn Out Scarf",
    "Strange Briefcase", "Bomb", "Anshen's Lance", "Joseph's Signal", "Anshen's Arm Plates",
    "Cultist Staff", "Camellite Arrow", "SHAPER // SWORD", "Cosmic Remnant", "The Vessel Shard",
    "Kars' Calamity Force", "Calibrated Manifold", "STAR SEED", "Harmonic Decoder", "Sukuna's Finger",
    "Heavenly Nectar", "Dormant Staff", "Dormant Dagger", "Hito Devil Fruit", "Cosmic Fragments",
    "Meat On A Bone", "Fractured Sigil", "Geode", "Keycard", "The Denzien Of Hell's Calamity Force",
    "Bait Vampire Mask", "Camellite Fragment", "Mining Laser MK2", "Catalyst", "Crystalline Core",
    "Inhumane Spirit", "Shadow's Calamity Force", "Whitebeard's Calamity Force", "Locacaca",
    "Fragment of Death", "Ancient Sword", "Metal Loot", "Anshen's Suit", "DIO's Diary",
    "King of Curses Shard", "Mysterious Hat", "Slingshot", "Sovereign's Chapter", "Cultist Dagger",
    "Remembrance of the Strongest", "Anshen's Helmet", "Draconic Gemstone", "Cursed Arm",
    "Metal Ingot", "Gun Parts", "Metal Scraps", "Bisento", "Bouquet Of Flowers", "Eyelander",
    "Cursed Gemstone", "Letter to Jonathan", "Aja Stone", "Hamon Imbued Frog", "Altered Steel Ball",
    "Manual of Gryphon's Techniques", "Cursed Apple", "Shrine Item", "Godly Doctor's Poison",
    "Anshen's Chestplate", "Simple Domain Essence", "Slime Energy", "Anshen's Wing Set",
    "Haki Shard", "Remembrance of the Vessel", "Kenbunshoku Manual", "Monochromatic Gemstone",
    "Arm Band", "Bat", "Haoshoku Manual", "Wheel of Dharma", "Playful Cloud", "Knight's Blade",
    "Pumpkin", "Coal", "Saints Legs", "Rundown Mask", "Corrupted Soul", "Kinetic Orb",
    "Letter to Joseph", "Saints Ribcage", "Jonathan's Worn Out Gloves", "Sword", "Gomu Devil Fruit",
    "Kinetic Gemstone", "True Stone Mask", "Baroque Works Contractor Den Den", "Sanji's Cookbook",
    "Ope Devil Fruit", "Grenade Launcher", "Dio's Remains", "Suna Devil Fruit", "Used Arrow",
    "Tactical Vest", "Law's Cap", "Frog", "Trowel", "Saint's Corpse", "Monochromatic Orb"
}

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

-- Initialize with all items by default
if #_G.AutoSaveSelectedItems == 0 then
    _G.AutoSaveSelectedItems = table.clone(_G.AvailableItems)
end
