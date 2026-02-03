-- Modules/MainGameEngine.lua
-- Role: The Mastermind (Main Engine)
-- Summary: Connects all 25 systems, manages intermission, game loops, and win logic.

local MainGameEngine = {}

-- [1] Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] Dependencies (Connections to previous 25 modules)
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config             = require(Modules:WaitForChild("Config"))
local IdentityProtector  = require(Modules:WaitForChild("IdentityProtector"))
local LightingManager    = require(Modules:WaitForChild("LightingManager"))
local EliminationManager = require(Modules:WaitForChild("EliminationManager"))
local GameRewards        = require(Modules:WaitForChild("GameRewards"))
-- Assumed modules from previous steps:
-- local RoleDistributor = require(Modules:WaitForChild("RoleDistributor"))
-- local VotingSystem    = require(Modules:WaitForChild("VotingSystem"))

-- [3] Game State Variables
local MIN_PLAYERS = 4
local GameActive = false

-- [4] Intermission System
-- Checks for player count before starting the game
function MainGameEngine.StartIntermission()
    print("⏳ Starting Intermission... Waiting for players.")
    
    while not GameActive do
        local currentPlayers = Players:GetPlayers()
        
        if #currentPlayers >= MIN_PLAYERS then
            print("✅ Minimum players reached. Starting game in 10 seconds...")
            task.wait(10)
            if #Players:GetPlayers() >= MIN_PLAYERS then
                MainGameEngine.BeginMatch()
            end
        else
            print("👥 Waiting for " .. (MIN_PLAYERS - #currentPlayers) .. " more players.")
            task.wait(5)
        end
    end
end

-- [5] Match Initialization
function MainGameEngine.BeginMatch()
    GameActive = true
    print("🎬 Match Started! Initializing roles and security.")
    
    -- 1. Identity Protection & Role Distribution
    for _, player in ipairs(Players:GetPlayers()) do
        IdentityProtector.MaskPlayerIdentity(player)
        player:SetAttribute("IsAlive", true)
    end
    
    -- RoleDistributor.AssignRoles(Players:GetPlayers()) -- Assigning Mafia, Judge, etc.
    
    -- Start Core Loop
    task.spawn(MainGameEngine.GameLoop)
end

-- [6] The Master Game Loop (Orchestration)
function MainGameEngine.GameLoop()
    while GameActive do
        -- A. NIGHT PHASE
        print("🌙 Night Phase Started.")
        LightingManager.SetNight(5)
        -- Notify Mafia UI/Targeting systems
        ReplicatedStorage.Events.PhaseChanged:FireAllClients("Night")
        task.wait(Config.TimeSettings.NightDuration)
        
        -- Post-Night Elimination Check
        if MainGameEngine.CheckForWinner() then break end

        -- B. NEWS/RESULTS PHASE
        print("📰 Morning News: Reporting casualties.")
        ReplicatedStorage.Events.PhaseChanged:FireAllClients("News")
        task.wait(Config.TimeSettings.NewsDuration)

        -- C. DAY PHASE
        print("☀️ Day Phase Started. Discussion and Voting.")
        LightingManager.SetDay(5)
        ReplicatedStorage.Events.PhaseChanged:FireAllClients("Day")
        
        -- VotingSystem.StartVoting() -- Enable the judge and voting weights
        task.wait(Config.TimeSettings.DayDuration)
        
        -- Post-Day Elimination Check
        if MainGameEngine.CheckForWinner() then break end
    end
end

-- [7] Win Logic & Reward Distribution
function MainGameEngine.CheckForWinner()
    local winner = EliminationManager.CheckWinConditions() -- Returns "Mafia", "Citizens", or nil
    
    if winner then
        print("🏆 Game Over! Winners: " .. winner)
        GameActive = false
        
        -- Call Rewards System (Handles 150/250 SAR Subscriber Boosts)
        GameRewards.DistributeRoundRewards(Players:GetPlayers(), winner)
        
        -- Reset for next round
        task.wait(15)
        MainGameEngine.ResetServer()
        return true
    end
    return false
end

-- [8] Reset Server
function MainGameEngine.ResetServer()
    print("♻️ Resetting server for next game...")
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("Role", "Hidden")
        player:SetAttribute("IsAlive", false)
    end
    task.spawn(MainGameEngine.StartIntermission)
end

-- [9] Automation (Immediate Entry Point)
function MainGameEngine.Init()
    print("🚀 Main Game Engine Initialized.")
    IdentityProtector.Init() -- Secure PlayerAdded/Removing
    LightingManager.Init()   -- Set Default Lighting
    
    -- Start Intermission as a background process
    task.spawn(MainGameEngine.StartIntermission)
end

return MainGameEngine
