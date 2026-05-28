local placeIds = { 10449761463, 118758941554698, 17698425045, 86098085533596 }

-- 1. Check the ID first
if table.find(placeIds, game.PlaceId) then
    
    -- 2. If it matches, NOW download and load Rayfield
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
       Name = "Zolen",
       Icon = 0, 
       LoadingTitle = "Work in progress",
       LoadingSubtitle = "by Zoi Chain",
       ShowText = "Rayfield", 
       Theme = "Default", 
       ToggleUIKeybind = "RightShift", 
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

    -- 3. Now that Rayfield exists, you can safely send the notification
    Rayfield:Notify({
       Title = "Game Supported",
       Content = "The script supports this game",
       Duration = 6.5,
       Image = 4483362458,
    })

    -- 4. Create your tabs and sections inside the Window
    local Tab1 = Window:CreateTab("Main", nil)
    local Section = Tab1:CreateSection("MainSection")

end -- 5. Close the if statement at the very end
