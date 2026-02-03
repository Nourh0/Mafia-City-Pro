-- Modules/NotificationManager.lua
-- نظام التنبيهات وإدارة الدردشة (NotificationManager)
-- الوظيفة: إدارة الرسائل السرية، إعلانات الترقيات، وتنسيق ألقاب الدردشة الملونة

local NotificationManager = {}

-- [1] الخدمات الأساسية
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- التأكد من وجود مجلد الأحداث والحدث المطلوب
local Events = ReplicatedStorage:WaitForChild("Events")
local NotificationEvent = Events:FindFirstChild("NotificationEvent") or Instance.new("RemoteEvent", Events)
NotificationEvent.Name = "NotificationEvent"

-- [2] إعدادات الألوان بصيغة Hex للـ RichText
local COLORS = {
    GOLD = "#FFD700",      -- لفئة Elite (250 SAR) والترقيات
    SILVER = "#C0C0C0",    -- لفئة Platinum (150 SAR)
    RED = "#FF3131",       -- للمافيا والتنبيهات الخطيرة
    JUDGE = "#1E90FF",     -- للقاضي والتنبيهات الرسمية
    SUCCESS = "#00FF7F"    -- للنجاح والجوائز
}

-- [3] إرسال تنبيه خاص (Confidential Role Messages)
-- يرسل رسالة سرية تظهر فقط للاعب المعني (مثل المافيا أو القاضي)
function NotificationManager.SendPrivate(player, message, colorType)
    local color = COLORS[colorType] or COLORS.JUDGE
    local richText = string.format('<font color="%s"><b>[سري]:</b> %s</font>', color, message)
    
    NotificationEvent:FireClient(player, richText)
end

-- [4] إعلانات الاحتفالات العامة (Public Celebrations)
-- تنبيه ترقية المستوى (Level Up)
function NotificationManager.AnnounceLevelUp(player, newLevel)
    local message = string.format("🌟 مبروك! اللاعب %s وصل إلى المستوى [%d]!", player.Name, newLevel)
    local richText = string.format('<font color="%s"><b>%s</b></font>', COLORS.GOLD, message)
    
    NotificationEvent:FireAllClients(richText)
end

-- تنبيه الاشتراكات الجديدة (Subscriptions 250/150 SAR)
function NotificationManager.AnnounceSubscription(player, tier)
    local tierName = ""
    local color = ""
    
    if tier == 250 then
        tierName = "ELITE"
        color = COLORS.GOLD
    elseif tier == 150 then
        tierName = "PLATINUM"
        color = COLORS.SILVER
    end
    
    local message = string.format("💎 رحبوا بـ %s الجديد: [%s]! شكراً لدعمك للمدينة.", tierName, player.Name)
    local richText = string.format('<font color="%s"><b>%s</b></font>', color, message)
    
    NotificationEvent:FireAllClients(richText)
end

-- [5] تنسيق هوية الدردشة (Chat Identity)
-- يضيف ألقاب ملونة بجانب اسم اللاعب في الدردشة بناءً على نوع العضوية
function NotificationManager.GetChatTag(player)
    local subStatus = player:GetAttribute("SubStatus") -- "Premium" أو "Platinum"
    local tag = ""
    
    if subStatus == "Premium" then
        tag = string.format('<font color="%s">[ELITE]</font> ', COLORS.GOLD)
    elseif subStatus == "Platinum" then
        tag = string.format('<font color="%s">[PLATINUM]</font> ', COLORS.SILVER)
    else
        tag = '<font color="#FFFFFF">[GUEST]</font> '
    end
    
    return tag
end

-- [6] بث رسالة جولة (Round Announcements)
function NotificationManager.BroadcastRoundEvent(message, isUrgent)
    local color = isUrgent and COLORS.RED or COLORS.JUDGE
    local richText = string.format('<font color="%s"><b>[المدينة]:</b> %s</font>', color, message)
    
    NotificationEvent:FireAllClients(richText)
end

return NotificationManager
