-- AUT Multi-Tool Hub - WindUI FULL + Auto Save Config (SAFE) - Sửa lỗi chỉ hiện tab "Chính"

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "AUT Multi-Tool Hub",
    Icon = "package",
    Author = "by Baolong",
    Folder = "AUTHub",
    Theme = "Dark",
    Transparent = false,
    Resizable = true,
    SideBarWidth = 200,
})
Window:EditOpenButton({
    Title = "Open AUT Hub",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})
Window:SetToggleKey(Enum.KeyCode.K)

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("myAUTConfig")

-- Scripts URLs
local REPO_BASE = "https://raw.githubusercontent.com/Baolong12355/AUT/main/"
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

_G.AvailableItems = {
    "Mining Laser", "Phoenix Gemstone", "Jonathan's Signal", "Coal Loot", "Medic's Equipment",
    -- ... bạn thêm đầy đủ như mẫu Rayfield (cắt ngắn ở đây cho gọn, bạn có thể copy nguyên list cũ)
    "Saint's Corpse", "Monochromatic Orb"
}

_G.LoadedScripts = {}
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

local function safeBool(val) return type(val)=="boolean" and val or false end
local function safeTable(val) return type(val)=="table" and val or {} end
local function safeString(val, def) return type(val)=="string" and val or def end
local function safeNumber(val, def) return type(val)=="number" and val or def end

-------------------------------------------
-- ========== TAB CHÍNH ==========
local MainTab = Window:Tab({Title = "Chính", Icon = "home"})
MainTab:Section({Title = "Tải Script"})
MainTab:Paragraph({Title = "Tab Chính", Desc = "Nơi tải và reload script."})
local LoadAllButton = MainTab:Button({
    Title = "Tải Tất Cả Script",
    Callback = function()
        local loaded, total = 0, 0
        for name, url in pairs(SCRIPTS) do
            total = total + 1
            if loadScript(name, url) then loaded = loaded + 1 end
        end
        WindUI:Notify({
            Title = "Hoàn tất",
            Content = "Đã tải " .. loaded .. "/" .. total .. " scripts",
            Duration = 3,
            Icon = "download"
        })
    end
})

-------------------------------------------
-- ========== TAB COMBAT ==========
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword"})
CombatTab:Paragraph({Title = "Combat Tab", Desc = "Tính năng combat."})

CombatTab:Section({Title = "Auto Combat"})
local CombatToggle = CombatTab:Toggle({
    Title = "Auto Combat",
    Default = safeBool(myConfig.Data.CombatEnabled),
    Callback = function(Value)
        _G.CombatEnabled = Value
        if Value and not _G.LoadedScripts.combat then loadScript("combat", SCRIPTS.combat) end
        if _G.ResetCombatTarget then _G.ResetCombatTarget() end
        myConfig:Save()
    end
})
myConfig:Register("CombatEnabled", CombatToggle)

local CombatTypeDropdown = CombatTab:Dropdown({
    Title = "Loại Quái",
    Values = {"cultists", "cursed", "hooligans", "prisoners", "thugs", "pirates", "guardian"},
    Value = safeString(myConfig.Data.CombatType, "cultists"),
    Callback = function(Options)
        _G.CombatTargetType = Options
        if _G.ResetCombatTarget then _G.ResetCombatTarget() end
        myConfig:Save()
    end
})
myConfig:Register("CombatType", CombatTypeDropdown)

local EscapeHeightSlider = CombatTab:Slider({
    Title = "Độ Cao Thoát (Studs)",
    Step = 5,
    Value = {Min = 10, Max = 100, Default = safeNumber(myConfig.Data.EscapeHeight, 30)},
    Callback = function(Value)
        _G.CombatEscapeHeight = Value
        myConfig:Save()
    end
})
myConfig:Register("EscapeHeight", EscapeHeightSlider)

