-- AUT Main Loader - WindUI Version - Quản lý tất cả script với WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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
    speciallevelfarm = REPO_BASE .. "SpecialLevelFarm.lua", 
    oneshot = REPO_BASE .. "oneshot.lua",
    autohaki = REPO_BASE .. "autohaki.lua",
    standstate = REPO_BASE .. "autostandonoff.lua"
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
_G.CombatSelectedSkills = {""}

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

-- Create main GUI with WindUI
local Window = WindUI:CreateWindow({
    Title = "AUT Multi-Tool Hub",
    Icon = "shield",
    Author = "by Baolong",
    Folder = "AUTHub",
    Size = UDim2.fromOffset(650, 500),
    Theme = "Dark",
    Resizable = true,
    Transparent = false
})

-- Create tabs
local MainTab = Window:Tab({
    Title = "Chính",
    Icon = "home"
})

local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "sword"
})

local ItemTab = Window:Tab({
    Title = "Vật Phẩm",
    Icon = "package"
})

local QuestTab = Window:Tab({
    Title = "Quest",
    Icon = "map"
})

local TraitTab = Window:Tab({
    Title = "Trait & Stats",
    Icon = "star"
})

local SettingsTab = Window:Tab({
    Title = "Cài Đặt",
    Icon = "settings"
})

-- === MAIN TAB ===
MainTab:Section({
    Title = "Tải Script",
    Icon = "download"
})

local LoadAllButton = MainTab:Button({
    Title = "Tải Tất Cả Script",
    Desc = "Tải tất cả script từ GitHub",
    Callback = function()
        local loaded = 0
        local total = 0
        for name, url in pairs(SCRIPTS) do
            total = total + 1
            if loadScript(name, url) then
                loaded = loaded + 1
            end
        end
        WindUI:Notify({
            Title = "Hoàn tất",
            Content = "Đã tải " .. loaded .. "/" .. total .. " scripts",
            Duration = 3,
            Icon = "check"
        })
    end
})

-- === COMBAT TAB ===
CombatTab:Section({
    Title = "Auto Combat",
    Icon = "swords"
})

