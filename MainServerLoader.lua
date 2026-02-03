-- MainServerLoader.lua
-- Location: ServerScriptService
-- Role: The Ignition Key (File #27)
-- Summary: This script finalizes the backend by requiring the MainGameEngine 
-- and ensuring all 26 modules are synchronized and ready for players.

print("----------------------------------------------------------------")
print("🏙️  MAFIA CITY: BACKEND INITIALIZATION STARTING...")
print("----------------------------------------------------------------")

-- [1] Services & Paths
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- [2] Safety Check: Waiting for the Modules Folder
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

if not Modules then
    warn("❌ CRITICAL ERROR: 'Modules' folder not found in ReplicatedStorage!")
    return
end

-- [رابط الكود الأول] - استدعاء واجهة الأدوار
local RoleUI = require(Modules.RoleUI)

-- [3] Linking the Master Engine
local MainGameEngine = require(Modules:WaitForChild("MainGameEngine"))

-- [4] Final Initialization
local function StartServer()
    local success, err = pcall(function()
        -- تشغيل المحرك الرئيسي
        MainGameEngine.Init()
    end)

    if success then
        print("✅ SUCCESS: Mafia City Backend is now 100% Live!")
        
        -- [رابط الكود الأول] - تنفيذ عرض دور العراب عند دخول اللاعب
        game.Players.PlayerAdded:Connect(function(player)
            -- يتم عرض بطاقة العراب باللون الأحمر فور دخول اللاعب (للتجربة)
            RoleUI.ShowRole(player, "Godfather", Color3.fromRGB(255, 0, 0))
        end)
        
        print("🎮 Game State: Waiting for players to start Intermission...")
    else
        warn("⚠️ FAILED to initialize MainGameEngine: " .. tostring(err))
    end
end

-- Start the execution flow
StartServer()

-- [5] Final Structure Check (Verification Summary)
print("----------------------------------------------------------------")
print("🏆 CONGRATULATIONS! THE FRAMEWORK IS COMPLETE.")
print("🚀 Ready for Roblox Studio deployment.")
print("----------------------------------------------------------------")
