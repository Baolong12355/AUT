-- Auto Feed Shards Script (Skip Max Level Abilities)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local GetAllAbilityShards = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.CraftingService.RF.GetAllAbilityShards
local ConsumeShardsForXP = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.LevelService.RF.ConsumeShardsForXP
local GetAbilityPVEInfo = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.LevelService.RF.GetAbilityPVEInfo

local function feedAllShards()
    -- Lấy tất cả shards hiện có
    local success, allShards = pcall(function()
        return GetAllAbilityShards:InvokeServer()
    end)
    
    if not success or not allShards then return end
    
    -- Tạo bảng feed chỉ những abilities chưa max level
    local shardsToFeed = {}
    
    for abilityId, shardInfo in pairs(allShards) do
        if shardInfo.Shards and shardInfo.Shards > 0 then
            -- Kiểm tra level của ability
            local abilitySuccess, abilityInfo = pcall(function()
                return GetAbilityPVEInfo:InvokeServer(abilityId)
            end)
            
            -- Chỉ feed nếu level < 200 (chưa max)
            if abilitySuccess and abilityInfo and abilityInfo.CurrentLevel and abilityInfo.CurrentLevel < 200 then
                shardsToFeed[abilityId] = shardInfo.Shards
            end
        end
    end
    
    -- Nếu không có shard nào để feed thì return
    if next(shardsToFeed) == nil then return end
    
    -- Feed các shards của abilities chưa max level
    pcall(function()
        ConsumeShardsForXP:InvokeServer(shardsToFeed)
    end)
end

-- Auto run
spawn(function()
    wait(3)
    feedAllShards()
    
    while true do
        wait(8)
        feedAllShards()
    end
end)

_G.FeedAllShards = feedAllShards