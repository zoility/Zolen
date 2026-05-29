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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tabs & Sections
local MainTab = Window:CreateTab("Main", nil) 
local TradeTab = Window:CreateTab("Trade", nil) -- New Trade Tab
local MiscTab = Window:CreateTab("Misc", nil) 
local MiscSection = MiscTab:CreateSection("Misc")

-- Variables
local weavetrue = false
local weaveint = 0.3336
local AutoWeaveConnection = nil
local weaveElapsed = 0

local currentWalkSpeed = 20
local WalkSpeedConnection = nil

local hitboxtrue = false
local hitboxsize = 2
local HitboxConnection = nil

-- Fling Tracking Variables
local selectedPlayerName = ""
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- ==========================================
-- TRADE TAB ELEMENTS (Fling Mechanics)
-- ==========================================

TradeTab:CreateSection("Target Settings")

-- Dynamic Player Dropdown
local PlayerDropdown = TradeTab:CreateDropdown({
   Name = "Select Target",
   Options = {},
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "FlingTargetDropdown",
   Callback = function(Options)
      selectedPlayerName = Options[1]
   end,
})

-- Helper function to refresh the player dropdown list
local function RefreshDropdown()
   local playerList = {}
   for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer then
         table.insert(playerList, p.Name)
      end
   end
   PlayerDropdown:Refresh(playerList)
end

-- Hook up dropdown updates to player events
Players.PlayerAdded:Connect(RefreshDropdown)
Players.PlayerRemoving:Connect(RefreshDropdown)
task.spawn(RefreshDropdown) -- Initial layout load

-- 4-Second Target Fling Button
local FlingButton = TradeTab:CreateButton({
   Name = "Fling Target (4s)",
   Callback = function()
      local targetPlayer = Players:FindFirstChild(selectedPlayerName)
      if not targetPlayer or not targetPlayer.Character then 
         return Rayfield:Notify({Title = "Error", Content = "No valid target selected or player left!", Duration = 3}) 
      end

      local myChar = LocalPlayer.Character
      local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
      local myRoot = myHum and myHum.RootPart
      local tChar = targetPlayer.Character
      local tHum = tChar:FindFirstChildOfClass("Humanoid")
      local tRoot = tHum and tHum.RootPart

      if myChar and myHum and myRoot then
         if tHum and tHum.Sit then
            return Rayfield:Notify({Title = "Error", Content = targetPlayer.Name .. " is sitting!", Duration = 3})
         end

         -- Save original position before teleporting away
         if myRoot.Velocity.Magnitude < 50 then
            getgenv().OldPos = myRoot.CFrame
         end

         -- Bypass the boundary line crash check
         workspace.FallenPartsDestroyHeight = 0/0

         -- Anchor vector stability forcing
         local BV = Instance.new("BodyVelocity")
         BV.Parent = myRoot
         BV.Velocity = Vector3.new(0, 0, 0)
         BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

         myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

         -- Fling Positioning Calculations
         local FPos = function(BasePart, Pos, Ang)
            myRoot.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            myChar:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            myRoot.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            myRoot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
         end

         -- Execution Loop Tracking variables
         local basePartToTarget = tRoot or tChar:FindFirstChild("Head") or tChar:FindFirstChildWhichIsA("BasePart")
         if not basePartToTarget then return end

         local startTime = tick()
         local maxTimeLimit = 4 -- Hard capped at exactly 4 seconds
         local angleDeg = 0

         -- Notification Alert
         Rayfield:Notify({Title = "Flinging", Content = "Attacking " .. targetPlayer.Name .. " for 4 seconds...", Duration = 4})

         -- Processing loop runs up to 4 seconds maximum
         repeat
            if myRoot and tHum and basePartToTarget and basePartToTarget.Parent then
               if basePartToTarget.Velocity.Magnitude < 50 then
                  angleDeg = angleDeg + 100
                  FPos(basePartToTarget, CFrame.new(0, 1.5, 0) + tHum.MoveDirection * basePartToTarget.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angleDeg), 0, 0))
                  task.wait()
                  FPos(basePartToTarget, CFrame.new(0, -1.5, 0) + tHum.MoveDirection * basePartToTarget.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angleDeg), 0, 0))
                  task.wait()
               else
                  FPos(basePartToTarget, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                  task.wait()
                  FPos(basePartToTarget, CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                  task.wait()
               end
            else
               break
            end
         until tick() - startTime >= maxTimeLimit

         -- Clean up physical constraints immediately
         BV:Destroy()
         myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

         -- Safe snap back return to starting coordinates
         if getgenv().OldPos then
            repeat
               myRoot.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
               myChar:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
               myHum:ChangeState("GettingUp")
               for _, part in pairs(myChar:GetChildren()) do
                  if part:IsA("BasePart") then
                     part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                  end
               end
               task.wait()
            until (myRoot.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
         end
         
         Rayfield:Notify({Title = "Finished", Content = "Returned safely to original spot.", Duration = 2})
      end
   end,
})

-- ==========================================
-- MAIN TAB ELEMENTS
-- ==========================================

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
