-- =============================================================================
-- LAYER 1: HEADER (Programmer Information & Description)
-- =============================================================================
-- File: Modules/ShopModule.lua
-- Version: 2.0
-- Project: Mafia City
-- Description: نظام المتجر المركزي لإدارة المشتريات، العضويات، والموارد البرمجية.
-- Structure: Header, Memberships, Inventory, Logic.
-- =============================================================================

local ShopModule = {}

-- =============================================================================
-- LAYER 2: MEMBERSHIPS (Elite 250 SAR & Med 150 SAR)
-- =============================================================================
ShopModule.Memberships = {
    ["Elite_VIP"] = {
        DisplayName = "عضوية النخبة (Elite)",
        PriceSAR = 250,
        AccessLevel = 3, -- مستوى وصول كامل
        Benefits = {"Double XP", "Rare Cards Access", "Exclusive Furniture"}
    },
    ["Med_VIP"] = {
        DisplayName = "العضوية المتوسطة (Medium)",
        PriceSAR = 150,
        AccessLevel = 2, -- مستوى وصول متوسط
        Benefits = {"1.5x XP", "Rare Identity Items"}
    },
    ["Normal"] = {
        DisplayName = "عضوية عادية (Normal)",
        PriceSAR = 0,
        AccessLevel = 1,
        Benefits = {"Basic Access"}
    }
}

-- =============================================================================
-- LAYER 3: INVENTORY (Furniture, Identity, UI_Assets, Cards)
-- =============================================================================
ShopModule.Inventory = {
    -- فئة الأثاث (Furniture)
    Furniture = {
        {Id = 101, Name = "Royal Chair", Price = 500, MinAccess = 3},
        {Id = 102, Name = "Wooden Table", Price = 200, MinAccess = 1}
    },
    
    -- فئة الهوية (Identity)
    Identity = {
        {Id = 201, Name = "Godfather Title", Price = 1000, MinAccess = 3},
        {Id = 202, Name = "Detective Hat", Price = 300, MinAccess = 2}
    },
    
    -- فئة الواجهات (UI_Assets)
    UI_Assets = {
        {Id = 301, Name = "Golden Frame", Price = 450, MinAccess = 3},
        {Id = 302, Name = "Dark Theme", Price = 150, MinAccess = 1}
    },
    
    -- فئة بطاقات الأدوار (Cards)
    Cards = {
        {Id = 401, Name = "Double Vote Card", Price = 600, MinAccess = 2},
        {Id = 402, Name = "Shield Card", Price = 400, MinAccess = 1}
    }
}

-- =============================================================================
-- LAYER 4: LOGIC (Functions & Access Control)
-- =============================================================================

-- وظيفة للتحقق من صلاحيات اللاعب (GetPlayerPermissions)
function ShopModule.GetPlayerPermissions(player)
    -- يتم جلب حالة الاشتراك من السيرفر (Attributes)
    local subStatus = player:GetAttribute("SubStatus") or "Normal"
    local membershipInfo = ShopModule.Memberships[subStatus]
    
    return {
        Tier = subStatus,
        AccessLevel = membershipInfo.AccessLevel,
        Title = membershipInfo.DisplayName
    }
end

-- وظيفة لجلب العناصر المتاحة بناءً على رتبة اللاعب
function ShopModule.GetAvailableItems(player, category)
    local playerPerms = ShopModule.GetPlayerPermissions(player)
    local availableItems = {}
    
    if ShopModule.Inventory[category] then
        for _, item in ipairs(ShopModule.Inventory[category]) do
            if playerPerms.AccessLevel >= item.MinAccess then
                table.insert(availableItems, item)
            end
        end
    end
    
    return availableItems
end

-- وظيفة لجلب بيانات عنصر معين بالاسم
function ShopModule.GetItemData(itemName)
    for category, items in pairs(ShopModule.Inventory) do
        for _, item in ipairs(items) do
            if item.Name == itemName then
                return item, category
            end
        end
    end
    return nil
end

return ShopModule
