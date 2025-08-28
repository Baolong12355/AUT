-- Bật/tắt qua: getgenv().AutoHakiEnabled = true/false

local UserInputRemote = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.MoveInputService.RF.FireInput
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Biến toàn cục để quản lý kết nối
getgenv()._AutoHakiEnabled = getgenv().AutoHakiEnabled or false
getgenv()._AutoHakiConnection = nil

-- Kiểm tra có moves Busoshoku Haki trên GUI
local function hasHakiMove()
    local success, result = pcall(function()
        local ui = player:WaitForChild("PlayerGui", 5):WaitForChild("UI", 5)
        local gameplay = ui:WaitForChild("Gameplay", 5)
        local moves = gameplay:WaitForChild("Moves", 5)
        return moves:FindFirstChild("Busoshoku Haki") ~= nil
    end)
    return success and result
end

-- Kiểm tra có cooldown Haki hay không
local function hasHakiCooldown()
    local cooldowns = player:FindFirstChild("Cooldowns")
    return cooldowns and cooldowns:FindFirstChild("Busoshoku Haki")
end

-- Kiểm tra Haki đã bật trên Left Arm hay chưa
local function isLeftArmHakiOn()
    local living = workspace:WaitForChild("Living"):FindFirstChild(player.Name)
    if not living then return false end
    local leftArm = living:FindFirstChild("Left Arm")
    if not leftArm then return false end
    local leftHaki = leftArm:FindFirstChild("LeftHakiLimb")
    return leftHaki ~= nil
end

-- Lấy meter
local function getMeter()
    local living = workspace:WaitForChild("Living"):FindFirstChild(player.Name)
    if not living then return 0 end
    return living:GetAttribute("Meter") or 0
end

-- Tạo kết nối Heartbeat
local function setupAutoHaki()
    -- Ngắt kết nối cũ nếu có
    if getgenv()._AutoHakiConnection then
        getgenv()._AutoHakiConnection:Disconnect()
    end

    -- Kết nối mới
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
end

-- Bắt đầu lần đầu
setupAutoHaki()

-- Gắn sự kiện khi hồi sinh để chạy lại
player.CharacterAdded:Connect(function()
    task.wait(1) -- chờ nhân vật và GUI được tạo lại
    setupAutoHaki()
end)