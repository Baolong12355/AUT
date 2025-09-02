-- Service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Player
local player = Players.LocalPlayer

-- Remote Function
local ResetStats = ReplicatedStorage:WaitForChild("ReplicatedModules")
    :WaitForChild("KnitPackage")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("StatService")
    :WaitForChild("RF")
    :WaitForChild("ResetStats")

-- Biến trạng thái
local currentAbilityID = nil
local heartbeatConnection = nil

-- Cập nhật ability ID
local function updateAbilityID()
    local success, result = pcall(function()
        local data = player:WaitForChild("Data", 10)
        local ability = data and data:WaitForChild("Ability", 10)
        return ability and ability.Value
    end)

    if success then
        currentAbilityID = result
    else
        currentAbilityID = nil
    end
end

-- Theo dõi thay đổi ability
local abilityConnection = nil
local function setupAbilityWatcher()
    updateAbilityID()
    
    -- Disconnect connection cũ nếu có
    if abilityConnection then
        abilityConnection:Disconnect()
        abilityConnection = nil
    end
    
    local data = player:FindFirstChild("Data")
    local ability = data and data:FindFirstChild("Ability")

    if ability then
        abilityConnection = ability:GetPropertyChangedSignal("Value"):Connect(function()
            currentAbilityID = ability.Value
        end)
    end
end

-- Bắt đầu auto reset stats
local function startStatsReset()
    if heartbeatConnection then return end
    
    setupAbilityWatcher()
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoStatsResetEnabled then
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
            end
            return
        end
        
        if currentAbilityID then
            pcall(function()
                ResetStats:InvokeServer(currentAbilityID)
            end)
        end
    end)
end

-- Dừng auto reset stats
local function stopStatsReset()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    if abilityConnection then
        abilityConnection:Disconnect()
        abilityConnection = nil
    end
end

-- Kiểm tra trạng thái và bắt đầu nếu cần
if _G.AutoStatsResetEnabled then
    startStatsReset()
end

-- Theo dõi thay đổi trạng thái
local statusConnection = nil
statusConnection = RunService.Heartbeat:Connect(function()
    if _G.AutoStatsResetEnabled and not heartbeatConnection then
        startStatsReset()
    elseif not _G.AutoStatsResetEnabled and heartbeatConnection then
        stopStatsReset()
    end
end)