CombatTab:Section({Title = "Combat Skills"})
local availableSkills = {
    "B", "Q", "E", "R", "T", "Y", "U", "F", "G", "H", "Z", "X", "C", "V",
    "B+", "Q+", "E+", "R+", "T+", "Y+", "U+", "F+", "G+", "H+", "Z+", "X+", "C+", "V+",
    "MOUSEBUTTON2"
}
local CombatSkillsDropdown = CombatTab:Dropdown({
    Title = "Chọn Skills Combat",
    Values = availableSkills,
    Value = safeTable(myConfig.Data.CombatSkills),
    Multi = true,
    Callback = function(Options)
        _G.CombatSelectedSkills = Options
        myConfig:Save()
    end
})
myConfig:Register("CombatSkills", CombatSkillsDropdown)

CombatTab:Paragraph({
    Title = "Hướng Dẫn Skills",
    Desc = "• Skills thường: B, Q, E, R...\n• Skills nâng cao: B+, Q+, E+, R+...\n• M2: MOUSEBUTTON2\n• Có thể chọn nhiều skills cùng lúc"
})

CombatTab:Section({Title = "Auto Stand On/Off"})
local StandAutoToggle = CombatTab:Toggle({
    Title = "Auto Stand (Bật/Tắt)",
    Default = safeBool(myConfig.Data.AutoStandEnabled),
    Callback = function(Value)
        getgenv().AutoStandEnabled = Value
        if not Value then
            getgenv().AutoStandState = nil
        else
            if getgenv().AutoStandState ~= "on" and getgenv().AutoStandState ~= "off" then
                getgenv().AutoStandState = "on"
            end
            if not _G.LoadedScripts.standstate then loadScript("standstate", SCRIPTS.standstate) end
        end
        myConfig:Save()
    end
})
myConfig:Register("AutoStandEnabled", StandAutoToggle)

local StandStateDropdown = CombatTab:Dropdown({
    Title = "Chế độ Stand",
    Values = {"on", "off"},
    Value = safeString(myConfig.Data.StandStateMode, "on"),
    Callback = function(mode)
        getgenv().AutoStandState = mode
        if getgenv().AutoStandEnabled and not _G.LoadedScripts.standstate then
            loadScript("standstate", SCRIPTS.standstate)
        end
        myConfig:Save()
    end
})
myConfig:Register("StandStateMode", StandStateDropdown)

local SlayerQuestToggle = CombatTab:Toggle({
    Title = "Ưu Tiên Slayer Boss",
    Default = safeBool(myConfig.Data.SlayerPriority),
    Callback = function(Value)
        _G.SlayerQuestActive = Value
        myConfig:Save()
    end
})
myConfig:Register("SlayerPriority", SlayerQuestToggle)

CombatTab:Section({Title = "Auto One Shot"})
local OneShotSlider = CombatTab:Slider({
    Title = "Ngưỡng HP One Shot (%)",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = safeNumber(myConfig.Data.OneShotHPThreshold, 50)},
    Callback = function(Value)
        getgenv().AutoOneShotHPThreshold = Value
        myConfig:Save()
    end
})
myConfig:Register("OneShotHPThreshold", OneShotSlider)

local OneShotToggle = CombatTab:Toggle({
    Title = "Auto One Shot (HP dưới ngưỡng)",
    Default = safeBool(myConfig.Data.OneShotEnabled),
    Callback = function(Value)
        getgenv().AutoOneShotting = Value
        if Value and not _G.LoadedScripts.oneshot then loadScript("oneshot", SCRIPTS.oneshot) end
        myConfig:Save()
    end
})
myConfig:Register("OneShotEnabled", OneShotToggle)

local HakiToggle = CombatTab:Toggle({
    Title = "Auto Bật Busoshoku Haki",
    Default = safeBool(myConfig.Data.AutoHakiEnabled),
    Callback = function(Value)
        getgenv().AutoHakiEnabled = Value
        if Value and not _G.LoadedScripts.autohaki then loadScript("autohaki", SCRIPTS.autohaki) end
        myConfig:Save()
    end
})
myConfig:Register("AutoHakiEnabled", HakiToggle)

