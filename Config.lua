-- Modules/Config.lua
-- هذا الملف هو المحرك المركزي لتوازنات اللعبة

local Config = {}

-- [1] إعدادات الأوقات (بالثواني)
Config.TimeSettings = {
    NightDuration = 35,   -- مدة الليل
    DayDuration = 60,     -- مدة النهار
    NewsDuration = 12     -- مدة عرض الأخبار (الجريدة)
}

-- [2] ميكانيكيات ونظام التصويت
Config.VotingMechanics = {
    JudgeVoteWeight = 2,   -- قوة صوت القاضي (صوته يحسب عن اثنين)
    AllowSelfVote = false, -- منع اللاعب من التصويت لنفسه
    VetoEnabled = true     -- تفعيل خاصية النقض (Veto)
}

-- [3] تعريف الأدوار الأساسية (7 أدوار ثنائية اللغة)
Config.Roles = {
    {Id = 1, NameAr = "مواطن", NameEn = "Villager"},
    {Id = 2, NameAr = "مافيا", NameEn = "Mafia"},
    {Id = 3, NameAr = "طبيب", NameEn = "Doctor"},
    {Id = 4, NameAr = "محقق", NameEn = "Detective"},
    {Id = 5, NameAr = "قاضي", NameEn = "Judge"},
    {Id = 6, NameAr = "حارس شخصي", NameEn = "Bodyguard"},
    {Id = 7, NameAr = "عراب", NameEn = "Godfather"}
}

-- [4] ملاحظات برمجية للاستخدام:
-- لاستدعاء هذا الملف من سكريبتات أخرى استخدم السطر التالي:
-- local Config = require(game:GetService("ReplicatedStorage").Modules.Config)

return Config
