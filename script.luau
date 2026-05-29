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
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Tabs & Sections
local MainTab = Window:CreateTab("Main", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

local MiscTab = Window:CreateTab("Misc", nil) -- Title, Image
local MiscSection = MiscTab:CreateSection("Misc")

-- Auto Weave Configuration Variables
local weavetrue = false
local weaveint = 0.3336
local AutoWeaveConnection = nil
local elapsed = 0

-- Main Tab Elements
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
         -- Safety check to ensure we don't stack multiple connections
         if AutoWeaveConnection then 
            AutoWeaveConnection:Disconnect() 
            AutoWeaveConnection = nil 
         end
         
         elapsed = 0
         local MICRO_VARIATION = 0.00005

         AutoWeaveConnection = RunService.Heartbeat:Connect(function(dt)
            if not weavetrue then return end
            elapsed = elapsed + dt
            
            -- Character & Core Validation
            local char = LocalPlayer.Character if not char then return end
            local core = char:FindFirstChild('Core') if not core then return end
            local comm = core:FindFirstChild('Communicate') if not comm then return end
            local phonk = comm:FindFirstChild('RemoteEvent') or comm:FindFirstChildOfClass('RemoteEvent')
            if not phonk then return end

            -- Micro-optimized timing math from your friend's script
            local interval = weaveint + (math.random() - 0.5) * MICRO_VARIATION
            while elapsed >= interval do
               elapsed = elapsed - interval
               pcall(function() 
                  -- Directly fires the remote with your arguments ("Weave", nil, true)
                  -- This removes the deprecated 'table.maxn' which breaks on modern executors
                  phonk:FireServer("Weave", nil, true) 
               end)
            end
         end)
      else
         -- Kill the heartbeat loop instantly when toggled off
         if AutoWeaveConnection then 
            AutoWeaveConnection:Disconnect() 
            AutoWeaveConnection = nil 
         end
      end
   end,
})

local Slider = MiscTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 300},
   Increment = 2,
   Suffix = "WalkSpeed",
   CurrentValue = 20,
   Flag = "Slider1", 
   Callback = function(Value)
      -- Safely updates WalkSpeed instantly without using any RenderStepped/Heartbeat connections
      local player = game.Players.LocalPlayer
      if player and player.Character then
         local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.WalkSpeed = Value
         end
      end
   end,
})
