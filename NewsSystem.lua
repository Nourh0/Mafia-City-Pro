-- Modules/NewsSystem.lua
-- نظام الأخبار (NewsSystem)
-- الوظيفة: تحويل أحداث الليل إلى نصوص "جريدة الصباح" باللغتين العربية والإنجليزية

local NewsSystem = {}

-- [1] قوالب النصوص (Templates)
-- تدعم النظام ثنائي اللغة ودمج اسم الضحية تلقائياً
local NEWS_TEMPLATES = {
    ["KILLED"] = {
        ["Ar"] = "📰 أخبار الصباح: استيقظت المدينة على خبر حزين.. لقد تم اغتيال {NAME} من قبل المافيا!",
        ["En"] = "📰 Morning News: The city woke up to sad news.. {NAME} has been assassinated by the Mafia!"
    },
    ["SAVED"] = {
        ["Ar"] = "📰 أخبار الصباح: ليلة هادئة! بفضل شجاعة الطبيب، نجا {NAME} من محاولة اغتيال محققة.",
        ["En"] = "📰 Morning News: A quiet night! Thanks to the Doctor's courage, {NAME} survived an assassination attempt."
    },
    ["NO_ACTION"] = {
        ["Ar"] = "📰 أخبار الصباح: لم يحدث شيء الليلة، يبدو أن الجميع ناموا بسلام.",
        ["En"] = "📰 Morning News: Nothing happened tonight, it seems everyone slept peacefully."
    }
}

-- [2] دالة صياغة الخبر (GenerateEventText)
-- المدخلات: نوع الحدث (KILLED/SAVED)، اسم اللاعب، اللغة المطلوبة (Ar/En)
function NewsSystem.GenerateEventText(eventType, playerName, lang)
    lang = lang or "Ar" -- اللغة الافتراضية هي العربية
    local template = NEWS_TEMPLATES[eventType] or NEWS_TEMPLATES["NO_ACTION"]
    
    local text = template[lang]
    
    -- دمج اسم اللاعب داخل النص
    if playerName then
        text = string.gsub(text, "{NAME}", playerName)
    end
    
    return text
end

-- [3] دالة بث الأخبار (BroadcastNews)
-- تقوم بإرسال الخبر لجميع اللاعبين عبر RemoteEvent ليظهر في واجهة المستخدم (UI)
function NewsSystem.BroadcastNews(eventType, victimPlayer)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Events = ReplicatedStorage:WaitForChild("Events")
    local NewsEvent = Events:FindFirstChild("NewsEvent")
    
    local victimName = victimPlayer and victimPlayer.Name or ""
    
    -- إنشاء النصوص للغتين
    local messageAr = NewsSystem.GenerateEventText(eventType, victimName, "Ar")
    local messageEn = NewsSystem.GenerateEventText(eventType, victimName, "En")
    
    print("📢 بث الخبر: " .. messageAr)
    
    -- إرسال الخبر للسيرفر ليتم عرضه في الـ UI لدى الجميع
    if NewsEvent then
        NewsEvent:FireAllClients(messageAr, messageEn)
    end
end

return NewsSystem
