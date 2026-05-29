local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Zolen",
   Icon = 0, 
   LoadingTitle = "ZOLEN ON TOP",
   LoadingSubtitle = "by zoility",
   ShowText = "Zolen", 
   Theme = "AmberGlow", 

   ToggleUIKeybind = "K", 

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   },

   KeySystem = false, 
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", 
      FileName = "Key", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Hello"} 
   }
})

-- Services & Players Setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Tabs organized in ALPHABETICAL ORDER
local MainTab = Window:CreateTab("Main", nil) 
local MiscTab = Window:CreateTab("Misc", nil) 
local TradeTab = Window:CreateTab("Trade", nil) 

local MiscSection = MiscTab:CreateSection("Misc")

-- Configuration States
local weavetrue = false
local weaveint = 0.3336
local AutoWeaveConnection = nil
local weaveElapsed = 0

local currentWalkSpeed = 12 
local WalkSpeedConnection = nil

local hitboxtrue = false
local hitboxsize = 2
local HitboxConnection = nil

-- Fling Tracking Variables
local selectedPlayerName = ""
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Helper functions for Character Collisions (From your found logic)
local function EnableCollisions(character)
   if not character then return end 
   for _, part in pairs(character:GetDescendants()) do
      if part:IsA("BasePart") then
         part.CanCollide = true
      end
   end
end

local function DisableCollisions(character)
   if not character then return end
   for _, part in pairs(character:GetDescendants()) do
      if part:IsA("BasePart") then
         part.CanCollide = false
      end
   end
end

-- ==========================================
-- MAIN TAB ELEMENTS
-- ==========================================

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

local MainHitboxSlider = MainTab:CreateSlider({
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

local MainHitboxToggle = MainTab:CreateToggle({
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

if WalkSpeedConnection then
   WalkSpeedConnection:Disconnect()
end

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
   CurrentValue = 12, 
   Flag = "Slider1", 
   Callback = function(Value)
      currentWalkSpeed = Value
   end,
})

-- ==========================================
-- TRADE TAB ELEMENTS (Enhanced Fling Mechanics)
-- ==========================================

TradeTab:CreateSection("Target Settings")

local PlayerDropdown = TradeTab:CreateDropdown({
   Name = "Select Target",
   Options = {},
   CurrentOption = "", 
   MultipleOptions = false,
   Flag = "FlingTargetDropdown",
   Callback = function(Options)
      selectedPlayerName = Options[1]
   end,
})

local function RefreshDropdown()
   local playerList = {}
   for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer then
         table.insert(playerList, p.Name)
      end
   end
   PlayerDropdown:Refresh(playerList)
end

Players.PlayerAdded:Connect(RefreshDropdown)
Players.PlayerRemoving:Connect(RefreshDropdown)
task.spawn(RefreshDropdown)

-- Advanced 4-Second Target Fling Button
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

         if myRoot.Velocity.Magnitude < 50 then
            getgenv().OldPos = myRoot.CFrame
         end

         -- STRICTLY LOCK CAMERA IN PLACE
         local originalCameraCFrame = Camera.CFrame
         Camera.CameraType = Enum.CameraType.Scriptable

         workspace.FallenPartsDestroyHeight = 0/0

         -- Create physical push force stability 
         local BV = Instance.new("BodyVelocity")
         BV.Parent = myRoot
         BV.Velocity = Vector3.new(0, 0, 0)
         BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

         myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

         -- NEW ENHANCED VELOCITY LOGIC (High Power De-obfuscated Matrix)
         local FPos = function(BasePart, Pos, Ang)
            myRoot.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            myChar:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            
            -- Multiplied stability forces from the new algorithm logic
            myRoot.Velocity = Vector3.new(9e8, 9e8 * 10, 9e8)
            myRoot.RotVelocity = Vector3.new(9e9, 9e9, 9e9) 
         end

         local basePartToTarget = tRoot or tChar:FindFirstChild("Head") or tChar:FindFirstChildWhichIsA("BasePart")
         if not basePartToTarget then return end

         local startTime = tick()
         local maxTimeLimit = 4 
         local angleDeg = 0

         Rayfield:Notify({Title = "Flinging", Content = "Launching " .. targetPlayer.Name .. "...", Duration = 4})

         repeat
            if myRoot and tHum and basePartToTarget and basePartToTarget.Parent then
               angleDeg = angleDeg + 100 -- Faster rotation increment from your logic
               Camera.CFrame = originalCameraCFrame
               
               -- Temporarily open player physics collisions to maximize impact energy transferring
               EnableCollisions(myChar)
               
               -- Alternating High/Low Cross-Vector Shifts
               if basePartToTarget.Velocity.Magnitude < 50 then
                  FPos(basePartToTarget, CFrame.new(0, 1.5, 0) + tHum.MoveDirection * basePartToTarget.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angleDeg), 0, 0))
                  task.wait()
                  FPos(basePartToTarget, CFrame.new(0, -1.5, 0) + tHum.MoveDirection * basePartToTarget.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angleDeg), 0, 0))
                  task.wait()
               else
                  FPos(basePartToTarget, CFrame.new(0, 1.5, tHum.MoveDirection), CFrame.Angles(math.rad(90), 0, 0))
                  task.wait()
                  FPos(basePartToTarget, CFrame.new(0, -1.5, -tHum.MoveDirection), CFrame.Angles(0, 0, 0))
                  task.wait()
               end
            else
               break
            end
         until tick() - startTime >= maxTimeLimit

         -- Clean up physics forces immediately
         BV:Destroy()
         myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
         DisableCollisions(myChar)

         -- Teleport back to original placement location safely
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
         
         -- RE-ATTACH CAMERA SAFELY TO CHARACTER
         Camera.CameraType = Enum.CameraType.Custom
         Camera.CameraSubject = myHum
         
         Rayfield:Notify({Title = "Finished", Content = "Returned safely.", Duration = 2})
      end
   end,
})
