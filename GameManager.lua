-- GameManager.lua
-- الدور: المحرك الرئيسي (The Engine)
-- الموقع: Project Root (يُفضل وضعه في ServerScriptService)

local GameManager = {}

-- [1] استدعاء كافة الوحدات (Modules)
-- ملاحظة: تأكد من أن مجلد Modules موجود في ReplicatedStorage أو نفس مكان السكريبت
local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")

local Config             = require(Modules:WaitForChild("Config"))
local DataPersistence    = require(Modules:WaitForChild("DataPersistence"))
local EliminationManager = require(Modules:WaitForChild("EliminationManager"))
-- الوحدات التالية يتم استدعاؤها عند الحاجة (مثل الروابط المستقبلية)
-- local RoleDistributor = require(Modules:WaitForChild("RoleDistributor"))
-- local NewsSystem      = require(Modules:WaitForChild("NewsSystem"))

-- [2] متغيرات الحالة العامة
local CurrentRound = 0
local IsGameRunning = false

-- [3] دالة تشغيل المراحل (Phases)
function GameManager.StartGameLoop()
    IsGameRunning = true
    
    -- الخطوة الأولى: توزيع الأدوار عند بداية اللعبة
    print("🎲 جاري توزيع الأدوار على اللاعبين...")
    -- RoleDistributor.AssignRoles() -- سيتم تفعيله في الخطوة القادمة
    
    while IsGameRunning do
        CurrentRound = CurrentRound + 1
        print("🚩 بداية الجولة رقم: " .. CurrentRound)

        -- الفصيلة 1: مرحلة الليل (Night Phase)
        GameManager.RunNightPhase()

        -- الفصيلة 2: مرحلة الأخبار (News Phase)
        GameManager.RunNewsPhase()

        -- الفصيلة 3: مرحلة النهار والتصويت (Day Phase)
        GameManager.RunDayPhase()
        
        -- فحص هل انتهت اللعبة؟
        -- if EliminationManager.CheckWinConditions() then break end
    end
end

-- [4] تفاصيل مرحلة الليل
function GameManager.RunNightPhase()
    print("🌙 بدأ الليل.. المافيا تتحرك الآن.")
    -- إخطار اللاعبين عبر الـ UI (سيتم ربطه لاحقاً)
    
    task.wait(Config.TimeSettings.NightDuration)
end

-- [5] تفاصيل مرحلة الأخبار
function GameManager.RunNewsPhase()
    print("📰 جاري طباعة جريدة الصباح..")
    -- NewsSystem.ShowResults() -- سيتم ربطه لاحقاً
    
    task.wait(Config.TimeSettings.NewsDuration)
end

-- [6] تفاصيل مرحلة النهار
function GameManager.RunDayPhase()
    print("☀️ بدأ النهار.. وقت النقاش والتصويت.")
    -- تفعيل نظام التصويت
    -- VotingSystem.StartVoting() 
    
    task.wait(Config.TimeSettings.DayDuration)
end

-- [7] تشغيل السيرفر (Initialization)
function GameManager.Initialize()
    print("⚙️ يتم الآن تهيئة سيرفر مافيا سيتي...")
    
    game.Players.PlayerAdded:Connect(function(player)
        -- تحميل بيانات اللاعب من الخزنة
        local data = DataPersistence.LoadData(player)
        
        -- إعداد الخصائص الأولية
        player:SetAttribute("IsAlive", true)
        player:SetAttribute("Level", data.Level or 1)
        
        print("Welcome " .. player.Name .. " to Mafia City!")
    end)
end

-- البدء الفعلي
GameManager.Initialize()

-- ملاحظة: في اللعبة الفعلية، يتم استدعاء StartGameLoop عند اكتمال عدد اللاعبين
-- GameManager.StartGameLoop() 

return GameManager
