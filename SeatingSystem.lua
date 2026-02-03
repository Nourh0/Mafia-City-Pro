-- Modules/RoundCycleManager.lua
-- نظام إدارة دورة الجولات (النسخة المحدثة بالربط مع نظام الجلوس)

local RoundCycleManager = {}

-- [1] الخدمات والاعتمادات
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
local RoleManager = require(Modules:WaitForChild("RoleManager"))

-- إعدادات الوقت
local NIGHT_DURATION = 30
local DAY_DURATION = 60

-- [2] دالة مرحلة الليل
function RoundCycleManager.StartNightPhase()
    print("🌙 بدأت مرحلة الليل...")
    LightingManager.SetNight(5)
    NotificationManager.BroadcastRoundEvent("حل الليل.. المافيا تتحرك الآن.", true)
    
    task.wait(NIGHT_DURATION)
end

-- [3] دالة تشغيل مرحلة النهار (المحدثة والمنقحة)
function RoundCycleManager.StartDayPhase()
    print("☀️ بدأت مرحلة النهار...")
    
    -- 1. استدعاء نظام الجلوس لنقل اللاعبين للطاولة
    local SeatingSystem = require(Modules:WaitForChild("SeatingSystem"))
    local alivePlayers = {}
    
    -- جلب اللاعبين الأحياء فقط للجلوس حول الطاولة
    for _, p in ipairs(Players:GetPlayers()) do
        if p:GetAttribute("IsAlive") ~= false then
            table.insert(alivePlayers, p)
        end
    end
    
    -- تنفيذ عملية الجلوس الرياضية
    SeatingSystem.ArrangePlayers(alivePlayers)

    -- 2. تحويل الإضاءة للظهيرة
    LightingManager.SetDay(5)
    
    -- 3. تنبيه اللاعبين ببدء النقاش
    NotificationManager.BroadcastRoundEvent("أشرقت الشمس.. الجميع حول الطاولة الآن للنقاش.", false)
    
    -- 4. انتظار مدة النهار
    task.wait(DAY_DURATION)
    
    -- 5. تنظيف الكراسي بعد انتهاء النهار
    SeatingSystem.ClearSeats()
end

-- [4] المحرك الرئيسي للجولات
function RoundCycleManager.RunGameLoop()
    while true do
        if #Players:GetPlayers() >= 4 then
            -- توزيع الأدوار
            RoleManager.AssignRoles(Players:GetPlayers())
            
            -- تعاقب المراحل
            RoundCycleManager.StartNightPhase()
            RoundCycleManager.StartDayPhase()
        else
            task.wait(10)
            print("⏳ في انتظار اكتمال العدد...")
        end
        task.wait(2)
    end
end

return RoundCycleManager
