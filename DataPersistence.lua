-- Modules/DataPersistence.lua
-- نظام حفظ البيانات الدائم (DataPersistence)
-- هذا الملف هو المسؤول عن حفظ واسترجاع بيانات اللاعبين من سحابة روبلوكس

local DataPersistence = {}

-- استدعاء الخدمات الأساسية
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- اسم قاعدة البيانات (المفتاح الرئيسي للخزنة)
local GameDataStore = DataStoreService:GetDataStore("PlayerGameData_v1")

-- الإعدادات الافتراضية للاعبين الجدد
local DEFAULT_DATA = {
    Level = 1,          -- مستوى الخبرة
    XP = 0,             -- نقاط الخبرة
    Coins = 0,          -- الرصيد المالي
    SubStatus = "None"  -- نوع العضوية (مثال: 150 ريال، 250 ريال، أو لا يوجد)
}

-- [1] دالة تحميل البيانات (Load Data)
function DataPersistence.LoadData(player)
    local userId = player.UserId
    local key = "Player_" .. userId
    
    local success, data = pcall(function()
        return GameDataStore:GetAsync(key)
    end)
    
    if success then
        if data then
            print("✅ تم استعادة بيانات اللاعب: " .. player.Name)
            return data
        else
            print("🆕 لاعب جديد، يتم إنشاء بيانات افتراضية لـ: " .. player.Name)
            return DEFAULT_DATA
        end
    else
        warn("⚠️ خطأ في الاتصال بسيرفرات روبلوكس أثناء تحميل بيانات: " .. player.Name)
        return nil
    end
end

-- [2] دالة حفظ البيانات (Save Data)
function DataPersistence.SaveData(player, dataToSave)
    local userId = player.UserId
    local key = "Player_" .. userId
    
    local success, err = pcall(function()
        GameDataStore:SetAsync(key, dataToSave)
    end)
    
    if success then
        print("💾 تم حفظ بيانات اللاعب " .. player.Name .. " بنجاح.")
    else
        warn("❌ فشل حفظ بيانات اللاعب " .. player.Name .. ". الخطأ: " .. err)
    end
    
    return success
end

-- [3] دالة تحديث قيمة معينة (مثل إضافة عملات أو ترقية اشتراك)
-- تستخدم لضمان عدم ضياع البيانات عند التعديل السريع
function DataPersistence.UpdateValue(player, keyName, newValue)
    -- هذه الوظيفة اختيارية وتستخدم للتعديلات المباشرة
    local data = DataPersistence.LoadData(player)
    if data and data[keyName] ~= nil then
        data[keyName] = newValue
        DataPersistence.SaveData(player, data)
    end
end

-- تصدير الموديول
return DataPersistence