-------------------------------------------
-- ========== TAB VẬT PHẨM ==========
local ItemTab = Window:Tab({Title = "Vật Phẩm", Icon = "package"})
ItemTab:Paragraph({Title = "Tab Vật Phẩm", Desc = "Chức năng vật phẩm."})

ItemTab:Section({Title = "Auto Save Item"})
local AutoSaveToggle = ItemTab:Toggle({
    Title = "Auto Save Item",
    Default = safeBool(myConfig.Data.AutoSaveItem),
    Callback = function(Value)
        _G.AutoSaveEnabled = Value
        if Value and not _G.LoadedScripts.autosave then loadScript("autosave", SCRIPTS.autosave) end
        myConfig:Save()
    end
})
myConfig:Register("AutoSaveItem", AutoSaveToggle)

local AutoSaveItemsDropdown = ItemTab:Dropdown({
    Title = "Chọn Items Cần Save",
    Values = _G.AvailableItems,
    Value = safeTable(myConfig.Data.AutoSaveItems),
    Multi = true,
    Callback = function(Options)
        _G.AutoSaveSelectedItems = Options
        myConfig:Save()
    end
})
myConfig:Register("AutoSaveItems", AutoSaveItemsDropdown)

ItemTab:Button({
    Title = "Save Item Thủ Công",
    Callback = function()
        if not _G.LoadedScripts.autosave then loadScript("autosave", SCRIPTS.autosave) end
        if _G.TriggerAutoSave then _G.TriggerAutoSave() end
    end
})

ItemTab:Section({Title = "Auto Sell"})
local AutoSellToggle = ItemTab:Toggle({
    Title = "Auto Sell",
    Default = safeBool(myConfig.Data.AutoSellEnabled),
    Callback = function(Value)
        _G.AutoSellEnabled = Value
        if Value and not _G.LoadedScripts.sell then loadScript("sell", SCRIPTS.sell) end
        myConfig:Save()
    end
})
myConfig:Register("AutoSellEnabled", AutoSellToggle)

local AutoSellExcludeDropdown = ItemTab:Dropdown({
    Title = "Chọn Items KHÔNG Bán",
    Values = _G.AvailableItems,
    Value = safeTable(myConfig.Data.AutoSellExclude),
    Multi = true,
    Callback = function(Options)
        _G.AutoSellExcludeList = Options
        myConfig:Save()
    end
})
myConfig:Register("AutoSellExclude", AutoSellExcludeDropdown)

local SellDelaySlider = ItemTab:Slider({
    Title = "Sell Delay (giây)",
    Step = 5,
    Value = {Min = 5, Max = 120, Default = safeNumber(myConfig.Data.SellDelay, 30)},
    Callback = function(Value)
        _G.AutoSellDelay = Value
        myConfig:Save()
    end
})
myConfig:Register("SellDelay", SellDelaySlider)

ItemTab:Section({Title = "Loot & Crate"})
local LootToggle = ItemTab:Toggle({
    Title = "Auto Loot Chest",
    Default = safeBool(myConfig.Data.LootEnabled),
    Callback = function(Value)
        _G.LootEnabled = Value
        if Value and not _G.LoadedScripts.loot then loadScript("loot", SCRIPTS.loot) end
        myConfig:Save()
    end
})
myConfig:Register("LootEnabled", LootToggle)

local CrateToggle = ItemTab:Toggle({
    Title = "Auto Crate Collector",
    Default = safeBool(myConfig.Data.CrateEnabled),
    Callback = function(Value)
        _G.CrateCollectorEnabled = Value
        if Value and not _G.LoadedScripts.crate then loadScript("crate", SCRIPTS.crate) end
        myConfig:Save()
    end
})
myConfig:Register("CrateEnabled", CrateToggle)

