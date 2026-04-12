local ExHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/zerotheking152-png/bug.lua/refs/heads/main/buggy.lua"))()

local Window = ExHub.Build({
    Title = "Quantum Hub",
    Subtitle = "Sawah Indo 1.0",
    Theme = "Matrix Green"
})

local TabInformation = Window:AddTab("Information", "")
TabInformation:AddLabel("Welcome To Quantum Hub")
TabInformation:AddInfoBox([[
Tips Penggunaan :
- SCRIPT FREE TIDAK UNTUK DI PERJUAL BELIKAN
- Gunakan tombol minimize untuk menyembunyikan UI tanpa menutupnya.
- Klik tab di sidebar untuk berpindah halaman.
- Semua pengaturan bisa disimpan otomatis sesuai executor.
- Jika ada error Atau Pun Bug, Silahkan Lapor Ke Discord Official kami
]])
TabInformation:AddDiscordLink("https://discord.gg/5Vby3xdjT")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = workspace

local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TutorialRemotes")
local plr = Players.LocalPlayer
local CropsFolder = Workspace:WaitForChild("ActiveCrops")

local TabAutoFarm = Window:AddTab("Auto Farm", "")
TabAutoFarm:AddLabel("AUTO FARM")

TabAutoFarm:AddLabel("AUTO HARVEST (TP + Harvest)")

local autoHarvestConn = nil

TabAutoFarm:AddToggle("Auto Harvest (TP + Harvest)", function(state)
    if state then
        autoHarvestConn = task.spawn(function()
            while true do
                pcall(function()
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    for _, crop in pairs(CropsFolder:GetChildren()) do
                        local ownerId = crop:GetAttribute("OwnerId")
                        if ownerId == plr.UserId or (crop.Name and string.find(crop.Name, tostring(plr.UserId))) then
                            local root = crop:FindFirstChild("Root")
                            if root then
                                local prompt = root:FindFirstChildOfClass("ProximityPrompt")
                                if prompt and prompt.Enabled then
                                    local dist = (hrp.Position - root.Position).Magnitude
                                    if dist > 7 then
                                        char:PivotTo(root.CFrame * CFrame.new(0, 3, 0))
                                        task.wait(0.25)
                                    end
                                    prompt.HoldDuration = 0
                                    fireproximityprompt(prompt, 1)
                                    task.wait(0.12)
                                end
                            end
                        end
                    end

                    for _, item in pairs(Workspace:GetChildren()) do
                        if item:IsA("Model") or item:IsA("BasePart") then
                            local fType = item:GetAttribute("FruitType")
                            local fOwner = item:GetAttribute("OwnerId")
                            if fType and fOwner == plr.UserId then
                                local fPrompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if fPrompt and fPrompt.Enabled then
                                    local fDist = (hrp.Position - fPrompt.Parent.Position).Magnitude
                                    if fDist > 7 then
                                        char:PivotTo(fPrompt.Parent.CFrame * CFrame.new(0, 3, 0))
                                        task.wait(0.25)
                                    end
                                    fPrompt.HoldDuration = 0
                                    fireproximityprompt(fPrompt, 1)
                                    task.wait(0.12)
                                end
                            end
                        end
                    end
                end)

                task.wait(0.35)
            end
        end)
    else
        if autoHarvestConn then
            task.cancel(autoHarvestConn)
            autoHarvestConn = nil
        end
    end
end)

TabAutoFarm:AddLabel("AUTO TANAM BIBIT")

local plantOptions = {
    "Bibit Buah", "Bibit Padi", "Bibit Jagung", "Bibit Tomat",
    "Bibit Terong", "Bibit Strawberry", "Bibit Sawit", "Bibit Durian"
}

local selectedPlant = "Bibit Buah"

