-- ==========================================
-- DEPENDENCIES & ENVIRONMENT SETUP
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Fallbacks for the game's decompiled local environment variables
local v_u_7 = v_u_7 or game:GetService("Players").LocalPlayer.Character
local v_u_116 = v_u_116 or { CanAttack = true, PushDebounce = false, CanWeave = false }
local v_u_194 = v_u_194 or function() 
    local SecureFire = game:GetService("ReplicatedStorage"):FindFirstChild("SecureFire") or game:GetService("ReplicatedStorage"):FindFirstChild("CombatRemote")
    if SecureFire then
        SecureFire:FireServer("Push")
    end
end

-- ==========================================
-- UNIVERSAL ENGINE CONFIGURATIONS
-- ==========================================
local AuraEnabled = false
local AURA_RADIUS = 50
local ATTACK_COOLDOWN = 0.15
local FullbrightEnabled = false
local EspEnabled = false
local InvisibleEnabled = false
local TeleportToolEnabled = false

-- Addition State Parameters
local WalkSpeedValue = 16
local JumpPowerValue = 50
local InfiniteJumpEnabled = false
local NoclipEnabled = false
local AutoFarmEnabled = false
local TargetPlayerName = ""
local ChatSpamEnabled = false
local ChatSpamMessage = "Helper Active!"
local SpinBotEnabled = false
local ViewTargetEnabled = false
local HitboxSizeValue = 2
local HitboxExtendEnabled = false

-- Service references
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

-- Specialized targeted scanning for low health units
local function getOptimalTarget()
    local myCharacter = LocalPlayer.Character or v_u_7
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myHRP = myCharacter.HumanoidRootPart
    local targetEnemy = nil
    local lowestHealth = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local enemyChar = player.Character
            if enemyChar and enemyChar:FindFirstChild("HumanoidRootPart") and enemyChar:FindFirstChild("Humanoid") then
                local currentHealth = enemyChar.Humanoid.Health
                
                if currentHealth > 0 and not enemyChar:GetAttribute("IsDead") and not enemyChar:FindFirstChild("IFrame") then
                    local enemyHRP = enemyChar.HumanoidRootPart
                    local distance = (myHRP.Position - enemyHRP.Position).Magnitude
                    
                    if distance <= AURA_RADIUS and currentHealth < lowestHealth then
                        lowestHealth = currentHealth
                        targetEnemy = enemyChar
                    end
                end
            end
        end
    end
    return targetEnemy
end

