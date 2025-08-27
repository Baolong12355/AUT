-- AUT Main Loader - Quản lý tất cả script với Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- GitHub repository URLs
local REPO_BASE = "https://raw.githubusercontent.com/Baolong12355/AUT/main/"

-- Scripts URLs
local SCRIPTS = {
    autosave = REPO_BASE .. "autosave.lua",
    sell = REPO_BASE .. "sell.lua",
    trait = REPO_BASE .. "trait.lua",
    stats = REPO_BASE .. "stats.lua",
    slayer = REPO_BASE .. "slayer.lua",
    rollbanner = REPO_BASE .. "rollbanner.lua",
    loot = REPO_BASE .. "loot.lua",
    feed = REPO_BASE .. "feed.lua",
    crate = REPO_BASE .. "crate.lua",
    combat = REPO_BASE .. "combat.lua",
    asc = REPO_BASE .. "asc.lua",
    specialgrade = REPO_BASE .. "SpecialGradeQuest.lua",
    speciallevelfarm = REPO_BASE .. "SpecialLevelFarm.lua" -- THÊM DÒNG NÀY
}

-- Item list dùng trực tiếp (không lấy từ link)
_G.AvailableItems = {
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

_G.LoadedScripts = {}

-- Default values
_G.AutoSaveSelectedItems = {}
_G.AutoSellExcludeList = {}
_G.CombatSelectedSkills = {"B"}

-- Không còn hàm loadItemList, mọi nơi dùng _G.AvailableItems trực tiếp

-- Load script from GitHub
local function loadScript(name, url)
    if _G.LoadedScripts[name] then return true end

    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        _G.LoadedScripts[name] = true
        return true
    end
    return false
end

-- Create main GUI
local Window = Rayfield:CreateWindow({
    Name = "AUT Multi-Tool Hub",
    LoadingTitle = "AUT Hub Loading",
    LoadingSubtitle = "by Baolong",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AUTHub",
        FileName = "Config"
    },
    Theme = "DarkBlue",
    ToggleUIKeybind = "K"
})

-- Create tabs
local MainTab = Window:CreateTab("Chính", "home")
local CombatTab = Window:CreateTab("Combat", "sword")
local ItemTab = Window:CreateTab("Vật Phẩm", "package")
local QuestTab = Window:CreateTab("Quest", "map")
local TraitTab = Window:CreateTab("Trait & Stats", "star")
local SettingsTab = Window:CreateTab("Cài Đặt", "settings")

-- === MAIN TAB ===
MainTab:CreateSection("Tải Script")

local LoadAllButton = MainTab:CreateButton({
    Name = "Tải Tất Cả Script",
    Callback = function()
        local loaded = 0
        local total = 0
        for name, url in pairs(SCRIPTS) do
            total = total + 1
            if loadScript(name, url) then
                loaded = loaded + 1
            end
        end
        Rayfield:Notify({
            Title = "Hoàn tất",
            Content = "Đã tải " .. loaded .. "/" .. total .. " scripts",
            Duration = 3,
            Image = "download"
        })
    end
})

-- === COMBAT TAB ===
CombatTab:CreateSection("Auto Combat")

local CombatToggle = CombatTab:CreateToggle({
    Name = "Auto Combat",
    CurrentValue = false,
    Flag = "CombatEnabled",
    Callback = function(Value)
        _G.CombatEnabled = Value
        if Value and not _G.LoadedScripts.combat then
            loadScript("combat", SCRIPTS.combat)
        end
        if _G.ResetCombatTarget then
            _G.ResetCombatTarget()
        end
    end
})

local CombatTypeDropdown = CombatTab:CreateDropdown({
    Name = "Loại Quái",
    Options = {"cultists", "cursed"},
    CurrentOption = {"cultists"},
    Flag = "CombatType",
    Callback = function(Options)
        _G.CombatTargetType = Options[1]
        if _G.ResetCombatTarget then
            _G.ResetCombatTarget()
        end
    end
})

local EscapeHeightSlider = CombatTab:CreateSlider({
    Name = "Độ Cao Thoát (Studs)",
    Range = {10, 100},
    Increment = 5,
    CurrentValue = 30,
    Flag = "EscapeHeight",
    Callback = function(Value)
        _G.CombatEscapeHeight = Value
    end
})

CombatTab:CreateSection("Combat Skills")