local plantData = {
    ["Bibit Buah"] = { remote = "PlantCrop", position = Vector3.new(-160.67109680176, 39.296875, -323.17553710938), bibitKeyword = "Bibit" },
    ["Bibit Padi"] = { remote = "PlantCrop", position = Vector3.new(-160.67109680176, 39.296875, -323.17553710938), bibitKeyword = "Bibit Padi" },
    ["Bibit Jagung"] = { remote = "PlantCrop", position = Vector3.new(-160.67109680176, 39.296875, -323.17553710938), bibitKeyword = "Bibit Jagung" },
    ["Bibit Tomat"] = { remote = "PlantCrop", position = Vector3.new(-160.67109680176, 39.296875, -323.17553710938), bibitKeyword = "Bibit Tomat" },
    ["Bibit Terong"] = { remote = "PlantCrop", position = Vector3.new(-160.67109680176, 39.296875, -323.17553710938), bibitKeyword = "Bibit Terong" },
    ["Bibit Strawberry"] = { remote = "PlantCrop", position = Vector3.new(-160.67109680176, 39.296875, -323.17553710938), bibitKeyword = "Bibit Strawberry" },
    ["Bibit Sawit"] = { remote = "PlantLahanCrop", position = Vector3.new(198.16787719727, 45.06761932373, -160.22273254395), bibitKeyword = "Bibit Sawit" },
    ["Bibit Durian"] = { remote = "PlantLahanCrop", position = Vector3.new(200.75859069824, 45.06761932373, -161.96453857422), bibitKeyword = "Bibit Durian" }
}

TabAutoFarm:AddChoice("Pilih Bibit Tanaman Auto Tanam", function(choice)
    selectedPlant = choice
    local character = plr.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local config = plantData[choice]
        local tpPos = config.position + Vector3.new(0, 6, 0)
        character.HumanoidRootPart.CFrame = CFrame.new(tpPos)
    end
end, plantOptions)

local plantLimit = 15
local plantedThisSession = 0

TabAutoFarm:AddChoice("Pilih Jumlah Tanam", function(choice)
    plantLimit = tonumber(choice)
end, {"15", "25"})

TabAutoFarm:AddInput("Set Manual", function(text)
    local num = tonumber(text)
    if num and num >= 1 and num <= 25 then
        plantLimit = num
    end
end, "15")

local autoPlantConn = nil
local autoPlantEnabled = false

TabAutoFarm:AddToggle("Auto Tanam Bibit (ON/OFF)", function(state)
    autoPlantEnabled = state
    if state then
        plantedThisSession = 0
        local character = plr.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local config = plantData[selectedPlant]
            local tpPos = config.position + Vector3.new(0, 6, 0)
            character.HumanoidRootPart.CFrame = CFrame.new(tpPos)
        end

        autoPlantConn = task.spawn(function()
            while autoPlantEnabled do
                local character = plr.Character or plr.CharacterAdded:Wait()
                local humanoid = character:FindFirstChild("Humanoid")
                local root = character:FindFirstChild("HumanoidRootPart")
                local backpack = plr:FindFirstChild("Backpack")

                if not (humanoid and root and backpack) then task.wait(1) continue end

                local config = plantData[selectedPlant]
                local currentTool = character:FindFirstChildWhichIsA("Tool")
                local isHoldingCorrectBibit = currentTool and currentTool.Name:find(config.bibitKeyword)

                if not isHoldingCorrectBibit then
                    local equipped = false
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:find(config.bibitKeyword) then
                            humanoid:EquipTool(tool)
                            equipped = true
                            break
                        end
                    end
                    if equipped then
                        for _ = 1, 15 do
                            task.wait(0.1)
                            currentTool = character:FindFirstChildWhichIsA("Tool")
                            if currentTool and currentTool.Name:find(config.bibitKeyword) then
                                isHoldingCorrectBibit = true
                                break
                            end
                        end
                    end
                end

                if isHoldingCorrectBibit and currentTool then
                    pcall(function()
                        Remotes[config.remote]:FireServer(config.position)
                    end)
                    plantedThisSession = plantedThisSession + 1
                    if plantedThisSession >= plantLimit then
                        autoPlantEnabled = false
                        break
                    end
                end

                if math.random(1, 12) == 1 and root then
                    root.CFrame = CFrame.new(config.position + Vector3.new(0, 6, 0))
                end

                task.wait(0.85)
            end
        end)
    else
        if autoPlantConn then task.cancel(autoPlantConn) autoPlantConn = nil end
    end
end)

