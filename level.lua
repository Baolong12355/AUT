if game.PlaceId ~= 8023712967 then return end

local Players = game:GetService("Players")
if not Players.LocalPlayer.Character then
    Players.LocalPlayer.CharacterAdded:Wait()
end

local REPO_BASE = "https://raw.githubusercontent.com/Baolong12355/AUT/main/"

_G.LoadedScripts = _G.LoadedScripts or {}

local function loadScript(name, url)
    if _G.LoadedScripts[name] then return end
    pcall(function()
        loadstring(game:HttpGet(url))()
        _G.LoadedScripts[name] = true
    end)
end

loadScript("asc", REPO_BASE .. "asc.lua")
loadScript("rollbanner", REPO_BASE .. "rollbanner.lua")
loadScript("feed", REPO_BASE .. "feed.lua")

_G.AutoAscendEnabled = true
_G.RollBannerEnabled = true
_G.FeedShardsEnabled = true