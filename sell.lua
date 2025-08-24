-- Auto Sell Script - Fixed version with item exclude list, bán hết nếu list rỗng

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- Global variables for external control
_G.AutoSellEnabled = _G.AutoSellEnabled or false
_G.AutoSellDelay = _G.AutoSellDelay or 30
_G.AutoSellExcludeList = _G.AutoSellExcludeList or {} -- Items được chọn để KHÔNG bán

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

local function shouldSell(itemName)
    if #_G.AutoSellExcludeList == 0 then
        -- Nếu không có item nào được bỏ qua: bán hết
        return true
    end
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