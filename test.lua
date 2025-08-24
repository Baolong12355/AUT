hookfunction(fn, function(args)
	pcall(function()
		if typeof(args) == "table" then
			local origin = args.Origin
			local size = args.Size

			if origin then
				print("🔥 Origin =", origin)
			end
			if size then
				print("📏 Size =", size)
			end

			-- Dịch chuyển origin nếu cần
			local function getClosestEnemy()
				local player = game:GetService("Players").LocalPlayer
				local myChar = player.Character
				local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myHRP then return end

				local closest, shortest = nil, math.huge
				for _, model in ipairs(workspace:GetDescendants()) do
					if model:IsA("Model") and model ~= myChar then
						local hrp = model:FindFirstChild("HumanoidRootPart")
						local hum = model:FindFirstChildOfClass("Humanoid")
						if hrp and hum and hum.Health > 0 then
							local dist = (hrp.Position - myHRP.Position).Magnitude
							if dist < shortest then
								closest, shortest = hrp.Position, dist