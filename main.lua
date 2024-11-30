--RF24
if game.PlaceId == 15758062201 or game.PlaceId == 14004668761 or game.PlaceId == 18119572340 then

    --ac bypass
    if not (identifyexecutor and identifyexecutor() == "Solara") then
        local util = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/BypassUtil/main/BypassUtils"))()
        util.ClearContext() -- Disable onerror connections.
        util.CloseScriptThread("BALLA") -- script you want to error.
        util.UniversalBypass() -- Built-in universal bypass, silent and lightweight works on most games.
    end
    

    --locals
    local executor = identifyexecutor() or "Unknown"
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local network = ReplicatedStorage:WaitForChild("network")
    local Shared = network:WaitForChild("Shared")
    local Lighting = game:GetService("Lighting")
    local plr = game:GetService('Players').LocalPlayer
    local id = plr.UserId
    local r_storage = game:GetService("ReplicatedStorage")
    local profiles = r_storage.network.Profiles
    local p_prof = profiles:FindFirstChild(tostring(id))
    local lfolder = p_prof.level
    local sfolder = p_prof.stats
    
    --ui manager
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | Real Futbol 24",
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "percent" }),
        Misc = Window:AddTab({ Title = "Local", Icon = "user" }),
        Data = Window:AddTab({ Title = "Stats Editor", Icon = "pencil" }),
        Fun = Window:AddTab({ Title = "Fun", Icon = "gift" }),
        Teams = Window:AddTab({ Title = "Teams", Icon = "shirt" }),
        BallMod = Window:AddTab({ Title = "BallMod", Icon = "gem" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    --main
    local scriptEnabled = true
    _G.distance = 6

    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")

    local ballsCache = {}

    local function findBalls(parent)
        local balls = {}
        local function scanForBalls(folder)
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Folder") then
                    scanForBalls(obj)
                elseif obj:IsA("Part") and obj:FindFirstChild("network") then
                    table.insert(balls, obj)
                end
            end
        end
        scanForBalls(parent)
        return balls
    end

    local function updateBallsCache()
        ballsCache = findBalls(Workspace)
    end

    task.spawn(function()
        while true do
            updateBallsCache()
            task.wait(5)
        end
    end)

    local function attachToBall(collidePart, ball)
        collidePart.Massless = true
        collidePart.CanCollide = false
        collidePart.Anchored = true
        collidePart.CFrame = ball.CFrame
    end

    local function leaveCollideInPlace(collidePart)
        collidePart.Anchored = true
    end

    local function sendNotification(title, text)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = 2;
        })
    end

    Tabs.Main:AddParagraph({
        Title = "Distance Recommendation",
        Content = "Set the distance to 6 for the best experience."
    })

    local ReachToggle = Tabs.Main:AddToggle("ReachToggle", {
        Title = "Reach Toggle",
        Default = true
    })

    ReachToggle:OnChanged(function()
        scriptEnabled = ReachToggle.Value
        sendNotification("Script Status", "Reach is now " .. (scriptEnabled and "ON" or "OFF"))
    end)

    local DistanceSlider = Tabs.Main:AddSlider("DistanceSlider", {
        Title = "Adjust Distance",
        Description = "Set interaction distance",
        Default = _G.distance,
        Min = 0,
        Max = 7.7,
        Rounding = 1
    })

    DistanceSlider:OnChanged(function(Value)
        _G.distance = tonumber(Value)
    end)

    game:GetService('RunService').Heartbeat:Connect(function()
        if not scriptEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local collidePart = character:FindFirstChild("Collide")
        if not collidePart then return end
        
        local weld = collidePart:FindFirstChildOfClass("WeldConstraint")
        if weld then
            weld:Destroy()
        end
        
        local isAttachedToBall = false
        
        for _, ball in ipairs(ballsCache) do
            local distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude
            if distance <= _G.distance then
                attachToBall(collidePart, ball)
                isAttachedToBall = true
                break
            end
        end
        
        if not isAttachedToBall then
            leaveCollideInPlace(collidePart)
        end
    end)

    --Misc
    -- Infinite Stamina Toggle
    local staminaLoopActive = false
    local staminaConnection
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function getStaminaValue()
        local success, result = pcall(function()
            return game:GetService("AssetService").controllers.movementController.stamina
        end)
        return success and result or nil
    end

    local function ensureInfiniteStamina()
        local staminaValue = getStaminaValue()
        while staminaLoopActive do
            if staminaValue and staminaValue.Value < 100 then
                staminaValue.Value = 100
            end
            task.wait(0.1)
        end
    end

    local InfiniteStaminaToggle = Tabs.Misc:AddToggle("InfiniteStamina", {Title = "Infinite Stamina", Default = false})

    InfiniteStaminaToggle:OnChanged(function(Value)
        staminaLoopActive = Value
        if staminaLoopActive then
            staminaConnection = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1)
                ensureInfiniteStamina()
            end)
            ensureInfiniteStamina()
        elseif staminaConnection then
            staminaConnection:Disconnect()
            staminaConnection = nil
        end
    end)

    -- Enable All Celebrations Button
    local EnableCelebrationsButton = Tabs.Misc:AddButton({
        Title = "Enable All Celebrations",
        Description = "Unlocks all celebrations",
        Callback = function()
            local AssetService = game:GetService("AssetService")
            local Profiles = game.ReplicatedStorage.network.Profiles

            local function createAccessoryValues(player, category, itemName, assetPath)
                local playerProfileFolder = Profiles:FindFirstChild(player.UserId)
                local inventoryFolder = playerProfileFolder and playerProfileFolder:FindFirstChild("inventory")
                local accessoriesFolder = inventoryFolder and inventoryFolder:FindFirstChild(category)
                local playerItemValue = accessoriesFolder and accessoriesFolder:FindFirstChild(itemName)
                
                if playerItemValue then
                    for _, asset in pairs(assetPath:GetChildren()) do
                        local clonedValue = playerItemValue:Clone()
                        clonedValue.Name = asset.Name
                        clonedValue.Parent = accessoriesFolder

                        local defaultValue = Instance.new("BoolValue")
                        defaultValue.Name = "DefaultValue"
                        defaultValue.Value = true
                        defaultValue.Parent = clonedValue
                    end
                end
            end

            local player = game.Players.LocalPlayer
            createAccessoryValues(player, "Accessories", "Player Gloves", AssetService.game.accessories)
            createAccessoryValues(player, "Boots", "White and Black", AssetService.game.boots)
            createAccessoryValues(player, "Gloves", "White and Black", AssetService.game.gloves)
            createAccessoryValues(player, "Ball Holds", "Default", AssetService.game.animations.Ball)
            createAccessoryValues(player, "Celebrations", "Fist Pump", AssetService.game.animations.Celebrations)
        end
    })

    -- Ball Predictor Toggle
    local toggleActive = false
    local maxSegments = 30
    local TweenService = game:GetService("TweenService")

    local function findBalls(parent)
        local balls = {}
        local function scanForBalls(folder)
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Folder") then
                    scanForBalls(obj)
                elseif obj:IsA("Part") and obj:FindFirstChild("network") then
                    table.insert(balls, obj)
                end
            end
        end
        scanForBalls(parent)
        return balls
    end

    local function quadraticBezier(t, P0, P1, P2)
        local oneMinusT = 1 - t
        return Vector3.new(
            oneMinusT^2 * P0.X + 2 * oneMinusT * t * P1.X + t^2 * P2.X,
            oneMinusT^2 * P0.Y + 2 * oneMinusT * t * P1.Y + t^2 * P2.Y,
            oneMinusT^2 * P0.Z + 2 * oneMinusT * t * P1.Z + t^2 * P2.Z
        )
    end

    local function getOrCreateBallPathModel()
        local existingPath = workspace:FindFirstChild("BallPathMesh") or Instance.new("Model")
        existingPath.Name = "BallPathMesh"
        existingPath.Parent = workspace
        return existingPath
    end

    local function showBallPath(P0, P1, P2, existingPath)
        local points = {}
        for i = 0, maxSegments do
            table.insert(points, quadraticBezier(i / maxSegments, P0, P1, P2))
        end

        for i = 1, #points - 1 do
            local segment = existingPath:FindFirstChild("Segment" .. i) or Instance.new("Part")
            segment.Name = "Segment" .. i
            segment.Size = Vector3.new(0.15, (points[i + 1] - points[i]).Magnitude, 0.15)
            segment.Anchored = true
            segment.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 0, 255), i / (#points - 1))
            segment.Material = Enum.Material.Neon
            segment.Transparency = 0.2 + i / (#points - 1) * 0.5
            segment.CanCollide = false
            segment.Parent = existingPath
            segment.CFrame = CFrame.new((points[i] + points[i + 1]) / 2, points[i + 1]) * CFrame.Angles(math.pi / 2, 0, 0)
        end
    end

    local function updateBallPredictions(parent)
        local balls = findBalls(parent)
        local existingPath = getOrCreateBallPathModel()
        for _, ball in ipairs(balls) do
            if ball and ball.Velocity.Magnitude > 0 then
                local P0, P1, P2 = ball.Position, ball.Position + ball.Velocity * 0.5, ball.Position + ball.Velocity * 1.5
                showBallPath(P0, P1, P2, existingPath)
            end
        end
    end

    local BallPredictorToggle = Tabs.Misc:AddToggle("BallPredictor", {Title = "Ball Predictor", Default = false})
    BallPredictorToggle:OnChanged(function(Value)
        toggleActive = Value
        if toggleActive then
            coroutine.wrap(function()
                while toggleActive do
                    updateBallPredictions(workspace)
                    task.wait(0.25)
                end
            end)()
        else
            local existingPath = workspace:FindFirstChild("BallPathMesh")
            if existingPath then
                existingPath:Destroy()
            end
        end
    end)

    -- Ball Aimbot Toggle
    local toggleActive = false
    local ballAimbotConnection
    local activeBall = nil

    local function findBalls(parent)
        local balls = {}
        local function scanForBalls(folder)
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Folder") then
                    scanForBalls(obj)
                elseif obj:IsA("Part") and obj:FindFirstChild("network") then
                    table.insert(balls, obj)
                end
            end
        end
        scanForBalls(parent)
        return balls
    end

    local function findNearestBall()
        local balls = findBalls(workspace)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        local nearestBall = nil
        local shortestDistance = math.huge

        for _, ball in ipairs(balls) do
            local distance = (ball.Position - hrp.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestBall = ball
            end
        end

        return nearestBall
    end

    local function smoothAimToBall(ball, smoothSpeed)
        local camera = workspace.CurrentCamera

        if ballAimbotConnection then
            ballAimbotConnection:Disconnect()
        end

        ballAimbotConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if ball and toggleActive and ball.Parent then
                local newCameraCFrame = CFrame.new(camera.CFrame.Position, ball.Position)
                camera.CFrame = camera.CFrame:Lerp(newCameraCFrame, smoothSpeed)
            else
                activeBall = nil
            end
        end)
    end

    local function startBallAimbot()
        local smoothSpeed = 0.1

        while toggleActive do
            if not activeBall or not activeBall.Parent then
                local nearestBall = findNearestBall()

                if nearestBall and nearestBall ~= activeBall then
                    activeBall = nearestBall
                    smoothAimToBall(activeBall, smoothSpeed)
                end
            end

            task.wait(0.1)
        end
    end

    local BallAimbotToggle = Tabs.Misc:AddToggle("BallAimbot", {Title = "Ball Aimbot", Default = false})
    BallAimbotToggle:OnChanged(function(Value)
        toggleActive = Value

        if toggleActive then
            coroutine.wrap(startBallAimbot)()
        else
            if ballAimbotConnection then
                ballAimbotConnection:Disconnect()
                ballAimbotConnection = nil
                activeBall = nil
            end
        end
    end)


    -- Invisible FE Toggle
    local invis_on = false
    local function toggleInvisibility(state)
        invis_on = state
        if invis_on then
            local savedpos = LocalPlayer.Character.HumanoidRootPart.CFrame
            LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            wait(0.15)

            local Seat = Instance.new('Seat', workspace)
            Seat.Anchored, Seat.CanCollide, Seat.Transparency, Seat.Position = false, false, 1, Vector3.new(-25.95, 84, 3537.55)
            Seat.Name = 'invischair'
            
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0, Weld.Part1 = Seat, LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")

            Seat.CFrame = savedpos
            game.StarterGui:SetCore("SendNotification", {Title = "Invis On", Duration = 1})
        else
            local invisChair = workspace:FindFirstChild('invischair')
            if invisChair then invisChair:Destroy() end
            game.StarterGui:SetCore("SendNotification", {Title = "Invis Off", Duration = 1})
        end
    end

    local InvisibleToggle = Tabs.Misc:AddToggle("InvisibleFE", {Title = "Invisible FE", Default = false})
    InvisibleToggle:OnChanged(function(Value)
        toggleInvisibility(Value)
    end)

    --Data
    local LevelInput = Tabs.Data:AddInput("LevelInput", {
        Title = "Level",
        Default = tostring(lfolder.Level.Value),
        Placeholder = "Enter Level",
        Numeric = true, 
        Finished = true, 
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                lfolder.Level.Value = math.clamp(Number, 1, 100)
            else
                LevelInput:SetText(tostring(lfolder.Level.Value))
            end
        end
    })

    local XPInput = Tabs.Data:AddInput("XPInput", {
        Title = "XP",
        Default = tostring(lfolder.XP.Value),
        Placeholder = "Enter XP",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                lfolder.XP.Value = math.max(Number, 0)
            else
                XPInput:SetText(tostring(lfolder.XP.Value))
            end
        end
    })

    local XPNeededInput = Tabs.Data:AddInput("XPNeededInput", {
        Title = "XP Needed",
        Default = tostring(lfolder.XPNeeded.Value),
        Placeholder = "Enter XP Needed",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                lfolder.XPNeeded.Value = math.max(Number, 0)
            else
                XPNeededInput:SetText(tostring(lfolder.XPNeeded.Value))
            end
        end
    })

    local CashInput = Tabs.Data:AddInput("CashInput", {
        Title = "Point (Cash)",
        Default = tostring(sfolder.Cash.Value),
        Placeholder = "Enter Cash Amount",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                sfolder.Cash.Value = math.max(Number, 0)
            else
                CashInput:SetText(tostring(sfolder.Cash.Value))
            end
        end
    })

    local GoalsInput = Tabs.Data:AddInput("GoalsInput", {
        Title = "Goals",
        Default = tostring(sfolder.Goals.Value),
        Placeholder = "Enter Goals",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                sfolder.Goals.Value = math.floor(math.max(Number, 0))
            else
                GoalsInput:SetText(tostring(sfolder.Goals.Value))
            end
        end
    })

    local MOTMInput = Tabs.Data:AddInput("MOTMInput", {
        Title = "MOTM",
        Default = tostring(sfolder.MOTM.Value),
        Placeholder = "Enter MOTM Count",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                sfolder.MOTM.Value = math.floor(math.max(Number, 0))
            else
                MOTMInput:SetText(tostring(sfolder.MOTM.Value))
            end
        end
    })

    local WinsInput = Tabs.Data:AddInput("WinsInput", {
        Title = "Wins",
        Default = tostring(sfolder.Wins.Value),
        Placeholder = "Enter Wins",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                sfolder.Wins.Value = math.floor(math.max(Number, 0))
            else
                WinsInput:SetText(tostring(sfolder.Wins.Value))
            end
        end
    })

    local SavesInput = Tabs.Data:AddInput("SavesInput", {
        Title = "Saves",
        Default = tostring(sfolder.Saves.Value),
        Placeholder = "Enter Saves",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local Number = tonumber(Value)
            if Number then
                sfolder.Saves.Value = math.floor(math.max(Number, 0))
            else
                SavesInput:SetText(tostring(sfolder.Saves.Value))
            end
        end
    })

    --Fun

    -- Toggle for "Bring Ball"
    local Toggle = Tabs.Fun:AddToggle("BringBallToggle", {
        Title = "Bring Ball (Best in training or GK)",
        Default = false
    })

    Toggle:OnChanged(function(Value)
        catchingBalls = Value

        if catchingBalls then
            coroutine.wrap(function()
                while catchingBalls do
                    local balls = findBalls(workspace)
                    for _, ball in ipairs(balls) do
                        catchBall(ball)
                    end
                    task.wait(1)
                end
            end)()
        end
    end)

    Toggle:SetValue(false)

    -- Button for "AntiCheat Bypass"
    Tabs.Fun:AddButton({
        Title = "Anticheat Bypass",
        Description = "Bypass anticheat (Not recommended if you want to play for real)",
        Callback = function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            local CFrameLocation = CFrame.new(0, 0, 0)
            
            if RootPart then
                RootPart.Parent = nil
                RootPart.CFrame = CFrameLocation
                RootPart.Parent = Character
            end
        end
    })

    -- Button for "Ball TP"
    Tabs.Fun:AddButton({
        Title = "Ball TP (Requires anticheat bypass)",
        Description = "Teleport to nearest ball",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            local nearestBall = findNearestBall()
            
            if nearestBall then
                hrp.CFrame = nearestBall.CFrame
            else
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Ball TP",
                    Text = "No balls found",
                    Duration = 2
                })
            end
        end
    })

    -- Dropdown for "Players List"
    local Dropdown = Tabs.Fun:AddDropdown("PlayersListDropdown", {
        Title = "Extra scripts",
        Values = {"Inf Yield", "Remote Spy", "Dex Explorer"},
        Multi = false,
        Default = "Choose..."
    })

    Dropdown:OnChanged(function(Value)
        if Value == "Inf Yield" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            print("Inf Yield loaded")
        elseif Value == "Remote Spy" then
            loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()
            print("Remote Spy loaded")
        elseif Value == "Dex Explorer" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/86225d1d59a5eff48203fa2b1a14f5459e363ed4/dex.lua"))()
            print("Dex Explorer loaded")
        end
    end)

    --Teams
    local function fireAnyRemote(team)
        local remotesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("network"):FindFirstChild("Shared")

        if remotesFolder then
            for _, remote in pairs(remotesFolder:GetChildren()) do
                if remote:IsA("RemoteEvent") then
                    local args = {
                        [1] = 1000,
                        [2] = "team",
                        [3] = game:GetService("Teams"):FindFirstChild(team)
                    }
                    remote:FireServer(unpack(args))
                    return
                end
            end
        end
    end

    Tabs.Teams:AddButton({
        Title = "Join Home Team",
        Description = "Join the Home Team",
        Callback = function()
            fireAnyRemote("Home")
        end
    })

    Tabs.Teams:AddButton({
        Title = "Join Home Team GK",
        Description = "Join the Home Team as Goalkeeper",
        Callback = function()
            fireAnyRemote("Home GK")
        end
    })

    Tabs.Teams:AddButton({
        Title = "Join Away Team",
        Description = "Join the Away Team",
        Callback = function()
            fireAnyRemote("Away")
        end
    })

    Tabs.Teams:AddButton({
        Title = "Join Away Team GK",
        Description = "Join the Away Team as Goalkeeper",
        Callback = function()
            fireAnyRemote("Away GK")
        end
    })

    --Ball Mod
    local Section = Tabs.BallMod:AddSection("Ball Modifier")
    local Paragraph = Section:AddParagraph({
        Title = "Change the ball speed as preferred."
    })

    local xSpeed, ySpeed, zSpeed = 0, 0, 0
    local ballsCache = {}
    local previousForce = Vector3.new(0, 0, 0)

    local function findBalls(parent)
        local balls = {}
        
        local function scanForBalls(folder)
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Folder") then
                    scanForBalls(obj)
                elseif obj:IsA("Part") and obj:FindFirstChild("network") then
                    table.insert(balls, obj)
                end
            end
        end
        
        scanForBalls(parent)
        return balls
    end

    local function findGravityVectorForce(ball)
        local gravity = nil
        
        local function scanForGravity(folder)
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Folder") or obj:IsA("Model") then
                    scanForGravity(obj)
                elseif obj:IsA("VectorForce") and obj.Name == "gravity" then
                    gravity = obj
                    return
                end
            end
        end

        scanForGravity(ball)
        return gravity
    end

    local function updateBallForces()
        for _, ball in ipairs(ballsCache) do
            local gravity = findGravityVectorForce(ball)
            if gravity and gravity.Force ~= previousForce then
                gravity.Force = Vector3.new(xSpeed, ySpeed, zSpeed)
                previousForce = gravity.Force
            end
        end
    end

    local function refreshBallsCache()
        ballsCache = findBalls(workspace)
    end

    local XInput = Tabs.BallMod:AddInput("X Speed", {
        Title = "Set X Speed",
        Placeholder = "Enter X speed",
        Numeric = true,
        Callback = function(value)
            xSpeed = tonumber(value) or 0
            updateBallForces()
        end
    })

    local YInput = Tabs.BallMod:AddInput("Y Speed", {
        Title = "Set Y Speed",
        Placeholder = "Enter Y speed",
        Numeric = true,
        Callback = function(value)
            ySpeed = tonumber(value) or 0
            updateBallForces()
        end
    })

    local ZInput = Tabs.BallMod:AddInput("Z Speed", {
        Title = "Set Z Speed",
        Placeholder = "Enter Z speed",
        Numeric = true,
        Callback = function(value)
            zSpeed = tonumber(value) or 0
            updateBallForces()
        end
    })

    local RunService = game:GetService("RunService")
    RunService.Heartbeat:Connect(function()
        if tick() % 5 < 0.1 then  
            refreshBallsCache()
        end
    end)

    
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    Window:SelectTab(1)
    
    Fluent:Notify({
        Title = "Plasma",
        Content = "The script has been loaded.",
        Duration = 8
    })
    
    SaveManager:LoadAutoloadConfig()
    


