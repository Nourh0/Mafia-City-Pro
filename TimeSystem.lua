-- Modules/TimeSystem.lua
-- نظام إدارة الوقت (TimeSystem)
-- الوظيفة: تنظيم الإيقاع الزمني للجولات وضمان مزامنة المراحل

local TimeSystem = {}

-- [1] إعدادات مدد المراحل (بالثواني)
TimeSystem.Durations = {
    Night = 30, -- وقت تحرك المافيا والأدوار السرية
    News = 10,  -- وقت قراءة نتائج الليل (الجريدة)
    Day = 60    -- وقت النقاش العام واتخاذ القرارات
}

-- [2] متغيرات الحالة
local currentPhase = "None"

-- [3] دالة انتظار المرحلة (WaitPhase)
-- تستخدم آلية التعليق (Yielding) لإيقاف العمليات حتى انتهاء الوقت المحدد لكل مرحلة
function TimeSystem.WaitPhase(phaseName)
    local duration = TimeSystem.Durations[phaseName]
    
    if duration then
        currentPhase = phaseName
        print("🕒 بدأت مرحلة [" .. phaseName .. "] - المدة: " .. duration .. " ثانية")
        
        -- تعليق العمل برمجياً حتى انتهاء الوقت
        task.wait(duration)
        
        print("🏁 انتهت مرحلة [" .. phaseName .. "]")
    else
        warn("⚠️ تحذير: المرحلة المسمّاة [" .. tostring(phaseName) .. "] غير موجودة في إعدادات الوقت.")
    end
end

-- [4] دالة جلب الوقت المتبقي (اختيارية للـ UI)
function TimeSystem.GetPhaseDuration(phaseName)
    return TimeSystem.Durations[phaseName] or 0
end

-- [5] دالة جلب المرحلة الحالية
function TimeSystem.GetCurrentPhase()
    return currentPhase
end

return TimeSystem