local CrateDelaySlider = ItemTab:Slider({
    Title = "Crate Check Delay",
    Step = 10,
    Value = {Min = 10, Max = 300, Default = safeNumber(myConfig.Data.CrateDelay, 60)},
    Callback = function(Value)
        _G.CrateLoopDelay = Value
        myConfig:Save()
    end
})
myConfig:Register("CrateDelay", CrateDelaySlider)

local CrateTPDelaySlider = ItemTab:Slider({
    Title = "Crate TP Delay",
    Step = 0.1,
    Value = {Min = 0.1, Max = 2, Default = safeNumber(myConfig.Data.CrateTPDelay, 0.1)},
    Callback = function(Value)
        _G.CrateTPDelay = Value
        myConfig:Save()
    end
})
myConfig:Register("CrateTPDelay", CrateTPDelaySlider)

-------------------------------------------
-- ========== TAB QUEST ==========
local QuestTab = Window:Tab({Title = "Quest", Icon = "map"})
QuestTab:Paragraph({Title = "Quest Tab", Desc = "Chức năng quest."})
QuestTab:Section({Title = "Auto Quest"})

local SlayerToggle = QuestTab:Toggle({
    Title = "Auto Slayer Quest",
    Default = safeBool(myConfig.Data.SlayerEnabled),
    Callback = function(Value)
        _G.SlayerQuestEnabled = Value
        if Value and not _G.LoadedScripts.slayer then loadScript("slayer", SCRIPTS.slayer) end
        myConfig:Save()
    end
})
myConfig:Register("SlayerEnabled", SlayerToggle)

local SlayerQuestDropdown = QuestTab:Dropdown({
    Title = "Slayer Quest Ưu Tiên",
    Values = {"Finger Bearer", "Gojo", "Xeno", "Bur", "Dragon knight", "Oni"},
    Value = safeTable(myConfig.Data.SlayerQuests),
    Multi = true,
    Callback = function(Options)
        _G.PreferredSlayerQuests = Options
        myConfig:Save()
    end
})
myConfig:Register("SlayerQuests", SlayerQuestDropdown)

local SpecialGradeToggle = QuestTab:Toggle({
    Title = "Auto Special Grade Quest",
    Default = safeBool(myConfig.Data.SpecialGradeEnabled),
    Callback = function(Value)
        _G.SpecialGradeQuestEnabled = Value
        if Value and not _G.LoadedScripts.specialgrade then loadScript("specialgrade", SCRIPTS.specialgrade) end
        myConfig:Save()
    end
})
myConfig:Register("SpecialGradeEnabled", SpecialGradeToggle)

local SpecialGradeDelaySlider = QuestTab:Slider({
    Title = "Special Grade Delay",
    Step = 30,
    Value = {Min = 30, Max = 300, Default = safeNumber(myConfig.Data.SpecialGradeDelay, 60)},
    Callback = function(Value)
        _G.SpecialGradeQuestDelay = Value
        myConfig:Save()
    end
})
myConfig:Register("SpecialGradeDelay", SpecialGradeDelaySlider)

-------------------------------------------
-- ========== TAB TRAIT & STATS ==========
local TraitTab = Window:Tab({Title = "Trait & Stats", Icon = "star"})
TraitTab:Paragraph({Title = "Trait & Stats Tab", Desc = "Chức năng trait & stats."})
TraitTab:Section({Title = "Auto Trait"})

local TraitToggle = TraitTab:Toggle({
    Title = "Auto Pick Trait",
    Default = safeBool(myConfig.Data.TraitEnabled),
    Callback = function(Value)
        _G.TraitAutoPickEnabled = Value
        if Value and not _G.LoadedScripts.trait then loadScript("trait", SCRIPTS.trait) end
        if _G.TriggerAutoPickTrait then _G.TriggerAutoPickTrait() end
        myConfig:Save()
    end
})
myConfig:Register("TraitEnabled", TraitToggle)