--end of rf24 script
end
    

--Super League Soccer
if game.PlaceId == 12177325772 or game.PlaceId == 14382948560 or game.PlaceId == 110948941832728 then

    --anticheat bypass
    local executor = identifyexecutor and identifyexecutor() or "Unknown"
    if executor ~= "Solara" then
        local player = game:GetService("Players").LocalPlayer
        local old
    
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return
            end
            return old(self, ...)
        end)
    end

    --UI Manager
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | Super League Soccer",
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    })

    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "percent" }),
        Misc = Window:AddTab({ Title = "Local", Icon = "user" }),
        Teams = Window:AddTab({ Title = "Teams", Icon = "shirt" }),
        Auto = Window:AddTab({ Title = "Auto", Icon = "bot" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- Reach Settings

    Tabs.Main:AddParagraph({
        Title = "Works on Solara"
    })

    local currentSize = Vector3.new(5, 5, 5)
    local currentTransparency = 0
    local currentMaterial = Enum.Material.Plastic
    local hitboxAdjustEnabled = false

    local XSize, YSize, ZSize = 5, 5, 5
    local transparencyValue = 0
    local materialValue = "Plastic"

    local function applyHitboxSettings()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hitbox = character:FindFirstChild("Hitbox")
        local tackleHitbox = character:FindFirstChild("TackleHitbox")
        if hitbox then
            hitbox.Size = currentSize
            hitbox.Transparency = currentTransparency
            hitbox.Material = currentMaterial
        end
        if tackleHitbox then
            tackleHitbox.Size = currentSize
            tackleHitbox.Transparency = currentTransparency
            tackleHitbox.Material = currentMaterial
        end
    end

    local function resetHitboxes()
        currentSize = Vector3.new(0, 0, 0)
        currentTransparency = 1
        currentMaterial = Enum.Material.Plastic
        applyHitboxSettings()
    end

    local function updateHitboxSize()
        if hitboxAdjustEnabled then
            currentSize = Vector3.new(XSize, YSize, ZSize)
            applyHitboxSettings()
        end
    end

    local function updateTransparency()
        if hitboxAdjustEnabled then
            currentTransparency = transparencyValue
            applyHitboxSettings()
        end
    end

    local function updateMaterial()
        if hitboxAdjustEnabled then
            currentMaterial = Enum.Material[materialValue]
            applyHitboxSettings()
        end
    end

    Tabs.Main:AddToggle("Enable Reach", {
        Title = "Enable Reach",
        Default = false,
        Callback = function(Value)
            hitboxAdjustEnabled = Value
            if Value then
                updateHitboxSize()
                updateTransparency()
                updateMaterial()
            else
                resetHitboxes()
            end
        end
    })

    Tabs.Main:AddSlider("X Size", {
        Title = "X Size",
        Description = "Adjust the X Size",
        Min = 0,
        Max = 300,
        Default = 5,
        Rounding = 0,
        Callback = function(Value)
            XSize = Value
            updateHitboxSize()
        end
    })

    Tabs.Main:AddSlider("Y Size", {
        Title = "Y Size",
        Description = "Adjust the Y Size",
        Min = 0,
        Max = 300,
        Default = 5,
        Rounding = 0,
        Callback = function(Value)
            YSize = Value
            updateHitboxSize()
        end
    })

    Tabs.Main:AddSlider("Z Size", {
        Title = "Z Size",
        Description = "Adjust the Z Size",
        Min = 0,
        Max = 300,
        Default = 5,
        Rounding = 0,
        Callback = function(Value)
            ZSize = Value
            updateHitboxSize()
        end
    })

    Tabs.Main:AddSlider("Reach Transparency", {
        Title = "Reach Transparency",
        Description = "Adjust Reach transparency",
        Min = 0,
        Max = 1,
        Default = 0,
        Rounding = 2,
        Callback = function(Value)
            transparencyValue = Value
            updateTransparency()
        end
    })

    local materialsList = {
        "Plastic", "Wood", "Metal", "DiamondPlate", "Foil", "Glass", "Ice",
        "Marble", "Granite", "Brick", "Slate", "Concrete", "CorrodedMetal",
        "Pebble", "SmoothPlastic", "ForceField", "Sand", "Fabric", "Neon"
    }

    Tabs.Main:AddDropdown("Material", {
        Title = "Material",
        Description = "Select the material",
        Values = materialsList,
        Default = "Plastic",
        Callback = function(Value)
            materialValue = Value
            updateMaterial()
        end
    })

    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        if hitboxAdjustEnabled then
            applyHitboxSettings()
        else
            resetHitboxes()
        end
    end)

    -- Walkspeed Control

    Tabs.Misc:AddParagraph({
        Title = "Caution!",
        Content = "Won't work on Solara"
    })

    local currentWalkSpeed = 16

    Tabs.Misc:AddSlider("Walkspeed", {
        Title = "Walkspeed",
        Min = 16,
        Max = 100,
        Default = 16,
        Rounding = 0,
        Callback = function(Value)
            currentWalkSpeed = Value
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                humanoid.WalkSpeed = currentWalkSpeed
            end
        end
    })

    local function applyStoredWalkSpeed()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        task.delay(0.1, function()
            if humanoid then
                humanoid.WalkSpeed = currentWalkSpeed
            end
        end)
    end

    game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        applyStoredWalkSpeed()

        local humanoid = character:WaitForChild("Humanoid")
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= currentWalkSpeed then
                humanoid.WalkSpeed = currentWalkSpeed
            end
        end)
    end)

    Tabs.Misc:AddParagraph({
        Title = "(Break ball) Works when in possession of ball",
        Content = "Other wise it wont work"
    })

    --break ball
    local finalPosition = Vector3.new(-0.10196399688720703, 10.74035930633545, -185.67771911621094)

