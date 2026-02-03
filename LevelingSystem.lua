-- Modules/LevelingSystem.lua
-- نظام المستويات والمكافآت (LevelingSystem)
-- هذا الملف يدير تطور اللاعب من المستوى 1 إلى الاحتراف وفتح الأدوار المغلقة

local LevelingSystem = {}

-- [1] الإعدادات الأساسية
local XP_PER_LEVEL = 500      -- الخبرة المطلوبة لكل مستوى
local LEVEL_UP_REWARD = 100  -- عملات مجانية عند الترقية
local JUDGE_MIN_LEVEL = 10    -- المستوى المطلوب لفتح دور القاضي

-- [2] دالة إضافة الخبرة (Add XP)
-- تقوم بحساب الخبرة بناءً على نوع الاشتراك وتحديث سمات اللاعب
function LevelingSystem.AddXP(player, amount)
    if not player then return end

    -- جلب مستوى الاشتراك لتحديد المضاعف (Boost)
    local subStatus = player:GetAttribute("SubStatus") or "None"
    local multiplier = 1

    if subStatus == "Premium_250" then
        multiplier = 2    -- مضاعفة 2x لمشترك الـ 250 ريال
    elseif subStatus == "Platinum_150" then
        multiplier = 1.5  -- زيادة 1.5x لمشترك الـ 150 ريال
    end

    local finalXP = amount * multiplier
    local currentXP = player:GetAttribute("XP") or 0
    
    -- تحديث القيمة الجديدة
    player:SetAttribute("XP", currentXP + finalXP)
    print("✨ تم منح " .. player.Name .. " مقدار " .. finalXP .. " نقطة خبرة.")

    -- التحقق من الترقية لمستوى جديد
    LevelingSystem.CheckLevelUp(player)
end

-- [3] دالة فحص الترقية (Check Level Up)
function LevelingSystem.CheckLevelUp(player)
    local currentXP = player:GetAttribute("XP") or 0
    local currentLevel = player:GetAttribute("Level") or 1

    -- حلقة لمعالجة الترقيات المتعددة في حال حصل على XP عالي جداً
    while currentXP >= XP_PER_LEVEL do
        currentXP = currentXP - XP_PER_LEVEL
        currentLevel = currentLevel + 1
        
        -- تحديث السمات بعد الترقية
        player:SetAttribute("Level", currentLevel)
        player:SetAttribute("XP", currentXP)
        
        -- منح مكافأة العملات
        local currentCoins = player:GetAttribute("Coins") or 0
        player:SetAttribute("Coins", currentCoins + LEVEL_UP_REWARD)
        
        print("🆙 ترقية! " .. player.Name .. " وصل إلى المستوى " .. currentLevel)
        
        -- التحقق من فتح صلاحية القاضي
        LevelingSystem.CheckJudgeUnlock(player, currentLevel)
    end
end

-- [4] دالة فتح صلاحية القاضي (Judge Unlock)
-- تُفعل ميزة "CanBeJudge" لضمان اختيار الخبراء فقط لهذا الدور الحساس
function LevelingSystem.CheckJudgeUnlock(player, currentLevel)
    if currentLevel >= JUDGE_MIN_LEVEL then
        if player:GetAttribute("CanBeJudge") ~= true then
            player:SetAttribute("CanBeJudge", true)
            print("⚖️ مبروك! " .. player.Name .. " مؤهل الآن ليصبح قاضياً.")
            -- هنا يمكن إرسال تنبيه واجهة (UI Notification) للاعب
        end
    end
end

-- [5] تهيئة بيانات اللاعب عند الدخول (تُستدعى من IdentityProtector)
function LevelingSystem.InitPlayer(player, data)
    player:SetAttribute("Level", data.Level or 1)
    player:SetAttribute("XP", data.XP or 0)
    player:SetAttribute("Coins", data.Coins or 0)
    
    -- التحقق من الصلاحيات فور الدخول بناءً على المستوى المحمل
    LevelingSystem.CheckJudgeUnlock(player, data.Level or 1)
end

return LevelingSystem
