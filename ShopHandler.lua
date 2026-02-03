-- Modules/ShopHandler.lua
-- نظام معالجة المشتريات (ShopHandler)
-- الوظيفة: التحقق من أهلية اللاعب (المستوى والمال) وإتمام الصفقات المالية

local ShopHandler = {}

-- [1] الخدمات والاعتمادات
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

-- ربط الأنظمة السابقة لضمان التنسيق
local ShopModule = require(Modules:WaitForChild("ShopModule"))

-- [2] إعدادات قيود المستويات (Level Gatekeeping)
local LEVEL_REQUIREMENTS = {
    NORMAL = 1,  -- العناصر العادية (مستوى 1+)
    MEDIUM = 5,  -- العناصر المتوسطة (مستوى 5+)
    ELITE  = 10  -- العناصر النخبوية (مستوى 10+)
}

-- [3] الدالة الرئيسية لمعالجة الشراء (ProcessPurchase)
function ShopHandler.ProcessPurchase(player, itemName)
    -- أ. جلب بيانات العنصر من موديول المتجر
    local itemData = ShopModule.GetItemData(itemName)
    
    if not itemData then
        return false, "العنصر غير موجود في المتجر!"
    end

    -- ب. التحقق من المستوى (Gatekeeping Logic)
    local playerLevel = player:GetAttribute("Level") or 1
    local requiredLevel = itemData.RequiredLevel or LEVEL_REQUIREMENTS.NORMAL
    
    if playerLevel < requiredLevel then
        return false, "مستواك منخفض جداً! يتطلب مستوى: " .. requiredLevel
    end

    -- ج. التحقق من الرصيد المالي (Currency Logic)
    local playerCoins = player:GetAttribute("Coins") or 0
    local price = itemData.Price or 0
    
    if playerCoins < price then
        return false, "ليس لديك عملات كافية!"
    end

    -- د. إتمام العملية (Transaction)
    local success = ShopHandler.ExecuteTransaction(player, price, itemName)
    
    if success then
        print("💰 تمت العملية بنجاح: " .. player.Name .. " اشترى " .. itemName)
        return true, "تم الشراء بنجاح!"
    else
        return false, "حدث خطأ أثناء معالجة الدفع."
    end
end

-- [4] دالة تنفيذ الخصم وتحديث البيانات (Security & Execution)
function ShopHandler.ExecuteTransaction(player, price, itemName)
    local currentCoins = player:GetAttribute("Coins") or 0
    
    -- الخصم المباشر من الـ Attributes
    player:SetAttribute("Coins", currentCoins - price)
    
    -- تسجيل الغرض المشترا في سجل اللاعب (يمكن ربطه بنظام الجرد لاحقاً)
    -- player:SetAttribute("Has_" .. itemName, true)
    
    return true
end

-- [5] التحقق من أهلية العرض (Check Eligibility)
-- تستخدم لتعتيم العناصر في الواجهة (UI) إذا كان مستوى اللاعب منخفضاً
function ShopHandler.CanPlayerSeeItem(player, itemName)
    local itemData = ShopModule.GetItemData(itemName)
    local playerLevel = player:GetAttribute("Level") or 1
    
    if itemData and playerLevel >= (itemData.RequiredLevel or 1) then
        return true
    end
    return false
end

return ShopHandler