local Options = {}

Options.BreakBallToggle = Tabs.Misc:AddToggle("BreakBallToggle", {Title = "Break Ball", Default = false})

Options.BreakBallToggle:OnChanged(function()
    if Options.BreakBallToggle.Value then
        while Options.BreakBallToggle.Value do
            local args = {
                [1] = "ShotActivated",
                [2] = workspace:WaitForChild("Junk"):WaitForChild("Football"),
                [3] = Vector3.new(2.131572961807251, 1.62501859664917, -130.14883422851562),
                [4] = finalPosition
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ActionService"):WaitForChild("RE"):WaitForChild("PerformAction"):FireServer(unpack(args))
            
            wait(0.1)
        end
    end
end)

Options.BreakBallToggle:SetValue(false)



    Tabs.Teams:AddParagraph({
        Title = "If you clicked and nothing worked its full.",
        Content = "Choose another position"
    })

    --teams
    local Dropdown = Tabs.Teams:AddDropdown("Dropdown", {
        Title = "Select Position (HOME)",
        Values = {"GK", "LB", "RB", "CM", "LF", "RF", "CF"},
        Multi = false,
        Default = 0,
    })
    
    Dropdown:SetValue("")
    
    Dropdown:OnChanged(function(Value)
        local args = {
            [1] = {
                ["Team"] = game:GetService("Teams"):WaitForChild("Home"),
                ["TeamPosition"] = Value
            }
        }
    
        game:GetService("ReplicatedStorage"):WaitForChild("__GamemodeComm"):WaitForChild("RE"):WaitForChild("_RequestJoin"):FireServer(unpack(args))
    end)

    --away (teams)
    local Dropdown = Tabs.Teams:AddDropdown("Dropdown", {
        Title = "Select Position (AWAY)",
        Values = {"GK", "LB", "RB", "CM", "LF", "RF", "CF"},
        Multi = false,
        Default = 0,
    })
    
    Dropdown:SetValue("")
    
    Dropdown:OnChanged(function(Value)
        local args = {
            [1] = {
                ["Team"] = game:GetService("Teams"):WaitForChild("Away"),
                ["TeamPosition"] = Value
            }
        }
    
        game:GetService("ReplicatedStorage"):WaitForChild("__GamemodeComm"):WaitForChild("RE"):WaitForChild("_RequestJoin"):FireServer(unpack(args))
    end)
    

    -- Auto Pack Opening

    Tabs.Auto:AddButton({
        Title = "Open Gold Pack",
        Callback = function()
            local args1 = { [1] = "Packs (Opening) - Opened" }
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("AnalyticsService"):WaitForChild("RE"):WaitForChild("LogEvent"):FireServer(unpack(args1))

            local args2 = { [1] = "Gold", [2] = 1 }
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PacksService"):WaitForChild("RF"):WaitForChild("ProcessPurchase"):InvokeServer(unpack(args2))
        end
    })

    Tabs.Auto:AddButton({
        Title = "Open Bronze Pack",
        Callback = function()
            local args1 = { [1] = "Packs (Opening) - Opened" }
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("AnalyticsService"):WaitForChild("RE"):WaitForChild("LogEvent"):FireServer(unpack(args1))

            local args2 = { [1] = "Bronze", [2] = 1 }
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PacksService"):WaitForChild("RF"):WaitForChild("ProcessPurchase"):InvokeServer(unpack(args2))
        end
    })

    Tabs.Auto:AddButton({
        Title = "Open Silver Pack",
        Callback = function()
            local args1 = { [1] = "Packs (Opening) - Opened" }
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("AnalyticsService"):WaitForChild("RE"):WaitForChild("LogEvent"):FireServer(unpack(args1))

            local args2 = { [1] = "Silver", [2] = 1 }
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PacksService"):WaitForChild("RF"):WaitForChild("ProcessPurchase"):InvokeServer(unpack(args2))
        end
    })




    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    Window:SelectTab(1)
    
    Fluent:Notify({
        Title = "Plasma",
        Content = "The script has been loaded.",
        Duration = 8
    })
    
    SaveManager:LoadAutoloadConfig()

--end of super league soccer script
end

--tps street soccer
if game.PlaceId == 335760407 then

    --anticheat bypass
    local function removeNumericNamedLocalScripts()
        for _, descendant in pairs(game:GetDescendants()) do
            if descendant:IsA("LocalScript") then
                local scriptNameAsNumber = tonumber(descendant.Name)
                if scriptNameAsNumber then
                    descendant:Destroy()
                end
            end
        end
    end
    
    local player = game.Players.LocalPlayer
    
    player.CharacterAdded:Connect(function()
        wait(math.random(1, 3))
        removeNumericNamedLocalScripts()
    end)
    
    removeNumericNamedLocalScripts()
    
    --UI Manager
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | TPS Street Soccer",
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "percent" }),
        Misc = Window:AddTab({ Title = "Local", Icon = "user" }),
        Ball = Window:AddTab({ Title = "Ball", Icon = "podcast" }),
        Map = Window:AddTab({ Title = "Game", Icon = "gamepad" }),
        Extra = Window:AddTab({ Title = "Extra", Icon = "backpack" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    --Main
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    local currentHeadTransparency = 0
    local currentHeadSize = 2
    local currentFootSize = 2
    local currentFootTransparency = 0
    local headToggleEnabled = false
    local footToggleEnabled = false
    
    local function adjustHeadProperties(size, transparency)
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                head.CanCollide = false
                head.Massless = true
                head.Transparency = transparency
                head.Size = Vector3.new(size, size, size)
            end
        end
    end
    
    local function adjustFootProperties(size, transparency)
        local character = player.Character
        if character then
            local leftFoot = character:FindFirstChild("LeftFoot")
            local rightFoot = character:FindFirstChild("RightFoot")
            if leftFoot then
                leftFoot.CanCollide = false
                leftFoot.Massless = true
                leftFoot.Transparency = transparency
                leftFoot.Size = Vector3.new(size, size, size)
            end
            if rightFoot then
                rightFoot.CanCollide = false
                rightFoot.Massless = true
                rightFoot.Transparency = transparency
                rightFoot.Size = Vector3.new(size, size, size)
            end
        end
    end
    
    local headSection = Tabs.Main:AddSection("Head")
    
    local headHitboxToggle = headSection:AddToggle("HeadHitboxToggle", {Title = "Enable Head Hitbox Adjustment", Default = false })
    
    headHitboxToggle:OnChanged(function(value)
        headToggleEnabled = value
        if headToggleEnabled then
            adjustHeadProperties(currentHeadSize, currentHeadTransparency)
        else
            adjustHeadProperties(2, 0)
        end
    end)
    
    local headSizeSlider = headSection:AddSlider("HeadSizeSlider", {
        Title = "Head Size",
        Description = "Adjust head size",
        Default = 2,
        Min = 0,
        Max = 25,
        Rounding = 1,
        Callback = function(value)
            currentHeadSize = value
            if headToggleEnabled then
                adjustHeadProperties(currentHeadSize, currentHeadTransparency)
            end
        end
    })
    
    local headTransparencySlider = headSection:AddSlider("HeadTransparencySlider", {
        Title = "Head Transparency",
        Description = "Adjust head transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(value)
            currentHeadTransparency = value
            if headToggleEnabled then
                adjustHeadProperties(currentHeadSize, currentHeadTransparency)
            end
        end
    })
    
    local footSection = Tabs.Main:AddSection("Foot")
    
    local footHitboxToggle = footSection:AddToggle("FootHitboxToggle", {Title = "Enable Foot Hitbox Adjustment", Default = false })
    
    footHitboxToggle:OnChanged(function(value)
        footToggleEnabled = value
        if footToggleEnabled then
            adjustFootProperties(currentFootSize, currentFootTransparency)
        else
            adjustFootProperties(2, 0)
        end
    end)
    
    local footSizeSlider = footSection:AddSlider("FootSizeSlider", {
        Title = "Foot Size",
        Description = "Adjust foot size",
        Default = 2,
        Min = 0,
        Max = 25,
        Rounding = 1,
        Callback = function(value)
            currentFootSize = value
            if footToggleEnabled then
                adjustFootProperties(currentFootSize, currentFootTransparency)
            end
        end
    })
    
    local footTransparencySlider = footSection:AddSlider("FootTransparencySlider", {
        Title = "Foot Transparency",
        Description = "Adjust foot transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(value)
            currentFootTransparency = value
            if footToggleEnabled then
                adjustFootProperties(currentFootSize, currentFootTransparency)
            end
        end
    })
    
    local function onCharacterAdded()
        if headToggleEnabled then
            adjustHeadProperties(currentHeadSize, currentHeadTransparency)
        end
        if footToggleEnabled then
            adjustFootProperties(currentFootSize, currentFootTransparency)
        end
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    --misc
    local WalkSpeedSlider = Tabs.Misc:AddSlider("WalkSpeed", {
        Title = "WalkSpeed",
        Description = "Adjusts the player's walk speed",
        Default = 16,
        Min = 16,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })
    
    WalkSpeedSlider:OnChanged(function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end)
    
    WalkSpeedSlider:SetValue(16)
    
    --jumpower
    local JumpPowerSlider = Tabs.Misc:AddSlider("JumpPower", {
        Title = "JumpPower",
        Description = "Adjusts the player's jump power",
        Default = 50,
        Min = 50,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    })
    
    JumpPowerSlider:OnChanged(function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end)
    
    JumpPowerSlider:SetValue(50)
    
    
    --Ball
    
    --TP to ball
    Tabs.Ball:AddButton({
        Title = "Teleport to Ball",
        Description = "Click to teleport to the ball",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local targetPart = workspace.TPSSystem.TPS
    
            if character and targetPart then
                character:MoveTo(targetPart.Position)
            end
        end
    })
    
    Tabs.Ball:AddParagraph({
        Title = "OP FOR REACH",
        Content = "Set the distance to 25 for the best experience."
    })
    
    --Ball Size
    local Slider = Tabs.Ball:AddSlider("Slider", {
        Title = "Ball Size",
        Description = "Adjust the size of the ball",
        Default = 2.6,
        Min = 0,
        Max = 25,
        Rounding = 1,
        Callback = function(Value)
            local newSize = Vector3.new(Value, Value, Value)
            workspace.TPSSystem.TPS.Size = newSize
        end
    })
    
    Slider:OnChanged(function(Value)
        local newSize = Vector3.new(Value, Value, Value)
        workspace.TPSSystem.TPS.Size = newSize
    end)
    
    Slider:SetValue(2.6)
    workspace.TPSSystem.TPS.Size = Vector3.new(2.6, 2.6, 2.6)
    
    --Graphics
    local Dropdown = Tabs.Map:AddDropdown("Dropdown", {
        Title = "Graphics Lighting",
        Values = {"Compatibility", "Future", "Legacy", "ShadowMap", "Unified", "Voxel"},
        Multi = false,
        Default = 1,
    })
    
    Dropdown:SetValue("ShadowMap")
    
    Dropdown:OnChanged(function(Value)
        local lighting = game:GetService("Lighting")
        lighting.Technology = Enum.Technology[Value]
    end)
    
    --extra
    Tabs.Extra:AddButton({
        Title = "Fe Fling",
        Description = "Executes the Fe Fling script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI"))()
        end
    })
    
    Tabs.Extra:AddButton({
        Title = "Inf Yield",
        Description = "Executes the Inf Yield script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end
    })
    
    
    
    
    
    
    SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("FluentScriptHub")
        SaveManager:SetFolder("FluentScriptHub/specific-game")
        
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
        
        Window:SelectTab(1)
        
        Fluent:Notify({
            Title = "Plasma",
            Content = "The script has been loaded.",
            Duration = 8
        })
        
        SaveManager:LoadAutoloadConfig()
    
