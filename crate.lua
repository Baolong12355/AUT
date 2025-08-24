-- Equipment Crate Auto Collector (Tự động tắt combat khi phát hiện crate, chờ hồi sinh khi chiết)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

_G.CrateCollectorEnabled = _G.CrateCollectorEnabled or false
_G.CrateTPDelay = _G.CrateTPDelay or 0.1
_G.CrateLoopDelay = _G.CrateLoopDelay or 60
_G.CrateCollecting = _G.CrateCollecting or false

local spawnPositions = {
    Vector3.new(-746.103271484375, 86.75, -620.1206),
    Vector3.new(-353.0508, 132.3436, 50.36768),
    Vector3.new(-70.82892, 81.39054, 834.0665)
}

local function getHumanoidRootPart()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function teleportTo(position)
    local humanoidRootPart = getHumanoidRootPart()
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function checkAndCollectCrate()
    local itemSpawns = workspace:FindFirstChild("ItemSpawns")
    if not itemSpawns then return false end

    local labCrate = itemSpawns:FindFirstChild("LabCrate")
    if not labCrate then return false end

    for _, crateSpawn in pairs(labCrate:GetChildren()) do
        local crate = crateSpawn:FindFirstChild("Crate")
        if crate then
            local proximityAttachment = crate:FindFirstChild("ProximityAttachment")
            if proximityAttachment then
                local interaction = proximityAttachment:FindFirstChild("Interaction")
                if interaction and interaction.Enabled then
                    -- Đánh dấu đang nhặt crate, TẮT COMBAT nếu đang bật
                    _G.CrateCollecting = true
                    if _G.CombatEnabled then
                        _G.CombatEnabled = false
                        if _G.ResetCombatTarget then
                            _G.ResetCombatTarget()
                        end
                    end

                    teleportTo(crate.Position)
                    -- Chờ hồi sinh nếu bị chiết
                    while interaction.Enabled do
                        -- Nếu bị chiết thì chờ hồi sinh rồi tiếp tục
                        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                            repeat
                                player.CharacterAdded:Wait()
                                task.wait(0.2)
                            until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            teleportTo(crate.Position)
                        end
                        fireproximityprompt(interaction)
                        task.wait(0.1)
                    end

                    -- Gọi remote nộp crate
                    local args = {[1] = "TurnInCrate"}
                    ReplicatedStorage:WaitForChild("ReplicatedModules")
                        :WaitForChild("KnitPackage")
                        :WaitForChild("Knit")
                        :WaitForChild("Services")
                        :WaitForChild("DialogueService")
                        :WaitForChild("RF")
                        :WaitForChild("CheckRequirement")
                        :InvokeServer(unpack(args))

                    _G.CrateCollecting = false
                    return true
                end
            end
        end
    end
    return false
end

local function checkSpawnLocationAtPosition(position)
    local itemSpawns = workspace:FindFirstChild("ItemSpawns")
    if not itemSpawns then return false end

    local labCrate = itemSpawns:FindFirstChild("LabCrate")
    if not labCrate then return false end

    for _, spawnLocation in pairs(labCrate:GetChildren()) do
        if spawnLocation.Name == "SpawnLocation" and spawnLocation.Position then
            local distance = (spawnLocation.Position - position).Magnitude
            if distance < 50 then
                return true
            end
        end
    end

    return false
end

spawn(function()
    while true do
        if _G.CrateCollectorEnabled then
            local foundCrate = false
            for _, pos in ipairs(spawnPositions) do
                teleportTo(pos)
                task.wait(_G.CrateTPDelay or 0.1)

                if checkSpawnLocationAtPosition(pos) then
                    if checkAndCollectCrate() then
                        foundCrate = true
                        break
                    end
                end
            end
            _G.CrateCollecting = false
            task.wait(_G.CrateLoopDelay or 60)
        else
            _G.CrateCollecting = false
            task.wait(1)
        end
    end
end)