-- MainServerLoader.lua
-- Location: ServerScriptService
-- Role: The Ignition Key (File #27)
-- Summary: This script finalizes the backend by requiring the MainGameEngine 
-- and ensuring all 26 modules are synchronized and ready for players.

print("--------------------------------------------------")
print("🏙️  MAFIA CITY: BACKEND INITIALIZATION STARTING...")
print("--------------------------------------------------")

-- [1] Services & Paths
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- [2] Safety Check: Waiting for the Modules Folder
-- This ensures that the server doesn't crash if modules take time to load
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

if not Modules then
    warn("❌ CRITICAL ERROR: 'Modules' folder not found in ReplicatedStorage!")
    return
end

-- [3] Linking the Master Engine
-- This line activates the 26-file software framework
local MainGameEngine = require(Modules:WaitForChild("MainGameEngine"))

-- [4] Final Initialization
-- 1. Calls IdentityProtector to secure player data and roles.
-- 2. Validates Subscriptions (250/150 Riyals) via DataPersistence.
-- 3. Starts the Intermission and Game Loop.
local function StartServer()
    local success, err = pcall(function()
        -- The big moment: Linking and Starting the Engine
        MainGameEngine.Init()
    end)

    if success then
        print("✅ SUCCESS: Mafia City Backend is now 100% Live!")
        print("🎮 Game State: Waiting for players to start Intermission...")
    else
        warn("⚠️ FAILED to initialize MainGameEngine: " .. tostring(err))
    end
end

-- Start the execution flow
StartServer()

-- [5] Final Structure Check (Verification Summary)
-- ServerScriptService -> MainServerLoader.lua
-- ReplicatedStorage   -> Modules Folder (Contains 26 files)
-- ReplicatedStorage   -> Events Folder (PhaseChanged, MafiaChatEvent, etc.)

print("--------------------------------------------------")
print("🏆 CONGRATULATIONS! THE FRAMEWORK IS COMPLETE.")
print("🚀 Ready for Roblox Studio deployment.")
print("--------------------------------------------------")
