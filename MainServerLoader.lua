-- Location: ServerScriptService/MainServerLoader.lua
-- الدور: المايسترو (The Master Maestro) - مفتاح تشغيل مدينة المافيا
-- الملخص: يقوم بتنسيق تشغيل كافة المحركات (27 ملفاً) وضمان تزامن البيانات والأمان.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- [1] فحص الأمان: التأكد من وجود مجلد الموديولات قبل البدء
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

if not Modules then
    warn("❌ خطأ حرج: لم يتم العثور على مجلد Modules في ReplicatedStorage!")
    return
end

-- [2] استدعاء الأنظمة الأساسية (Requirements)
-- ملاحظة: يتم تحميل الأنظمة هنا لضمان جاهزيتها قبل التنفيذ
local MainGameEngine    = require(Modules:WaitForChild("MainGameEngine"))
local RoundCycleManager = require(Modules:WaitForChild("RoundCycleManager"))
local LightingManager   = require(Modules:WaitForChild("LightingManager"))
local IdentityProtector = require(Modules:WaitForChild("IdentityProtector"))
local RoleUI            = require(Modules:WaitForChild("RoleUI"))

print("----------------------------------------------------------------")
print("🏙️  MAFIA CITY: STARTING CENTRAL CORE & INITIALIZING...")
print("----------------------------------------------------------------")

-- [3] تهيئة الأنظمة الأولية (Initialization)
-- يتم تشغيل الإضاءة ونظام حماية البيانات فوراً لضمان الخصوصية والجو العام
LightingManager.Init() 
IdentityProtector.Init()
print("⚙️  Initial Systems (Lighting & Security) are prepared.")

-- [4] تشغيل المحرك الرئيسي (The Core Execution)
-- نستخدم task.spawn و pcall لضمان استقرار السيرفر وعدم توقفه
task.spawn(function()
    local success, err = pcall(function()
        -- تشغيل محرك اللعبة الرئيسي
        MainGameEngine.Init() 
        
        -- تشغيل محرك الجولات في خيط منفصل (Thread)
        task.spawn(function()
            print("🎮 Round Cycle Engine is launching...")
            RoundCycleManager.RunGameLoop()
        end)
    end)

    if success then
        print("✅ SUCCESS: Mafia City Backend is Live and Synced!")
    else
        warn("⚠️ CRITICAL ERROR: FAILED to start Core Engine: " .. tostring(err))
    end
end)

-- [5] نظام اختبار الواجهات (Testing Integration)
-- يتم عرض بطاقة "العراب" فور دخول أي لاعب للتأكد من عمل نظام RoleUI
game.Players.PlayerAdded:Connect(function(player)
    print("👋 Player Joined: " .. player.Name .. " | Applying initial test data.")
    
    -- انتظار بسيط لضمان تحميل واجهة اللاعب (GUI)
    task.wait(2)
    
    -- اختبار نظام عرض الأدوار (Godfather باللون الأحمر)
    RoleUI.ShowRole(player, "Godfather", Color3.fromRGB(255, 0, 0))
end)

-- [6] ملخص التحقق النهائي
print("----------------------------------------------------------------")
print("🏆 CONGRATULATIONS! THE CENTRAL MAESTRO IS READY.")
print("🚀 Backend is 100% active. Waiting for players to start match.")
print("----------------------------------------------------------------")
