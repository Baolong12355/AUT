local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

-- Global settings
_G.CombatEnabled = _G.CombatEnabled or false
_G.CombatTargetType = _G.CombatTargetType or "cultists"
_G.CombatEscapeHeight = _G.CombatEscapeHeight or 30
_G.CombatSelectedSkills = _G.CombatSelectedSkills or {"B"}
_G.CrateCollecting = _G.CrateCollecting or false
_G.ItemAutoSaving = _G.ItemAutoSaving or false
_G.SlayerQuestActive = _G.SlayerQuestActive or false
_G.LootEnabled = _G.LootEnabled or false
_G.LootCollecting = _G.LootCollecting or false

local combatSettings = {
    selectedSkills = _G.CombatSelectedSkills,
    escapeHeight = _G.CombatEscapeHeight,
    targetType = _G.CombatTargetType,
    currentSkillIndex = 1,
    lastEnabled = _G.CombatEnabled,
    lastTargetType = _G.CombatTargetType
}

local targetLists = {
    cultists = {
        "workspace.Living.Assailant",
        "workspace.Living.Conjurer"
    },
    cursed = {
        "workspace.Living.Roppongi Curse",
        "workspace.Living.Mantis Curse",
        "workspace.Living.Jujutsu Sorcerer",
        "workspace.Living.Flyhead"
    }
}

local waitPositions = {
    cultists = Vector3.new(10291.4921875, 6204.5986328125, -255.45745849609375),
    cursed = Vector3.new(-240.7166290283203, 233.30340576171875, 417.1275939941406)
}

local FireInput = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.MoveInputService.RF.FireInput

local currentTarget = nil
local isInCombat = false
local shouldEscape = false
local lastSkillTime = {}
local lastSkillUse = 0
local chestToLoot = nil

local slayerBossMap = {
    ["dragon"] = "The Knight",
    ["gojo"] = "The Honored One",
    ["oni"] = "The Oni",
    ["xeno"] = "Shadow Assassin",
    ["finger bearer"] = "The Bearer",
    ["bur"] = "The Boss"
}

local heartbeatTPConnection = nil

local function getTargetFromPath(path)
    local success, result = pcall(function()
        local parts = string.split(path, ".")
        local obj = _G
        for i, part in ipairs(parts) do
            if i == 1 and part == "workspace" then
                obj = workspace
            else
                local cleanPart = part:gsub("'", ""):gsub("%[", ""):gsub("%]", "")
                obj = obj:FindFirstChild(cleanPart)
                if not obj then return nil end
            end
        end
        return obj
    end)
    return success and result or nil
end

local function isValidTarget(target)
    return target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid")
end

local function isTargetAlive(target)
    if not isValidTarget(target) then return false end
    local humanoid = target:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isStunned()
    local character = localPlayer.Character
    if not character then return false end
    return character:GetAttribute("Stunned") or false
end

local function isRagdolled()
    local character = localPlayer.Character
    if not character then return false end
    return character:GetAttribute("Ragdolled") or false
end

local function hasCooldown(skillKey)
    local character = localPlayer.Character
    if not character then return true end
    local cooldownFolder = character:FindFirstChild("Cooldowns")
    if not cooldownFolder then return false end
    return cooldownFolder:FindFirstChild(skillKey) ~= nil
end

local function teleportToPosition(position)
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    character.HumanoidRootPart.CFrame = CFrame.new(position)
end

local function teleportBehindTarget(target)
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not isValidTarget(target) then return end
    local targetCFrame = target.HumanoidRootPart.CFrame
    local behindPos = targetCFrame * CFrame.new(0, 0, 5)
    character.HumanoidRootPart.CFrame = behindPos
end

local function escapeToHeight(target)
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local escapePos
    if isValidTarget(target) then
        escapePos = target.HumanoidRootPart.Position + Vector3.new(0, _G.CombatEscapeHeight, 0)
    else
        escapePos = character.HumanoidRootPart.Position + Vector3.new(0, _G.CombatEscapeHeight, 0)
    end
    character.HumanoidRootPart.CFrame = CFrame.new(escapePos)
end

local function useSkill(skillKey)
    local success = pcall(function()
        FireInput:InvokeServer(skillKey)
    end)
    if success then
        lastSkillTime[skillKey] = tick()
        lastSkillUse = tick()
        return true
    end
    return false
end

local function getSlayerBossTarget()
    for _, bossName in pairs(slayerBossMap) do
        local boss = Workspace.Living:FindFirstChild(bossName)
        if boss and isTargetAlive(boss) then
            return boss
        end
    end
    return nil
end

