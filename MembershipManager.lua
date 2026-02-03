-- Modules/MembershipManager.lua
-- نظام إدارة العضويات والامتيازات (MembershipManager)
-- الوظيفة: التحقق من فئة الاشتراك (250 ريال أو 150 ريال) ومنح الصلاحيات والألقاب

local MembershipManager = {}

-- [1] تعريف فئات العضوية وامتيازاتها
local TIERS = {
    ["Premium_250"] = {
        Title = "[PREMIUM]",
        AccessLevel = 3, -- Elite Access
        Color = Color3.fromRGB(255, 215, 0), -- ذهبي
        XpMultiplier = 2.0
    },
    ["Platinum_150"] = {
        Title = "[PLATINUM]",
        AccessLevel = 2, -- Medium Access
        Color = Color3.fromRGB(192, 192, 192), -- فضي
        XpMultiplier = 1.5
    },
    ["Guest"] = {
        Title = "[GUEST]",
        AccessLevel = 1, -- Basic Access
        Color = Color3.fromRGB(255, 255, 255), -- أبيض
        XpMultiplier = 1.0
    }
}

-- [2] استدعاء الموديولات المعتمدة (Dependencies)
-- ملاحظة: يعتمد على وجود ShopModule لجلب بيانات العناصر وأسعارها
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
-- local ShopModule = require(Modules:WaitForChild("ShopModule")) 

-- [3] دالة تفعيل العضوية للاعب (ApplyMembership)
function MembershipManager.ApplyMembership(player, tierName)
    local data = TIERS[tierName] or TIERS["Guest"]
    
    -- تعيين السمات (Attributes) لسهولة الوصول إليها من الأنظمة الأخرى
    player:SetAttribute("SubStatus", tierName)
    player:SetAttribute("AccessLevel", data.AccessLevel)
    player:SetAttribute("ChatTag", data.Title)
    
    print("💎 " .. player.Name .. " تم تفعيل رتبة: " .. data.Title)
    
    -- هنا يمكن إضافة كود لتغيير لون الاسم فوق الرأس أو في الدردشة
end

-- [4] نظام حراسة الموارد (Gatekeeping System)
-- يتحقق مما إذا كان اللاعب يملك المستوى المطلوب لاستخدام غرض معين
function MembershipManager.CanUseItem(player, itemRequirement)
    local playerAccess = player:GetAttribute("AccessLevel") or 1
    
    if playerAccess >= itemRequirement then
        return true
    else
        warn("🚫 " .. player.Name .. " حاول استخدام عنصر يتطلب اشتراكاً أعلى!")
        return false
    end
end

-- [5] دالة جلب بيانات الفئة (GetTierInfo)
function MembershipManager.GetTierInfo(player)
    local tierName = player:GetAttribute("SubStatus") or "Guest"
    return TIERS[tierName]
end

-- [6] دالة تحديث الاشتراك (Upgrade Subscription)
-- تستخدم عند شراء اللاعب لعضوية جديدة من المتجر
function MembershipManager.Upgrade(player, newTier)
    if TIERS[newTier] then
        MembershipManager.ApplyMembership(player, newTier)
        -- هنا يمكن ربط نظام حفظ البيانات لضمان بقاء الاشتراك
    end
end

return MembershipManager
