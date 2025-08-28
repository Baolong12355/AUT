-- AUT Main Loader chuyển sang WindUI - Quản lý tất cả script với WindUI GUI

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
Window:SetToggleKey(Enum.KeyCode.K) -- nếu vẫn muốn dùng phím K cho PC

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

_G.AvailableItems = { -- giữ nguyên danh sách
    "Mining Laser", "Phoenix Gemstone", "Jonathan's Signal", "Coal Loot", "Medic's Equipment",
    -- ... (cắt ngắn cho gọn, bạn dùng lại full list như cũ)
    "Saint's Corpse", "Monochromatic Orb"
}

_G.LoadedScripts = {}
_G.AutoSaveSelectedItems = {}
_G.AutoSellExcludeList = {}
_G.CombatSelectedSkills = {""}

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

-- Tabs
local MainTab = Window:Tab({Title = "Chính", Icon = "home"})
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword"})
local ItemTab = Window:Tab({Title = "Vật Phẩm", Icon = "package"})
local QuestTab = Window:Tab({Title = "Quest", Icon = "map"})
local TraitTab = Window:Tab({Title = "Trait & Stats", Icon = "star"})
local SettingsTab = Window:Tab({Title = "Cài Đặt", Icon = "settings"})

-- === MAIN TAB ===
MainTab:Section({Title = "Tải Script"})
MainTab:Button({
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

-- === COMBAT TAB ===
CombatTab:Section({Title = "Auto Combat"})
CombatTab:Toggle({
    Title = "Auto Combat",
    Default = false,
    Callback = function(Value)
        _G.CombatEnabled = Value
        if Value and not _G.LoadedScripts.combat then loadScript("combat", SCRIPTS.combat) end
        if _G.ResetCombatTarget then _G.ResetCombatTarget() end
    end
})

CombatTab:Dropdown({
    Title = "Loại Quái",
    Values = {"cultists", "cursed", "hooligans", "prisoners", "thugs", "pirates", "guardian"},
    Value = "cultists",
    Callback = function(Options)
        _G.CombatTargetType = Options
        if _G.ResetCombatTarget then _G.ResetCombatTarget() end
    end
})

CombatTab:Slider({
    Title = "Độ Cao Thoát (Studs)",
    Step = 5,
    Value = {Min = 10, Max = 100, Default = 30},
    Callback = function(Value) _G.CombatEscapeHeight = Value end
})

CombatTab:Section({Title = "Combat Skills"})
local availableSkills = {
    "B", "Q", "E", "R", "T", "Y", "U", "F", "G", "H", "Z", "X", "C", "V",
    "B+", "Q+", "E+", "R+", "T+", "Y+", "U+", "F+", "G+", "H+", "Z+", "X+", "C+", "V+",
    "MOUSEBUTTON2"
}
CombatTab:Dropdown({
    Title = "Chọn Skills Combat",
    Values = availableSkills,
    Value = {"B"},
    Multi = true,
    Callback = function(Options) _G.CombatSelectedSkills = Options end
})
CombatTab:Paragraph({
    Title = "Hướng Dẫn Skills",
    Desc = "• Skills thường: B, Q, E, R...\n• Skills nâng cao: B+, Q+, E+, R+...\n• M2: MOUSEBUTTON2\n• Có thể chọn nhiều skills cùng lúc"
})

CombatTab:Section({Title = "Auto Stand On/Off"})
CombatTab:Toggle({
    Title = "Auto Stand (Bật/Tắt)",
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

CombatTab:Dropdown({
    Title = "Chế độ Stand",
    Values = {"on", "off"},
    Value = "on",
    Callback = function(mode)
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

CombatTab:Toggle({
    Title = "Ưu Tiên Slayer Boss",
    Default = false,
    Callback = function(Value) _G.SlayerQuestActive = Value end
})

CombatTab:Section({Title = "Auto One Shot"})
CombatTab:Slider({
    Title = "Ngưỡng HP One Shot (%)",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = 50},
    Callback = function(Value) getgenv().AutoOneShotHPThreshold = Value end
})
CombatTab:Toggle({
    Title = "Auto One Shot (HP dưới ngưỡng)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoOneShotting = Value
        if Value and not _G.LoadedScripts.oneshot then loadScript("oneshot", SCRIPTS.oneshot) end
    end
})
CombatTab:Toggle({
    Title = "Auto Bật Busoshoku Haki",
    Default = false,
    Callback = function(Value)
        getgenv().AutoHakiEnabled = Value
        if Value and not _G.LoadedScripts.autohaki then loadScript("autohaki", SCRIPTS.autohaki) end
    end
})

-- === ITEM TAB ===
ItemTab:Section({Title = "Auto Save Item"})
ItemTab:Toggle({
    Title = "Auto Save Item",
    Default = false,
    Callback = function(Value)
        _G.AutoSaveEnabled = Value
        if Value and not _G.LoadedScripts.autosave then loadScript("autosave", SCRIPTS.autosave) end
    end
})
ItemTab:Dropdown({
    Title = "Chọn Items Cần Save",
    Values = _G.AvailableItems,
    Value = {},
    Multi = true,
    Callback = function(Options) _G.AutoSaveSelectedItems = Options end
})
ItemTab:Button({
    Title = "Save Item Thủ Công",
    Callback = function()
        if not _G.LoadedScripts.autosave then loadScript("autosave", SCRIPTS.autosave) end
        if _G.TriggerAutoSave then _G.TriggerAutoSave() end
    end
})

ItemTab:Section({Title = "Auto Sell"})
ItemTab:Toggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(Value)
        _G.AutoSellEnabled = Value
        if Value and not _G.LoadedScripts.sell then loadScript("sell", SCRIPTS.sell) end
    end
})
ItemTab:Dropdown({
    Title = "Chọn Items KHÔNG Bán",
    Values = _G.AvailableItems,
    Value = {},
    Multi = true,
    Callback = function(Options) _G.AutoSellExcludeList = Options end
})
ItemTab:Slider({
    Title = "Sell Delay (giây)",
    Step = 5,
    Value = {Min = 5, Max = 120, Default = 30},
    Callback = function(Value) _G.AutoSellDelay = Value end
})

ItemTab:Section({Title = "Loot & Crate"})
ItemTab:Toggle({
    Title = "Auto Loot Chest",
    Default = false,
    Callback = function(Value)
        _G.LootEnabled = Value
        if Value and not _G.LoadedScripts.loot then loadScript("loot", SCRIPTS.loot) end
    end
})
ItemTab:Toggle({
    Title = "Auto Crate Collector",
    Default = false,
    Callback = function(Value)
        _G.CrateCollectorEnabled = Value
        if Value and not _G.LoadedScripts.crate then loadScript("crate", SCRIPTS.crate) end
    end
})
ItemTab:Slider({
    Title = "Crate Check Delay",
    Step = 10,
    Value = {Min = 10, Max = 300, Default = 60},
    Callback = function(Value) _G.CrateLoopDelay = Value end
})
ItemTab:Slider({
    Title = "Crate TP Delay",
    Step = 0.1,
    Value = {Min = 0.1, Max = 2, Default = 0.1},
    Callback = function(Value) _G.CrateTPDelay = Value end
})

-- === QUEST TAB ===
QuestTab:Section({Title = "Auto Quest"})
QuestTab:Toggle({
    Title = "Auto Slayer Quest",
    Default = false,
    Callback = function(Value)
        _G.SlayerQuestEnabled = Value
        if Value and not _G.LoadedScripts.slayer then loadScript("slayer", SCRIPTS.slayer) end
    end
})
QuestTab:Dropdown({
    Title = "Slayer Quest Ưu Tiên",
    Values = {"Finger Bearer", "Gojo", "Xeno", "Bur", "Dragon knight", "Oni"},
    Value = {"Finger Bearer"},
    Multi = true,
    Callback = function(Options) _G.PreferredSlayerQuests = Options end
})
QuestTab:Toggle({
    Title = "Auto Special Grade Quest",
    Default = false,
    Callback = function(Value)
        _G.SpecialGradeQuestEnabled = Value
        if Value and not _G.LoadedScripts.specialgrade then loadScript("specialgrade", SCRIPTS.specialgrade) end
    end
})
QuestTab:Slider({
    Title = "Special Grade Delay",
    Step = 30,
    Value = {Min = 30, Max = 300, Default = 60},
    Callback = function(Value) _G.SpecialGradeQuestDelay = Value end
})

-- === TRAIT & STATS TAB ===
TraitTab:Section({Title = "Auto Trait"})
TraitTab:Toggle({
    Title = "Auto Pick Trait",
    Default = false,
    Callback = function(Value)
        _G.TraitAutoPickEnabled = Value
        if Value and not _G.LoadedScripts.trait then loadScript("trait", SCRIPTS.trait) end
        if _G.TriggerAutoPickTrait then _G.TriggerAutoPickTrait() end
    end
})
TraitTab:Dropdown({
    Title = "Legendary Traits Ưu Tiên",
    Values = {"Prime", "Angelic", "Solar", "Cursed", "Vampiric", "Gluttonous", "Voided", "Gambler", "Overflowing", "Deferred", "True", "Cultivation", "Economic", "Frostbite"},
    Value = {"Prime"},
    Multi = true,
    Callback = function(Options) _G.TraitList_Legendary = Options end
})
TraitTab:Dropdown({
    Title = "Legendary Hexed Traits",
    Values = {"Overconfident Prime", "Fallen Angelic", "Icarus Solar", "Undying Cursed", "Ancient Vampiric", "Festering Gluttonous", "Abyssal Voided", "Idle Death Gambler", "Torrential Overflowing", "Fractured Deferred", "Vitriolic True", "Soul Reaping Cultivation", "Greedy Economic"},
    Value = {"Overconfident Prime"},
    Multi = true,
    Callback = function(Options) _G.TraitList_LegendaryHexed = Options end
})
TraitTab:Dropdown({
    Title = "Mythic Traits Ưu Tiên",
    Values = {"Godly", "Temporal", "RCT", "Spiritual", "Ryoiki", "Adaptation"},
    Value = {"Godly"},
    Multi = true,
    Callback = function(Options) _G.TraitList_Mythic = Options end
})
TraitTab:Dropdown({
    Title = "Mythic Hexed Traits",
    Values = {"Egotistic Godly", "FTL Temporal", "Automatic RCT", "Mastered Spiritual", "Overcharged Ryoiki", "Unbound Adaptation"},
    Value = {"Egotistic Godly"},
    Multi = true,
    Callback = function(Options) _G.TraitList_MythicHexed = Options end
})
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
TraitTab:Toggle({
    Title = "Auto Stats",
    Default = false,
    Callback = function(Value)
        _G.AutoStatsEnabled = Value
        if Value and not _G.LoadedScripts.stats then loadScript("stats", SCRIPTS.stats) end
    end
})
TraitTab:Dropdown({
    Title = "Loại Stats",
    Values = {"Attack", "Defense", "Health", "Special"},
    Value = "Attack",
    Callback = function(Options) _G.AutoStatsType = Options end
})
TraitTab:Slider({
    Title = "Số Điểm Mỗi Lần",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = 1},
    Callback = function(Value) _G.AutoStatsAmount = Value end
})

TraitTab:Section({Title = "Auto Ascend & Feed"})
TraitTab:Toggle({
    Title = "Auto Ascend",
    Default = false,
    Callback = function(Value)
        _G.AutoAscendEnabled = Value
        if Value and not _G.LoadedScripts.asc then loadScript("asc", SCRIPTS.asc) end
    end
})
TraitTab:Toggle({
    Title = "Auto Feed Shards",
    Default = false,
    Callback = function(Value)
        _G.FeedShardsEnabled = Value
        if Value and not _G.LoadedScripts.feed then loadScript("feed", SCRIPTS.feed) end
    end
})

-- === SETTINGS TAB ===
SettingsTab:Section({Title = "Banner Roll"})
SettingsTab:Toggle({
    Title = "Auto Roll Banner",
    Default = false,
    Callback = function(Value)
        _G.RollBannerEnabled = Value
        if Value and not _G.LoadedScripts.rollbanner then loadScript("rollbanner", SCRIPTS.rollbanner) end
    end
})

SettingsTab:Section({Title = "level fram"})
SettingsTab:Toggle({
    Title = "special leveling",
    Default = false,
    Callback = function(Value)
        _G.SpecialLevelFarmEnabled = Value
        if Value and not _G.LoadedScripts.speciallevelfarm then loadScript("speciallevelfarm", SCRIPTS.speciallevelfarm) end
    end
})

SettingsTab:Paragraph({
    Title = "Ghi chú Max Item Bank",
    Desc = "• Tự động nâng max item bank cho Hamon Base.\n• Yêu cầu: ĐÃ LÀM QUEST của Joseph's Informant và đang ở Hamon Base!"
})
SettingsTab:Section({Title = "Thông Tin"})
SettingsTab:Paragraph({
    Title = "AUT Multi-Tool Hub",
    Desc = "• Tất cả script được load từ GitHub\n• Tự động đồng bộ cài đặt\n• Pause logic giữa các script\n• Phím tắt: K để ẩn/hiện GUI"
})
SettingsTab:Button({
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