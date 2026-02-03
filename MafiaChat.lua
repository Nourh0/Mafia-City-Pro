-- Modules/MafiaChat.lua
-- نظام دردشة المافيا السري (MafiaChat)
-- الوظيفة: عزل محادثات المافيا والجواسيس عن بقية اللاعبين لتنسيق الهجمات الليلية

local MafiaChat = {}

-- [1] الخدمات الأساسية
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] إعدادات الفريق الشرير (Villain Team)
-- هؤلاء هم اللاعبون الذين يمكنهم رؤية الدردشة السرية
local VILLAIN_ROLES = {
    ["Mafia"] = true,
    ["Godfather"] = true,
    ["Spy"] = true
}

-- [3] إرسال رسالة خاصة (SendPrivateMessage)
-- تقوم الدالة بالتحقق من هوية المرسل وإرسال الرسالة فقط للأعضاء المصرح لهم
function MafiaChat.SendPrivateMessage(sender, message)
    if not sender or message == "" then return end
    
    -- التأكد أن المرسل حي وينتمي لفريق الأشرار
    local senderRole = sender:GetAttribute("Role")
    local isAlive = sender:GetAttribute("IsAlive")
    
    if isAlive and VILLAIN_ROLES[senderRole] then
        -- تنسيق الرسالة (مثال: [دردشة سرية] فلان: الرسالة)
        local formattedMessage = "🌑 [SECRET] " .. sender.Name .. ": " .. message
        
        -- البحث عن كل الأعضاء المصرح لهم (مافيا وجواسيس)
        for _, player in ipairs(Players:GetPlayers()) do
            local playerRole = player:GetAttribute("Role")
            
            -- إرسال الرسالة فقط إذا كان اللاعب من فريق الأشرار
            if VILLAIN_ROLES[playerRole] then
                -- استدعاء RemoteEvent لإظهار الرسالة في واجهة المستخدم (UI) لدى العميل
                local Events = ReplicatedStorage:FindFirstChild("Events")
                if Events then
                    local MafiaChatEvent = Events:FindFirstChild("MafiaChatEvent")
                    if MafiaChatEvent then
                        MafiaChatEvent:FireClient(player, formattedMessage)
                    end
                end
            end
        end
        
        print("🕵️ Mafia Message Sent from: " .. sender.Name)
    else
        warn("⚠️ محاولة اختراق: " .. sender.Name .. " حاول الإرسال في دردشة المافيا!")
    end
end

-- [4] تهيئة نظام الاستماع (Initialization)
-- يتم ربط الـ RemoteEvent بهذا الموديول عند تشغيل السيرفر
function MafiaChat.Init()
    local Events = ReplicatedStorage:WaitForChild("Events")
    local MafiaChatEvent = Events:WaitForChild("MafiaChatEvent")
    
    MafiaChatEvent.OnServerEvent:Connect(function(player, message)
        -- تنظيف النص من أي أحرف غير لائقة (اختياري)
        local filteredMessage = message -- يمكن ربط خدمة ChatFilter هنا
        MafiaChat.SendPrivateMessage(player, filteredMessage)
    end)
    
    print("✅ نظام MafiaChat جاهز للعمل.")
end

return MafiaChat
