-- Modules/JudgeSystem.lua
-- نظام القاضي والمطرقة (JudgeSystem)
-- هذا الملف يدير صلاحيات القاضي، وزن تصويته، وميكانيكية "المطرقة"

local JudgeSystem = {}

-- [1] الخدمات الأساسية
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] استدعاء الإعدادات
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = require(Modules:WaitForChild("Config"))

-- [3] متغيرات الحالة القضائية
JudgeSystem.IsHammerTime = false -- هل المحكمة في حالة إصدار حكم؟

-- [4] دالة حساب قوة التصويت (Judicial Vote Weight)
function JudgeSystem.GetVoteWeight(player)
    -- التأكد أن اللاعب هو القاضي وحي
    if player:GetAttribute("Role") == "Judge" and player:GetAttribute("IsAlive") then
        print("⚖️ تم تطبيق قوة تصويت القاضي (X2) لـ " .. player.Name)
        return Config.VotingMechanics.JudgeVoteWeight or 2
    end
    return 1 -- التصويت العادي
end

-- [5] ميزة صمت المحكمة (Silence Mechanic)
-- تستخدم لإيقاف الدردشة العامة أثناء نطق الحكم
function JudgeSystem.SilenceCourt(enable)
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("Role") ~= "Judge" then
            -- إرسال أمر تعطيل الدردشة للواجهة (UI)
            -- يفضل ربطه بنظام TextChatService في روبلوكس
            player:SetAttribute("CanChat", not enable)
        end
    end
    
    local status = enable and "🔇 تم إعلان صمت المحكمة" or "🔊 تم السماح بالحديث"
    print(status)
end

-- [6] نظام المطرقة (The Hammer Logic)
-- يوضع اللاعب المختار تحت المحاكمة (UnderTrial)
function JudgeSystem.ActivateHammer(judge, targetPlayer)
    if not targetPlayer or not targetPlayer:GetAttribute("IsAlive") then return end
    
    if judge:GetAttribute("Role") == "Judge" then
        JudgeSystem.IsHammerTime = true
        targetPlayer:SetAttribute("UnderTrial", true)
        
        -- [7] تكامل التميز (Premium Integration - 150 SAR)
        local subStatus = judge:GetAttribute("SubStatus")
        if subStatus == "Platinum_150" then
            JudgeSystem.ApplyGoldenEffects(targetPlayer)
        end
        
        print("🔨 القاضي " .. judge.Name .. " يطرق المطرقة على " .. targetPlayer.Name)
    end
end

-- [8] التأثيرات البصرية الذهبية (للمشتركين فقط)
function JudgeSystem.ApplyGoldenEffects(target)
    -- كود لإظهار هالة ذهبية أو مطرقة مشعة فوق المتهم
    -- يتم استدعاء ريموت إيفنت لتشغيل جزيئات (Particles) عند اللاعبين
    print("✨ تم تفعيل التأثيرات البصرية الذهبية (فئة البلاتينيوم)")
end

-- [9] إنهاء المحاكمة
function JudgeSystem.EndTrial(targetPlayer)
    JudgeSystem.IsHammerTime = false
    if targetPlayer then
        targetPlayer:SetAttribute("UnderTrial", false)
    end
    JudgeSystem.SilenceCourt(false)
end

return JudgeSystem