local availableSkills = {
    "B", "Q", "E", "R", "T", "Y", "U", "F", "G", "H", "Z", "X", "C", "V",
    "B+", "Q+", "E+", "R+", "T+", "Y+", "U+", "F+", "G+", "H+", "Z+", "X+", "C+", "V+",
    "MOUSEBUTTON2"
}

local CombatSkillsDropdown = CombatTab:CreateDropdown({
    Name = "Chọn Skills Combat",
    Options = availableSkills,
    CurrentOption = {"B"},
    MultipleOptions = true,
    Flag = "CombatSkills",
    Callback = function(Options)
        _G.CombatSelectedSkills = Options
    end
})

CombatTab:CreateParagraph({
    Title = "Hướng Dẫn Skills",
    Content = "• Skills thường: B, Q, E, R...\n• Skills nâng cao: B+, Q+, E+, R+...\n• M2: MOUSEBUTTON2\n• Có thể chọn nhiều skills cùng lúc"
})

local SlayerQuestToggle = CombatTab:CreateToggle({
    Name = "Ưu Tiên Slayer Boss",
    CurrentValue = false,
    Flag = "SlayerPriority",
    Callback = function(Value)
        _G.SlayerQuestActive = Value
    end
})

-- === ITEM TAB ===
ItemTab:CreateSection("Auto Save Item")

local AutoSaveToggle = ItemTab:CreateToggle({
    Name = "Auto Save Item",
    CurrentValue = false,
    Flag = "AutoSaveEnabled",
    Callback = function(Value)
        _G.AutoSaveEnabled = Value
        if Value and not _G.LoadedScripts.autosave then
            loadScript("autosave", SCRIPTS.autosave)
        end
    end
})

local AutoSaveItemsDropdown = ItemTab:CreateDropdown({
    Name = "Chọn Items Cần Save",
    Options = _G.AvailableItems,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AutoSaveItems",
    Callback = function(Options)
        _G.AutoSaveSelectedItems = Options
    end
})

local AutoSaveManualButton = ItemTab:CreateButton({
    Name = "Save Item Thủ Công",
    Callback = function()
        if not _G.LoadedScripts.autosave then
            loadScript("autosave", SCRIPTS.autosave)
        end
        if _G.TriggerAutoSave then
            _G.TriggerAutoSave()
        end
    end
})

ItemTab:CreateSection("Auto Sell")

local AutoSellToggle = ItemTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellEnabled",
    Callback = function(Value)
        _G.AutoSellEnabled = Value
        if Value and not _G.LoadedScripts.sell then
            loadScript("sell", SCRIPTS.sell)
        end
    end
})

local AutoSellExcludeDropdown = ItemTab:CreateDropdown({
    Name = "Chọn Items KHÔNG Bán",
    Options = _G.AvailableItems,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AutoSellExclude",
    Callback = function(Options)
        _G.AutoSellExcludeList = Options
    end
})

local SellDelaySlider = ItemTab:CreateSlider({
    Name = "Sell Delay (giây)",
    Range = {5, 120},
    Increment = 5,
    CurrentValue = 30,
    Flag = "SellDelay",
    Callback = function(Value)
        _G.AutoSellDelay = Value
    end
})

ItemTab:CreateSection("Loot & Crate")

local LootToggle = ItemTab:CreateToggle({
    Name = "Auto Loot Chest",
    CurrentValue = false,
    Flag = "LootEnabled",
    Callback = function(Value)
        _G.LootEnabled = Value
        if Value and not _G.LoadedScripts.loot then
            loadScript("loot", SCRIPTS.loot)
        end
    end
})

local CrateToggle = ItemTab:CreateToggle({
    Name = "Auto Crate Collector",
    CurrentValue = false,
    Flag = "CrateEnabled",
    Callback = function(Value)
        _G.CrateCollectorEnabled = Value
        if Value and not _G.LoadedScripts.crate then
            loadScript("crate", SCRIPTS.crate)
        end
    end
})

local CrateDelaySlider = ItemTab:CreateSlider({
    Name = "Crate Check Delay",
    Range = {10, 300},
    Increment = 10,
    CurrentValue = 60,
    Flag = "CrateDelay",
    Callback = function(Value)
        _G.CrateLoopDelay = Value
    end
})

local CrateTPDelaySlider = ItemTab:CreateSlider({
    Name = "Crate TP Delay",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.1,
    Flag = "CrateTPDelay",
    Callback = function(Value)
        _G.CrateTPDelay = Value
    end
})

-- === QUEST TAB ===
QuestTab:CreateSection("Auto Quest")

