-- Modules/EliminationManager.lua
-- نظام التصفية وحسم الجولات (EliminationManager)
-- الوظيفة: تنفيذ الإعدام، تحويل اللاعبين لمشاهدين، وفحص شروط الفوز

local EliminationManager = {}

-- [1] الخدمات والاعتمادات
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

-- [2] دالة تصفية اللاعب (EliminatePlayer)
-- يتم استدعاؤها عند القتل في الليل أو الإعدام بالتصويت في النهار
function EliminationManager.EliminatePlayer(player, reason)
    if not player then return end

    -- تحديث حالة اللاعب برمجياً إلى "ميت"
    player:SetAttribute("IsAlive", false)
    player:SetAttribute("CanVote", false)
    player:SetAttribute("CanChatInPublic", false)

    -- إرسال رسالة مخصصة بناءً على سبب الوفاة
    local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
    local message = ""
    
    if reason == "Mafia" then
        message = "💀 عُثر على " .. player.Name .. " مقتولاً في منزله.. يبدو أنها المافيا!"
    elseif reason == "Vote" then
        message = "⚖️ قرر الشعب إعدام " .. player.Name .. " بعد جلسة تصويت طويلة."
    else
        message = "👻 غادر " .. player.Name .. " عالم الأحياء لأسباب غامضة."
    end

    print(message)
    NotificationManager.BroadcastRoundEvent(message, true)

    -- تحويل اللاعب لوضع المشاهد (نقل الشخصية)
    EliminationManager.HandleSpectatorMode(player)

    -- فحص هل انتهت اللعبة بعد هذا الموت؟
    return EliminationManager.CheckWinConditions()
end

-- [3] وضع المشاهد (Spectator Mode)
function EliminationManager.HandleSpectatorMode(player)
    local character = player.Character
    if character then
        -- نقل اللاعب بعيداً عن طاولة الاجتماع (إلى منطقة مرتفعة أو مقبرة)
        character:MoveTo(Vector3.new(0, 100, 0)) 
        
        -- إخفاء الشخصية أو جعلها شفافة (اختياري)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.CanCollide = false
            end
        end
    end
    print("🎥 " .. player.Name .. " انتقل الآن إلى وضع المشاهد.")
end

-- [4] فحص شروط الفوز (Checking Win Conditions)
function EliminationManager.CheckWinConditions()
    local aliveMafia = 0
    local aliveCitizens = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p:GetAttribute("IsAlive") == true then
            local role = p:GetAttribute("Role")
            
            if role == "Mafia" or role == "Godfather" then
                aliveMafia = aliveMafia + 1
            else
                aliveCitizens = aliveCitizens + 1
            end
        end
    end

    -- منطق حسم الجولة
    if aliveMafia == 0 then
        EliminationManager.DeclareVictory("Citizens")
        return true
    elseif aliveMafia >= aliveCitizens then
        EliminationManager.DeclareVictory("Mafia")
        return true
    end
    
    return false -- اللعبة مستمرة
end

-- [5] إعلان الفريق الفائز
function EliminationManager.DeclareVictory(winner)
    local NotificationManager = require(Modules:WaitForChild("NotificationManager"))
    
    if winner == "Citizens" then
        print("🎉 النصر للمواطنين!")
        NotificationManager.BroadcastRoundEvent("🏆 مبروك! انتصر المواطنون وتم تطهير المدينة.", false)
    elseif winner == "Mafia" then
        print("🌑 انتصرت المافيا!")
        NotificationManager.BroadcastRoundEvent("🏆 سقطت المدينة.. فازت المافيا بالسيطرة الكاملة.", true)
    end

    -- هنا يمكنك إضافة إعادة تشغيل السيرفر بعد وقت قصير
end

return EliminationManager
