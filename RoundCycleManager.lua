-- Modules/RoundCycleManager.lua
-- نظام إدارة دورة الجولات (RoundCycleManager)
-- الوظيفة: المايسترو المسؤول عن تعاقب الليل والنهار، الإضاءة، وتوجيه الأدوار

local RoundCycleManager = {}

-- [1] الخدمات والاعتمادات (Dependencies)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightingManager = require(Modules:WaitForChild("LightingManager"))
local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
local RoleManager = require(Modules:WaitForChild("RoleManager"))

-- [2] إعدادات المراحل (Phase Settings)
local NIGHT_DURATION = 30 -- مدة الليل (30 ثانية)
local DAY_DURATION = 60   -- مدة النهار (60 ثانية)

-- [3] دالة تشغيل مرحلة الليل (Night Phase)
function RoundCycleManager.StartNightPhase()
    print("🌙 بدأت مرحلة الليل...")
    
    -- تحويل الإضاءة لمنتصف الليل
    LightingManager.SetNight(5)
    
    -- تنبيه اللاعبين (بث عام وخاص)
    NotificationManager.BroadcastRoundEvent("حل الليل على المدينة.. المافيا تتحرك الآن.", true)
    
    -- توجيه الأدوار الليلية (أمثلة)
    for _, player in ipairs(Players:GetPlayers()) do
        local role = player:GetAttribute("CurrentRole")
        if role == "Mafia" or role == "Godfather" then
            NotificationManager.SendPrivate(player, "إختر ضحيتك الآن مع بقية أفراد المافيا.", "RED")
            -- هنا يتم تفعيل واجهة اختيار الضحية (MafiaTargetUI)
        elseif role == "Doctor" then
            NotificationManager.SendPrivate(player, "إختر شخصاً واحداً لحمايته الليلة.", "SUCCESS")
        end
    end
    
    task.wait(NIGHT_DURATION)
end

-- [4] دالة تشغيل مرحلة النهار (Day Phase)
function RoundCycleManager.StartDayPhase()
    print("☀️ بدأت مرحلة النهار...")
    
    -- تحويل الإضاءة للظهيرة
    LightingManager.SetDay(5)
    
    -- تنبيه اللاعبين
    NotificationManager.BroadcastRoundEvent("أشرقت الشمس.. ابدأوا النقاش لكشف المتسللين.", false)
    
    -- هنا يتم فتح بوابة النقاش العام وتفعيل نظام التصويت (VotingSystem)
    
    task.wait(DAY_DURATION)
end

-- [5] تهيئة الجولة الجديدة (Round Setup)
function RoundCycleManager.PrepareNewRound()
    print("🎲 جاري تحضير جولة جديدة وتوزيع الأدوار...")
    
    local activePlayers = Players:GetPlayers()
    if #activePlayers >= 4 then
        -- توزيع الأدوار بناءً على نظام الاحتمالات (60/40)
        RoleManager.AssignRoles(activePlayers)
        
        NotificationManager.BroadcastRoundEvent("تم توزيع الأدوار السرية.. استعدوا!", false)
        return true
    else
        print("⚠️ لا يوجد لاعبين كافيين لبدء الجولة.")
        return false
    end
end

-- [6] محرك اللعبة المستمر (RunGameLoop)
function RoundCycleManager.RunGameLoop()
    print("🚀 محرك الجولات قيد التشغيل...")
    
    while true do
        -- فحص وجود لاعبين قبل البدء
        if #Players:GetPlayers() >= 4 then
            -- 1. تجهيز الجولة
            if RoundCycleManager.PrepareNewRound() then
                
                -- 2. دورة الليل
                RoundCycleManager.StartNightPhase()
                
                -- 3. دورة النهار
                RoundCycleManager.StartDayPhase()
                
                -- 4. حسم النتائج (هل فازت المافيا أم المواطنون؟)
                -- يتم استدعاء EliminationManager.CheckWin() هنا
            end
        else
            -- انتظار لاعبين إذا قل العدد عن 4
            task.wait(10)
            print("⏳ في انتظار اكتمال العدد لبدء الجولة...")
        end
        
        task.wait(2) -- فاصل بسيط بين الدورات
    end
end

return RoundCycleManager
