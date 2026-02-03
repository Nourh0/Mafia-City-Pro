-- Modules/IdentityProtector.lua
-- نظام حماية الهويات (IdentityProtector)
-- الوظيفة: حماية الأدوار من الغش، وتأمين حفظ البيانات عند المغادرة

local IdentityProtector = {}

-- [1] الخدمات الأساسية
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] استدعاء موديول حفظ البيانات (الملف رقم 19)
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DataPersistence = require(Modules:WaitForChild("DataPersistence"))

-- [3] دالة تشفير الهوية الابتدائية (Role Encryption)
-- يتم استدعاؤها عند بداية الجولة لإخفاء الأدوار عن المخربين
function IdentityProtector.MaskPlayerIdentity(player)
    player:SetAttribute("Role", "Hidden") -- تشفير برمجي لمنع كشف الدور
    player:SetAttribute("IsMasked", true)
    print("🔒 تم تفعيل القناع البرمجي للاعب: " .. player.Name)
end

-- [4] إرسال تعليمات آمنة (Secure Messaging)
-- تضمن وصول الرسائل للمافيا أو القاضي دون ظهورها في السجلات العامة
function IdentityProtector.SendSecureInstruction(player, instruction)
    -- يتم استخدام RemoteEvent خاص هنا لإرسال التوجيهات لواجهة اللاعب فقط
    local SecureEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SecureNotify")
    SecureEvent:FireClient(player, instruction)
    -- ملاحظة: لا يتم طباعة المحتوى في السيرفر لزيادة الأمان
end

-- [5] استقبال اللاعب وتأمين بياناته (Automated Load)
function IdentityProtector.OnPlayerJoined(player)
    print("🛡️ حارس البوابة: يتم الآن استقبال " .. player.Name)
    
    -- تحميل البيانات من الخزنة (DataPersistence)
    local savedData = DataPersistence.LoadData(player)
    
    if savedData then
        -- تطبيق البيانات على Attributes لسهولة الوصول إليها
        player:SetAttribute("Level", savedData.Level or 1)
        player:SetAttribute("XP", savedData.XP or 0)
        player:SetAttribute("Coins", savedData.Coins or 0)
        player:SetAttribute("SubStatus", savedData.SubStatus or "None")
        player:SetAttribute("Role", "Hidden") -- تأمين الدور افتراضياً
    end
end

-- [6] تأمين الخروج وحفظ البيانات (Safe Exit)
function IdentityProtector.OnPlayerLeaving(player)
    print("🚪 حارس البوابة: تأمين خروج " .. player.Name)
    
    -- جمع البيانات الحالية من الـ Attributes قبل خروج اللاعب
    local dataToSave = {
        Level = player:GetAttribute("Level"),
        XP = player:GetAttribute("XP"),
        Coins = player:GetAttribute("Coins"),
        SubStatus = player:GetAttribute("SubStatus")
    }
    
    -- حفظ البيانات فوراً في قاعدة البيانات
    local success = DataPersistence.SaveData(player, dataToSave)
    
    if success then
        print("💾 تم تأمين وحفظ بيانات " .. player.Name .. " بنجاح.")
    else
        warn("⚠️ تحذير: فشل حفظ بيانات " .. player.Name .. " أثناء الخروج!")
    end
end

-- [7] الربط بالأحداث (Initialization)
function IdentityProtector.Init()
    Players.PlayerAdded:Connect(IdentityProtector.OnPlayerJoined)
    Players.PlayerRemoving:Connect(IdentityProtector.OnPlayerLeaving)
end

return IdentityProtector
