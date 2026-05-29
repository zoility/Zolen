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

-- Configuration Variables
local weavetrue = false
local weaveint = 0.3336
local AutoWeaveConnection = nil
local elapsed = 0

local currentWalkSpeed = 20
local WalkSpeedConnection = nil

local hitboxtrue = false
local hitboxsize = 2
local HitboxConnection = nil

-- New Animation Speed Configuration
local currentPunchSpeed = 1.0
local AnimationConnection = nil

-- ==========================================
-- MAIN TAB ELEMENTS
-- ==========================================

-- Auto Weave
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
         
         elapsed = 0
         local MICRO_VARIATION = 0.00005

         AutoWeaveConnection = RunService.Heartbeat:Connect(function(dt)
            if not weavetrue then return end
            elapsed = elapsed + dt
            
            local char = LocalPlayer.Character if not char then return end
            local core = char:FindFirstChild('Core') if not core then return end
            local comm = core:FindFirstChild('Communicate') if not comm then return end
            local phonk = comm:FindFirstChild('RemoteEvent') or comm:FindFirstChildOfClass('RemoteEvent')
            if not phonk then return end

            local interval = weaveint + (math.random() - 0.5) * MICRO_VARIATION
            while elapsed >= interval do
               elapsed = elapsed - interval
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

MainTab:CreateSection("Combat")

-- Punch Speed Slider (1 is normal speed, 5 is 5x faster)
local PunchSlider = MainTab:CreateSlider({
   Name = "Punch Speed Multiplier",
   Range = {1, 10},
   Increment = 0.1,
   Suffix = "x Speed",
   CurrentValue = 1,
   Flag = "PunchSpeedSlider",
   Callback = function(Value)
      currentPunchSpeed = Value
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
-- BACKGROUND TRACKING LOOPS
-- ==========================================

-- Continuous Animation Interceptor Loop
AnimationConnection = RunService.Heartbeat:Connect(function()
   pcall(function()
      local char = LocalPlayer.Character
      if char then
         local humanoid = char:FindFirstChildOfClass("Humanoid")
         if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            local target = animator or humanoid -- Falls back to Humanoid if Animator isn't explicit
            
            if target then
               -- Scans all tracks currently playing on your character every frame
               for _, track in ipairs(target:GetPlayingAnimationTracks()) do
                  local animId = tostring(track.Animation.AnimationId):lower()
                  
                  -- Filters out movement animations so you don't ruin your walk cycles
                  if not animId:find("run") and not animId:find("walk") and not animId:find("idle") and not animId:find("fall") and not animId:find("jump") then
                     track:AdjustSpeed(currentPunchSpeed)
                  end
               end
            end
         end
      end
   end)
end)

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
