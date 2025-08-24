-- Auto Crate Collector - Dùng method đọc chat, không log, không file, chỉ dùng biến nội bộ (_G)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

_G.CrateCollectorEnabled = _G.CrateCollectorEnabled or false
_G.CrateTPDelay = _G.CrateTPDelay or 0.1
_G.CrateLoopDelay = _G.CrateLoopDelay or 60
_G.CrateCollecting = _G.CrateCollecting or false

local positionsToCheck = {
    Vector3.new(-746.103271484375, 86.75001525878906, -620.12060546875),
    Vector3.new(-353.05078125, 132.3436279296875, 50.36767578125),
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

local function hasDespawned()
    local despawnKeyword = "equipment crate+has despawned or been turned in!"
    if lastChat:lower():find(despawnKeyword) then return true end
    for _, chat in pairs(chatHistory) do
        if chat:find(despawnKeyword) then return true end
    end
    return false
end

-- ==== Crate logic ====
local function getHumanoidRootPart()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHumanoidRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(pos)
    end
end

local function getValidCrate()
    local itemSpawns = workspace:FindFirstChild("ItemSpawns")
    if not itemSpawns then return nil, nil end
    local labCrate = itemSpawns:FindFirstChild("LabCrate")
    if not labCrate then return nil, nil end
    for _, spawn in ipairs(labCrate:GetChildren()) do
        local crate = spawn:FindFirstChild("Crate")
        if crate then
            local pa = crate:FindFirstChild("ProximityAttachment")
            if pa then
                local prox = pa:FindFirstChild("Interaction")
                if prox and prox.Enabled then
                    return crate, prox
                end
            end
        end
    end
    return nil, nil
end

local function turnInCrate()
    pcall(function()
        ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services
            .DialogueService.RF.CheckRequirement:InvokeServer("TurnInCrate")
    end)
end

local function collectCrate(crate, prox)
    if not crate or not prox then return false end
    _G.CrateCollecting = true

    -- Chờ hồi sinh nếu bị chiết
    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
        if not _G.CrateCollectorEnabled then _G.CrateCollecting = false return false end
        player.CharacterAdded:Wait()
        task.wait(0.2)
    end

    teleportTo(crate.Position)
    task.wait(0.05)
    fireproximityprompt(prox, 1, true)

    local timeout = 0
    while prox.Enabled and timeout < 5 do
        if not _G.CrateCollectorEnabled then _G.CrateCollecting = false return false end
        -- Nếu bị chiết thì chờ hồi sinh và tiếp tục
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            repeat
                player.CharacterAdded:Wait()
                task.wait(0.2)
            until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            teleportTo(crate.Position)
        end
        task.wait(0.1)
        timeout = timeout + 0.1
    end

    if not prox.Enabled then
        turnInCrate()
        _G.CrateCollecting = false
        return true
    end

    _G.CrateCollecting = false
    return false
end

-- ==== Main loop ====
spawn(monitorChat)

spawn(function()
    while true do
        if _G.CrateCollectorEnabled then
            local found = false
            for _, pos in ipairs(positionsToCheck) do
                teleportTo(pos)
                task.wait(_G.CrateTPDelay or 0.1)
                local crate, prox = getValidCrate()
                if crate and prox then
                    if collectCrate(crate, prox) then
                        found = true
                        -- Chờ chat despawn xác nhận xong
                        waitForChatKeyword("equipment crate+has despawned or been turned in!", 10)
                        break
                    end
                end
            end
            if not found then
                -- Không thấy crate, chờ chat thông báo spawn
                waitForChatKeyword("equipment crate+has been reported!", _G.CrateLoopDelay or 60)
            end
            _G.CrateCollecting = false
            task.wait(_G.CrateLoopDelay or 60)
        else
            _G.CrateCollecting = false
            task.wait(1)
        end
    end
end)