local SlayerToggle = QuestTab:CreateToggle({
    Name = "Auto Slayer Quest",
    CurrentValue = false,
    Flag = "SlayerEnabled",
    Callback = function(Value)
        _G.SlayerQuestEnabled = Value
        if Value and not _G.LoadedScripts.slayer then
            loadScript("slayer", SCRIPTS.slayer)
        end
    end
})

local SlayerQuestDropdown = QuestTab:CreateDropdown({
    Name = "Slayer Quest Ưu Tiên",
    Options = {"Finger Bearer", "Gojo", "Xeno", "Bur", "Dragon knight", "Oni"},
    CurrentOption = {"Finger Bearer"},
    MultipleOptions = true,
    Flag = "SlayerQuests",
    Callback = function(Options)
        _G.PreferredSlayerQuests = Options
    end
})

local SpecialGradeToggle = QuestTab:CreateToggle({
    Name = "Auto Special Grade Quest",
    CurrentValue = false,
    Flag = "SpecialGradeEnabled",
    Callback = function(Value)
        _G.SpecialGradeQuestEnabled = Value
        if Value and not _G.LoadedScripts.specialgrade then
            loadScript("specialgrade", SCRIPTS.specialgrade)
        end
    end
})

local SpecialGradeDelaySlider = QuestTab:CreateSlider({
    Name = "Special Grade Delay",
    Range = {30, 300},
    Increment = 30,
    CurrentValue = 60,
    Flag = "SpecialGradeDelay",
    Callback = function(Value)
        _G.SpecialGradeQuestDelay = Value
    end
})

-- === TRAIT & STATS TAB ===
TraitTab:CreateSection("Auto Trait")

local TraitToggle = TraitTab:CreateToggle({
    Name = "Auto Pick Trait",
    CurrentValue = false,
    Flag = "TraitEnabled",
    Callback = function(Value)
        _G.TraitAutoPickEnabled = Value
        if Value and not _G.LoadedScripts.trait then
            loadScript("trait", SCRIPTS.trait)
        end
    end
})

local LegendaryTraitsDropdown = TraitTab:CreateDropdown({
    Name = "Legendary Traits Ưu Tiên",
    Options = {"Prime", "Angelic", "Solar", "Cursed", "Vampiric", "Gluttonous", "Voided", "Gambler", "Overflowing", "Deferred", "True", "Cultivation", "Economic"},
    CurrentOption = {"Prime"},
    MultipleOptions = true,
    Flag = "LegendaryTraits",
    Callback = function(Options)
        _G.TraitList_Legendary = Options
    end
})

local LegendaryHexedTraitsDropdown = TraitTab:CreateDropdown({
    Name = "Legendary Hexed Traits",
    Options = {"Overconfident Prime", "Fallen Angelic", "Icarus Solar", "Undying Cursed", "Ancient Vampiric", "Festering Gluttonous", "Abyssal Voided", "Idle Death Gambler", "Torrential Overflowing", "Fractured Deferred", "Vitriolic True", "Soul Reaping Cultivation", "Greedy Economic"},
    CurrentOption = {"Overconfident Prime"},
    MultipleOptions = true,
    Flag = "LegendaryHexedTraits",
    Callback = function(Options)
        _G.TraitList_LegendaryHexed = Options
    end
})

local MythicTraitsDropdown = TraitTab:CreateDropdown({
    Name = "Mythic Traits Ưu Tiên",
    Options = {"Godly", "Temporal", "RCT", "Spiritual", "Ryoiki", "Adaptation"},
    CurrentOption = {"Godly"},
    MultipleOptions = true,
    Flag = "MythicTraits",
    Callback = function(Options)
        _G.TraitList_Mythic = Options
    end
})

local MythicHexedTraitsDropdown = TraitTab:CreateDropdown({
    Name = "Mythic Hexed Traits",
    Options = {"Egotistic Godly", "FTL Temporal", "Automatic RCT", "Mastered Spiritual", "Overcharged Ryoiki", "Unbound Adaptation"},
    CurrentOption = {"Egotistic Godly"},
    MultipleOptions = true,
    Flag = "MythicHexedTraits",
    Callback = function(Options)
        _G.TraitList_MythicHexed = Options
    end
})

