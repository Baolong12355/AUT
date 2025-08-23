-- Equipment Crate Auto Collector (Bật/tắt, tuỳ chỉnh delay qua loader)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Loader/GUI có thể chỉnh các biến này
_G.CrateCollectorEnabled = _G.CrateCollectorEnabled or false
_G.CrateTPDelay = _G.CrateTPDelay or 0.1     -- Delay giữa mỗi lần teleport (giây)
_G.CrateLoopDelay = _G.CrateLoopDelay or 60  -- Delay mỗi vòng lặp lớn (giây)

-- Danh sách vị trí spawn
local spawnPositions = {
    Vector3.new(-746.103271484375, 86.75001525878906, -620.12060546875),
    Vector3.new(-353.05078125, 132.3436279296875, 50.36767578125),
    Vector3.new(-70.82891845703125, 81.39054107666016, 834.0664672851562)
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
                    -- Teleport đến crate
                    teleportTo(crate.Position)

                    -- Tương tác
                    while interaction.Enabled do
                        fireproximityprompt(interaction)
                        task.wait(0.1)
                    end

                    -- Gọi remote
                    local args = {[1] = "TurnInCrate"}
                    ReplicatedStorage:WaitForChild("ReplicatedModules")
                        :WaitForChild("KnitPackage")
                        :WaitForChild("Knit")
                        :WaitForChild("Services")
                        :WaitForChild("DialogueService")
                        :WaitForChild("RF")
                        :WaitForChild("CheckRequirement")
                        :InvokeServer(unpack(args))

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

-- Hàm chính, chỉ chạy khi bật _G.CrateCollectorEnabled
spawn(function()
    while true do
        if _G.CrateCollectorEnabled then
            for _, pos in ipairs(spawnPositions) do
                teleportTo(pos)
                task.wait(_G.CrateTPDelay or 0.1)

                if checkSpawnLocationAtPosition(pos) then
                    if checkAndCollectCrate() then
                        break -- nếu đã nhặt được crate thì không cần kiểm tra tiếp
                    end
                end
            end
            task.wait(_G.CrateLoopDelay or 60)
        else
            task.wait(1)
        end
    end
end)