TraitTab:Dropdown({
    Title = "Legendary Traits Ưu Tiên",
    Values = {"Prime", "Angelic", "Solar", "Cursed", "Vampiric", "Gluttonous", "Voided", "Gambler", "Overflowing", "Deferred", "True", "Cultivation", "Economic", "Frostbite"},
    Value = safeTable(myConfig.Data.LegendaryTraits),
    Multi = true,
    Callback = function(Options)
        _G.TraitList_Legendary = Options
        myConfig:Save()
    end
}):Register("LegendaryTraits", TraitTab)

TraitTab:Dropdown({
    Title = "Legendary Hexed Traits",
    Values = {"Overconfident Prime", "Fallen Angelic", "Icarus Solar", "Undying Cursed", "Ancient Vampiric", "Festering Gluttonous", "Abyssal Voided", "Idle Death Gambler", "Torrential Overflowing", "Fractured Deferred", "Vitriolic True", "Soul Reaping Cultivation", "Greedy Economic"},
    Value = safeTable(myConfig.Data.LegendaryHexedTraits),
    Multi = true,
    Callback = function(Options)
        _G.TraitList_LegendaryHexed = Options
        myConfig:Save()
    end
}):Register("LegendaryHexedTraits", TraitTab)

TraitTab:Dropdown({
    Title = "Mythic Traits Ưu Tiên",
    Values = {"Godly", "Temporal", "RCT", "Spiritual", "Ryoiki", "Adaptation"},
    Value = safeTable(myConfig.Data.MythicTraits),
    Multi = true,
    Callback = function(Options)
        _G.TraitList_Mythic = Options
        myConfig:Save()
    end
}):Register("MythicTraits", TraitTab)

TraitTab:Dropdown({
    Title = "Mythic Hexed Traits",
    Values = {"Egotistic Godly", "FTL Temporal", "Automatic RCT", "Mastered Spiritual", "Overcharged Ryoiki", "Unbound Adaptation"},
    Value = safeTable(myConfig.Data.MythicHexedTraits),
    Multi = true,
    Callback = function(Options)
        _G.TraitList_MythicHexed = Options
        myConfig:Save()
    end
}):Register("MythicHexedTraits", TraitTab)

TraitTab:Button({
    Title = "Xem 5 Trait Đã Discard",
    Callback = function()
        if _G.TraitDiscardHistory and #_G.TraitDiscardHistory > 0 then
            local historyText = "Trait đã discard:\n"
            for i, traits in ipairs(_G.TraitDiscardHistory) do
                historyText = historyText .. i .. ". " .. traits .. "\n"
            end
            WindUI:Notify({
                Title = "Lịch Sử Trait",
                Content = historyText,
                Duration = 8
            })
        else
            WindUI:Notify({
                Title = "Không Có Lịch Sử",
                Content = "Chưa discard trait nào",
                Duration = 3
            })
        end
    end
})

TraitTab:Section({Title = "Auto Stats"})
local StatsToggle = TraitTab:Toggle({
    Title = "Auto Stats",
    Default = safeBool(myConfig.Data.StatsEnabled),
    Callback = function(Value)
        _G.AutoStatsEnabled = Value
        if Value and not _G.LoadedScripts.stats then loadScript("stats", SCRIPTS.stats) end
        myConfig:Save()
    end
})
myConfig:Register("StatsEnabled", StatsToggle)

local StatsTypeDropdown = TraitTab:Dropdown({
    Title = "Loại Stats",
    Values = {"Attack", "Defense", "Health", "Special"},
    Value = safeString(myConfig.Data.StatsType, "Attack"),
    Callback = function(Options)
        _G.AutoStatsType = Options
        myConfig:Save()
    end
})
myConfig:Register("StatsType", StatsTypeDropdown)

