-- Modules/LightingManager.lua
-- مدير الإضاءة والبيئة (LightingManager)
-- الوظيفة: التحكم في الوقت والإضاءة لخلق أجواء النهار والليل

local LightingManager = {}

-- [1] الخدمات الأساسية
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService") -- لتغيير الإضاءة بشكل ناعم

-- [2] إعدادات النهار (Day Mode)
local DAY_SETTINGS = {
    ClockTime = 12,                    -- ظهراً
    Brightness = 2.0,                  -- إضاءة قوية
    Ambient = Color3.fromRGB(200, 200, 200), -- إضاءة محيطة طبيعية
    OutdoorAmbient = Color3.fromRGB(128, 128, 128)
}

-- [3] إعدادات الليل (Night Mode)
local NIGHT_SETTINGS = {
    ClockTime = 0,                     -- منتصف الليل
    Brightness = 0.5,                  -- إضاءة خافتة
    Ambient = Color3.fromRGB(10, 20, 60),    -- إضاءة محيطة زرقاء قاتمة (للتوتر)
    OutdoorAmbient = Color3.fromRGB(5, 5, 25)
}

-- [4] دالة الانتقال إلى وضع الليل
function LightingManager.SetNight(duration)
    duration = duration or 5 -- مدة الانتقال بالثواني
    
    print("🌙 جاري تحويل المدينة إلى وضع الليل...")
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local nightTween = TweenService:Create(Lighting, tweenInfo, {
        ClockTime = NIGHT_SETTINGS.ClockTime,
        Brightness = NIGHT_SETTINGS.Brightness,
        Ambient = NIGHT_SETTINGS.Ambient,
        OutdoorAmbient = NIGHT_SETTINGS.OutdoorAmbient
    })
    
    nightTween:Play()
end

-- [5] دالة الانتقال إلى وضع النهار
function LightingManager.SetDay(duration)
    duration = duration or 5
    
    print("☀️ جاري تحويل المدينة إلى وضع النهار...")
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local dayTween = TweenService:Create(Lighting, tweenInfo, {
        ClockTime = DAY_SETTINGS.ClockTime,
        Brightness = DAY_SETTINGS.Brightness,
        Ambient = DAY_SETTINGS.Ambient,
        OutdoorAmbient = DAY_SETTINGS.OutdoorAmbient
    })
    
    dayTween:Play()
end

-- [6] دالة التهيئة (تعيين النهار كوضع افتراضي)
function LightingManager.Init()
    Lighting.GlobalShadows = true
    Lighting.ClockTime = DAY_SETTINGS.ClockTime
    Lighting.Brightness = DAY_SETTINGS.Brightness
    Lighting.Ambient = DAY_SETTINGS.Ambient
end

return LightingManager
