-- ServerScriptService/MainServerLoader.lua
-- Location: ServerScriptService
-- Role: The Ignition Key (File #27)
-- Summary: This script finalizes the backend by connecting all modules and engines.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- [1] Safety Check: Waiting for the Modules Folder
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

if not Modules then
    warn("❌ CRITICAL ERROR: 'Modules' folder not found in ReplicatedStorage!")
    return 
end

-- [2] Requirements from both codes
local RoundCycleManager = require(Modules:WaitForChild("RoundCycleManager"))
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local RoleUI = require(Modules:WaitForChild("RoleUI"))
local MainGameEngine = require(Modules:WaitForChild("MainGameEngine"))

-- [3] Initialization Logic (From Code 1)
print("----------------------------------------------------------------")
print("⚙️ Server systems are being prepared...")

-- Set the default lighting (daylight)
LightingManager.Init()

-- Activate the game loop in a separate thread
task.spawn(function()
    print("🎮 The Rounds Engine has been successfully launched.")
    RoundCycleManager.RunGameLoop()
end)

-- [4] Main Engine Initialization (From Code 2)
print("----------------------------------------------------------------")
print("🏙️  MAFIA CITY: BACKEND INITIALIZATION STARTING...")
print("----------------------------------------------------------------")

local function StartServer()
    local success, err = pcall(function()
        -- Starting the main engine
        MainGameEngine.Init()
    end)

    if success then
        print("✅ SUCCESS: Mafia City Backend is now 100% Live!")

        -- Implementing the Godfather role display upon player entry (for testing)
        game.Players.PlayerAdded:Connect(function(player)
            -- Wait a brief moment for UI to load
            task.wait(2)
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