--end of TPS street soccer script
end



--TPS Ultimate soccer
if game.PlaceId == 5783581 then

    --anticheat bypass
    local function removeNumericNamedLocalScripts()
        for _, descendant in pairs(game:GetDescendants()) do
            if descendant:IsA("LocalScript") then
                local scriptNameAsNumber = tonumber(descendant.Name)
                if scriptNameAsNumber then
                    descendant:Destroy()
                end
            end
        end
    end
    
    local player = game.Players.LocalPlayer
    
    player.CharacterAdded:Connect(function()
        wait(math.random(1, 3))
        removeNumericNamedLocalScripts()
    end)
    
    removeNumericNamedLocalScripts()

--UI Manager
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Plasma | TPS Ultimate Soccer",
    SubTitle = "by Capone",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "percent" }),
    Misc = Window:AddTab({ Title = "Local", Icon = "user" }),
    Ball = Window:AddTab({ Title = "Ball", Icon = "podcast" }),
    Map = Window:AddTab({ Title = "Game", Icon = "gamepad" }),
    Extra = Window:AddTab({ Title = "Extra", Icon = "backpack" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--Main
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local currentHeadTransparency = 0
local currentHeadSize = 2
local currentLegSize = 2
local currentLegTransparency = 0
local currentHandSize = 2
local currentHandTransparency = 0
local headToggleEnabled = false
local legToggleEnabled = false
local handToggleEnabled = false

local function adjustHeadProperties(size, transparency)
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            head.CanCollide = false
            head.Massless = true
            head.Transparency = transparency
            head.Size = Vector3.new(size, size, size)
        end
    end
end

local function adjustLegProperties(size, transparency)
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        local leftLeg = character:FindFirstChild("Left Leg")
        local rightLeg = character:FindFirstChild("Right Leg")
        if leftLeg then
            leftLeg.CanCollide = false
            leftLeg.Massless = true
            leftLeg.Transparency = transparency
            leftLeg.Size = Vector3.new(size, size, size)
        end
        if rightLeg then
            rightLeg.CanCollide = false
            rightLeg.Massless = true
            rightLeg.Transparency = transparency
            rightLeg.Size = Vector3.new(size, size, size)
        end
    end
end

local function adjustHandProperties(size, transparency)
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        local leftArm = character:FindFirstChild("Left Arm")
        local rightArm = character:FindFirstChild("Right Arm")
        if leftArm then
            leftArm.CanCollide = false
            leftArm.Massless = true
            leftArm.Transparency = transparency
            leftArm.Size = Vector3.new(size, size, size)
        end
        if rightArm then
            rightArm.CanCollide = false
            rightArm.Massless = true
            rightArm.Transparency = transparency
            rightArm.Size = Vector3.new(size, size, size)
        end
    end
end

local headSection = Tabs.Main:AddSection("Head")

local headHitboxToggle = headSection:AddToggle("HeadHitboxToggle", {Title = "Enable Head Hitbox Adjustment", Default = false })

headHitboxToggle:OnChanged(function(value)
    headToggleEnabled = value
    if headToggleEnabled then
        adjustHeadProperties(currentHeadSize, currentHeadTransparency)
    else
        adjustHeadProperties(2, 0)
    end
end)

local headSizeSlider = headSection:AddSlider("HeadSizeSlider", {
    Title = "Head Size",
    Description = "Adjust head size",
    Default = 2,
    Min = 0,
    Max = 25,
    Rounding = 1,
    Callback = function(value)
        currentHeadSize = value
        if headToggleEnabled then
            adjustHeadProperties(currentHeadSize, currentHeadTransparency)
        end
    end
})

local headTransparencySlider = headSection:AddSlider("HeadTransparencySlider", {
    Title = "Head Transparency",
    Description = "Adjust head transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        currentHeadTransparency = value
        if headToggleEnabled then
            adjustHeadProperties(currentHeadSize, currentHeadTransparency)
        end
    end
})

local legSection = Tabs.Main:AddSection("Leg")

local legHitboxToggle = legSection:AddToggle("LegHitboxToggle", {Title = "Enable Leg Hitbox Adjustment", Default = false })

legHitboxToggle:OnChanged(function(value)
    legToggleEnabled = value
    if legToggleEnabled then
        adjustLegProperties(currentLegSize, currentLegTransparency)
    else
        adjustLegProperties(2, 0)
    end
end)

local legSizeSlider = legSection:AddSlider("LegSizeSlider", {
    Title = "Leg Size",
    Description = "Adjust leg size",
    Default = 2,
    Min = 0,
    Max = 25,
    Rounding = 1,
    Callback = function(value)
        currentLegSize = value
        if legToggleEnabled then
            adjustLegProperties(currentLegSize, currentLegTransparency)
        end
    end
})

local legTransparencySlider = legSection:AddSlider("LegTransparencySlider", {
    Title = "Leg Transparency",
    Description = "Adjust leg transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        currentLegTransparency = value
        if legToggleEnabled then
            adjustLegProperties(currentLegSize, currentLegTransparency)
        end
    end
})

local handSection = Tabs.Main:AddSection("Hand")

local handHitboxToggle = handSection:AddToggle("HandHitboxToggle", {Title = "Enable Hand Hitbox Adjustment", Default = false })

handHitboxToggle:OnChanged(function(value)
    handToggleEnabled = value
    if handToggleEnabled then
        adjustHandProperties(currentHandSize, currentHandTransparency)
    else
        adjustHandProperties(2, 0)
    end
end)

local handSizeSlider = handSection:AddSlider("HandSizeSlider", {
    Title = "Hand Size",
    Description = "Adjust hand size",
    Default = 2,
    Min = 0,
    Max = 25,
    Rounding = 1,
    Callback = function(value)
        currentHandSize = value
        if handToggleEnabled then
            adjustHandProperties(currentHandSize, currentHandTransparency)
        end
    end
})

local handTransparencySlider = handSection:AddSlider("HandTransparencySlider", {
    Title = "Hand Transparency",
    Description = "Adjust hand transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        currentHandTransparency = value
        if handToggleEnabled then
            adjustHandProperties(currentHandSize, currentHandTransparency)
        end
    end
})

local function onCharacterAdded()
    if headToggleEnabled then
        adjustHeadProperties(currentHeadSize, currentHeadTransparency)
    end
    if legToggleEnabled then
        adjustLegProperties(currentLegSize, currentLegTransparency)
    end
    if handToggleEnabled then
        adjustHandProperties(currentHandSize, currentHandTransparency)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

--Ball
    
    --TP to ball
    Tabs.Ball:AddButton({
        Title = "Teleport to Ball",
        Description = "Click to teleport to the ball",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local targetPart = workspace.TPSSystem.TPS
    
            if character and targetPart then
                character:MoveTo(targetPart.Position)
            end
        end
    })
    
    Tabs.Ball:AddParagraph({
        Title = "OP FOR REACH",
        Content = "Set the distance to 25 for the best experience."
    })
    
    --Ball Size
    local Slider = Tabs.Ball:AddSlider("Slider", {
        Title = "Ball Size",
        Description = "Adjust the size of the ball",
        Default = 2.6,
        Min = 0,
        Max = 25,
        Rounding = 1,
        Callback = function(Value)
            local newSize = Vector3.new(Value, Value, Value)
            workspace.TPSSystem.TPS.Size = newSize
        end
    })
    
    Slider:OnChanged(function(Value)
        local newSize = Vector3.new(Value, Value, Value)
        workspace.TPSSystem.TPS.Size = newSize
    end)
    
    Slider:SetValue(2.6)
    workspace.TPSSystem.TPS.Size = Vector3.new(2.6, 2.6, 2.6)
    
    --Graphics
    local Dropdown = Tabs.Map:AddDropdown("Dropdown", {
        Title = "Graphics Lighting",
        Values = {"Compatibility", "Future", "Legacy", "ShadowMap", "Unified", "Voxel"},
        Multi = false,
        Default = 1,
    })
    
    Dropdown:SetValue("ShadowMap")
    
    Dropdown:OnChanged(function(Value)
        local lighting = game:GetService("Lighting")
        lighting.Technology = Enum.Technology[Value]
    end)
    
    --extra
    Tabs.Extra:AddButton({
        Title = "Fe Fling",
        Description = "Executes the Fe Fling script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI"))()
        end
    })
    
    Tabs.Extra:AddButton({
        Title = "Inf Yield",
        Description = "Executes the Inf Yield script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end
    })


SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("FluentScriptHub")
        SaveManager:SetFolder("FluentScriptHub/specific-game")
        
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
        
        Window:SelectTab(1)
        
        Fluent:Notify({
            Title = "Plasma",
            Content = "The script has been loaded.",
            Duration = 8
        })
        
        SaveManager:LoadAutoloadConfig()

--end of tps ultimate soccer script
end

--Skillfull
if game.PlaceId == 11442626954 or game.PlaceId == 113275036542619 or game.PlaceId == 130976392556634 then

    --UI Manager
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | SkillFull ",
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "percent" }),
        Misc = Window:AddTab({ Title = "Local", Icon = "user" }),
        Extra = Window:AddTab({ Title = "Extra", Icon = "backpack" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    Tabs.Main:AddParagraph({
        Title = "Info",
        Content = "Works when another player isnt in possesion of ball."
    })
    
    --Main
    local folder = workspace:FindFirstChild("Messi")
    local scanningEnabled = false
    local currentSize = 3
    local RunService = game:GetService("RunService")
    
    local function resizeAllColliders(size)
        if folder then
            for _, child in ipairs(folder:GetDescendants()) do
                if child:IsA("BasePart") and child.Name == "Collider" then
                    child.Size = Vector3.new(size, size, size)
                end
            end
        end
    end
    
    local function scanAndResizeColliders(size)
        if folder then
            for _, child in ipairs(folder:GetDescendants()) do
                if child:IsA("BasePart") and child.Name == "Collider" and child.Size ~= Vector3.new(size, size, size) then
                    child.Size = Vector3.new(size, size, size)
                end
            end
        end
    end
    
    local heartbeatConnection
    
    local Toggle = Tabs.Main:AddToggle("EnableReach", {Title = "Enable Reach", Default = false})
    
    Toggle:OnChanged(function(Value)
        scanningEnabled = Value
        if scanningEnabled then
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                scanAndResizeColliders(currentSize)
            end)
        else
            resizeAllColliders(3)
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
            end
        end
    end)
    
    local Slider = Tabs.Main:AddSlider("Reach", {
        Title = "Reach",
        Description = "Adjust collider size",
        Default = 3,
        Min = 3,
        Max = 25,
        Rounding = 0,
        Callback = function(Value)
            currentSize = Value
            if scanningEnabled then
                resizeAllColliders(Value)
            end
        end
    })
    
    Slider:SetValue(3)
    Toggle:SetValue(false)
    
    --TP to ball
    Tabs.Main:AddButton({
        Title = "Tp to Ball",
        Description = "Teleports to the ball",
        Callback = function()
            local folder = workspace:FindFirstChild("Messi")
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer
    
            if folder and localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = localPlayer.Character.HumanoidRootPart
                for _, child in ipairs(folder:GetDescendants()) do
                    if child:IsA("BasePart") and child.Name == "Collider" then
                        humanoidRootPart.CFrame = child.CFrame
                        break 
                    end
                end
            end
        end
    })
    
    
    --Misc
    
    --infinite Stamina
    local player = game.Players.LocalPlayer
    local infiniteStaminaEnabled = false
    
    local Toggle = Tabs.Misc:AddToggle("InfiniteStamina", {Title = "Infinite Stamina", Default = false})
    
    Toggle:OnChanged(function()
        infiniteStaminaEnabled = Toggle.Value
    end)
    
    local function maintainStamina()
        while true do
            wait(0.1)
            if infiniteStaminaEnabled then
                if player.Character and player.Character:FindFirstChild("PlayerInfo") then
                    local playerInfo = player.Character.PlayerInfo
                    if playerInfo:FindFirstChild("Stamina") then
                        playerInfo.Stamina.Value = 100
                    end
                end
            end
        end
    end
    
    spawn(maintainStamina)
    
    --click to tp
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    
    local isTeleportEnabled = false
    
    local Toggle = Tabs.Misc:AddToggle("Enable Teleport", {Title = "Enable Click Teleport", Default = false})
    
    local function teleportToMousePosition()
        if isTeleportEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = mouse.Hit.p
            player.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
    end
    
    Toggle:OnChanged(function()
        isTeleportEnabled = Toggle.Value
        print("Teleportation enabled:", isTeleportEnabled)
    end)
    
    mouse.Button1Down:Connect(function()
        teleportToMousePosition()
    end)
    
    
    --extra
    --Graphics
    local Dropdown = Tabs.Extra:AddDropdown("Dropdown", {
        Title = "Graphics Lighting",
        Values = {"Compatibility", "Future", "Legacy", "ShadowMap", "Unified", "Voxel"},
        Multi = false,
        Default = 1,
    })
    
    Dropdown:SetValue("ShadowMap")
    
    Dropdown:OnChanged(function(Value)
        local lighting = game:GetService("Lighting")
        lighting.Technology = Enum.Technology[Value]
    end)
    
    Tabs.Extra:AddButton({
        Title = "Fe Fling",
        Description = "Executes the Fe Fling script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI"))()
        end
    })
    
    Tabs.Extra:AddButton({
        Title = "Inf Yield",
        Description = "Executes the Inf Yield script",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end
    })
    
    
    
    
    SaveManager:SetLibrary(Fluent)
            InterfaceManager:SetLibrary(Fluent)
            
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({})
            InterfaceManager:SetFolder("FluentScriptHub")
            SaveManager:SetFolder("FluentScriptHub/specific-game")
            
            InterfaceManager:BuildInterfaceSection(Tabs.Settings)
            SaveManager:BuildConfigSection(Tabs.Settings)
            
            Window:SelectTab(1)
            
            Fluent:Notify({
                Title = "Plasma",
                Content = "The script has been loaded.",
                Duration = 8
            })
            
            SaveManager:LoadAutoloadConfig()
    
