-- Location: ReplicatedStorage/Modules/MafiaChat.lua
-- الإصدار المصحح: نظام دردشة المافيا السري مع فلترة النصوص والتحقق من الأدوار

local MafiaChat = {}

-- [1] الخدمات الأساسية
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] إعدادات الفريق الشرير (Villain Team)
local VILLAIN_ROLES = {
    ["Mafia"] = true,
    ["Godfather"] = true,
    ["Spy"] = true
}

-- [3] دالة فلترة النصوص (Roblox Policy Requirement)
-- هذه الدالة تضمن عدم مخالفة قوانين روبلوكس وتمنع النصوص غير اللائقة
local function FilterMessage(message, senderId)
    local filteredText = ""
    local success, err = pcall(function()
        local filterResult = TextService:FilterStringAsync(message, senderId)
        -- نستخدم الفلترة العامة المناسبة لجميع المستخدمين في الدردشة الجماعية
        filteredText = filterResult:GetNonChatStringForBroadcastAsync()
    end)

    if success then
        return filteredText
    else
        warn("❌ فشلت فلترة الرسالة: " .. tostring(err))
        return nil
    end
end

-- [4] دالة إرسال الرسالة السرية (SendPrivateMessage)
function MafiaChat.SendPrivateMessage(sender, message)
    if not sender or message == "" then return end

    -- أ. التحقق من هوية المرسل (يجب أن يكون من الأشرار وحياً)
    local role = sender:GetAttribute("Role")
    local isAlive = sender:GetAttribute("IsAlive")

    if not VILLAIN_ROLES[role] then
        warn("🚫 محاولة اختراق: لاعب غير مصرح له حاول استخدام دردشة المافيا! اللاعب: " .. sender.Name)
        return
    end

    if isAlive == false then
        warn("🚫 الأموات لا يتحدثون! اللاعب: " .. sender.Name)
        return
    end

    -- ب. معالجة فلترة النص قبل البث
    local filteredMessage = FilterMessage(message, sender.UserId)
    if not filteredMessage then return end

    -- ج. تحديد المستلمين (الأشرار الأحياء فقط) وتنسيق الرسالة
    local messageFormat = "🌑 [SECRET] " .. sender.Name .. ": " .. filteredMessage
    local Events = ReplicatedStorage:WaitForChild("Events")
    local MafiaChatEvent = Events:FindFirstChild("MafiaChatEvent")

    if MafiaChatEvent then
        for _, player in ipairs(Players:GetPlayers()) do
            local pRole = player:GetAttribute("Role")
            local pAlive = player:GetAttribute("IsAlive")

            -- إرسال الرسالة فقط للأعضاء المصرح لهم (أشرار وأحياء)
            if VILLAIN_ROLES[pRole] and pAlive ~= false then
                MafiaChatEvent:FireClient(player, messageFormat)
            end
        end
        print("📢 تم إرسال رسالة مافيا مشفرة بنجاح من: " .. sender.Name)
    else
        warn("❌ خطأ: لم يتم العثور على MafiaChatEvent في مجلد Events!")
    end
end

-- [5] تهيئة نظام الاستماع (Initialization)
function MafiaChat.Init()
    local Events = ReplicatedStorage:WaitForChild("Events")
    -- التأكد من وجود الحدث أو إنشاؤه
    local MafiaChatEvent = Events:FindFirstChild("MafiaChatEvent") or Instance.new("RemoteEvent", Events)
    MafiaChatEvent.Name = "MafiaChatEvent"

    -- ربط استقبال الرسائل من اللاعبين بالدالة البرمجية
    MafiaChatEvent.OnServerEvent:Connect(function(player, message)
        MafiaChat.SendPrivateMessage(player, message)
    end)

    print("✅ نظام MafiaChat المصحح جاهز للعمل مع نظام الفلترة.")
end

return MafiaChat
