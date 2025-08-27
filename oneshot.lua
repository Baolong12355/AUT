getgenv().AutoOneShotting = getgenv().AutoOneShotting or false
local hpPercentThreshold = 50 -- one shot nếu máu hiện tại <= 50% máu tối đa

local player = game.Players.LocalPlayer

local function doOneShot()
    for _, k in ipairs(workspace.Living:GetChildren()) do
        if k:IsA("Model")
            and k:FindFirstChild("Head")
            and k.Head:IsA("Part")
            and k.Head.Name == "Head"
            and player.Character
            and player.Character:FindFirstChild("Head")
            and k.Head ~= player.Character.Head then

            if (k.Head.Position - player.Character.Head.Position).Magnitude <= 35 then
                local humanoid = k:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local health = humanoid.Health or humanoid:GetAttribute("Health")
                    local maxHealth = humanoid.MaxHealth or humanoid:GetAttribute("MaxHealth")

                    if health and maxHealth and health < maxHealth then
                        local percent = (health / maxHealth) * 100
                        if percent <= hpPercentThreshold then
                            local success = pcall(function()
                                humanoid.Health = 0
                            end)

                            if not success then
                                pcall(function()
                                    humanoid:SetAttribute("Health", 0)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

if not getgenv()._AutoOneShotConnection then
    getgenv()._AutoOneShotConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().AutoOneShotting == true then
            pcall(doOneShot)
        end
    end)
end