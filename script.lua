local placeIds = { 10449761463, 118758941554698, 17698425045, 86098085533596 }

-- Check if the current place ID is NOT in the allowed list
if not table.find(placeIds, game.PlaceId) then
    local success, _ = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Access Denied",
            Text = "Unauthorized Place ID. Script execution halted.",
            Duration = 5
        })
    end)
    
    print("Unauthorized Place ID. Stopping script.")
    return -- This stops the rest of the script from running entirely
end

-- If the check passes, the script continues down here normally:
print("Player is in an authorized place! Loading UI...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Zolen",
   Icon = 0, 
   LoadingTitle = "Work in progress",
   LoadingSubtitle = "by Zoi Chain",
   ShowText = "Rayfield", 
   Theme = "Default", 

   ToggleUIKeybind = "M", 

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
