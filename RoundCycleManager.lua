-- Modules/RoundCycleManager.lua
-- RoundCycleManager - النسخة النهائية المحدثة والمربوطة بنظام التصويت، الإقصاء، والوقت

local RoundCycleManager = {}

-- [1] Services and Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
local RoleManager = require(Modules:WaitForChild("RoleManager"))

-- [الربط] استدعاء نظام الوقت
local TimeSystem = require(Modules:WaitForChild("TimeSystem"))

-- Time Settings
local NIGHT_DURATION = 30
local DAY_DURATION = 60

-- [2] Night Phase Function
function RoundCycleManager.StartNightPhase()
    print("🌙 Night Phase has started...")

    -- Changing the lighting and notifying players
    LightingManager.SetNight(5)
    NotificationManager.BroadcastRoundEvent("Night has fallen on the city... The mafia is on the move now.", true)

    -- ملاحظة: WaitPhase سيقوم بالانتظار الفعلي بدلاً من task.wait هنا لضمان التزامن
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

    -- [ملاحظة]: تم نقل الانتظار (task.wait) إلى محرك الجولات عبر TimeSystem.WaitPhase
end

-- وظيفة معالجة نتائج التصويت (يتم استدعاؤها بعد انتهاء وقت النهار)
function RoundCycleManager.ProcessVotingResults()
    local VotingSystem = require(Modules:WaitForChild("VotingSystem"))
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
            end
        end
    else
        print("⚖️ No one found Victim (Tie or No Votes)")
    end

    -- 5. Clean the seats and release the players after the day ends
    local SeatingSystem = require(Modules:WaitForChild("SeatingSystem"))
    SeatingSystem.ClearSeats()
end

-- [4] Main Game Engine (المحدث بنظام الوقت)
function RoundCycleManager.RunGameLoop()
    print("🚀 Main Game Engine is running...")

    while true do
        -- Checking for minimum player availability (4 players)
        if #Players:GetPlayers() >= 4 then
            -- توزيع الأدوار عشوائياً عند بداية الجولة
            RoleManager.AssignRoles(Players:GetPlayers())

            -- 1. مرحلة الليل (Night Phase)
            RoundCycleManager.StartNightPhase()
            TimeSystem.WaitPhase("Night")

            -- 2. مرحلة الأخبار (News Phase)
            NotificationManager.BroadcastRoundEvent("The press is publishing last night's news...", false)
            TimeSystem.WaitPhase("News")

            -- 3. مرحلة النهار (Day Phase)
            RoundCycleManager.StartDayPhase()
            TimeSystem.WaitPhase("Day")
            
            -- معالجة التصويت بعد انتهاء وقت النهار
            RoundCycleManager.ProcessVotingResults()

        else
            task.wait(10)
            print("⏳ Waiting for the number to reach (4 players) to start the round...")
        end

        task.wait(2) -- Short time interval between rounds
    end
end

return RoundCycleManager
