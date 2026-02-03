-- Modules/RoundCycleManager.lua
-- نظام إدارة دورة الجولات (RoundCycleManager) - النسخة المحدثة والمربوطة بنظام الجلوس

local RoundCycleManager = {}

-- [1] الخدمات والاعتمادات (Services and Dependencies)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
local RoleManager = require(Modules:WaitForChild("RoleManager"))

-- إعدادات الوقت (Time Settings)
local NIGHT_DURATION = 30
local DAY_DURATION = 60

-- [2] دالة مرحلة الليل (Night Phase)
function RoundCycleManager.StartNightPhase()
    print("🌙 بدأت مرحلة الليل...")
    
    -- تغيير الإضاءة وتنبيه اللاعبين
    LightingManager.SetNight(5)
    NotificationManager.BroadcastRoundEvent("حل الليل على المدينة.. المافيا تتحرك الآن.", true)
    
    task.wait(NIGHT_DURATION)
end

-- [3] دالة تشغيل مرحلة النهار (Day Phase) - المحدثة بالربط مع نظام الجلوس
function RoundCycleManager.StartDayPhase()
    print("☀️ بدأت مرحلة النهار...")

    -- 1. استدعاء نظام الجلوس (SeatingSystem)
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

    -- 2. تحويل الإضاءة للظهيرة (Daylight)
    LightingManager.SetDay(5)
    
    -- 3. تنبيه اللاعبين ببدء النقاش وكشف القتلة
    NotificationManager.BroadcastRoundEvent("أشرقت الشمس.. الجميع حول الطاولة الآن للنقاش.", false)
    
    -- 4. انتظار مدة النهار المحددة للنقاش والتصويت
    task.wait(DAY_DURATION)
    
    -- 5. تنظيف المقاعد وتحرير اللاعبين بعد انتهاء النهار
    SeatingSystem.ClearSeats()
end

-- [4] المحرك الرئيسي للجولة (Main Game Engine)
function RoundCycleManager.RunGameLoop()
    print("🚀 المحرك الرئيسي للجولات قيد التشغيل...")
    
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
            print("⏳ في انتظار اكتمال العدد (4 لاعبين) لبدء الجولة...")
        end
        
        task.wait(2) -- فاصل زمني بسيط بين الجولات
    end
end

return RoundCycleManager
