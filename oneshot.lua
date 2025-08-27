-- AutoOneShotting Script (tích hợp loader)
getgenv().AutoOneShotting = getgenv().AutoOneShotting or false
local hpPercentThreshold = getgenv().AutoOneShotHPThreshold or 50

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

-- Đảm bảo chỉ tạo 1 connection duy nhất
if not getgenv()._AutoOneShotConnection or not getgenv()._AutoOneShotConnection.Connected then
    getgenv()._AutoOneShotConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().AutoOneShotting == true then
            pcall(doOneShot)
        end
    end)
end