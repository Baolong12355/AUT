-- Equipment Crate Auto Collector (Dừng combat từ lúc phát hiện chat spawn crate đến khi nhặt xong, sau đó tự bật lại nếu trước đó đang bật)

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
    Vector3.new(-70.82891845703125, 81.39054107666016, 834.0664672851562)
}

-- ==== Chat monitor (KHÔNG log file/console, chỉ lưu trạng thái) ====
local lastChat = ""
local chatHistory = {}

local function logToMemory(text)
    if text and text ~= lastChat then
        lastChat = text
        table.insert(chatHistory, text:lower())
        if #chatHistory > 100 then
            table.remove(chatHistory, 1)
        end
    end
end

local function monitorChat()
    -- TextChatService (new chat)
    pcall(function()
        local chatService = game:GetService("TextChatService")
        if chatService then
            chatService.MessageReceived:Connect(function(textChatMessage)
                if textChatMessage.Text then
                    logToMemory(textChatMessage.Text)
                end
            end)
        end
    end)
    -- GUI scan fallback
    local function scanDescendant(desc)
        if desc:IsA("TextLabel") or desc:IsA("TextBox") then
            if desc.Text and #desc.Text > 0 and desc.Text ~= lastChat then
                logToMemory(desc.Text)
            end
            desc:GetPropertyChangedSignal("Text"):Connect(function()
                if desc.Text and #desc.Text > 0 and desc.Text ~= lastChat then
                    logToMemory(desc.Text)
                end
            end)
        end
    end
    local guiTargets = {
        Players.LocalPlayer:WaitForChild("PlayerGui"),
        game:GetService("CoreGui")
    }
    for _, gui in ipairs(guiTargets) do
        gui.DescendantAdded:Connect(scanDescendant)
        for _, desc in ipairs(gui:GetDescendants()) do
            scanDescendant(desc)
        end
        gui.ChildAdded:Connect(function(child)
            scanDescendant(child)
        end)
    end
end

-- ==== Chat utilities ====
local function hasSpawned()
    local spawnKeyword = "equipment crate+has been reported!"
    if lastChat:lower():find(spawnKeyword) then return true end
    for _, chat in pairs(chatHistory) do
        if chat:find(spawnKeyword) then return true end
    end
    return false
end

local function waitForChatKeyword(keyword, timeout)
    local t0 = tick()
    timeout = timeout or 30
    while tick() - t0 < timeout do
        if not _G.CrateCollectorEnabled then return false end
        if lastChat:lower():find(keyword:lower()) then return true end
        for _, chat in pairs(chatHistory) do
            if chat:find(keyword:lower()) then return true end
        end
        task.wait(0.1)
    end
    return false
end

-- ==== Crate logic ====
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
                    _G.CrateCollecting = true
                    teleportTo(crate.Position)
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

spawn(monitorChat)

spawn(function()
    local combatWasEnabled = false
    while true do
        if _G.CrateCollectorEnabled then
            -- Nếu phát hiện crate spawn chat, dừng combat system và nhớ trạng thái
            if hasSpawned() then
                if _G.CombatEnabled then
                    combatWasEnabled = true
                    _G.CombatEnabled = false
                    if _G.ResetCombatTarget then
                        _G.ResetCombatTarget()
                    end
                else
                    combatWasEnabled = false
                end

                -- Xử lý nhặt crate
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

                -- Sau khi nhặt crate xong, nếu combat trước đó bật thì bật lại
                if combatWasEnabled then
                    _G.CombatEnabled = true
                    combatWasEnabled = false
                end

                task.wait(_G.CrateLoopDelay or 60)
            else
                -- Nếu chưa có spawn chat, chờ tiếp
                task.wait(1)
            end
        else
            _G.CrateCollecting = false
            task.wait(1)
        end
    end
end)