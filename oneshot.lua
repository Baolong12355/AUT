getgenv().AutoOneShotting = true
local hpPercentThreshold = 50 -- one shot nếu máu hiện tại <= 10% máu tối đa

task.spawn(function()
    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().AutoOneShotting == true then
            pcall(function()
                for _, k in ipairs(workspace.Living:GetChildren()) do
                    if k:IsA("Model") 
                        and k:FindFirstChild("Head") 
                        and k.Head:IsA("Part") 
                        and k.Head.Name == "Head" 
                        and k.Head ~= game.Players.LocalPlayer.Character.Head then
                        
                        if (k.Head.Position - game.Players.LocalPlayer.Character.Head.Position).Magnitude <= 35 then
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
            end)
        else
            connection:Disconnect()
        end
    end)
end)