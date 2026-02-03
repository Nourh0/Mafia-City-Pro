-- Modules/RoundCycleManager.lua
-- نظام إدارة دورة الجولات (RoundCycleManager) - النسخة المحدثة والمربوطة بنظام التصويت والجلوس

local RoundCycleManager = {}

-- [1] الخدمات والاعتمادات (Services and Dependencies)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
local RoleManager = require(Modules:WaitForChild("RoleManager"))

-- إعدادات الوقت
local NIGHT_DURATION = 30
local DAY_DURATION = 60

-- [2] دالة مرحلة الليل (Night Phase)
function RoundCycleManager.StartNightPhase()
    print("🌙 Night Phase has started...")

    -- تغيير الإضاءة وتنبيه اللاعبين
    LightingManager.SetNight(5)
    NotificationManager.BroadcastRoundEvent("Night has fallen on the city... The mafia is on the move now.", true)

    task.wait(NIGHT_DURATION)
end

-- [3] دالة تشغيل مرحلة النهار (Day Phase) - المحدثة بالربط مع نظام الجلوس والتصويت
function RoundCycleManager.StartDayPhase()
    print("☀️ Day Phase has begun...")

    -- 1. استدعاء نظام الجلوس لنقل اللاعبين للطاولة
    local SeatingSystem = require(Modules:WaitForChild("SeatingSystem"))
    local alivePlayers = {}

    -- جلب اللاعبين الأحياء فقط للمشاركة في طاولة النقاش
    for _, p in ipairs(Players:GetPlayers()) do
        if p:GetAttribute("IsAlive") ~= false then
            table.insert(alivePlayers, p)
        end
    end

    -- تنفيذ عملية الجلوس الرياضية حول الطاولة
    SeatingSystem.ArrangePlayers(alivePlayers)

    -- 2. تحويل الإضاءة للظهيرة
    LightingManager.SetDay(5)

    -- 3. تنبيه اللاعبين ببدء النقاش
    NotificationManager.BroadcastRoundEvent("The sun is up... Everyone is around the table now to discuss.", false)

    -- [إضافة] بدء عملية التصويت
    local VotingSystem = require(Modules:WaitForChild("VotingSystem"))
    VotingSystem.StartVoting()

    -- 4. انتظار مدة النهار المحددة للنقاش والتصويت
    task.wait(DAY_DURATION)

    -- [إضافة] الحصول على النتيجة وتنفيذ الإقصاء
    local victimName = VotingSystem.GetResult()
    if victimName then
        -- هنا يتم استدعاء EliminationManager لحذف اللاعب (سيتم ربطه لاحقاً)
        print("The city has decided to eliminate: " .. victimName)
    end

    -- 5. تنظيف المقاعد وتحرير اللاعبين بعد انتهاء النهار
    SeatingSystem.ClearSeats()
end

-- [4] المحرك الرئيسي للجولة (Main Game Engine)
function RoundCycleManager.RunGameLoop()
    print("🚀 Main Game Engine is running...")

    while true do
        -- التحقق من توفر الحد الأدنى من اللاعبين (4 لاعبين)
        if #Players:GetPlayers() >= 4 then
            -- توزيع الأدوار عشوائياً (Mafia, Judge, etc.)
            RoleManager.AssignRoles(Players:GetPlayers())

            -- تعاقب مراحل اللعبة
            RoundCycleManager.StartNightPhase()
            RoundCycleManager.StartDayPhase()

            -- يمكن إضافة EliminationManager.CheckWinCondition() هنا لاحقاً
        else
            task.wait(10)
            print("⏳ Waiting for the number to reach (4 players) to start the round...")
        end

        task.wait(2) -- فاصل زمني بسيط بين الجولات
    end
end

return RoundCycleManager
