-- Modules/IdentityProtector.lua
-- نظام حماية الهويات (IdentityProtector)
-- الوظيفة: حماية الأدوار من الغش، وتأمين حفظ البيانات عند المغادرة

local IdentityProtector = {}

-- [1] الخدمات الأساسية
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] استدعاء موديول حفظ البيانات
-- ملاحظة: يفترض وجود ملف DataPersistence في نفس مجلد Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DataPersistence = require(Modules:WaitForChild("DataPersistence"))

-- [3] دالة تشفير الهوية الابتدائية (Role Encryption)
-- تمنع "الهكرز" من معرفة الأدوار عبر فحص خصائص اللاعب
function IdentityProtector.MaskPlayerIdentity(player)
    player:SetAttribute("Role", "Hidden") -- تشفير برمجي
    player:SetAttribute("IsMasked", true)
    print("🔒 تم تفعيل القناع البرمجي للاعب: " .. player.Name)
end

-- [4] إرسال تعليمات آمنة (Secure Messaging)
-- ترسل رسائل خاصة للأدوار (مثل المافيا) دون أن تظهر للجميع
function IdentityProtector.SendSecureInstruction(player, instruction)
    -- تأكد من وجود مجلد Events و RemoteEvent باسم SecureNotify في ReplicatedStorage
    local Events = ReplicatedStorage:FindFirstChild("Events")
    if Events then
        local SecureEvent = Events:FindFirstChild("SecureNotify")
        if SecureEvent then
            SecureEvent:FireClient(player, instruction)
        end
    end
end

-- [5] استقبال اللاعب وتأمين بياناته (Automated Load)
function IdentityProtector.OnPlayerJoined(player)
    print("🛡️ حارس البوابة: يتم الآن استقبال " .. player.Name)
    
    -- تحميل البيانات من الخزنة عبر موديول DataPersistence
    local savedData = DataPersistence.LoadData(player)
    
    if savedData then
        -- نقل البيانات إلى Attributes لسهولة قراءتها من بقية الأنظمة
        player:SetAttribute("Level", savedData.Level or 1)
        player:SetAttribute("XP", savedData.XP or 0)
        player:SetAttribute("Coins", savedData.Coins or 0)
        player:SetAttribute("SubStatus", savedData.SubStatus or "None")
        player:SetAttribute("Role", "Hidden") -- حماية الدور افتراضياً
        player:SetAttribute("IsAlive", true)  -- تعيين الحالة كحي عند الدخول
    end
end

-- [6] تأمين الخروج وحفظ البيانات (Safe Exit)
function IdentityProtector.OnPlayerLeaving(player)
    print("🚪 حارس البوابة: تأمين خروج " .. player.Name)
    
    -- جمع القيم الحالية من Attributes لحفظها
    local dataToSave = {
        Level = player:GetAttribute("Level") or 1,
        XP = player:GetAttribute("XP") or 0,
        Coins = player:GetAttribute("Coins") or 0,
        SubStatus = player:GetAttribute("SubStatus") or "None"
    }
    
    -- استدعاء دالة الحفظ
    local success = DataPersistence.SaveData(player, dataToSave)
    
    if success then
        print("💾 تم حفظ بيانات " .. player.Name .. " بنجاح قبل المغادرة.")
    else
        warn("⚠️ خطأ: تعذر حفظ بيانات " .. player.Name)
    end
end

-- [7] الربط بالأحداث (Initialization)
-- هذه الدالة يتم استدعاؤها مرة واحدة عند تشغيل السيرفر
function IdentityProtector.Init()
    -- ربط أحداث الدخول والخروج بالوظائف البرمجية
    Players.PlayerAdded:Connect(IdentityProtector.OnPlayerJoined)
    Players.PlayerRemoving:Connect(IdentityProtector.OnPlayerLeaving)
    
    -- معالجة اللاعبين الموجودين أصلاً (في حال إعادة تشغيل السكريبت)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            IdentityProtector.OnPlayerJoined(player)
        end)
    end
    
    print("✅ تم تفعيل نظام IdentityProtector بنجاح.")
end

return IdentityProtector
