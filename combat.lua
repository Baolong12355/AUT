-- Auto Combat Script with Crate and Auto Save Pause Logic
-- Combat will pause whenever you are auto saving item(s) or collecting crate. 
-- When these processes finish, combat resumes immediately (no delay, no reset position).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

_G.CombatEnabled = _G.CombatEnabled or false
_G.CombatTargetType = _G.CombatTargetType or "cultists"
_G.CombatEscapeHeight = _G.CombatEscapeHeight or 30
_G.CrateCollecting = _G.CrateCollecting or false
_G.ItemAutoSaving = _G.ItemAutoSaving or false
_G.SlayerQuestActive = _G.SlayerQuestActive or false

local combatSettings = {
    selectedSkills = {"B"},
    escapeHeight = _G.CombatEscapeHeight,
    targetType = _G.CombatTargetType,
    currentSkillIndex = 1
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

local slayerBossMap = {
    ["dragon"] = "The Knight",
    ["gojo"] = "The Honored One",
    ["oni"] = "The Oni",
    ["xeno"] = "Shadow Assassin",
    ["finger bearer"] = "The Bearer",
    ["bur"] = "The Boss"
}

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

local function findRandomTarget()
    local validTargets = {}
    if _G.SlayerQuestActive then
        local boss = getSlayerBossTarget()
        if boss then table.insert(validTargets, boss) end
    end
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

spawn(function()
    while true do
        -- Pause combat if collecting crate or auto saving items
        if _G.CrateCollecting or _G.ItemAutoSaving then
            task.wait(0.05)
        elseif not _G.CombatEnabled then
            task.wait(1)
        else
            if not currentTarget or not isTargetAlive(currentTarget) then
                currentTarget = findRandomTarget()
            end

            if not currentTarget then
                teleportToPosition(waitPositions[_G.CombatTargetType] or Vector3.new())
                task.wait(0.3)
            else
                isInCombat = true
                if isStunned() or isRagdolled() then
                    shouldEscape = true
                    escapeToHeight(currentTarget)
                else
                    shouldEscape = false
                    teleportBehindTarget(currentTarget)
                end

                if tick() - lastSkillUse > 0.1 and #combatSettings.selectedSkills > 0 then
                    local skill = combatSettings.selectedSkills[combatSettings.currentSkillIndex]
                    useSkill(skill)
                    combatSettings.currentSkillIndex = combatSettings.currentSkillIndex + 1
                    if combatSettings.currentSkillIndex > #combatSettings.selectedSkills then
                        combatSettings.currentSkillIndex = 1
                    end
                end

                spawn(function()
                    while not hasCooldown("MOUSEBUTTON1")
                        and _G.CombatEnabled
                        and isInCombat
                        and not shouldEscape
                        and isTargetAlive(currentTarget)
                        and not _G.CrateCollecting
                        and not _G.ItemAutoSaving do
                        useSkill("MOUSEBUTTON1")
                        task.wait(0.05)
                    end
                end)
            end
            task.wait(0.15)
        end
    end
end)

_G.ResetCombatTarget = function() currentTarget = nil end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    task.wait(2)
    if _G.CombatEnabled then
        currentTarget = nil
    end
end)