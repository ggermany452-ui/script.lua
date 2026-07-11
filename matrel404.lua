local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Roblox Utility Menu",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by Peer Developer",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RayfieldSpecs",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "", -- Using custom copy button instead
      RememberJoins = true
   },
   KeySystem = false
})

-- ==========================================
-- TAB 1: PLAYER ESP & DISTANCE
-- ==========================================
local Tab1 = Window:CreateTab("Visuals", 4483362458) -- Eye icon ID

local Section1 = Tab1:CreateSection("Player Tracking")

local ESPEnabled = false
local DistanceEnabled = false

Tab1:CreateToggle({
   Name = "Show Player (ESP)",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
      ESPEnabled = Value
      -- Add your ESP logic here using the ESPEnabled variable
      if ESPEnabled then
          print("ESP Activated")
      else
          print("ESP Deactivated")
      end
   end,
})

Tab1:CreateToggle({
   Name = "Show Distance",
   CurrentValue = false,
   Flag = "Distance_Toggle",
   Callback = function(Value)
      DistanceEnabled = Value
      -- Add your distance tracking logic here using the DistanceEnabled variable
      if DistanceEnabled then
          print("Distance Tracker Activated")
      else
          print("Distance Tracker Deactivated")
      end
   end,
})

-- ==========================================
-- TAB 2: MOVEMENT SPEED
-- ==========================================
local Tab2 = Window:CreateTab("Movement", 4483362748) -- Running icon ID

local Section2 = Tab2:CreateSection("Speed Modification")

Tab2:CreateSlider({
   Name = "WalkSpeed Multiplier",
   Min = 1,
   Max = 230,
   CurrentValue = 16,
   Flag = "Speed_Slider",
   Callback = function(Value)
      local LocalPlayer = game:GetService("Players").LocalPlayer
      if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
          LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
      end
   end,
})

-- ==========================================
-- TAB 3: INFO & DISCORD CORNER
-- ==========================================
local Tab3 = Window:CreateTab("Info", 4483362534) -- Info icon ID

local Section3 = Tab3:CreateSection("About Script")

Tab3:CreateLabel("Script Version: 1.0.0")
Tab3:CreateLabel("Status: Operational")

local SectionDiscord = Tab3:CreateSection("Community")

Tab3:CreateButton({
   Name = "Copy Discord Link",
   Callback = function()
      local discordLink = "https://discord.gg/8P8ZuuYcu"
      
      -- Handles clipboard copying across various executors (Synapse, Krnl, ScriptWare, etc.)
      if setclipboard then
          setclipboard(discordLink)
          Rayfield:Notify({
             Name = "Success!",
             Content = "Discord link copied to clipboard.",
             Duration = 3,
             Image = 4483362458,
          })
      elseif toclipboard then
          toclipboard(discordLink)
          Rayfield:Notify({
             Name = "Success!",
             Content = "Discord link copied to clipboard.",
             Duration = 3,
             Image = 4483362458,
          })
      else
          Rayfield:Notify({
             Name = "Error",
             Content = "Your executor doesn't support clipboard copying.",
             Duration = 4,
             Image = 4483362458,
          })
      end
   end,
})