local function checkForChestToLoot()
    if not _G.LootEnabled then return nil end
    for _, chest in ipairs(workspace:GetDescendants()) do
        if chest:IsA("BasePart") and chest.Name:lower():find("chest") then
            local pa = chest:FindFirstChild("ProximityAttachment")
            if pa then
                local prompt = pa:FindFirstChild("Interaction")
                if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local whitelist = chest:FindFirstChild("Whitelisted")
                    if whitelist and whitelist:IsA("Folder") then
                        for _, v in ipairs(whitelist:GetChildren()) do
                            if tonumber(v.Name) == localPlayer.UserId then
                                return chest
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function findRandomTarget()
    local validTargets = {}
    
    -- FIXED: Luôn kiểm tra chest trước, bất kể có boss slayer hay không
    chestToLoot = checkForChestToLoot()
    
    -- Ưu tiên slayer boss nếu có
    if _G.SlayerQuestActive then
        local boss = getSlayerBossTarget()
        if boss then table.insert(validTargets, boss) end
    end
    
    -- Thêm target thường
    local targetPaths = targetLists[_G.CombatTargetType]
    for _, path in ipairs(targetPaths or {}) do
        local target = getTargetFromPath(path)
        if isTargetAlive(target) then
            table.insert(validTargets, target)
        end
    end
    
    if #validTargets > 0 then
        return validTargets[math.random(1, #validTargets)]
    end
    return nil
end

function _G.ResetCombatTarget()
    currentTarget = nil
    chestToLoot = nil
end

-- Heartbeat teleport logic (liên tục giữ vị trí hợp lý với target)
local function startHeartbeatTeleport()
    if heartbeatTPConnection then
        heartbeatTPConnection:Disconnect()
        heartbeatTPConnection = nil
    end
    heartbeatTPConnection = RunService.Heartbeat:Connect(function()
        if not _G.CombatEnabled then return end
        if _G.CrateCollecting or _G.ItemAutoSaving or _G.LootCollecting then return end
        if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

        -- Lấy target hiện tại
        if chestToLoot then
            -- chest priority: giữ vị trí không dịch chuyển nếu đang combat
            if currentTarget and isTargetAlive(currentTarget) then
                if isStunned() or isRagdolled() then
                    escapeToHeight(currentTarget)
                else
                    teleportBehindTarget(currentTarget)
                end
            else
                -- Target chết hoặc không có target, không teleport
            end
        else
            if not currentTarget or not isTargetAlive(currentTarget) then
                -- Không có target, về vị trí đợi
                teleportToPosition(waitPositions[_G.CombatTargetType] or Vector3.new())
            else
                if isStunned() or isRagdolled() then
                    escapeToHeight(currentTarget)
                else
                    teleportBehindTarget(currentTarget)
                end
            end
        end
    end)
end

-- Combat loop với chest priority được đồng bộ
spawn(function()
    startHeartbeatTeleport()
    while true do
        -- Check for setting changes and reset if needed
        if combatSettings.lastEnabled ~= _G.CombatEnabled or 
           combatSettings.lastTargetType ~= _G.CombatTargetType then
            _G.ResetCombatTarget()
            combatSettings.lastEnabled = _G.CombatEnabled
            combatSettings.lastTargetType = _G.CombatTargetType
        end
        combatSettings.selectedSkills = _G.CombatSelectedSkills or {"B"}
        
        if _G.CrateCollecting or _G.ItemAutoSaving or _G.LootCollecting then
            task.wait()
        elseif not _G.CombatEnabled then
            task.wait()
        else
            -- FIXED: Tìm target mới sẽ tự động kiểm tra chest
            if not currentTarget or not isTargetAlive(currentTarget) then
                currentTarget = findRandomTarget()
            else
                -- Vẫn kiểm tra chest ngay cả khi có target
                chestToLoot = checkForChestToLoot()
            end
            
            if currentTarget and isTargetAlive(currentTarget) then
                isInCombat = true
                -- Teleport handled by heartbeat
                
                -- Use skills
                if tick() - lastSkillUse > 0.01 and #combatSettings.selectedSkills > 0 then
                    local skill = combatSettings.selectedSkills[combatSettings.currentSkillIndex]
                    useSkill(skill)
                    combatSettings.currentSkillIndex = combatSettings.currentSkillIndex + 1
                    if combatSettings.currentSkillIndex > #combatSettings.selectedSkills then
                        combatSettings.currentSkillIndex = 1
                    end
                end
                
                -- Auto attack
                spawn(function()
                    while not hasCooldown("MOUSEBUTTON1")
                        and _G.CombatEnabled
                        and isInCombat
                        and isTargetAlive(currentTarget)
                        and not _G.CrateCollecting
                        and not _G.ItemAutoSaving
                        and not _G.LootCollecting do
                        useSkill("MOUSEBUTTON1")
                        task.wait(0.05)
                    end
                end)
            else
                currentTarget = nil
                isInCombat = false
            end
            
            task.wait(0.15)
        end
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    task.wait(2)
    if _G.CombatEnabled then
        currentTarget = nil
        chestToLoot = nil
        if heartbeatTPConnection then
            heartbeatTPConnection:Disconnect()
            heartbeatTPConnection = nil
        end
        startHeartbeatTeleport()
    end
end)