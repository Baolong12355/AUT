-- AUT Multi-Tool Hub (WindUI) - Lưu toàn bộ settings vào config + Auto Load Config

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
    OnlyMobile = true,
    Enabled = true,
    Draggable = true,
})
Window:SetToggleKey(Enum.KeyCode.K)

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
    "Mining Laser", "Phoenix Gemstone", "Jonathan's Signal", "Coal Loot", "Saint's Corpse", "Monochromatic Orb"
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
local ConfigTab = Window:Tab({Title = "Config", Icon = "settings"})

------------------ MAIN TAB ------------------
MainTab:Section({Title = "Tải Script"})
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

------------------ COMBAT TAB ------------------
CombatTab:Section({Title = "Auto Combat"})
local CombatToggleElement = CombatTab:Toggle({
    Title = "Auto Combat",
    Default = false,
    Callback = function(Value)
        _G.CombatEnabled = Value
        if Value and not _G.LoadedScripts.combat then loadScript("combat", SCRIPTS.combat) end
        if _G.ResetCombatTarget then _G.ResetCombatTarget() end
    end
})
local CombatTypeDropdownElement = CombatTab:Dropdown({
    Title = "Loại Quái",
    Values = {"cultists", "cursed", "hooligans", "prisoners", "thugs", "pirates", "guardian"},
    Value = "cultists",
    Callback = function(Options)
        _G.CombatTargetType = Options
        if _G.ResetCombatTarget then _G.ResetCombatTarget() end
    end
})
local EscapeHeightSliderElement = CombatTab:Slider({
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
local CombatSkillsDropdownElement = CombatTab:Dropdown({
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
local StandAutoToggleElement = CombatTab:Toggle({
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
local StandStateDropdownElement = CombatTab:Dropdown({
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
local SlayerQuestToggleElement = CombatTab:Toggle({
    Title = "Ưu Tiên Slayer Boss",
    Default = false,
    Callback = function(Value) _G.SlayerQuestActive = Value end
})

CombatTab:Section({Title = "Auto One Shot"})
local OneShotSliderElement = CombatTab:Slider({
    Title = "Ngưỡng HP One Shot (%)",
    Step = 1,
    Value = {Min = 1, Max = 100, Default = 50},
    Callback = function(Value) getgenv().AutoOneShotHPThreshold = Value end
})
local OneShotToggleElement = CombatTab:Toggle({
    Title = "Auto One Shot (HP dưới ngưỡng)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoOneShotting = Value
        if Value and not _G.LoadedScripts.oneshot then loadScript("oneshot", SCRIPTS.oneshot) end
    end
})
local HakiToggleElement = CombatTab:Toggle({
    Title = "Auto Bật Busoshoku Haki",
    Default = false,
    Callback = function(Value)
        getgenv().AutoHakiEnabled = Value
        if Value and not _G.LoadedScripts.autohaki then loadScript("autohaki", SCRIPTS.autohaki) end
    end
})

------------------ ITEM TAB ------------------
ItemTab:Section({Title = "Auto Save Item"})
local AutoSaveToggleElement = ItemTab:Toggle({
    Title = "Auto Save Item",
    Default = false,
    Callback = function(Value)
        _G.AutoSaveEnabled = Value
        if Value and not _G.LoadedScripts.autosave then loadScript("autosave", SCRIPTS.autosave) end
    end
})
local AutoSaveItemsDropdownElement = ItemTab:Dropdown({
    Title = "Chọn Items Cần Save",
    Values = _G.AvailableItems,
    Value = {},
    Multi = true,
    Callback = function(Options) _G.AutoSaveSelectedItems = Options end
})
local AutoSaveManualButton = ItemTab:Button({
    Title = "Save Item Thủ Công",
    Callback = function()
        if not _G.LoadedScripts.autosave then loadScript("autosave", SCRIPTS.autosave) end
        if _G.TriggerAutoSave then _G.TriggerAutoSave() end
    end
})
ItemTab:Section({Title = "Auto Sell"})
local AutoSellToggleElement = ItemTab:Toggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(Value)
        _G.AutoSellEnabled = Value
        if Value and not _G.LoadedScripts.sell then loadScript("sell", SCRIPTS.sell) end
    end
})
local AutoSellExcludeDropdownElement = ItemTab:Dropdown({
    Title = "Chọn Items KHÔNG Bán",
    Values = _G.AvailableItems,
    Value = {},
    Multi = true,
    Callback = function(Options) _G.AutoSellExcludeList = Options end
})
local SellDelaySliderElement = ItemTab:Slider({
    Title = "Sell Delay (giây)",
    Step = 5,
    Value = {Min = 5, Max = 120, Default = 30},
    Callback = function(Value) _G.AutoSellDelay = Value end
})
ItemTab:Section({Title = "Loot & Crate"})
local LootToggleElement = ItemTab:Toggle({
    Title = "Auto Loot Chest",
    Default = false,
    Callback = function(Value)
        _G.LootEnabled = Value
        if Value and not _G.LoadedScripts.loot then loadScript("loot", SCRIPTS.loot) end
    end
})
local CrateToggleElement = ItemTab:Toggle({
    Title = "Auto Crate Collector",
    Default = false,
    Callback = function(Value)
        _G.CrateCollectorEnabled = Value
        if Value and not _G.LoadedScripts.crate then loadScript("crate", SCRIPTS.crate) end
    end
})
local CrateDelaySliderElement = ItemTab:Slider({
    Title = "Crate Check Delay",
    Step = 10,
    Value = {Min = 10, Max = 300, Default = 60},
    Callback = function(Value) _G.CrateLoopDelay = Value end
})
local CrateTPDelaySliderElement = ItemTab:Slider({
    Title = "Crate TP Delay",
    Step = 0.1,
    Value = {Min = 0.1, Max = 2, Default = 0.1},
    Callback = function(Value) _G.CrateTPDelay = Value end
})

------------------ QUEST TAB ------------------
QuestTab:Section({Title = "Auto Quest"})
local SlayerToggleElement = QuestTab:Toggle({
    Title = "Auto Slayer Quest",
    Default = false,
    Callback = function(Value)
        _G.SlayerQuestEnabled = Value
        if Value and not _G.LoadedScripts.slayer then loadScript("slayer", SCRIPTS.slayer) end
    end
})
local SlayerQuestDropdownElement = QuestTab:Dropdown({
    Title = "Slayer Quest Ưu Tiên",
    Values = {"Finger Bearer", "Gojo", "Xeno", "Bur", "Dragon knight", "Oni"},
    Value = {"Finger Bearer"},
    Multi = true,
    Callback = function(Options) _G.PreferredSlayerQuests = Options end
})
local SpecialGradeToggleElement = QuestTab:Toggle({
    Title = "Auto Special Grade Quest",
    Default = false,
    Callback = function(Value)
        _G.SpecialGradeQuestEnabled = Value
        if Value and not _G.LoadedScripts.specialgrade then loadScript("specialgrade", SCRIPTS.specialgrade) end
    end
})
local SpecialGradeDelaySliderElement = QuestTab:Slider({
    Title = "Special Grade Delay",
    Step = 30,
    Value = {Min = 30, Max = 300, Default = 60},
    Callback = function(Value) _G.SpecialGradeQuestDelay = Value end
})

------------------ TRAIT & STATS TAB ------------------
TraitTab:Section({Title = "Auto Trait"})
local TraitToggleElement = TraitTab:Toggle({
    Title = "Auto Pick Trait",
    Default = false,
    Callback = function(Value)
        _G.TraitAutoPickEnabled = Value
        if Value and not _G.LoadedScripts.trait then loadScript("trait", SCRIPTS.trait) end
        if _G.TriggerAutoPickTrait then _G.TriggerAutoPickTrait() end
    end
})
local LegendaryTraitsDropdownElement = TraitTab:Dropdown({
    Title = "Legendary Traits Ưu Tiên",
    Values = {"Prime", "Angelic", "Solar", "Cursed", "Vampiric", "Gluttonous", "Voided", "Gambler", "Overflowing", "Deferred", "True", "Cultivation", "Economic", "Frostbite"},
    Value = {"Prime"},
    Multi = true,
    Callback = function(Options) _G.TraitList_Legendary = Options end
})
local LegendaryHexedTraitsDropdownElement = TraitTab:Dropdown({
    Title = "Legendary Hexed Traits",
    Values = {"Overconfident Prime", "Fallen Angelic", "Icarus Solar", "Undying Cursed", "Ancient Vampiric", "Festering Gluttonous", "Abyssal Voided", "Idle Death Gambler", "Torrential Overflowing", "Fractured Deferred", "Vitriolic True", "Soul Reaping Cultivation", "Greedy Economic"},
    Value = {"Overconfident Prime"},
    Multi = true,
    Callback = function(Options) _G.TraitList_LegendaryHexed = Options end
})
local MythicTraitsDropdownElement = TraitTab:Dropdown({
    Title = "Mythic Traits Ưu Tiên",
    Values = {"Godly", "Temporal", "RCT", "Spiritual", "Ryoiki", "Adaptation"},
    Value = {"Godly"},
    Multi = true,
    Callback = function(Options) _G.TraitList_Mythic = Options end
})
local MythicHexedTraitsDropdownElement = TraitTab:Dropdown({
    Title = "Mythic Hexed Traits",
    Values = {"Egotistic Godly", "FTL Temporal", "Automatic RCT", "Mastered Spiritual", "Overcharged Ryoiki", "Unbound Adaptation"},
    Value = {"Egotistic Godly"},
    Multi = true,
    Callback = function(Options) _G.TraitList_MythicHexed = Options end
})
local TraitHistoryButton = TraitTab:Button({
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
local StatsToggleElement = TraitTab:Toggle({
    Title = "Auto Stats",
    Default = false,
    Callback = function(Value)
        _G.AutoStatsEnabled = Value
        if Value and not _G.LoadedScripts.stats then loadScript("stats", SCRIPTS.stats) end
    end
})
local StatsTypeDropdownElement = TraitTab:Dropdown({
    Title = "Loại Stats",
    Values = {"Attack", "Defense", "Health", "Special"},
    Value = "Attack",
    Callback = function(Options) _G.AutoStatsType = Options end
})
local StatsAmountSliderElement = TraitTab:Slider({
    Title = "Số Điểm Mỗi Lần",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = 1},
    Callback = function(Value) _G.AutoStatsAmount = Value end
})

TraitTab:Section({Title = "Auto Ascend & Feed"})
local AscendToggleElement = TraitTab:Toggle({
    Title = "Auto Ascend",
    Default = false,
    Callback = function(Value)
        _G.AutoAscendEnabled = Value
        if Value and not _G.LoadedScripts.asc then loadScript("asc", SCRIPTS.asc) end
    end
})
local FeedToggleElement = TraitTab:Toggle({
    Title = "Auto Feed Shards",
    Default = false,
    Callback = function(Value)
        _G.FeedShardsEnabled = Value
        if Value and not _G.LoadedScripts.feed then loadScript("feed", SCRIPTS.feed) end
    end
})

------------------ SETTINGS TAB ------------------
SettingsTab:Section({Title = "Banner Roll"})
local BannerToggleElement = SettingsTab:Toggle({
    Title = "Auto Roll Banner",
    Default = false,
    Callback = function(Value)
        _G.RollBannerEnabled = Value
        if Value and not _G.LoadedScripts.rollbanner then loadScript("rollbanner", SCRIPTS.rollbanner) end
    end
})
SettingsTab:Section({Title = "level fram"})
local SpecialLevelFarmToggleElement = SettingsTab:Toggle({
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

------------------ CONFIG TAB (QUẢN LÝ CONFIG + AUTO LOAD) ------------------
local ConfigManager = Window.ConfigManager
local AUTOLOAD_FILE = "windui_autoload_config.txt"
local function saveAutoLoadConfig(name, enabled)
    if writefile then
        writefile(AUTOLOAD_FILE, game:GetService("HttpService"):JSONEncode({config=name, enabled=enabled}))
    end
end
local function readAutoLoadConfig()
    if isfile and isfile(AUTOLOAD_FILE) then
        local data = game:GetService("HttpService"):JSONDecode(readfile(AUTOLOAD_FILE))
        return data.config or "", data.enabled
    end
    return "", false
end

local configNameInput = ConfigTab:Input({
    Title = "Tên Config Mới",
    Placeholder = "Nhập tên config...",
    Value = "",
})
local function getConfigList()
    local configs = ConfigManager:AllConfigs()
    local names = {}
    for i,v in ipairs(configs) do
        table.insert(names, v.Name)
    end
    return names
end
local selectedConfig = ""
local configDropdown = ConfigTab:Dropdown({
    Title = "Chọn Config",
    Values = getConfigList(),
    Value = "",
    Callback = function(option)
        selectedConfig = option
    end
})
local autoLoadToggle = ConfigTab:Toggle({
    Title = "Auto Load Config khi mở script",
    Default = false,
    Callback = function(state)
        saveAutoLoadConfig(selectedConfig, state)
        WindUI:Notify({
            Title = "Auto Load",
            Content = state and ("Auto Load config: " .. selectedConfig) or "Đã tắt Auto Load config!",
            Duration = 3,
            Icon = "check"
        })
    end
})
ConfigTab:Button({
    Title = "Set Auto Load Config",
    Callback = function()
        if selectedConfig == "" then
            WindUI:Notify({
                Title = "Chưa chọn config",
                Content = "Bạn phải chọn một config!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        saveAutoLoadConfig(selectedConfig, true)
        autoLoadToggle:Set(true)
        WindUI:Notify({
            Title = "Đã đặt Auto Load",
            Content = "Auto Load config: " .. selectedConfig,
            Duration = 3,
            Icon = "check"
        })
    end
})
ConfigTab:Button({
    Title = "Tạo & Lưu Config",
    Callback = function()
        local name = configNameInput.Value or "" -- Sửa lỗi Get
        if name == "" then
            WindUI:Notify({
                Title = "Tên thiếu",
                Content = "Bạn phải nhập tên config!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        local myConfig = ConfigManager:CreateConfig(name)
        myConfig:Register("CombatEnabled", CombatToggleElement)
        myConfig:Register("CombatType", CombatTypeDropdownElement)
        myConfig:Register("EscapeHeight", EscapeHeightSliderElement)
        myConfig:Register("CombatSkills", CombatSkillsDropdownElement)
        myConfig:Register("AutoStandEnabled", StandAutoToggleElement)
        myConfig:Register("StandStateMode", StandStateDropdownElement)
        myConfig:Register("SlayerPriority", SlayerQuestToggleElement)
        myConfig:Register("OneShotHPThreshold", OneShotSliderElement)
        myConfig:Register("OneShotEnabled", OneShotToggleElement)
        myConfig:Register("AutoHakiEnabled", HakiToggleElement)
        myConfig:Register("AutoSaveEnabled", AutoSaveToggleElement)
        myConfig:Register("AutoSaveItems", AutoSaveItemsDropdownElement)
        myConfig:Register("AutoSellEnabled", AutoSellToggleElement)
        myConfig:Register("AutoSellExclude", AutoSellExcludeDropdownElement)
        myConfig:Register("SellDelay", SellDelaySliderElement)
        myConfig:Register("LootEnabled", LootToggleElement)
        myConfig:Register("CrateEnabled", CrateToggleElement)
        myConfig:Register("CrateDelay", CrateDelaySliderElement)
        myConfig:Register("CrateTPDelay", CrateTPDelaySliderElement)
        myConfig:Register("SlayerEnabled", SlayerToggleElement)
        myConfig:Register("SlayerQuests", SlayerQuestDropdownElement)
        myConfig:Register("SpecialGradeEnabled", SpecialGradeToggleElement)
        myConfig:Register("SpecialGradeDelay", SpecialGradeDelaySliderElement)
        myConfig:Register("TraitEnabled", TraitToggleElement)
        myConfig:Register("LegendaryTraits", LegendaryTraitsDropdownElement)
        myConfig:Register("LegendaryHexedTraits", LegendaryHexedTraitsDropdownElement)
        myConfig:Register("MythicTraits", MythicTraitsDropdownElement)
        myConfig:Register("MythicHexedTraits", MythicHexedTraitsDropdownElement)
        myConfig:Register("StatsEnabled", StatsToggleElement)
        myConfig:Register("StatsType", StatsTypeDropdownElement)
        myConfig:Register("StatsAmount", StatsAmountSliderElement)
        myConfig:Register("AscendEnabled", AscendToggleElement)
        myConfig:Register("FeedEnabled", FeedToggleElement)
        myConfig:Register("BannerEnabled", BannerToggleElement)
        myConfig:Register("SpecialLevelFarmEnabled", SpecialLevelFarmToggleElement)
        myConfig:Save()
        configDropdown:Refresh(getConfigList())
        WindUI:Notify({
            Title = "Đã lưu config",
            Content = "Config ["..name.."] đã được tạo và lưu!",
            Duration = 3,
            Icon = "check"
        })
    end
})
ConfigTab:Button({
    Title = "Load Config Được Chọn",
    Callback = function()
        if selectedConfig == "" then
            WindUI:Notify({
                Title = "Chưa chọn config",
                Content = "Bạn phải chọn một config!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        local all = ConfigManager:AllConfigs()
        local found
        for _,v in ipairs(all) do
            if v.Name == selectedConfig then found = v break end
        end
        if found then
            found:Load()
            WindUI:Notify({
                Title = "Load thành công",
                Content = "Đã load config: "..selectedConfig,
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Không tìm thấy",
                Content = "Config ["..selectedConfig.."] không tồn tại!",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end
})
ConfigTab:Button({
    Title = "Xoá Config Được Chọn",
    Callback = function()
        if selectedConfig == "" then
            WindUI:Notify({
                Title = "Chưa chọn config",
                Content = "Bạn phải chọn một config!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        local all = ConfigManager:AllConfigs()
        local found, idx
        for i,v in ipairs(all) do
            if v.Name == selectedConfig then found = v idx = i break end
        end
        if found then
            found:Destroy()
            configDropdown:Refresh(getConfigList())
            WindUI:Notify({
                Title = "Đã xoá",
                Content = "Config ["..selectedConfig.."] đã bị xoá!",
                Duration = 3,
                Icon = "trash"
            })
        else
            WindUI:Notify({
                Title = "Không tìm thấy",
                Content = "Config ["..selectedConfig.."] không tồn tại!",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end
})

ConfigTab:Button({
    Title = "Reload Danh Sách Config",
    Callback = function()
        configDropdown:Refresh(getConfigList())
        WindUI:Notify({
            Title = "Đã reload danh sách config",
            Content = "Danh sách config đã được cập nhật!",
            Duration = 2,
            Icon = "refresh-cw"
        })
    end
})


-- Khi script khởi động: tự động load config nếu đã set auto load
local function autoLoadConfigOnStart()
    local name, enabled = readAutoLoadConfig()
    if enabled and name ~= "" then
        local all = ConfigManager:AllConfigs()
        for _,v in ipairs(all) do
            if v.Name == name then
                v:Load()
                WindUI:Notify({
                    Title = "Auto Load Config",
                    Content = "Đã tự động load config: " .. name,
                    Duration = 3,
                    Icon = "check"
                })
                break
            end
        end
    end
end
autoLoadConfigOnStart()

WindUI:Notify({
    Title = "AUT Hub Loaded",
    Content = "Hub đã sẵn sàng sử dụng!",
    Duration = 5,
    Icon = "check"
})