local CombatToggle = CombatTab:Toggle({
    Title = "Auto Combat",
    Desc = "Bật/tắt tự động combat",
    Default = false,
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

local CombatTypeDropdown = CombatTab:Dropdown({
    Title = "Loại Quái",
    Desc = "Chọn loại quái để đánh",
    Values = {"cultists", "cursed", "hooligans", "prisoners", "thugs", "pirates", "guardian"},
    Value = "cultists",
    Callback = function(Option)
        _G.CombatTargetType = Option
        if _G.ResetCombatTarget then
            _G.ResetCombatTarget()
        end
    end
})

local EscapeHeightSlider = CombatTab:Slider({
    Title = "Độ Cao Thoát",
    Desc = "Độ cao để thoát khỏi combat (Studs)",
    Value = {
        Min = 10,
        Max = 100,
        Default = 30
    },
    Step = 5,
    Callback = function(Value)
        _G.CombatEscapeHeight = Value
    end
})

CombatTab:Section({
    Title = "Combat Skills",
    Icon = "zap"
})

local availableSkills = {
    "B", "Q", "E", "R", "T", "Y", "U", "F", "G", "H", "Z", "X", "C", "V",
    "B+", "Q+", "E+", "R+", "T+", "Y+", "U+", "F+", "G+", "H+", "Z+", "X+", "C+", "V+",
    "MOUSEBUTTON2"
}

local CombatSkillsDropdown = CombatTab:Dropdown({
    Title = "Chọn Skills Combat",
    Desc = "Chọn các skill để sử dụng trong combat",
    Values = availableSkills,
    Value = {"B"},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.CombatSelectedSkills = Options
    end
})

CombatTab:Paragraph({
    Title = "Hướng Dẫn Skills",
    Desc = "• Skills thường: B, Q, E, R...\n• Skills nâng cao: B+, Q+, E+, R+...\n• M2: MOUSEBUTTON2\n• Có thể chọn nhiều skills cùng lúc",
    Color = "Blue"
})

CombatTab:Section({
    Title = "Auto Stand On/Off",
    Icon = "user"
})

local StandAutoToggle = CombatTab:Toggle({
    Title = "Auto Stand (Bật/Tắt)",
    Desc = "Tự động bật/tắt stand",
    Default = getgenv().AutoStandEnabled or false,
    Callback = function(Value)
        getgenv().AutoStandEnabled = Value
        if not Value then
            getgenv().AutoStandState = nil
        else
            if getgenv().AutoStandState ~= "on" and getgenv().AutoStandState ~= "off" then
                getgenv().AutoStandState = "on"
            end
            if not _G.LoadedScripts.standstate then
                loadScript("standstate", SCRIPTS.standstate)
            end
        end
    end
})

local StandStateDropdown = CombatTab:Dropdown({
    Title = "Chế độ Stand",
    Desc = "Chọn chế độ bật hoặc tắt stand",
    Values = {"on", "off"},
    Value = "on",
    Callback = function(Option)
        local mode = Option
        if mode == "on" or mode == "off" then
            getgenv().AutoStandState = mode
            if getgenv().AutoStandEnabled and not _G.LoadedScripts.standstate then
                loadScript("standstate", SCRIPTS.standstate)
            end
        else
            getgenv().AutoStandState = nil
        end
    end
})

local SlayerQuestToggle = CombatTab:Toggle({
    Title = "Ưu Tiên Slayer Boss",
    Desc = "Ưu tiên đánh slayer boss",
    Default = false,
    Callback = function(Value)
        _G.SlayerQuestActive = Value
    end
})

CombatTab:Section({
    Title = "Auto One Shot",
    Icon = "target"
})

local OneShotSlider = CombatTab:Slider({
    Title = "Ngưỡng HP One Shot",
    Desc = "Ngưỡng HP để thực hiện one shot (%)",
    Value = {
        Min = 1,
        Max = 100,
        Default = 50
    },
    Step = 1,
    Callback = function(Value)
        getgenv().AutoOneShotHPThreshold = Value
    end
})

local OneShotToggle = CombatTab:Toggle({
    Title = "Auto One Shot",
    Desc = "Tự động one shot khi HP dưới ngưỡng",
    Default = false,
    Callback = function(Value)
        getgenv().AutoOneShotting = Value
        if Value and not _G.LoadedScripts.oneshot then
            loadScript("oneshot", SCRIPTS.oneshot)
        end
    end
})

local HakiToggle = CombatTab:Toggle({
    Title = "Auto Bật Busoshoku Haki",
    Desc = "Tự động bật Busoshoku Haki",
    Default = false,
    Callback = function(Value)
        getgenv().AutoHakiEnabled = Value
        if Value and not _G.LoadedScripts.autohaki then
            loadScript("autohaki", SCRIPTS.autohaki)
        end
    end
})

-- === ITEM TAB ===
ItemTab:Section({
    Title = "Auto Save Item",
    Icon = "save"
})

local AutoSaveToggle = ItemTab:Toggle({
    Title = "Auto Save Item",
    Desc = "Tự động lưu item được chọn",
    Default = false,
    Callback = function(Value)
        _G.AutoSaveEnabled = Value
        if Value and not _G.LoadedScripts.autosave then
            loadScript("autosave", SCRIPTS.autosave)
        end
    end
})

local AutoSaveItemsDropdown = ItemTab:Dropdown({
    Title = "Chọn Items Cần Save",
    Desc = "Chọn các item muốn tự động lưu",
    Values = _G.AvailableItems,
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.AutoSaveSelectedItems = Options
    end
})

local AutoSaveManualButton = ItemTab:Button({
    Title = "Save Item Thủ Công",
    Desc = "Thực hiện save item ngay lập tức",
    Callback = function()
        if not _G.LoadedScripts.autosave then
            loadScript("autosave", SCRIPTS.autosave)
        end
        if _G.TriggerAutoSave then
            _G.TriggerAutoSave()
        end
    end
})

ItemTab:Section({
    Title = "Auto Sell",
    Icon = "dollar-sign"
})

local AutoSellToggle = ItemTab:Toggle({
    Title = "Auto Sell",
    Desc = "Tự động bán item (trừ item được bảo vệ)",
    Default = false,
    Callback = function(Value)
        _G.AutoSellEnabled = Value
        if Value and not _G.LoadedScripts.sell then
            loadScript("sell", SCRIPTS.sell)
        end
    end
})

local AutoSellExcludeDropdown = ItemTab:Dropdown({
    Title = "Chọn Items KHÔNG Bán",
    Desc = "Chọn các item muốn bảo vệ khỏi auto sell",
    Values = _G.AvailableItems,
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.AutoSellExcludeList = Options
    end
})

local SellDelaySlider = ItemTab:Slider({
    Title = "Sell Delay",
    Desc = "Thời gian delay giữa các lần sell (giây)",
    Value = {
        Min = 5,
        Max = 120,
        Default = 30
    },
    Step = 5,
    Callback = function(Value)
        _G.AutoSellDelay = Value
    end
})

ItemTab:Section({
    Title = "Loot & Crate",
    Icon = "box"
})

local LootToggle = ItemTab:Toggle({
    Title = "Auto Loot Chest",
    Desc = "Tự động loot chest trên map",
    Default = false,
    Callback = function(Value)
        _G.LootEnabled = Value
        if Value and not _G.LoadedScripts.loot then
            loadScript("loot", SCRIPTS.loot)
        end
    end
})

local CrateToggle = ItemTab:Toggle({
    Title = "Auto Crate Collector",
    Desc = "Tự động thu thập crate",
    Default = false,
    Callback = function(Value)
        _G.CrateCollectorEnabled = Value
        if Value and not _G.LoadedScripts.crate then
            loadScript("crate", SCRIPTS.crate)
        end
    end
})

local CrateDelaySlider = ItemTab:Slider({
    Title = "Crate Check Delay",
    Desc = "Thời gian delay check crate",
    Value = {
        Min = 10,
        Max = 300,
        Default = 60
    },
    Step = 10,
    Callback = function(Value)
        _G.CrateLoopDelay = Value
    end
})

local CrateTPDelaySlider = ItemTab:Slider({
    Title = "Crate TP Delay",
    Desc = "Thời gian delay khi teleport đến crate",
    Value = {
        Min = 0.1,
        Max = 2,
        Default = 0.1
    },
    Step = 0.1,
    Callback = function(Value)
        _G.CrateTPDelay = Value
    end
})

-- === QUEST TAB ===
QuestTab:Section({
    Title = "Auto Quest",
    Icon = "map-pin"
})

local SlayerToggle = QuestTab:Toggle({
    Title = "Auto Slayer Quest",
    Desc = "Tự động làm slayer quest",
    Default = false,
    Callback = function(Value)
        _G.SlayerQuestEnabled = Value
        if Value and not _G.LoadedScripts.slayer then
            loadScript("slayer", SCRIPTS.slayer)
        end
    end
})

local SlayerQuestDropdown = QuestTab:Dropdown({
    Title = "Slayer Quest Ưu Tiên",
    Desc = "Chọn các slayer quest ưu tiên",
    Values = {"Finger Bearer", "Gojo", "Xeno", "Bur", "Dragon knight", "Oni"},
    Value = {"Finger Bearer"},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.PreferredSlayerQuests = Options
    end
})

local SpecialGradeToggle = QuestTab:Toggle({
    Title = "Auto Special Grade Quest",
    Desc = "Tự động làm special grade quest",
    Default = false,
    Callback = function(Value)
        _G.SpecialGradeQuestEnabled = Value
        if Value and not _G.LoadedScripts.specialgrade then
            loadScript("specialgrade", SCRIPTS.specialgrade)
        end
    end
})

local SpecialGradeDelaySlider = QuestTab:Slider({
    Title = "Special Grade Delay",
    Desc = "Thời gian delay cho special grade quest",
    Value = {
        Min = 30,
        Max = 300,
        Default = 60
    },
    Step = 30,
    Callback = function(Value)
        _G.SpecialGradeQuestDelay = Value
    end
})

-- === TRAIT & STATS TAB ===
TraitTab:Section({
    Title = "Auto Trait",
    Icon = "gem"
})

local TraitToggle = TraitTab:Toggle({
    Title = "Auto Pick Trait",
    Desc = "Tự động chọn trait theo ưu tiên",
    Default = false,
    Callback = function(Value)
        _G.TraitAutoPickEnabled = Value
        if Value and not _G.LoadedScripts.trait then
            loadScript("trait", SCRIPTS.trait)
        end
        if _G.TriggerAutoPickTrait then
            _G.TriggerAutoPickTrait()
        end
    end
})

local LegendaryTraitsDropdown = TraitTab:Dropdown({
    Title = "Legendary Traits Ưu Tiên",
    Desc = "Chọn legendary traits ưu tiên",
    Values = {"Prime", "Angelic", "Solar", "Cursed", "Vampiric", "Gluttonous", "Voided", "Gambler", "Overflowing", "Deferred", "True", "Cultivation", "Economic", "Frostbite"},
    Value = {"Prime"},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.TraitList_Legendary = Options
    end
})

local LegendaryHexedTraitsDropdown = TraitTab:Dropdown({
    Title = "Legendary Hexed Traits",
    Desc = "Chọn legendary hexed traits",
    Values = {"Overconfident Prime", "Fallen Angelic", "Icarus Solar", "Undying Cursed", "Ancient Vampiric", "Festering Gluttonous", "Abyssal Voided", "Idle Death Gambler", "Torrential Overflowing", "Fractured Deferred", "Vitriolic True", "Soul Reaping Cultivation", "Greedy Economic"},
    Value = {"Overconfident Prime"},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.TraitList_LegendaryHexed = Options
    end
})

local MythicTraitsDropdown = TraitTab:Dropdown({
    Title = "Mythic Traits Ưu Tiên",
    Desc = "Chọn mythic traits ưu tiên",
    Values = {"Godly", "Temporal", "RCT", "Spiritual", "Ryoiki", "Adaptation"},
    Value = {"Godly"},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.TraitList_Mythic = Options
    end
})

local MythicHexedTraitsDropdown = TraitTab:Dropdown({
    Title = "Mythic Hexed Traits",
    Desc = "Chọn mythic hexed traits",
    Values = {"Egotistic Godly", "FTL Temporal", "Automatic RCT", "Mastered Spiritual", "Overcharged Ryoiki", "Unbound Adaptation"},
    Value = {"Egotistic Godly"},
    Multi = true,
    AllowNone = true,
    Callback = function(Options)
        _G.TraitList_MythicHexed = Options
    end
})

local TraitHistoryButton = TraitTab:Button({
    Title = "Xem 5 Trait Đã Discard",
    Desc = "Hiển thị lịch sử 5 trait đã discard gần nhất",
    Callback = function()
        if _G.TraitDiscardHistory and #_G.TraitDiscardHistory > 0 then
            local historyText = "Trait đã discard:\n"
            for i, traits in ipairs(_G.TraitDiscardHistory) do
                historyText = historyText .. i .. ". " .. traits .. "\n"
            end
            WindUI:Notify({
                Title = "Lịch Sử Trait",
                Content = historyText,
                Duration = 8,
                Icon = "history"
            })
        else
            WindUI:Notify({
                Title = "Không Có Lịch Sử",
                Content = "Chưa discard trait nào",
                Duration = 3,
                Icon = "info"
            })
        end
    end
})

TraitTab:Section({
    Title = "Auto Stats",
    Icon = "trending-up"
})

local StatsToggle = TraitTab:Toggle({
    Title = "Auto Stats",
    Desc = "Tự động phân phối điểm stats",
    Default = false,
    Callback = function(Value)
        _G.AutoStatsEnabled = Value
        if Value and not _G.LoadedScripts.stats then
            loadScript("stats", SCRIPTS.stats)
        end
    end
})

local StatsTypeDropdown = TraitTab:Dropdown({
    Title = "Loại Stats",
    Desc = "Chọn loại stats để phân phối",
    Values = {"Attack", "Defense", "Health", "Special"},
    Value = "Attack",
    Callback = function(Option)
        _G.AutoStatsType = Option
    end
})

local StatsAmountSlider = TraitTab:Slider({
    Title = "Số Điểm Mỗi Lần",
    Desc = "Số điểm stats để phân phối mỗi lần",
    Value = {
        Min = 1,
        Max = 50,
        Default = 1
    },
    Step = 1,
    Callback = function(Value)
        _G.AutoStatsAmount = Value
    end
})

TraitTab:Section({
    Title = "Auto Ascend & Feed",
    Icon = "arrow-up"
})

local AscendToggle = TraitTab:Toggle({
    Title = "Auto Ascend",
    Desc = "Tự động ascend khi đủ điều kiện",
    Default = false,
    Callback = function(Value)
        _G.AutoAscendEnabled = Value
        if Value and not _G.LoadedScripts.asc then
            loadScript("asc", SCRIPTS.asc)
        end
    end
})

local FeedToggle = TraitTab:Toggle({
    Title = "Auto Feed Shards",
    Desc = "Tự động feed shards",
    Default = false,
    Callback = function(Value)
        _G.FeedShardsEnabled = Value
        if Value and not _G.LoadedScripts.feed then
            loadScript("feed", SCRIPTS.feed)
        end
    end
})

-- === SETTINGS TAB ===
SettingsTab:Section({
    Title = "Banner Roll",
    Icon = "dice-1"
})

local BannerToggle = SettingsTab:Toggle({
    Title = "Auto Roll Banner",
    Desc = "Tự động roll banner",
    Default = false,
    Callback = function(Value)
        _G.RollBannerEnabled = Value
        if Value and not _G.LoadedScripts.rollbanner then
            loadScript("rollbanner", SCRIPTS.rollbanner)
        end
    end
})

SettingsTab:Section({
    Title = "Level Farm",
    Icon = "activity"
})

local SpecialLevelFarmToggle = SettingsTab:Toggle({
    Title = "Special Leveling",
    Desc = "Bật special level farming",
    Default = false,
    Callback = function(Value)
        _G.SpecialLevelFarmEnabled = Value
        if Value and not _G.LoadedScripts.speciallevelfarm then
            loadScript("speciallevelfarm", SCRIPTS.speciallevelfarm)
        end
    end
})

SettingsTab:Paragraph({
    Title = "Ghi chú Max Item Bank",
    Desc = "• Tự động nâng max item bank cho Hamon Base.\n• Yêu cầu: ĐÃ LÀM QUEST của Joseph's Informant và đang ở Hamon Base!",
    Color = "Orange"
})

SettingsTab:Section({
    Title = "Thông Tin & Điều Khiển",
    Icon = "info"
})

SettingsTab:Paragraph({
    Title = "AUT Multi-Tool Hub",
    Desc = "• Tất cả script được load từ GitHub\n• Tự động đồng bộ cài đặt\n• Pause logic giữa các script\n• WindUI interface với theme tối ưu",
    Color = "Blue"
})

local ReloadAllButton = SettingsTab:Button({
    Title = "Reload Tất Cả Script",
    Desc = "Reload tất cả script từ GitHub",
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
        WindUI:Notify({
            Title = "Reload Hoàn Tất",
            Content = "Đã reload " .. loaded .. "/" .. total .. " scripts",
            Duration = 3,
            Icon = "refresh-cw"
        })
    end
})

-- Create keybind for toggle GUI (K key like original)
Window:SetToggleKey(Enum.KeyCode.K)

-- Show completion notification
WindUI:Notify({
    Title = "AUT Hub Loaded",
    Content = "Hub đã sẵn sàng sử dụng!",
    Duration = 5,
    Icon = "check"
})