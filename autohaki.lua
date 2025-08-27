-- Auto Haki Toggle Script
-- Bật/tắt qua: getgenv().AutoHakiEnabled = true/false

local UserInputRemote = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.MoveInputService.RF.FireInput
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- Kiểm tra có moves Busoshoku Haki trên GUI
local function hasHakiMove()
    local moves = player.PlayerGui:FindFirstChild("UI")
    and player.PlayerGui.UI:FindFirstChild("Gameplay")
    and player.PlayerGui.UI.Gameplay:FindFirstChild("Moves")
    return moves and moves:FindFirstChild("Busoshoku Haki")
end

-- Kiểm tra có cooldown Haki hay không
local function hasHakiCooldown()
    local cooldowns = player:FindFirstChild("Cooldowns")
    return cooldowns and cooldowns:FindFirstChild("Busoshoku Haki")
end

-- Kiểm tra Haki đã bật trên Left Arm hay chưa
local function isLeftArmHakiOn()
    local living = workspace.Living:FindFirstChild(player.Name)
    if not living then return false end
    local leftArm = living:FindFirstChild("Left Arm")
    if not leftArm then return false end
    local leftHaki = leftArm:FindFirstChild("LeftHakiLimb")
    return leftHaki ~= nil
end

-- Lấy meter
local function getMeter()
    local living = workspace.Living:FindFirstChild(player.Name)
    if not living then return 0 end
    return living:GetAttribute("Meter") or 0
end

-- Heartbeat connection
if getgenv()._AutoHakiConnection then
    getgenv()._AutoHakiConnection:Disconnect()
end

getgenv()._AutoHakiConnection = RunService.Heartbeat:Connect(function()
    if getgenv().AutoHakiEnabled == true then
        pcall(function()
            if hasHakiMove() 
                and getMeter() >= 25 
                and not hasHakiCooldown() 
                and not isLeftArmHakiOn() then
                -- Gửi remote, phím J là skill Haki
                UserInputRemote:InvokeServer("J")
            end
        end)
    end
end)