-- ==========================================
-- UI INITIALIZATION
-- ==========================================
local Window = Rayfield:CreateWindow({
    Name = "Master Combat & Exploitation Engine",
    LoadingTitle = "Loading System Configuration...",
    LoadingSubtitle = "All Modules Pre-Loaded & Categorized",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "CombatProject",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- ==========================================
-- TAB 1: COMBAT (Elimination Engine)
-- ==========================================
local Tab1 = Window:CreateTab("Combat", 4483362458)

Tab1:CreateSection("--- [ MENU: AUTO ELIMINATION ] ---")

Tab1:CreateToggle({
    Name = "Aggressive Elimination Aura",
    CurrentValue = false,
    Flag = "PunchAuraToggle",
    Callback = function(Value)
        AuraEnabled = Value
        
        if AuraEnabled then
            task.spawn(function()
                while AuraEnabled do
                    if v_u_116 then
                        v_u_116.CanAttack = true
                        v_u_116.PushDebounce = false
                        v_u_116.CanWeave = false
                        
                        local myChar = LocalPlayer.Character or v_u_7
                        if myChar then
                            local stun = myChar:FindFirstChild("Stun") or myChar:FindFirstChild("BUSY")
                            if stun then stun:Destroy() end
                            myChar:SetAttribute("HitStun", false)
                        end
                    end

                    local target = getOptimalTarget()
                    
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        while AuraEnabled and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
                            
                            local myHRP = (LocalPlayer.Character or v_u_7):FindFirstChild("HumanoidRootPart")
                            if myHRP and target:FindFirstChild("HumanoidRootPart") then
                                myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(target.HumanoidRootPart.Position.X, myHRP.Position.Y, target.HumanoidRootPart.Position.Z))
                                
                                if (myHRP.Position - target.HumanoidRootPart.Position).Magnitude > AURA_RADIUS then
                                    break
                                end
                            end

                            if typeof(v_u_194) == "function" then
                                task.spawn(v_u_194)
                            end
                            
                            task.wait(ATTACK_COOLDOWN) 
                        end
                    end
                    
                    task.wait(0.1)
                end
            end)
        end
    end,
})

Tab1:CreateSection("--- [ MENU: AURA CONFIG ] ---")

Tab1:CreateSlider({
    Name = "Aura Reach Distance", Min = 10, Max = 100, DefaultValue = 50, Color = Color3.fromRGB(255, 75, 75), Increment = 5, ValueName = "Studs", Flag = "AuraRangeSlider",
    Callback = function(Value) AURA_RADIUS = Value end,
})

Tab1:CreateSlider({
    Name = "Attack Rate (Speed)", Min = 0.05, Max = 1.0, DefaultValue = 0.15, Color = Color3.fromRGB(75, 175, 255), Increment = 0.05, ValueName = "Seconds", Flag = "AttackSpeedSlider",
    Callback = function(Value) ATTACK_COOLDOWN = Value end,
})

Tab1:CreateSection("--- [ MENU: HITBOX EXTENSION ] ---")

Tab1:CreateToggle({
    Name = "Extend Target Hitboxes", CurrentValue = false, Flag = "ExtendBoxes",
    Callback = function(V) 
        HitboxExtendEnabled = V 
        game:GetService("RunService").RenderStepped:Connect(function() 
            if HitboxExtendEnabled then 
                for _, p in ipairs(Players:GetPlayers()) do 
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                        p.Character.HumanoidRootPart.Size = Vector3.new(HitboxSizeValue, HitboxSizeValue, HitboxSizeValue) 
                        p.Character.HumanoidRootPart.CanCollide = false 
                    end 
                end 
            end 
        end) 
    end
})

Tab1:CreateSlider({
    Name = "Hitbox Target Scale", Min = 2, Max = 30, DefaultValue = 2, Increment = 1, ValueName = "Size studs", Flag = "SizeScale",
    Callback = function(V) HitboxSizeValue = V end
})


-- ==========================================
-- TAB 2: MOVEMENT (Local Character Modifiers)
-- ==========================================
local Tab2 = Window:CreateTab("Movement", 4483362458)

Tab2:CreateSection("--- [ MENU: SPEED & PHYSICALS ] ---")

Tab2:CreateSlider({
    Name = "WalkSpeed Modifier", Min = 16, Max = 250, DefaultValue = 16, Increment = 1, ValueName = "Speed", Flag = "SpeedSlider",
    Callback = function(V) 
        WalkSpeedValue = V 
        local c = LocalPlayer.Character or v_u_7 
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = V end 
    end
})

Tab2:CreateSlider({
    Name = "JumpPower Modifier", Min = 50, Max = 500, DefaultValue = 50, Increment = 5, ValueName = "Power", Flag = "JumpSlider",
    Callback = function(V) 
        JumpPowerValue = V 
        local c = LocalPlayer.Character or v_u_7 
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = V c.Humanoid.UseJumpPower = true end 
    end
})

Tab2:CreateSection("--- [ MENU: ENVIRONMENT NAVIGATION ] ---")

Tab2:CreateToggle({
    Name = "Infinite Jump Engine", CurrentValue = false, Flag = "InfJump",
    Callback = function(V) 
        InfiniteJumpEnabled = V 
        game:GetService("UserInputService").JumpRequest:Connect(function() 
            if InfiniteJumpEnabled then 
                local c = LocalPlayer.Character or v_u_7 
                if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end 
            end 
        end) 
    end
})

Tab2:CreateToggle({
    Name = "Noclip Active", CurrentValue = false, Flag = "Noclip",
    Callback = function(V) 
        NoclipEnabled = V 
        game:GetService("RunService").Stepped:Connect(function() 
            if NoclipEnabled then 
                local c = LocalPlayer.Character or v_u_7 
                if c then for _, part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end 
            end 
        end) 
    end
})


-- ==========================================
-- TAB 3: VISUALS (Render Hooks)
-- ==========================================
local Tab3 = Window:CreateTab("Visuals", 4483362458)

Tab3:CreateSection("--- [ MENU: RENDERING & ESP ] ---")

Tab3:CreateToggle({
    Name = "Entity / Player ESP",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(Value)
        EspEnabled = Value
        
        local function applyESP(player)
            if player == LocalPlayer then return end
            player.CharacterAdded:Connect(function(char)
                if not EspEnabled then return end
                task.wait(0.5)
                if not char:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 75, 75)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = char
                end
            end)
            
            if player.Character and not player.Character:FindFirstChild("ESPHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 75, 75)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = player.Character
            end
        end

        if EspEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                applyESP(player)
            end
            _G.PlayerAddedConnection = Players.PlayerAdded:Connect(applyESP)
        else
            if _G.PlayerAddedConnection then 
                _G.PlayerAddedConnection:Disconnect() 
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                    player.Character.ESPHighlight:Destroy()
                end
            end
        end
    end,
})

Tab3:CreateToggle({
    Name = "Force Render Player Tag Overheads", CurrentValue = false, Flag = "TagEsp",
    Callback = function(V) 
        for _, p in ipairs(Players:GetPlayers()) do 
            if p.Character and p.Character:FindFirstChild("Head") and V then 
                if not p.Character.Head:FindFirstChild("EspTag") then
                    local b = Instance.new("BillboardGui", p.Character.Head) b.Name = "EspTag" b.Size = UDim2.new(0,200,0,50) b.AlwaysOnTop = true
                    local l = Instance.new("TextLabel", b) l.Size = UDim2.new(1,0,1,0) l.Text = p.Name l.TextColor3 = Color3.new(1,1,1) l.BackgroundTransparency = 1
                end
            else 
                if p.Character and p.Character.Head:FindFirstChild("EspTag") then p.Character.Head.EspTag:Destroy() end 
            end 
        end 
    end
})

Tab3:CreateToggle({
    Name = "Display Screen Tracers", CurrentValue = false, Flag = "Tracers",
    Callback = function(V) _G.TracersActive = V end
})

Tab3:CreateSection("--- [ MENU: ATMOSPHERE CONTROLS ] ---")

local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

Tab3:CreateToggle({
    Name = "Fullbright", CurrentValue = false, Flag = "FullbrightToggle",
    Callback = function(Value)
        FullbrightEnabled = Value
        if FullbrightEnabled then
            task.spawn(function()
                while FullbrightEnabled do
                    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                    Lighting.Brightness = 2
                    task.wait(0.5)
                end
            end)
        else
            Lighting.Ambient = OriginalAmbient
            Lighting.OutdoorAmbient = OriginalOutdoorAmbient
            Lighting.Brightness = 1
        end
    end,
})

Tab3:CreateSlider({
    Name = "Render FOV", Min = 70, Max = 120, DefaultValue = 70, Increment = 1, ValueName = "Degrees", Flag = "FovSlider",
    Callback = function(V) workspace.CurrentCamera.FieldOfView = V end
})

Tab3:CreateToggle({
    Name = "Disable Global Shadows", CurrentValue = false, Flag = "ShadowsToggle",
    Callback = function(V) game:GetService("Lighting").GlobalShadows = not V end
})

Tab3:CreateButton({
    Name = "Clear Atmosphere / Fog",
    Callback = function() 
        game:GetService("Lighting").FogEnd = 999999 
        if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"):Destroy() end 
    end
})

Tab3:CreateSlider({
    Name = "Force World Time (Hours)", Min = 0, Max = 24, DefaultValue = 12, Increment = 1, ValueName = "Clock Hours", Flag = "TimeSlider",
    Callback = function(V) game:GetService("Lighting").ClockTime = V end
})


-- ==========================================
-- TAB 4: AUTOMATION (Farms & Status Bypass)
-- ==========================================
local Tab4 = Window:CreateTab("Automation", 4483362458)

Tab4:CreateSection("--- [ MENU: BYPASS CODES ] ---")

Tab4:CreateButton({
    Name = "Force Unlock Attack States",
    Callback = function()
        if v_u_116 then
            v_u_116.CanAttack = true
            v_u_116.PushDebounce = false
            v_u_116.CanWeave = false
            Rayfield:Notify({Title = "State Overridden", Content = "Attack states successfully forced to True.", Duration = 3})
        end
    end,
})

Tab4:CreateToggle({
    Name = "Auto-Clear Stuns / Busy Flags", CurrentValue = false, Flag = "StunClearToggle",
    Callback = function(Value)
        _G.ClearStuns = Value
        task.spawn(function()
            while _G.ClearStuns do
                local myChar = LocalPlayer.Character or v_u_7
                if myChar then
                    local stun = myChar:FindFirstChild("Stun") or myChar:FindFirstChild("BUSY")
                    if stun then stun:Destroy() end
                    myChar:SetAttribute("HitStun", false)
                end
                task.wait(0.1)
            end
        end)
    end,
})

Tab4:CreateButton({
    Name = "Force Disable Ragdoll States",
    Callback = function() 
        local c = LocalPlayer.Character or v_u_7 
        if c then local r = c:FindFirstChild("Ragdoll") or c:FindFirstChild("RagdollTrigger") if r then r:Destroy() end end 
    end
})

Tab4:CreateSection("--- [ MENU: EXPLOITATIVE LOOPS ] ---")

Tab4:CreateToggle({
    Name = "Behind-Target Teleport Loop", CurrentValue = false, Flag = "FarmLoop",
    Callback = function(V) 
        AutoFarmEnabled = V 
        task.spawn(function() 
            while AutoFarmEnabled do 
                local t = getOptimalTarget() 
                if t and t:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                    LocalPlayer.Character.HumanoidRootPart.CFrame = t.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) 
                end 
                task.wait(0.1) 
            end 
        end) 
    end
})

