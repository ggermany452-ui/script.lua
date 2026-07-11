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

-- State variables for Tab Features
local AuraEnabled = false
local AURA_RADIUS = 50
local ATTACK_COOLDOWN = 0.15
local FullbrightEnabled = false
local EspEnabled = false
local InvisibleEnabled = false
local TeleportToolEnabled = false

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
    Name = "Combat & Exploration Helper",
    LoadingTitle = "Loading System Configuration...",
    LoadingSubtitle = "Initializing Project Modules",
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
-- TAB 1: MAIN COMBAT
-- ==========================================
local Tab1 = Window:CreateTab("Main", 4483362458)

Tab1:CreateSection("Local State Overrides")

Tab1:CreateButton({
    Name = "Force Unlock Attack States",
    Callback = function()
        if v_u_116 then
            v_u_116.CanAttack = true
            v_u_116.PushDebounce = false
            v_u_116.CanWeave = false
            Rayfield:Notify({
                Title = "State Overridden",
                Content = "Attack states successfully forced to True.",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

Tab1:CreateToggle({
    Name = "Auto-Clear Stuns / Busy Flags",
    CurrentValue = false,
    Flag = "StunClearToggle",
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

-- ==========================================
-- TAB 2: HORROR & VISUALS
-- ==========================================
local Tab2 = Window:CreateTab("Visuals", 4483362458)

Tab2:CreateSection("Environment Helpers")

local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

Tab2:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
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

Tab2:CreateToggle({
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

-- ==========================================
-- TAB 3: KNOCK (Optimized Elimination Engine)
-- ==========================================
local Tab3 = Window:CreateTab("Knock", 4483362458)

Tab3:CreateSection("Automated Combat Operations")

Tab3:CreateToggle({
    Name = "Aggressive Elimination Aura",
    CurrentValue = false,
    Flag = "PunchAuraToggle",
    Callback = function(Value)
        AuraEnabled = Value
        
        if AuraEnabled then
            task.spawn(function()
                while AuraEnabled do
                    -- 1. Unconditional Local State Management
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

                    -- 2. Target Acquisition & Lock-on
                    local target = getOptimalTarget()
                    
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        while AuraEnabled and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
                            
                            -- Continuous Orientation Adjustment
                            local myHRP = (LocalPlayer.Character or v_u_7):FindFirstChild("HumanoidRootPart")
                            if myHRP and target:FindFirstChild("HumanoidRootPart") then
                                myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(target.HumanoidRootPart.Position.X, myHRP.Position.Y, target.HumanoidRootPart.Position.Z))
                                
                                -- Re-verify distance dynamically inside the sub-loop
                                if (myHRP.Position - target.HumanoidRootPart.Position).Magnitude > AURA_RADIUS then
                                    break
                                end
                            end

                            -- 3. High-Frequency Execution Pointers
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

Tab3:CreateSection("Aura Configurations")

Tab3:CreateSlider({
    Name = "Aura Reach Distance",
    Min = 10,
    Max = 100,
    DefaultValue = 50,
    Color = Color3.fromRGB(255, 75, 75),
    Increment = 5,
    ValueName = "Studs",
    Flag = "AuraRangeSlider",
    Callback = function(Value)
        AURA_RADIUS = Value
    end,
})

Tab3:CreateSlider({
    Name = "Attack Rate (Speed)",
    Min = 0.05,
    Max = 1.0,
    DefaultValue = 0.15,
    Color = Color3.fromRGB(75, 175, 255),
    Increment = 0.05,
    ValueName = "Seconds",
    Flag = "AttackSpeedSlider",
    Callback = function(Value)
        ATTACK_COOLDOWN = Value
    end,
})

-- ==========================================
-- TAB 4: EXPLOITS (Invisibility & Teleport Tool)
-- ==========================================
local Tab4 = Window:CreateTab("Exploits", 4483362458)

Tab4:CreateSection("Character Modifiers")

-- Invisible Character Toggle Logic
Tab4:CreateToggle({
    Name = "Invisible Character Mode",
    CurrentValue = false,
    Flag = "InvisibilityToggle",
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
                            -- Maintain root integrity for structural scripts/remotes
                            if part.Name ~= "HumanoidRootPart" then
                                part.Transparency = 1
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            
            -- Restore visibility on toggle exit
            if not InvisibleEnabled then
                local resetChar = LocalPlayer.Character or v_u_7
                if resetChar then
                    for _, part in ipairs(resetChar:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            if part.Name ~= "HumanoidRootPart" then
                                part.Transparency = 0
                            end
                        end
                    end
                end
            end
        end)
    end,
})

Tab4:CreateSection("Map Traversal Utilites")

-- Click Teleport Tool Generator
Tab4:CreateToggle({
    Name = "Enable Click Teleport Tool",
    CurrentValue = false,
    Flag = "TPToolToggle",
    Callback = function(Value)
        TeleportToolEnabled = Value
        
        if TeleportToolEnabled then
            -- Create custom click interaction tool context dynamically
            local tpTool = Instance.new("Tool")
            tpTool.Name = "Click Teleport"
            tpTool.RequiresHandle = false
            tpTool.Parent = LocalPlayer.Backpack

            tpTool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                local char = LocalPlayer.Character or v_u_7
                if char and char:FindFirstChild("HumanoidRootPart") and mouse.Target then
                    -- Offset target slightly along the Y axis to keep character from clips
                    char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end)
            
            _G.ActiveTPTool = tpTool
        else
            -- Safely extract tool from inventory arrays when turned off
            if _G.ActiveTPTool then
                _G.ActiveTPTool:Destroy()
                _G.ActiveTPTool = nil
            end
            local oldTool = LocalPlayer.Backpack:FindFirstChild("Click Teleport") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Click Teleport"))
            if oldTool then oldTool:Destroy() end
        end
    end,
})

-- Initialize configuration defaults
Rayfield:LoadConfiguration()
