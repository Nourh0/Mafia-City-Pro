-- Modules/Config.lua
-- هذا الملف هو المحرك المركزي لتوازنات اللعبة (Mafia City)

local Config = {}

-- [1] إعدادات الأوقات (Time Settings - بالثواني)
Config.TimeSettings = {
    NightDuration = 35,   -- مدة الليل (تحركات المافيا)
    DayDuration = 60,     -- مدة النهار (النقاش والتصويت)
    NewsDuration = 12     -- مدة عرض الأخبار (الجريدة)
}

-- [2] ميكانيكيات ونظام التصويت (Voting Mechanics)
Config.VotingMechanics = {
    JudgeVoteWeight = 2,   -- قوة صوت القاضي (صوته يعادل صوتين)
    AllowSelfVote = false, -- منع اللاعب من التصويت لنفسه
    VetoEnabled = true     -- تفعيل خاصية النقض (الفيتو)
}

-- [3] حدود اللعبة (Game Limits - تحسين احترافي)
Config.GameLimits = {
    MinPlayers = 6,        -- الحد الأدنى لبدء الجولة
    MaxPlayers = 12,       -- الحد الأقصى للسيرفر
    MafiaCountRatio = 3    -- لاعب مافيا واحد لكل 3 لاعبين (توازن القوى)
}

-- [4] نظام المكافآت (Rewards - تحسين احترافي)
Config.Rewards = {
    WinCoins = 100,        -- عملات مكافأة الفوز
    ParticipationXP = 50   -- نقاط خبرة للمشاركة
}

-- [5] تعريف الأدوار الأساسية (7 أدوار ثنائية اللغة)
Config.Roles = {
    {Id = 1, NameAr = "مواطن", NameEn = "Villager"},
    {Id = 2, NameAr = "مافيا", NameEn = "Mafia"},
    {Id = 3, NameAr = "طبيب", NameEn = "Doctor"},
    {Id = 4, NameAr = "محقق", NameEn = "Detective"},
    {Id = 5, NameAr = "قاضي", NameEn = "Judge"},
    {Id = 6, NameAr = "حارس شخصي", NameEn = "Bodyguard"},
    {Id = 7, NameAr = "عراب", NameEn = "Godfather"}
}

-- [6] ملاحظات برمجية للاستخدام:
-- للوصول إلى هذا الملف من الأنظمة الأخرى (مثل VotingSystem أو RoleDistributor):
-- local Config = require(game:GetService("ReplicatedStorage").Modules.Config)

return Config