Tab4:CreateToggle({
    Name = "Enable Spinbot Matrix", CurrentValue = false, Flag = "Spin",
    Callback = function(V) 
        SpinBotEnabled = V 
        task.spawn(function() 
            while SpinBotEnabled do 
                local hrp = (LocalPlayer.Character or v_u_7):FindFirstChild("HumanoidRootPart") 
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), 0) end 
                task.wait(0.01) 
            end 
        end) 
    end
})


-- ==========================================
-- TAB 5: TELEPORTATION (Exploits & Mechanics)
-- ==========================================
local Tab5 = Window:CreateTab("Teleportation", 4483362458)

Tab5:CreateSection("--- [ MENU: UTILITIES ] ---")

Tab5:CreateToggle({
    Name = "Invisible Character Mode", CurrentValue = false, Flag = "InvisibilityToggle",
    Callback = function(Value)
        InvisibleEnabled = Value
        local char = LocalPlayer.Character or v_u_7
        if not char then return end

        task.spawn(function()
            while InvisibleEnabled do
                local updatedChar = LocalPlayer.Character or v_u_7
                if updatedChar then
                    for _, part in ipairs(updatedChar:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            if part.Name ~= "HumanoidRootPart" then part.Transparency = 1 end
                        end
                    end
                end
                task.wait(0.5)
            end
            if not InvisibleEnabled then
                local resetChar = LocalPlayer.Character or v_u_7
                if resetChar then
                    for _, part in ipairs(resetChar:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            if part.Name ~= "HumanoidRootPart" then part.Transparency = 0 end
                        end
                    end
                end
            end
        end)
    end,
})

Tab5:CreateToggle({
    Name = "Enable Click Teleport Tool", CurrentValue = false, Flag = "TPToolToggle",
    Callback = function(Value)
        TeleportToolEnabled = Value
        if TeleportToolEnabled then
            local tpTool = Instance.new("Tool")
            tpTool.Name = "Click Teleport"
            tpTool.RequiresHandle = false
            tpTool.Parent = LocalPlayer.Backpack
            tpTool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                local char = LocalPlayer.Character or v_u_7
                if char and char:FindFirstChild("HumanoidRootPart") and mouse.Target then
                    char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end)
            _G.ActiveTPTool = tpTool
        else
            if _G.ActiveTPTool then _G.ActiveTPTool:Destroy() _G.ActiveTPTool = nil end
            local oldTool = LocalPlayer.Backpack:FindFirstChild("Click Teleport") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Click Teleport"))
            if oldTool then oldTool:Destroy() end
        end
    end,
})

Tab5:CreateSection("--- [ MENU: DESYNC DEFENSE ] ---")

Tab5:CreateToggle({
    Name = "Anti-Fling Structural Lock", CurrentValue = false, Flag = "AntiFling",
    Callback = function(V) 
        game:GetService("RunService").Heartbeat:Connect(function() 
            if V then 
                local c = LocalPlayer.Character or v_u_7 
                if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Velocity = Vector3.new(0,0,0) p.RotVelocity = Vector3.new(0,0,0) end end end 
            end 
        end) 
    end
})

Tab5:CreateButton({
    Name = "Attempt Desync Godmode",
    Callback = function() 
        local c = LocalPlayer.Character or v_u_7 
        if c and c:FindFirstChild("Humanoid") then local clone = c.Humanoid:Clone() c.Humanoid:Destroy() clone.Parent = c end 
    end
})

Tab5:CreateButton({
    Name = "Instant Self-Reset (Fast Respawn)",
    Callback = function() 
        local c = LocalPlayer.Character or v_u_7 
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 0 end 
    end
})


-- ==========================================
-- TAB 6: UTILITIES (Server & Target Profilers)
-- ==========================================
local Tab6 = Window:CreateTab("Utilities", 4483362458)

Tab6:CreateSection("--- [ MENU: TARGETING SYSTEMS ] ---")

Tab6:CreateInput({
    Name = "Input Target Username", PlaceholderText = "Username here...", RemoveTextAfterFocusLost = false, Flag = "PlayerInput",
    Callback = function(Text) TargetPlayerName = Text end
})

Tab6:CreateButton({
    Name = "Teleport onto Target",
    Callback = function() 
        for _, p in ipairs(Players:GetPlayers()) do 
            if string.sub(string.lower(p.Name), 1, #TargetPlayerName) == string.lower(TargetPlayerName) then 
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                    local hrp = (LocalPlayer.Character or v_u_7):FindFirstChild("HumanoidRootPart") 
                    if hrp then hrp.CFrame = p.Character.HumanoidRootPart.CFrame end 
                end 
            end 
        end 
    end
})

Tab6:CreateToggle({
    Name = "View Target Camera", CurrentValue = false, Flag = "SpectateToggle",
    Callback = function(V) 
        ViewTargetEnabled = V 
        if V then 
            for _, p in ipairs(Players:GetPlayers()) do 
                if string.sub(string.lower(p.Name), 1, #TargetPlayerName) == string.lower(TargetPlayerName) then 
                    if p.Character and p.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = p.Character.Humanoid end 
                end 
            end 
        else 
            workspace.CurrentCamera.CameraSubject = (LocalPlayer.Character or v_u_7):FindFirstChild("Humanoid") 
        end 
    end
})

Tab6:CreateSection("--- [ MENU: WORLD & NET ENGINE ] ---")

Tab6:CreateSlider({
    Name = "Workspace Gravity Alteration", Min = 0, Max = 500, DefaultValue = 196.2, Increment = 10, ValueName = "Gravity", Flag = "GravSlider",
    Callback = function(V) workspace.Gravity = V end
})

Tab6:CreateToggle({
    Name = "Lag Switch Simulation", CurrentValue = false, Flag = "LagToggle",
    Callback = function(V) settings().Network.IncomingReplicationLag = V and 1000 or 0 end
})

Tab6:CreateButton({
    Name = "Spawn Emergency Baseplate Escape",
    Callback = function() 
        local b = Instance.new("Part", workspace) b.Size = Vector3.new(100, 1, 100) b.Position = (LocalPlayer.Character or v_u_7).HumanoidRootPart.Position - Vector3.new(0, 5, 0) b.Anchored = true b.Material = Enum.Material.SmoothPlastic b.Color = Color3.fromRGB(50,50,50) 
    end
})

Tab6:CreateButton({
    Name = "Wipe Map Seats (Anti-Seat Trap)",
    Callback = function() for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Seat") or v:IsA("VehicleSeat") then v:Destroy() end end end
})

Tab6:CreateSection("--- [ MENU: CHAT INTERACTION ] ---")

Tab6:CreateToggle({
    Name = "Auto Chat Spammer", CurrentValue = false, Flag = "ChatSpam",
    Callback = function(V) 
        ChatSpamEnabled = V 
        task.spawn(function() 
            while ChatSpamEnabled do 
                local textService = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") 
                if textService and textService:FindFirstChild("SayMessageRequest") then 
                    textService.SayMessageRequest:FireServer(ChatSpamMessage, "All") 
                end 
                task.wait(3.0) 
            end 
        end) 
    end
})

Tab6:CreateInput({
    Name = "Chat Content String", PlaceholderText = "Spam context...", RemoveTextAfterFocusLost = false, Flag = "SpamString",
    Callback = function(Text) ChatSpamMessage = Text end
})

Tab6:CreateSection("--- [ MENU: CONTROL PANEL ] ---")

Tab6:CreateButton({
    Name = "Rejoin Active Server",
    Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
})

Tab6:CreateButton({
    Name = "Hop to a Different Server Instance",
    Callback = function() 
        local sf = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) 
        for _, s in pairs(sf.data) do 
            if s.playing < s.maxPlayers and s.id ~= game.JobId then 
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer) 
            end 
        end 
    end
})

Tab6:CreateButton({
    Name = "Destroy Script Overlay",
    Callback = function() Rayfield:Destroy() end
})

-- Initialize configuration defaults
Rayfield:LoadConfiguration()