--end of Skillfull script
end

--Super free kick
if game.PlaceId == 16531522679 then

    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | Free kick AHH GAME LOL", 
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
    })
    
    --Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    Tabs.Main:AddParagraph({
        Title = "Read",
        Content = "Scans every 5 seconds for new balls this helps with lag"
    })
    
    --Main
    local Slider = Tabs.Main:AddSlider("BallHitboxSlider", {
        Title = "Ball Hitbox",
        Description = "Adjust the size of the ball hitbox",
        Default = 10,
        Min = 3,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            while wait(5) do
                for _, descendant in ipairs(workspace:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.Name == "b" then
                        descendant.Size = Vector3.new(Value, Value, Value)
                    end
                end
            end
        end
    })
    
    Slider:OnChanged(function(Value)
        -- Update the size for all current parts when the slider value changes
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name == "b" then
                descendant.Size = Vector3.new(Value, Value, Value)
            end
        end
    end)
    
    Slider:SetValue(10)
    
    
    
    -- Addons:
    -- SaveManager (Allows you to have a configuration system)
    -- InterfaceManager (Allows you to have a interface managment system)
    
    -- Hand the library over to our managers
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    -- Ignore keys that are used by ThemeManager.
    -- (we dont want configs to save themes, do we?)
    SaveManager:IgnoreThemeSettings()
    
    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})
    
    -- use case for doing it this way:
    -- a script hub could have themes in a global folder
    -- and game configs in a separate folder per game
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    
    Window:SelectTab(1)
    
    Fluent:Notify({
        Title = "Fluent",
        Content = "The script has been loaded.",
        Duration = 8
    })
    
    -- You can use the SaveManager:LoadAutoloadConfig() to load a config
    -- which has been marked to be one that auto loads!
    SaveManager:LoadAutoloadConfig()
    
--end of super freekick script
end

--Track and field 
if game.PlaceId == 16426795556 then
    
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | Track & Field: Infinite",
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift 
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Player", Icon = "keyboard" }),
        Misc = Window:AddTab({ Title = "Other", Icon = "package" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    --SpeedBoost
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local walkSpeedLocked = false

    local function lockWalkSpeed()
        if not walkSpeedLocked then return end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 30
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if walkSpeedLocked and humanoid.WalkSpeed ~= 30 then
                    humanoid.WalkSpeed = 30
                end
            end)
        end
    end

    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        newCharacter:WaitForChild("Humanoid")
        if walkSpeedLocked then
            lockWalkSpeed()
        end
    end)

    local Toggle = Tabs.Main:AddToggle("SpeedLockToggle", {Title = "Speed Boost", Default = false})

    Toggle:OnChanged(function()
        walkSpeedLocked = Toggle.Value
        if walkSpeedLocked then
            lockWalkSpeed()
        end
    end)

    lockWalkSpeed()


    
    --Macro
    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Enable Macro (Depends on your executor)", Default = false})
    
    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Macro Speed (PC for now)",
        Description = "Adjust wait speed between key presses",
        Default = 0.1,
        Min = 0.01,
        Max = 1,
        Rounding = 2
    })
    
    local isLoopEnabled = false
    local waitTime = 0.1
    
    local Options = Options or {}
    Options.MyToggle = Toggle
    Options.Slider = Slider
    
    local function startMacro()
        task.spawn(function()
            while isLoopEnabled do
                keypress(0x51)
                keyrelease(0x51)
                wait(waitTime)
    
                keypress(0x45)
                keyrelease(0x45)
                wait(waitTime)
            end
        end)
    end
    
    Toggle:OnChanged(function()
        isLoopEnabled = Toggle.Value
        if isLoopEnabled then
            startMacro()
        end
    end)
    
    Slider:OnChanged(function(Value)
        waitTime = Value
    end)
    
    --Click to tp
    local player = game.Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local isClickToTpEnabled = false
    
    local function teleport(position)
        if position then
            humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        end
    end
    
    local function handleInput(input, gameProcessed)
        if gameProcessed then return end
    
        if isClickToTpEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local mouse = player:GetMouse()
            if mouse.Target then
                local targetPosition = mouse.Hit.Position
                teleport(targetPosition)
            end
        end
    end
    
    UserInputService.InputBegan:Connect(handleInput)
    
    local Toggle = Tabs.Main:AddToggle("ClickToTpToggle", {Title = "Click to TP", Default = false})
    
    Toggle:OnChanged(function()
        isClickToTpEnabled = Toggle.Value
    end)
    
    --Other
    
    --Auto choose countries:
    local countryList = {
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", 
        "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", 
        "Bangladesh", "Barbados", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", 
        "Botswana", "Brazil", "Bulgaria", "Burkina Faso", "Cambodia", "Cameroon", "Canada", 
        "Chile", "China", "Colombia", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", 
        "Dominican Republic", "Ecuador", "Egypt", "Estonia", "Ethiopia", "Fiji", "Finland", 
        "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", 
        "Guatemala", "Guinea", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", 
        "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", 
        "Kazakhstan", "Kenya", "Korea", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", 
        "Liberia", "Libya", "Lithuania", "Madagascar", "Malaysia", "Maldives", "Malta", "Mexico", 
        "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Namibia", "Nepal", 
        "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", 
        "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", 
        "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saudi Arabia", "Senegal", 
        "Serbia", "Seychelles", "Singapore", "Slovakia", "Slovenia", "Somalia", "South Africa", 
        "South Korea", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", 
        "Syria", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", "Trinidad and Tobago", 
        "Tunisia", "Turkey", "Turkmenistan", "Uganda", "Ukraine", "United Arab Emirates", 
        "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", 
        "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    }
    
    local Dropdown = Tabs.Misc:AddDropdown("Country Selector", { 
        Title = "Select a Country",
        Values = countryList,
        Multi = false,
        Default = 1,
    })
    
    Dropdown:SetValue("United States")
    
    Dropdown:OnChanged(function(Value)
        print("Dropdown changed to:", Value)
        local args = {
            [1] = "Set",
            [2] = Value
        }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("CountrySelection"):InvokeServer(unpack(args))
    end)
    
    
    
    
    -- Addons:
    -- SaveManager (Allows you to have a configuration system)
    -- InterfaceManager (Allows you to have a interface managment system)
    
    -- Hand the library over to our managers
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    -- Ignore keys that are used by ThemeManager.
    -- (we dont want configs to save themes, do we?)
    SaveManager:IgnoreThemeSettings()
    
    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})
    
    -- use case for doing it this way:
    -- a script hub could have themes in a global folder
    -- and game configs in a separate folder per game
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    
    Window:SelectTab(1)
    
    Fluent:Notify({
        Title = "Fluent",
        Content = "The script has been loaded.",
        Duration = 8
    })
    
    -- You can use the SaveManager:LoadAutoloadConfig() to load a config
    -- which has been marked to be one that auto loads!
    SaveManager:LoadAutoloadConfig()
    
--End of Track & Field: Infinite SCRIPT    
end

