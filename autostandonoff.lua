local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputRemote = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.MoveInputService.RF.FireInput

local function getStandState()
    local living = workspace.Living:FindFirstChild(player.Name)
    if not living then return nil, nil end
    local states = living:FindFirstChild("StatesFolder")
    if not states then return nil, nil end
    return states:FindFirstChild("StandOn"), states:FindFirstChild("StandOff")
end

if getgenv()._AutoStandStateConnection then
    getgenv()._AutoStandStateConnection:Disconnect()
end

getgenv()._AutoStandStateConnection = RunService.Heartbeat:Connect(function()
    if not getgenv().AutoStandEnabled then return end -- Bật/Tắt tổng từ GUI
    local mode = tostring(getgenv().AutoStandState or "")
    if mode ~= "on" and mode ~= "off" then return end

    local StandOn, StandOff = getStandState()
    if not StandOn or not StandOff then return end

    if mode == "on" then
        if not StandOn.Value then
            UserInputRemote:InvokeServer("Q")
        end
    elseif mode == "off" then
        if not StandOff.Value then
            UserInputRemote:InvokeServer("Q")
        end
    end
end)