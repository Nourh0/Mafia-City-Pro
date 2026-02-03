-- Modules/GameRewards.lua
-- نظام مكافآت الجولات (GameRewards)
-- هذا الموديل مسؤول عن توزيع الـ XP والعملات بناءً على نتائج المباراة

local GameRewards = {}

-- [1] إعدادات المكافآت الأساسية (Reward Tiers)
local REWARD_CONFIG = {
    WINNER = { XP = 300, COINS = 50 },          -- مكافأة الفائز
    PARTICIPATION = { XP = 100, COINS = 10 },   -- مكافأة المشاركة (للخاسر)
    SPECIAL_BONUS = { XP = 150 },               -- مكافأة الأداء المتميز
}

-- [2] دالة توزيع المكافآت الرئيسية
-- يتم استدعاؤها من GameManager عند نهاية الجولة
function GameRewards.DistributeRoundRewards(players, winningTeam)
    print("💰 جاري توزيع المكافآت على اللاعبين...")

    for _, player in ipairs(players) do
        local playerTeam = player:GetAttribute("Team") -- يفترض أن الفريق مسجل في Attribute
        local isWinner = (playerTeam == winningTeam)
        
        -- تحديد المكافأة الأساسية
        local xpToGive = isWinner and REWARD_CONFIG.WINNER.XP or REWARD_CONFIG.PARTICIPATION.XP
        local coinsToGive = isWinner and REWARD_CONFIG.WINNER.COINS or REWARD_CONFIG.PARTICIPATION.COINS
        
        -- [3] نظام التآزر مع الاشتراكات (Subscription Synergy)
        -- إذا كان اللاعب مشتركاً في باقة الـ 250 ريال يحصل على Double XP
        local subStatus = player:GetAttribute("SubStatus")
        if subStatus == "Gold_250" or subStatus == "Premium_250" then
            xpToGive = xpToGive * 2
            print("✨ مضاعفة XP للاعب " .. player.Name .. " بسبب اشتراك الـ 250 ريال.")
        end

        -- [4] إضافة مكافآت الأداء المتميز (Special Bonus)
        -- مثال: إذا كان اللاعب "قاضي ذكي" أو "مافيا صامت" (يمكن إضافة شروط برمجية هنا)
        if player:GetAttribute("PerformedWell") == true then
            xpToGive = xpToGive + REWARD_CONFIG.SPECIAL_BONUS.XP
            print("🌟 مكافأة أداء متميز لـ " .. player.Name)
        end

        -- [5] تحديث البيانات لحظياً عبر الـ Attributes
        -- هذا سيؤدي لتحديث واجهة المستخدم (UI) فوراً
        local currentXP = player:GetAttribute("XP") or 0
        local currentCoins = player:GetAttribute("Coins") or 0

        player:SetAttribute("XP", currentXP + xpToGive)
        player:SetAttribute("Coins", currentCoins + coinsToGive)

        -- تنبيه اللاعب (اختياري - يربط بنظام الـ Notifications)
        -- print("✅ " .. player.Name .. " حصل على " .. xpToGive .. " خبرة.")
    end
end

-- [6] دالة منح مكافأة خاصة لمرة واحدة
function GameRewards.GiveSpecialBonus(player, bonusType)
    local bonus = REWARD_CONFIG.SPECIAL_BONUS.XP
    local currentXP = player:GetAttribute("XP") or 0
    player:SetAttribute("XP", currentXP + bonus)
    print("🎯 مكافأة خاصة (" .. bonusType .. ") منحت لـ " .. player.Name)
end

return GameRewards
