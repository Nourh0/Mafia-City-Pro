-- Modules/EliminationManager.lua
-- نظام التصفية وحسم الجولات (EliminationManager)

local EliminationManager = {}

-- الخدمات
local Players = game:GetService("Players")

-- استدعاء الوحدات الأخرى (يفترض وجودها في نفس المجلد)
-- local NotificationManager = require(script.Parent.NotificationManager)
-- local Config = require(script.Parent.Config)

-- [1] دالة تصفية اللاعب (EliminatePlayer)
function EliminationManager.EliminatePlayer(player, reason)
    if not player then return end
    
    -- تحديث الحالة إلى "ميت" برمجياً
    player:SetAttribute("IsAlive", false)
    
    -- إرسال رسالة مخصصة بناءً على سبب الوفاة
    local message = ""
    if reason == "Mafia" then
        message = "💀 تم العثور على " .. player.Name .. " مقتولاً في منزله.. يبدو أنها المافيا!"
    elseif reason == "Vote" then
        message = "⚖️ قرر الشعب إعدام " .. player.Name .. " بعد جلسة تصويت طويلة."
    else
        message = "👻 " .. player.Name .. " غادر عالم الأحياء لأسباب غامضة."
    end
    
    print(message)
    -- NotificationManager.Broadcast(message) -- تفعيل هذا السطر عند جاهزية نظام التنبيهات

    -- تحويل اللاعب إلى وضع المشاهد
    EliminationManager.HandleSpectatorMode(player)
    
    -- فحص شروط الفوز فوراً بعد كل تصفية
    EliminationManager.CheckWinConditions()
end

-- [2] نظام وضع المشاهد (Spectator Mode)
function EliminationManager.HandleSpectatorMode(player)
    local character = player.Character
    if character then
        -- جعل الشخصية شفافة أو نقلها لمكان بعيد (مقبرة اللاعبين أو غرفة المشاهدة)
        character:MoveTo(Vector3.new(0, 100, 0)) -- مثال لنقله لمنطقة مرتفعة
        
        -- منع اللاعب من التفاعل مع الأحياء (إخفاء خيارات التصويت وغيرها)
        player:SetAttribute("CanVote", false)
        player:SetAttribute("CanChatInPublic", false)
    end
    print("🎥 " .. player.Name .. " انتقل الآن إلى وضع المشاهد.")
end

-- [3] فحص شروط الفوز (Win Conditions)
function EliminationManager.CheckWinConditions()
    local aliveMafia = 0
    local aliveCitizens = 0
    
    for _, p in pairs(Players:GetPlayers()) do
        if p:GetAttribute("IsAlive") == true then
            local role = p:GetAttribute("Role") -- يفترض أن الدور مسجل مسبقاً
            
            -- تصنيف الأدوار (يمكن ربطها بملف Config لاحقاً)
            if role == "Mafia" or role == "Godfather" then
                aliveMafia = aliveMafia + 1
            else
                aliveCitizens = aliveCitizens + 1
            end
        end
    end
    
    -- حسم الجولة
    if aliveMafia == 0 then
        EliminationManager.DeclareVictory("Citizens")
    elseif aliveMafia >= aliveCitizens then
        EliminationManager.DeclareVictory("Mafia")
    end
end

-- [4] إعلان الفريق الفائز
function EliminationManager.DeclareVictory(winner)
    if winner == "Citizens" then
        print("🎉 النصر للمواطنين! تم تطهير المدينة من المافيا.")
        -- NotificationManager.Broadcast("🏆 فاز المواطنون!")
    elseif winner == "Mafia" then
        print("🌑 انتصرت المافيا! لقد سيطروا على المدينة بالكامل.")
        -- NotificationManager.Broadcast("🏆 فازت المافيا!")
    end
    
    -- هنا يتم استدعاء نظام إعادة تشغيل الجولة
    -- RoundCycleManager.EndRound()
end

return EliminationManager
