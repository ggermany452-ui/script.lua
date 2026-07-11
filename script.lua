local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Horror Game Helper",
   LoadingTitle = "Loading Systems...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- State management
local FullbrightEnabled = false
local MonsterESPEnabled = false
local InfJumpEnabled = false
local HighlightsTable = {}

-- Services
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Backup original lighting settings to restore later
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd

-- FIX: Ultra-fast loop using RenderStepped to overwrite game lighting overrides instantly
RunService.RenderStepped:Connect(function()
    if FullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
    end
end)

-- Function to check if a model is likely a monster
local function isMonster(model)
    if not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    
    local name = model.Name:lower()
    if name:find("monster") or name:find("entity") or name:find("rush") or name:find("ambush") or name:find("seeker") or name:find("killer") or name:find("beast") then
        return true
    end
    
    if model:FindFirstChildOfClass("Humanoid") then
        return true
    end
    
    return false
end

-- Manage Highlights
local function applyESP(model)
    if not MonsterESPEnabled then return end
    if HighlightsTable[model] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MonsterESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model
    
    HighlightsTable[model] = highlight
end

local function cleanESP()
    for model, highlight in pairs(HighlightsTable) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(HighlightsTable)
end

-- Watch workspace for spawning monsters
workspace.ChildAdded:Connect(function(child)
    task.wait(0.1)
    if isMonster(child) then
        applyESP(child)
    end
end)

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)


-- ==================== TAB 1: MAIN HACKS ====================
local MainTab = Window:CreateTab("Main Hacks", nil)

MainTab:CreateToggle({
   Name = "Fullbright (Anti-Darkness Override)",
   CurrentValue = false,
   Flag = "FullbrightToggle",
   Callback = function(Value)
      FullbrightEnabled = Value
      if not Value then
          Lighting.Ambient = origAmbient
          Lighting.OutdoorAmbient = origOutdoorAmbient
          Lighting.Brightness = origBrightness
          Lighting.ClockTime = origClockTime
          Lighting.FogEnd = origFogEnd
      end
   end,
})

MainTab:CreateToggle({
   Name = "Show Monsters (Wallhack/ESP)",
   CurrentValue = false,
   Flag = "MonsterESPToggle",
   Callback = function(Value)
      MonsterESPEnabled = Value
      if Value then
          for _, child in ipairs(workspace:GetChildren()) do
              if isMonster(child) then
                  applyESP(child)
              end
          end
      else
          cleanESP()
      end
   end,
})


-- ==================== TAB 2: PLAYER HACKS ====================
local PlayerTab = Window:CreateTab("Player", nil)

PlayerTab:CreateSlider({
   Name = "WalkSpeed (خێرایی)",
   Range = {1, 230},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
          LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump (بازدانی بێپایان)",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
      InfJumpEnabled = Value
   end,
})


Rayfield:Notify({
   Title = "Updated Successfully!",
   Content = "Tab 2 (Player) has been added to your script.",
   Duration = 5,
   Image = nil,
})
