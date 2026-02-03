-- Modules/RoundCycleManager.lua
-- RoundCycleManager - النسخة النهائية المحدثة والمربوطة بنظام التصويت والإقصاء

local RoundCycleManager = {}

-- [1] Services and Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
local RoleManager = require(Modules:WaitForChild("RoleManager"))

-- Time Settings
local NIGHT_DURATION = 30
local DAY_DURATION = 60

-- [2] Night Phase Function
function RoundCycleManager.StartNightPhase()
    print("🌙 Night Phase has started...")

    -- Changing the lighting and notifying players
    LightingManager.SetNight(5)
    NotificationManager.BroadcastRoundEvent("Night has fallen on the city... The mafia is on the move now.", true)

    task.wait(NIGHT_DURATION)
end

-- [3] Day Phase Function - Updated with the seating, voting, and elimination system
function RoundCycleManager.StartDayPhase()
    print("☀️ Day Phase has begun...")

    -- 1. Calling the seating system to move players to the table
    local SeatingSystem = require(Modules:WaitForChild("SeatingSystem"))
    local alivePlayers = {}

    -- Bring only live players to the discussion table
    for _, p in ipairs(Players:GetPlayers()) do
        if p:GetAttribute("IsAlive") ~= false then
            table.insert(alivePlayers, p)
        end
    end

    -- Perform seat allocation around the table
    SeatingSystem.ArrangePlayers(alivePlayers)

    -- 2. Set the lighting to midday
    LightingManager.SetDay(5)

    -- 3. Notify players that the discussion is starting
    NotificationManager.BroadcastRoundEvent("The sun is up... Everyone is around the table now to discuss.", false)

    -- Start the voting process
    local VotingSystem = require(Modules:WaitForChild("VotingSystem"))
    VotingSystem.StartVoting()

    -- 4. Wait for the specified daytime duration for discussion and voting
    task.wait(DAY_DURATION)

    -- [تم الربط هنا] - الحصول على نتيجة نظام التصويت وتفعيل الإقصاء الفعلي
    local victimName = VotingSystem.GetResult()

    if victimName then
        local victimPlayer = Players:FindFirstChild(victimName)

        if victimPlayer then
            -- Activate the "EliminationManager" to actually execute
            local EliminationManager = require(Modules:WaitForChild("EliminationManager"))

            print("⚖️ Execution is underway for: " .. victimPlayer.Name)

            -- Execute the elimination and determine the result
            local gameEnded = EliminationManager.EliminatePlayer(victimPlayer, "Vote")

            if gameEnded then
                print("🏁 Game over, stopping rounds.")
                -- يمكن كسر حلقة اللعبة هنا إذا كانت هذه نهاية المباراة
            end
        end
    else
        print("⚖️ No one found Victim (Tie or No Votes).")
    end

    -- 5. Clean the seats and release the players after the day ends
    SeatingSystem.ClearSeats()
end

-- [4] Main Game Engine
function RoundCycleManager.RunGameLoop()
    print("🚀 Main Game Engine is running...")

    while true do
        -- Checking for minimum player availability (4 players)
        if #Players:GetPlayers() >= 4 then
            -- Randomly assigning roles (Mafia, Judge, etc.)
            RoleManager.AssignRoles(Players:GetPlayers())

            -- Game phase sequence
            RoundCycleManager.StartNightPhase()
            RoundCycleManager.StartDayPhase()

            -- يمكن إضافة EliminationManager.CheckWinCondition() هنا لاحقاً
        else
            task.wait(10)
            print("⏳ Waiting for the number to reach (4 players) to start the round...")
        end

        task.wait(2) -- Short time interval between rounds
    end
end

return RoundCycleManager