local TraitHistoryButton = TraitTab:CreateButton({
    Name = "Xem 5 Trait Đã Discard",
    Callback = function()
        if _G.TraitDiscardHistory and #_G.TraitDiscardHistory > 0 then
            local historyText = "Trait đã discard:\n"
            for i, traits in ipairs(_G.TraitDiscardHistory) do
                historyText = historyText .. i .. ". " .. traits .. "\n"
            end
            Rayfield:Notify({
                Title = "Lịch Sử Trait",
                Content = historyText,
                Duration = 8
            })
        else
            Rayfield:Notify({
                Title = "Không Có Lịch Sử",
                Content = "Chưa discard trait nào",
                Duration = 3
            })
        end
    end
})

TraitTab:CreateSection("Auto Stats")

local StatsToggle = TraitTab:CreateToggle({
    Name = "Auto Stats",
    CurrentValue = false,
    Flag = "StatsEnabled",
    Callback = function(Value)
        _G.AutoStatsEnabled = Value
        if Value and not _G.LoadedScripts.stats then
            loadScript("stats", SCRIPTS.stats)
        end
    end
})

local StatsTypeDropdown = TraitTab:CreateDropdown({
    Name = "Loại Stats",
    Options = {"Attack", "Defense", "Health", "Special"},
    CurrentOption = {"Attack"},
    Flag = "StatsType",
    Callback = function(Options)
        _G.AutoStatsType = Options[1]
    end
})

local StatsAmountSlider = TraitTab:CreateSlider({
    Name = "Số Điểm Mỗi Lần",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 1,
    Flag = "StatsAmount",
    Callback = function(Value)
        _G.AutoStatsAmount = Value
    end
})

TraitTab:CreateSection("Auto Ascend & Feed")

local AscendToggle = TraitTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Flag = "AscendEnabled",
    Callback = function(Value)
        _G.AutoAscendEnabled = Value
        if Value and not _G.LoadedScripts.asc then
            loadScript("asc", SCRIPTS.asc)
        end
    end
})

local FeedToggle = TraitTab:CreateToggle({
    Name = "Auto Feed Shards",
    CurrentValue = false,
    Flag = "FeedEnabled",
    Callback = function(Value)
        _G.FeedShardsEnabled = Value
        if Value and not _G.LoadedScripts.feed then
            loadScript("feed", SCRIPTS.feed)
        end
    end
})

--- === SETTINGS TAB ===
SettingsTab:CreateSection("Banner Roll")

local BannerToggle = SettingsTab:CreateToggle({
    Name = "Auto Roll Banner",
    CurrentValue = false,
    Flag = "BannerEnabled",
    Callback = function(Value)
        _G.RollBannerEnabled = Value
        if Value and not _G.LoadedScripts.rollbanner then
            loadScript("rollbanner", SCRIPTS.rollbanner)
        end
    end
})

SettingsTab:CreateSection("level fram")

local SpecialLevelFarmToggle = SettingsTab:CreateToggle({
    Name = "special leveling",
    CurrentValue = false,
    Flag = "SpecialLevelFarmEnabled",
    Callback = function(Value)
        _G.SpecialLevelFarmEnabled = Value
        if Value and not _G.LoadedScripts.speciallevelfarm then
            loadScript("speciallevelfarm", SCRIPTS.speciallevelfarm)
        end
    end
})

SettingsTab:CreateParagraph({
    Title = "Ghi chú Max Item Bank",
    Content = "• Tự động nâng max item bank cho Hamon Base.\n• Yêu cầu: ĐÃ LÀM QUEST của Joseph's Informant và đang ở Hamon Base!"
})

SettingsTab:CreateSection("Thông Tin")

SettingsTab:CreateParagraph({
    Title = "AUT Multi-Tool Hub",
    Content = "• Tất cả script được load từ GitHub\n• Tự động đồng bộ cài đặt\n• Pause logic giữa các script\n• Phím tắt: K để ẩn/hiện GUI"
})

local ReloadAllButton = SettingsTab:CreateButton({
    Name = "Reload Tất Cả Script",
    Callback = function()
        _G.LoadedScripts = {}
        local loaded = 0
        local total = 0
        for name, url in pairs(SCRIPTS) do
            total = total + 1
            if loadScript(name, url) then
                loaded = loaded + 1
            end
        end
        Rayfield:Notify({
            Title = "Reload Hoàn Tất",
            Content = "Đã reload " .. loaded .. "/" .. total .. " scripts",
            Duration = 3,
            Image = "refresh-cw"
        })
    end
})

Rayfield:Notify({
    Title = "AUT Hub Loaded",
    Content = "Hub đã sẵn sàng sử dụng!",
    Duration = 5,
    Image = "check"
})

Rayfield:LoadConfiguration()