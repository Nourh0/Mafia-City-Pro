-- GameManager.lua
-- الدور: المحرك الرئيسي (The Engine)
-- الموقع: ServerScriptService

local GameManager = {}

-- [1] استدعاء كافة الوحدات (Modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

-- استدعاء الوحدات الأساسية
local Config             = require(Modules:WaitForChild("Config"))
local DataPersistence    = require(Modules:WaitForChild("DataPersistence"))
local EliminationManager = require(Modules:WaitForChild("EliminationManager"))

-- إضافة سطر نظام حماية الهوية (IdentityProtector)
local IdentityProtector  = require(Modules:WaitForChild("IdentityProtector"))

-- وحدات مستقبلية (موقوفة حالياً)
-- local RoleDistributor = require(Modules:WaitForChild("RoleDistributor"))
-- local NewsSystem      = require(Modules:WaitForChild("NewsSystem"))

-- [2] متغيرات الحالة العامة
local CurrentRound = 0
local IsGameRunning = false

-- [3] دالة تشغيل المراحل (Phases)
function GameManager.StartGameLoop()
    IsGameRunning = true
    
    print("🎲 جاري توزيع الأدوار على اللاعبين...")
    -- RoleDistributor.AssignRoles() 
    
    while IsGameRunning do
        CurrentRound = CurrentRound + 1
        print("🚩 بداية الجولة رقم: " .. CurrentRound)

        -- المرحلة 1: الليل
        GameManager.RunNightPhase()

        -- المرحلة 2: الأخبار
        GameManager.RunNewsPhase()

        -- المرحلة 3: النهار والتصويت
        GameManager.RunDayPhase()
        
        -- فحص شروط الفوز
        -- if EliminationManager.CheckWinConditions() then break end
    end
end

-- [4] تفاصيل مرحلة الليل
function GameManager.RunNightPhase()
    print("🌙 بدأ الليل.. المافيا تتحرك الآن.")
    task.wait(Config.TimeSettings.NightDuration)
end

-- [5] تفاصيل مرحلة الأخبار
function GameManager.RunNewsPhase()
    print("📰 جاري طباعة جريدة الصباح..")
    task.wait(Config.TimeSettings.NewsDuration)
end

-- [6] تفاصيل مرحلة النهار
function GameManager.RunDayPhase()
    print("☀️ بدأ النهار.. وقت النقاش والتصويت.")
    task.wait(Config.TimeSettings.DayDuration)
end

-- [7] تشغيل السيرفر (Initialization)
function GameManager.Initialize()
    print("⚙️ يتم الآن تهيئة سيرفر مافيا سيتي...")

    -- تفعيل نظام استقبال اللاعبين وحفظ بياناتهم وتأمين هوياتهم
    IdentityProtector.Init() 
    print("🛡️ تم تفعيل نظام حماية الهوية والأمان.")

    game.Players.PlayerAdded:Connect(function(player)
        -- إعداد الخصائص الأولية الإضافية التي يحتاجها المحرك
        player:SetAttribute("IsAlive", true)
        print("👋 أهلاً بك " .. player.Name .. " في مدينة المافيا!")
    end)
end

-- البدء الفعلي للمحرك
GameManager.Initialize()

-- ملاحظة: StartGameLoop تُستدعى عادةً بعد اكتمال عدد اللاعبين
-- task.spawn(GameManager.StartGameLoop) 

return GameManager