local StatsAmountSlider = TraitTab:Slider({
    Title = "Số Điểm Mỗi Lần",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = safeNumber(myConfig.Data.StatsAmount, 1)},
    Callback = function(Value)
        _G.AutoStatsAmount = Value
        myConfig:Save()
    end
})
myConfig:Register("StatsAmount", StatsAmountSlider)

TraitTab:Section({Title = "Auto Ascend & Feed"})
local AscendToggle = TraitTab:Toggle({
    Title = "Auto Ascend",
    Default = safeBool(myConfig.Data.AscendEnabled),
    Callback = function(Value)
        _G.AutoAscendEnabled = Value
        if Value and not _G.LoadedScripts.asc then loadScript("asc", SCRIPTS.asc) end
        myConfig:Save()
    end
})
myConfig:Register("AscendEnabled", AscendToggle)

local FeedToggle = TraitTab:Toggle({
    Title = "Auto Feed Shards",
    Default = safeBool(myConfig.Data.FeedEnabled),
    Callback = function(Value)
        _G.FeedShardsEnabled = Value
        if Value and not _G.LoadedScripts.feed then loadScript("feed", SCRIPTS.feed) end
        myConfig:Save()
    end
})
myConfig:Register("FeedEnabled", FeedToggle)

-------------------------------------------
-- ========== TAB CÀI ĐẶT ==========
local SettingsTab = Window:Tab({Title = "Cài Đặt", Icon = "settings"})
SettingsTab:Paragraph({Title = "Settings Tab", Desc = "Chức năng cài đặt."})
SettingsTab:Section({Title = "Banner Roll"})
local BannerToggle = SettingsTab:Toggle({
    Title = "Auto Roll Banner",
    Default = safeBool(myConfig.Data.BannerEnabled),
    Callback = function(Value)
        _G.RollBannerEnabled = Value
        if Value and not _G.LoadedScripts.rollbanner then loadScript("rollbanner", SCRIPTS.rollbanner) end
        myConfig:Save()
    end
})
myConfig:Register("BannerEnabled", BannerToggle)

SettingsTab:Section({Title = "level fram"})
local SpecialLevelFarmToggle = SettingsTab:Toggle({
    Title = "special leveling",
    Default = safeBool(myConfig.Data.SpecialLevelFarmEnabled),
    Callback = function(Value)
        _G.SpecialLevelFarmEnabled = Value
        if Value and not _G.LoadedScripts.speciallevelfarm then loadScript("speciallevelfarm", SCRIPTS.speciallevelfarm) end
        myConfig:Save()
    end
})
myConfig:Register("SpecialLevelFarmEnabled", SpecialLevelFarmToggle)

SettingsTab:Paragraph({
    Title = "Ghi chú Max Item Bank",
    Desc = "• Tự động nâng max item bank cho Hamon Base.\n• Yêu cầu: ĐÃ LÀM QUEST của Joseph's Informant và đang ở Hamon Base!"
})

SettingsTab:Section({Title = "Thông Tin"})
SettingsTab:Paragraph({
    Title = "AUT Multi-Tool Hub",
    Desc = "• Tất cả script được load từ GitHub\n• Tự động đồng bộ cài đặt\n• Pause logic giữa các script\n• Phím tắt: K để ẩn/hiện GUI"
})

local ReloadAllButton = SettingsTab:Button({
    Title = "Reload Tất Cả Script",
    Callback = function()
        _G.LoadedScripts = {}
        local loaded, total = 0, 0
        for name, url in pairs(SCRIPTS) do
            total = total + 1
            if loadScript(name, url) then loaded = loaded + 1 end
        end
        WindUI:Notify({
            Title = "Reload Hoàn Tất",
            Content = "Đã reload " .. loaded .. "/" .. total .. " scripts",
            Duration = 3,
            Icon = "refresh-cw"
        })
    end
})

WindUI:Notify({
    Title = "AUT Hub Loaded",
    Content = "Hub đã sẵn sàng sử dụng!",
    Duration = 5,
    Icon = "check"
})

myConfig:Load() -- Tải config khi mở hub