local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Zolen",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "ZOLEN ON TOP",
   LoadingSubtitle = "by zoility",
   ShowText = "Zolen", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "AmberGlow", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})
-- Services & Players Setup
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tabs & Sections
local MainTab = Window:CreateTab("Main", nil) 
local MainSection = MainTab:CreateSection("Main")

local MiscTab = Window:CreateTab("Misc", nil) 
local MiscSection = MiscTab:CreateSection("Misc")

-- Auto Weave Configuration Variables
local weavetrue = false
local weaveint = 0.3336
local AutoWeaveConnection = nil
local weaveElapsed = 0

-- Punch Speed Configuration Variables
local punchSpeedTrue = false
local punchSpeedInt = 0.3336
local PunchSpeedConnection = nil
local punchElapsed = 0

-- WalkSpeed Configuration Variables
local currentWalkSpeed = 20
local WalkSpeedConnection = nil

-- Hitbox Configuration Variables
local hitboxtrue = false
local hitboxsize = 2
local HitboxConnection = nil

-- ==========================================
-- MAIN TAB ELEMENTS
-- ==========================================

MainTab:CreateSection("Combat")

-- Auto Weave Slider
local WeaveSlider = MainTab:CreateSlider({
   Name = "Auto Weave Interval",
   Range = {0, 1},
   Increment = 0.01,
   Suffix = "s",
   CurrentValue = 0.33,
   Flag = "WeaveSlider", 
   Callback = function(Value)
      weaveint = Value
   end,
})

-- Auto Weave Toggle
local WeaveToggle = MainTab:CreateToggle({
   Name = "Auto Weave",
   CurrentValue = false,
   Flag = "WeaveToggle", 
   Callback = function(Value)
      weavetrue = Value
      
      if weavetrue then
         if AutoWeaveConnection then 
            AutoWeaveConnection:Disconnect() 
            AutoWeaveConnection = nil 
         end
         
         weaveElapsed = 0
         local MICRO_VARIATION = 0.00005

         AutoWeaveConnection = RunService.Heartbeat:Connect(function(dt)
            if not weavetrue then return end
            weaveElapsed = weaveElapsed + dt
            
            local char = LocalPlayer.Character if not char then return end
            local core = char:FindFirstChild('Core') if not core then return end
            local comm = core:FindFirstChild('Communicate') if not comm then return end
            local phonk = comm:FindFirstChild('RemoteEvent') or comm:FindFirstChildOfClass('RemoteEvent')
            if not phonk then return end

            local interval = weaveint + (math.random() - 0.5) * MICRO_VARIATION
            while weaveElapsed >= interval do
               weaveElapsed = weaveElapsed - interval
               pcall(function() 
                  phonk:FireServer("Weave", nil, true) 
               end)
            end
         end)
      else
         if AutoWeaveConnection then 
            AutoWeaveConnection:Disconnect() 
            AutoWeaveConnection = nil 
         end
      end
   end,
})

-- Punch Speed Interval Slider
local PunchSpeedSlider = MainTab:CreateSlider({
   Name = "Punch Cooldown Interval",
   Range = {0, 1},
   Increment = 0.01,
   Suffix = "s delay",
   CurrentValue = 0.33,
   Flag = "PunchSpeedSlider", 
   Callback = function(Value)
      punchSpeedInt = Value
   end,
})

-- Punch Speed Toggle
local PunchSpeedToggle = MainTab:CreateToggle({
   Name = "Punch Speed Modifier",
   CurrentValue = false,
   Flag = "PunchSpeedToggle", 
   Callback = function(Value)
      punchSpeedTrue = Value
      
      if punchSpeedTrue then
         if PunchSpeedConnection then 
            PunchSpeedConnection:Disconnect() 
            PunchSpeedConnection = nil 
         end
         
         punchElapsed = 0
         local MICRO_VARIATION = 0.00005

         PunchSpeedConnection = RunService.Heartbeat:Connect(function(dt)
            if not punchSpeedTrue then return end
            punchElapsed = punchElapsed + dt
            
            local char = LocalPlayer.Character if not char then return end
            local core = char:FindFirstChild('Core') if not core then return end
            local comm = core:FindFirstChild('Communicate') if not comm then return end
            local phonk = comm:FindFirstChild('RemoteEvent') or comm:FindFirstChildOfClass('RemoteEvent')
            if not phonk then return end

            -- Uses your friend's logic to fire the remote event at the specified speed interval
            local interval = punchSpeedInt + (math.random() - 0.5) * MICRO_VARIATION
            while punchElapsed >= interval do
               punchElapsed = punchElapsed - interval
               pcall(function() 
                  phonk:FireServer("Punch", nil, true) 
               end)
            end
         end)
      else
         if PunchSpeedConnection then 
            PunchSpeedConnection:Disconnect() 
            PunchSpeedConnection = nil 
         end
      end
   end,
})

MainTab:CreateSection("Hitboxes")

-- Hitbox Expander Slider
local HitboxSlider = MainTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {2, 10},
   Increment = 0.5,
   Suffix = " Studs",
   CurrentValue = 2,
   Flag = "HitboxSlider",
   Callback = function(Value)
      hitboxsize = Value
   end,
})

-- Hitbox Expander Toggle
local HitboxToggle = MainTab:CreateToggle({
   Name = "Hitbox Expander",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
      hitboxtrue = Value
      
      if hitboxtrue then
         if HitboxConnection then 
            HitboxConnection:Disconnect() 
            HitboxConnection = nil 
         end
         
         HitboxConnection = RunService.Heartbeat:Connect(function()
            if not hitboxtrue then return end
            
            for _, player in ipairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character then
                  local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                  if hrp then
                     hrp.Size = Vector3.new(hitboxsize, hitboxsize, hitboxsize)
                     hrp.Transparency = 0.7 
                     hrp.CanCollide = false 
                  end
               end
            end
         end)
      else
         if HitboxConnection then 
            HitboxConnection:Disconnect() 
            HitboxConnection = nil 
         end
         
         for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
               local hrp = player.Character:FindFirstChild("HumanoidRootPart")
               if hrp then
                  hrp.Size = Vector3.new(2, 2, 1) 
                  hrp.Transparency = 1          
                  hrp.CanCollide = true
               end
            end
         end
      end
   end,
})

-- ==========================================
-- MISC TAB ELEMENTS
-- ==========================================

-- Permanent Loop for WalkSpeed
WalkSpeedConnection = RunService.Heartbeat:Connect(function()
   local char = LocalPlayer.Character
   if char then
      local humanoid = char:FindFirstChildOfClass("Humanoid")
      if humanoid and humanoid.WalkSpeed ~= currentWalkSpeed then
         humanoid.WalkSpeed = currentWalkSpeed
      end
   end
end)

local WalkSpeedSlider = MiscTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 300},
   Increment = 2,
   Suffix = "WalkSpeed",
   CurrentValue = 20,
   Flag = "Slider1", 
   Callback = function(Value)
      currentWalkSpeed = Value
   end,
})