local TabShop = Window:AddTab("Shop", "")
TabShop:AddLabel("SHOP")

local buySeeds = {"Bibit Terong", "Bibit Strawberry", "Bibit Sawit", "Bibit Durian", "Bibit Tomat", "Bibit Jagung", "Bibit Padi"}
local sellFruits = {"Terong", "Strawberry", "Sawit", "Durian", "Tomat", "Jagung", "Padi"}

local selectedSeed = buySeeds[1]
local sellInterval = 8
local sellAmount = 999999

TabShop:AddChoice("Pilih Bibit Auto Buy", function(choice)
    selectedSeed = choice
end, buySeeds)

local autoBuyConn = nil
TabShop:AddToggle("Auto Buy Seed", function(state)
    if state then
        autoBuyConn = task.spawn(function()
            while true do
                pcall(function()
                    Remotes.RequestShop:InvokeServer("BUY", selectedSeed, 1)
                end)
                task.wait(1)
            end
        end)
    else
        if autoBuyConn then task.cancel(autoBuyConn); autoBuyConn = nil end
    end
end)

TabShop:AddInput("Interval Auto Sell (detik)", function(text)
    local num = tonumber(text)
    if num and num > 0 then sellInterval = num end
end, tostring(sellInterval))

TabShop:AddInput("Jumlah Maksimal Per Item", function(text)
    local num = tonumber(text)
    if num and num > 0 then sellAmount = num end
end, tostring(sellAmount))

local autoSellConn = nil
TabShop:AddToggle("Auto Sell All", function(state)
    if state then
        autoSellConn = task.spawn(function()
            while true do
                pcall(function()
                    for _, fruit in ipairs(sellFruits) do
                        pcall(function()
                            Remotes.RequestSell:InvokeServer("SELL", fruit, sellAmount)
                        end)
                        task.wait(0.2)
                    end
                end)
                task.wait(sellInterval)
            end
        end)
    else
        if autoSellConn then task.cancel(autoSellConn); autoSellConn = nil end
    end
end)

local TabMisc = Window:AddTab("Misc", "")
TabMisc:AddLabel("MISC")

TabMisc:AddToggle("FPS Booster", function(state)
    local Lighting = game:GetService("Lighting")
    if state then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
        settings().Rendering.QualityLevel = 1
        if not _G.FPSBoostConn then
            _G.FPSBoostConn = RunService.Heartbeat:Connect(function()
                settings().Rendering.QualityLevel = 1
            end)
        end
    else
        if _G.FPSBoostConn then _G.FPSBoostConn:Disconnect(); _G.FPSBoostConn = nil end
        settings().Rendering.QualityLevel = 2
    end
end)

TabMisc:AddToggle("Anti Afk", function(state)
    local VirtualUser = game:GetService("VirtualUser")
    if state then
        if not _G.AntiAfkConn then
            _G.AntiAfkConn = plr.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    else
        if _G.AntiAfkConn then _G.AntiAfkConn:Disconnect(); _G.AntiAfkConn = nil end
    end
end)

local reconnectEnabled = false
TabMisc:AddToggle("Auto Reconnect", function(state)
    reconnectEnabled = state
end)

local TabProfile = Window:AddTab("Profile", "")
TabProfile:AddProfile()

local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local JobId = game.JobId

plr.CharacterRemoving:Connect(function()
    if reconnectEnabled then
        task.wait(2)
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId)
    end
end)

Window:PlayIntro({
    IsSupported = true,
    MapName = "Sawah Indo"
})