--Fisch Script
if game.PlaceId == 16732694052 then

    --Services
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local HttpService = game:GetService("HttpService")
    local GuiService = game:GetService("GuiService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local CoreGui = game:GetService('StarterGui')
    local ContextActionService = game:GetService('ContextActionService')
    local UserInputService = game:GetService('UserInputService')
    
    --Locals
    local LocalPlayer = Players.LocalPlayer
    local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
    local UserPlayer = HumanoidRootPart:WaitForChild("user")
    local ActiveFolder = Workspace:FindFirstChild("active")
    local FishingZonesFolder = Workspace:FindFirstChild("zones"):WaitForChild("fishing")
    local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
    local NpcFolder = Workspace:FindFirstChild("world"):WaitForChild("npcs")
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui", PlayerGui)
    local shadowCountLabel = Instance.new("TextLabel", screenGui)
    local RenderStepped = RunService.RenderStepped
    local WaitForSomeone = RenderStepped.Wait
    
    --Features
    
    
    --Variables
    local CastMode = "Legit"
    local ShakeMode = "Navigation"
    local ReelMode = "Blatant"
    local CollectMode = "Teleports"
    local teleportSpots = {}
    local FreezeChar = false
    local DayOnlyLoop = nil
    local BypassGpsLoop = nil
    local Noclip = false
    local RunCount = false
    
    --Auto Cast
    local autoCastEnabled = false
    local function autoCast()
        if LocalCharacter then
            local tool = LocalCharacter:FindFirstChildOfClass("Tool")
            if tool then
                local hasBobber = tool:FindFirstChild("bobber")
                if not hasBobber then
                    if CastMode == "Legit" then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                        HumanoidRootPart.ChildAdded:Connect(function()
                            if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
                                HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                    if property == "Size" then
                                        if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                        end
                                    end
                                end)
                            end
                        end)
                    elseif CastMode == "Blatant" then
                        local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
                        if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                            task.wait(0.5)
                            local Random = math.random(90, 99)
                            rod.events.cast:FireServer(Random)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end
    
    --Auto Shake
    local autoShakeEnabled = false
    local autoShakeConnection
    local function autoShake()
        if ShakeMode == "Navigation" then
            task.wait()
            xpcall(function()
                local shakeui = PlayerGui:FindFirstChild("shakeui")
                if not shakeui then return end
                local safezone = shakeui:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                task.wait(0.2)
                GuiService.SelectedObject = button
                if GuiService.SelectedObject == button then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
                task.wait(0.1)
                GuiService.SelectedObject = nil
            end,function (err)
            end)
        elseif ShakeMode == "Mouse" then
            task.wait()
            xpcall(function()
                local shakeui = PlayerGui:FindFirstChild("shakeui")
                if not shakeui then return end
                local safezone = shakeui:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                local pos = button.AbsolutePosition
                local size = button.AbsoluteSize
                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, LocalPlayer, 0)
                VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, LocalPlayer, 0)
            end,function (err)
            end)
        end
    end
    
    local function startAutoShake()
        if autoShakeConnection or not autoShakeEnabled then return end
        autoShakeConnection = RunService.RenderStepped:Connect(autoShake)
    end
    
    local function stopAutoShake()
        if autoShakeConnection then
            autoShakeConnection:Disconnect()
            autoShakeConnection = nil
        end
    end
    
    PlayerGui.DescendantAdded:Connect(function(descendant)
        if autoShakeEnabled and descendant.Name == "button" and descendant.Parent and descendant.Parent.Name == "safezone" then
            startAutoShake()
        end
    end)
    
    PlayerGui.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
            stopAutoShake()
        end
    end)
    
    if autoShakeEnabled and PlayerGui:FindFirstChild("shakeui") and PlayerGui.shakeui:FindFirstChild("safezone") and PlayerGui.shakeui.safezone:FindFirstChild("button") then
        startAutoShake()
    end
    
    --Auto Reel
    local autoReelEnabled = false
    local PerfectCatchEnabled = false
    local autoReelConnection
    local function autoReel()
        local reel = PlayerGui:FindFirstChild("reel")
        if not reel then return end
        local bar = reel:FindFirstChild("bar")
        local playerbar = bar and bar:FindFirstChild("playerbar")
        local fish = bar and bar:FindFirstChild("fish")
        if playerbar and fish then
            playerbar.Position = fish.Position
        end
    end
    
    local function noperfect()
        local reel = PlayerGui:FindFirstChild("reel")
        if not reel then return end
        local bar = reel:FindFirstChild("bar")
        local playerbar = bar and bar:FindFirstChild("playerbar")
        if playerbar then
            playerbar.Position = UDim2.new(0, 0, -35, 0)
            wait(0.2)
        end
    end
    
    local function startAutoReel()
        if ReelMode == "Legit" then
            if autoReelConnection or not autoReelEnabled then return end
            noperfect()
            task.wait(2)
            autoReelConnection = RunService.RenderStepped:Connect(autoReel)
        elseif ReelMode == "Blatant" then
            local reel = PlayerGui:FindFirstChild("reel")
            if not reel then return end
            local bar = reel:FindFirstChild("bar")
            local playerbar = bar and bar:FindFirstChild("playerbar")
            playerbar:GetPropertyChangedSignal('Position'):Wait()
            game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
        end
    end
    
    local function stopAutoReel()
        if autoReelConnection then
            autoReelConnection:Disconnect()
            autoReelConnection = nil
        end
    end
    
    PlayerGui.DescendantAdded:Connect(function(descendant)
        if autoReelEnabled and descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
            startAutoReel()
        end
    end)
    
    PlayerGui.DescendantRemoving:Connect(function(descendant)
        if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
            stopAutoReel()
            if autoCastEnabled then
                task.wait(1)
                autoCast()
            end
        end
    end)
    
    if autoReelEnabled and PlayerGui:FindFirstChild("reel") and 
        PlayerGui.reel:FindFirstChild("bar") and 
        PlayerGui.reel.bar:FindFirstChild("playerbar") then
        startAutoReel()
    end
    
    --Zone Casts
    ZoneConnection = LocalCharacter.ChildAdded:Connect(function(child)
        if ZoneCast and child:IsA("Tool") and FishingZonesFolder:FindFirstChild(Zone) ~= nil then
            child.ChildAdded:Connect(function(blehh)
                if blehh.Name == "bobber" then
                    local RopeConstraint = blehh:FindFirstChildOfClass("RopeConstraint")
                    if ZoneCast and RopeConstraint ~= nil then
                        RopeConstraint.Changed:Connect(function(property)
                            if property == "Length" then
                                RopeConstraint.Length = math.huge
                            end
                        end)
                        RopeConstraint.Length = math.huge
                    end
                    task.wait(1)
                    while WaitForSomeone(RenderStepped) do
                        if ZoneCast and blehh.Parent ~= nil then
                            task.wait()
                            blehh.CFrame = FishingZonesFolder[Zone].CFrame
                        else
                            break
                        end
                    end
                end
            end)
        end
    end)
    
    --Find Tp's
    local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
    for i, v in pairs(TpSpotsFolder:GetChildren()) do
        if table.find(teleportSpots, v.Name) == nil then
            table.insert(teleportSpots, v.Name)
        end
    end
    
    --Get Position
    function GetPosition()
        if not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return {
                Vector3.new(0,0,0),
                Vector3.new(0,0,0),
                Vector3.new(0,0,0)
            }
        end
        return {
            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.X,
            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.Y,
            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position.Z
        }
    end
    
    function ExportValue(arg1, arg2)
        return tonumber(string.format("%."..(arg2 or 1)..'f', arg1))
    end
    
    --Sell Items
    function rememberPosition()
        spawn(function()
            local initialCFrame = HumanoidRootPart.CFrame
     
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = HumanoidRootPart
     
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.D = 100
            bodyGyro.P = 10000
            bodyGyro.CFrame = initialCFrame
            bodyGyro.Parent = HumanoidRootPart
     
            while AutoFreeze do
                HumanoidRootPart.CFrame = initialCFrame
                task.wait(0.01)
            end
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            if bodyGyro then
                bodyGyro:Destroy()
            end
        end)
    end
    function SellHand()
        local currentPosition = HumanoidRootPart.CFrame
        local sellPosition = CFrame.new(464, 151, 232)
        local wasAutoFreezeActive = false
        if AutoFreeze then
            wasAutoFreezeActive = true
            AutoFreeze = false
        end
        HumanoidRootPart.CFrame = sellPosition
        task.wait(0.5)
        workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Marc Merchant"):WaitForChild("merchant"):WaitForChild("sell"):InvokeServer()
        task.wait(1)
        HumanoidRootPart.CFrame = currentPosition
        if wasAutoFreezeActive then
            AutoFreeze = true
            rememberPosition()
        end
    end
    function SellAll()
        local currentPosition = HumanoidRootPart.CFrame
        local sellPosition = CFrame.new(464, 151, 232)
        local wasAutoFreezeActive = false
        if AutoFreeze then
            wasAutoFreezeActive = true
            AutoFreeze = false
        end
        HumanoidRootPart.CFrame = sellPosition
        task.wait(0.5)
        workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Marc Merchant"):WaitForChild("merchant"):WaitForChild("sellall"):InvokeServer()
        task.wait(1)
        HumanoidRootPart.CFrame = currentPosition
        if wasAutoFreezeActive then
            AutoFreeze = true
            rememberPosition()
        end
    end
    
    --Noclip
    NoclipConnection = RunService.Stepped:Connect(function()
        if Noclip == true then
            if LocalCharacter ~= nil then
                for i, v in pairs(LocalCharacter:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
    
    --Dupe
    local DupeEnabled = false
    local DupeConnection
    local function autoDupe()
        local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
        if hud then
            local safezone = hud:FindFirstChild("safezone")
            if safezone then
                local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
                if bodyAnnouncements then
                    local offerFrame = bodyAnnouncements:FindFirstChild("offer")
                    if offerFrame and offerFrame:FindFirstChild("confirm") then
                        firesignal(offerFrame.confirm.MouseButton1Click)
                    end
                end
            end
        end
    end
    
    local function startAutoDupe()
        if DupeConnection or not DupeEnabled then return end
        DupeConnection = RunService.RenderStepped:Connect(autoDupe)
    end
    
    local function stopAutoDupe()
        if DupeConnection then
            DupeConnection:Disconnect()
            DupeConnection = nil
        end
    end
    
    PlayerGui.DescendantAdded:Connect(function(descendant)
        if DupeEnabled and descendant.Name == "confirm" and descendant.Parent and descendant.Parent.Name == "offer" then
            local hud = LocalPlayer.PlayerGui:FindFirstChild("hud")
            if hud then
                local safezone = hud:FindFirstChild("safezone")
                if safezone then
                    local bodyAnnouncements = safezone:FindFirstChild("bodyannouncements")
                    if bodyAnnouncements then
                        local offerFrame = bodyAnnouncements:FindFirstChild("offer")
                        if offerFrame and offerFrame:FindFirstChild("confirm") then
                            firesignal(offerFrame.confirm.MouseButton1Click)
                        end
                    end
                end
            end
        end
    end)
    
    --UI Manager
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    
    local Window = Fluent:CreateWindow({
        Title = "Plasma | Fisch",
        SubTitle = "by Capone",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift 
    })
    
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "percent" }),
        Misc = Window:AddTab({ Title = "Player", Icon = "user" }),
        Teleports = Window:AddTab({ Title = "Teleports", Icon = "map" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
    
    local Options = Fluent.Options
    
    do
        
        --Main Tab
        local section = Tabs.Main:AddSection("Auto Fish")
        local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false })
        autoCast:OnChanged(function()
            local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
            if Options.autoCast.Value == true then
                autoCastEnabled = true
                if LocalPlayer.Backpack:FindFirstChild(RodName) then
                    LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
                end
                if LocalCharacter then
                    local tool = LocalCharacter:FindFirstChildOfClass("Tool")
                    if tool then
                        local hasBobber = tool:FindFirstChild("bobber")
                        if not hasBobber then
                            if CastMode == "Legit" then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                                HumanoidRootPart.ChildAdded:Connect(function()
                                    if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
                                        HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                            if property == "Size" then
                                                if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                                end
                                            end
                                        end)
                                    end
                                end)
                            elseif CastMode == "Blatant" then
                                local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
                                if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                                    task.wait(0.5)
                                    local Random = math.random(90, 99)
                                    rod.events.cast:FireServer(Random)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            else
                autoCastEnabled = false
            end
        end)
        local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false })
        autoShake:OnChanged(function()
            if Options.autoShake.Value == true then
                autoShakeEnabled = true
                startAutoShake()
            else
                autoShakeEnabled = false
                stopAutoShake()
            end
        end)
        local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false })
        autoReel:OnChanged(function()
            if Options.autoReel.Value == true then
                autoReelEnabled = true
                startAutoReel()
            else
                autoReelEnabled = false
                stopAutoReel()
            end
        end)
    
        --Mode Tab
        local section = Tabs.Main:AddSection("Adjust Modes")
        local autoCastMode = Tabs.Main:AddDropdown("autoCastMode", {
            Title = "Auto Cast Mode",
            Values = {"Legit", "Blatant"},
            Multi = false,
            Default = CastMode,
        })
        autoCastMode:OnChanged(function(Value)
            CastMode = Value
        end)
        local autoShakeMode = Tabs.Main:AddDropdown("autoShakeMode", {
            Title = "Auto Shake Mode",
            Values = {"Navigation", "Mouse"},
            Multi = false,
            Default = ShakeMode,
        })
        autoShakeMode:OnChanged(function(Value)
            ShakeMode = Value
        end)
        local autoReelMode = Tabs.Main:AddDropdown("autoReelMode", {
            Title = "Auto Reel Mode",
            Values = {"Legit", "Blatant"},
            Multi = false,
            Default = ReelMode,
        })
        autoReelMode:OnChanged(function(Value)
            ReelMode = Value
        end)
    
        --Misc Tab
    
        --Sell items
        local section = Tabs.Misc:AddSection("Sell Items")
        Tabs.Misc:AddButton({
            Title = "Sell Hand",
            Description = "",
            Callback = function()
                SellHand()
            end
        })
        Tabs.Misc:AddButton({
            Title = "Sell All",
            Description = "",
            Callback = function()
                SellAll()
            end
        })
    
        --Treasure
        local section = Tabs.Misc:AddSection("Treasure")
        Tabs.Misc:AddButton({
            Title = "Teleport to Jack Marrow",
            Callback = function()
                HumanoidRootPart.CFrame = CFrame.new(-2824.359, 214.311, 1518.130)
            end
        })
        Tabs.Misc:AddButton({
            Title = "Repair Map",
            Callback = function()
                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
                    if v.Name == "Treasure Map" then
                        game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                        workspace.world.npcs["Jack Marrow"].treasure.repairmap:InvokeServer()
                    end
                end
            end
        })
        Tabs.Misc:AddButton({
            Title = "Collect Treasure",
            Callback = function()
                for i, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                    if v.ClassName == "ProximityPrompt" then
                        v.HoldDuration = 0
                    end
                end
                for i, v in pairs(workspace.world.chests:GetDescendants()) do
                    if v:IsA("Part") and v:FindFirstChild("ChestSetup") then 
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        for _, v in pairs(workspace.world.chests:GetDescendants()) do
                            if v.Name == "ProximityPrompt" then
                                fireproximityprompt(v)
                            end
                        end
                        task.wait(1)
                    end 
                end
            end
        })
    
        --Walkspeed
        local section = Tabs.Misc:AddSection("Humanoid")
        local WalkSpeedSliderUI = Tabs.Misc:AddSlider("WalkSpeedSliderUI", {
            Title = "Walk Speed",
            Min = 16,
            Max = 200,
            Default = 16,
            Rounding = 1,
        })
        WalkSpeedSliderUI:OnChanged(function(value)
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
    
        --Jump Height
        local JumpHeightSliderUI = Tabs.Misc:AddSlider("JumpHeightSliderUI", {
            Title = "Jump Height",
            Min = 50,
            Max = 200,
            Default = 50,
            Rounding = 1,
        })
        JumpHeightSliderUI:OnChanged(function(value)
            LocalPlayer.Character.Humanoid.JumpPower = value
        end)
    
        --Oxygen
        local DisableOxygen = Tabs.Misc:AddToggle("DisableOxygen", {Title = "Infinite Oxygen", Default = true })
        DisableOxygen:OnChanged(function()
            LocalPlayer.Character.client.oxygen.Disabled = Options.DisableOxygen.Value
        end)
    
        --Teleport Tab
        local section = Tabs.Teleports:AddSection("Teleport")
        local IslandTPDropdownUI = Tabs.Teleports:AddDropdown("IslandTPDropdownUI", {
            Title = "Area Teleport",
            Values = teleportSpots,
            Multi = false,
            Default = nil,
        })
        IslandTPDropdownUI:OnChanged(function(Value)
            if teleportSpots ~= nil and HumanoidRootPart ~= nil then
                xpcall(function()
                    HumanoidRootPart.CFrame = TpSpotsFolder:FindFirstChild(Value).CFrame + Vector3.new(0, 5, 0)
                    IslandTPDropdownUI:SetValue(nil)
                end,function (err)
                end)
            end
        end)
        local TotemTPDropdownUI = Tabs.Teleports:AddDropdown("TotemTPDropdownUI", {
            Title = "Select Totem",
            Values = {"Aurora", "Sundial", "Windset", "Smokescreen", "Tempest"},
            Multi = false,
            Default = nil,
        })
        TotemTPDropdownUI:OnChanged(function(Value)
            SelectedTotem = Value
            if SelectedTotem == "Aurora" then
                HumanoidRootPart.CFrame = CFrame.new(-1811, -137, -3282)
                TotemTPDropdownUI:SetValue(nil)
            elseif SelectedTotem == "Sundial" then
                HumanoidRootPart.CFrame = CFrame.new(-1148, 135, -1075)
                TotemTPDropdownUI:SetValue(nil)
            elseif SelectedTotem == "Windset" then
                HumanoidRootPart.CFrame = CFrame.new(2849, 178, 2702)
                TotemTPDropdownUI:SetValue(nil)
            elseif SelectedTotem == "Smokescreen" then
                HumanoidRootPart.CFrame = CFrame.new(2789, 140, -625)
                TotemTPDropdownUI:SetValue(nil)
            elseif SelectedTotem == "Tempest" then
                HumanoidRootPart.CFrame = CFrame.new(35, 133, 1943)
                TotemTPDropdownUI:SetValue(nil)
            end
        end)
        local WorldEventTPDropdownUI = Tabs.Teleports:AddDropdown("WorldEventTPDropdownUI", {
            Title = "Select World Event",
            Values = {"Strange Whirlpool", "Great Hammerhead Shark", "Great White Shark", "Whale Shark", "The Depths - Serpent"},
            Multi = false,
            Default = nil,
        })
        WorldEventTPDropdownUI:OnChanged(function(Value)
            SelectedWorldEvent = Value
            if SelectedWorldEvent == "Strange Whirlpool" then
                local offset = Vector3.new(25, 135, 25)
                local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Isonade")
                if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Strange Whirlpool") end
                HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing.Isonade.Position + offset)                           -- Strange Whirlpool
                WorldEventTPDropdownUI:SetValue(nil)
            elseif SelectedWorldEvent == "Great Hammerhead Shark" then
                local offset = Vector3.new(0, 135, 0)
                local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Great Hammerhead Shark")
                if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Great Hammerhead Shark") end
                HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Great Hammerhead Shark"].Position + offset)         -- Great Hammerhead Shark
                WorldEventTPDropdownUI:SetValue(nil)
            elseif SelectedWorldEvent == "Great White Shark" then
                local offset = Vector3.new(0, 135, 0)
                local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Great White Shark")
                if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Great White Shark") end
                HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Great White Shark"].Position + offset)               -- Great White Shark
                WorldEventTPDropdownUI:SetValue(nil)
            elseif SelectedWorldEvent == "Whale Shark" then
                local offset = Vector3.new(0, 135, 0)
                local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("Whale Shark")
                if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found Whale Shark") end
                HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["Whale Shark"].Position + offset)                     -- Whale Shark
                WorldEventTPDropdownUI:SetValue(nil)
            elseif SelectedWorldEvent == "The Depths - Serpent" then
                local offset = Vector3.new(0, 50, 0)
                local WorldEvent = game.Workspace.zones.fishing:FindFirstChild("The Depths - Serpent")
                if not WorldEvent then WorldEventTPDropdownUI:SetValue(nil) return ShowNotification("Not found The Depths - Serpent") end
                HumanoidRootPart.CFrame = CFrame.new(game.Workspace.zones.fishing["The Depths - Serpent"].Position + offset)            -- The Depths - Serpent
                WorldEventTPDropdownUI:SetValue(nil)
            end
        end)
        Tabs.Teleports:AddButton({
            Title = "Teleport to Traveler Merchant",
            Description = "Teleports to the Traveler Merchant.",
            Callback = function()
                local Merchant = game.Workspace.active:FindFirstChild("Merchant Boat")
                if not Merchant then return ShowNotification("Not found Merchant") end
                HumanoidRootPart.CFrame = CFrame.new(game.Workspace.active["Merchant Boat"].Boat["Merchant Boat"].r.HandlesR.Position)
            end
        })
        Tabs.Teleports:AddButton({
            Title = "Create Safe Zone",
            Callback = function()
                local SafeZone = Instance.new("Part")
                SafeZone.Size = Vector3.new(30, 1, 30)
                SafeZone.Position = Vector3.new(math.random(-2000,2000), math.random(50000,90000), math.random(-2000,2000))
                SafeZone.Anchored = true
                SafeZone.BrickColor = BrickColor.new("Bright purple")
                SafeZone.Material = Enum.Material.ForceField
                SafeZone.Parent = game.Workspace
                HumanoidRootPart.CFrame = SafeZone.CFrame + Vector3.new(0, 5, 0)
            end
        })
    
    end 
    
    
    
    
    -- Addons:
    -- SaveManager (Allows you to have a configuration system)
    -- InterfaceManager (Allows you to have a interface managment system)
    
    -- Hand the library over to our managers
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    -- Ignore keys that are used by ThemeManager.
    -- (we dont want configs to save themes, do we?)
    SaveManager:IgnoreThemeSettings()
    
    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})
    
    -- use case for doing it this way:
    -- a script hub could have themes in a global folder
    -- and game configs in a separate folder per game
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    
    
    Window:SelectTab(1)
    
    Fluent:Notify({
        Title = "Plasma",
        Content = "The script has been loaded.",
        Duration = 8
    })
    
    -- You can use the SaveManager:LoadAutoloadConfig() to load a config
    -- which has been marked to be one that auto loads!
    SaveManager:LoadAutoloadConfig()
    
--End of Fisch Script
end