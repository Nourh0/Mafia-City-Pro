-- Location: ServerScriptService/MainServerLoader.lua
-- Role: The Master Maestro - Key to activating Mafia City
-- Summary: Coordinates the operation of all engines (27 files) and ensures data synchronization and security.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- [1] Security Check: Ensure the Modules folder exists before starting
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

if not Modules then
    warn("❌ Critical error: Modules folder not found in ReplicatedStorage!")
    return
end

-- [2] Invoking the Requirements
-- Note: The requirements are loaded here to ensure they are ready before execution
local MainGameEngine = require(Modules:WaitForChild("MainGameEngine"))
local RoundCycleManager = require(Modules:WaitForChild("RoundCycleManager"))
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local IdentityProtector = require(Modules:WaitForChild("IdentityProtector"))
local RoleUI = require(Modules:WaitForChild("RoleUI"))
local MafiaChat = require(Modules:WaitForChild("MafiaChat")) -- تم الربط هنا

print("----------------------------------------------------------------")
print("🏙️ MAFIA CITY: STARTING CENTRAL CORE & INITIALIZING...")
print("----------------------------------------------------------------")

-- [3] Initialization
-- Lighting and data protection systems are activated immediately to ensure privacy and a secure environment.
LightingManager.Init()
IdentityProtector.Init()
MafiaChat.Init() -- Launching the chat system (تم الربط هنا)
print("⚙️ Initial Systems (Lighting & Security) are prepared.")

-- [4] Core Execution
-- We use task.spawn and pcall to ensure server stability and prevent crashes.
task.spawn(function()
    local success, err = pcall(function()
        -- Launching the main game engine
        MainGameEngine.Init() 

        -- Launching the Round Cycle Engine in a separate thread
        task.spawn(function()
            print("🎮 Round Cycle Engine is launching...")
            RoundCycleManager.RunGameLoop()
        end)
    end)

    if success then
        print("✅ SUCCESS: Mafia City Backend is Live and Synced!")
    else
        warn("⚠️ CRITICAL ERROR: FAILED to start Core Engine: " .. tostring(err))
    end
end)

-- [5] Testing Integration System
-- The "Godfather" card is displayed immediately upon a player joining to verify the RoleUI system is working
game.Players.PlayerAdded:Connect(function(player)
    print("👋 Player Joined: " .. player.Name .. " | Applying initial test data.")
    
    -- انتظار بسيط لضمان تحميل واجهة اللاعب (GUI)
    task.wait(2)
    
    -- اختبار نظام عرض الأدوار (Godfather باللون الأحمر)
    RoleUI.ShowRole(player, "Godfather", Color3.fromRGB(255, 0, 0))
end)

-- [6] ملخص التحقق النهائي
print("----------------------------------------------------------------")
print("🏆 CONGRATULATIONS! THE CENTRAL MAESTRO IS READY.")
print("🚀 Backend is 100% active. Waiting for players to start match.")
print("----------------------------------------------------------------")
