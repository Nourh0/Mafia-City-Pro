-- Location: ReplicatedStorage/Modules/VotingSystem.lua
-- الإصدار المصحح النهائي: نظام التصويت المتوافق مع صلاحيات القاضي وحالة اللاعبين

local VotingSystem = {}

-- [1] الخدمات والاعتمادات
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

-- [2] متغيرات تخزين الأصوات
local currentVotes = {}      -- تخزين الأصوات (الاسم = عدد الأصوات)
local isVotingActive = false
local playersWhoVoted = {}   -- تتبع اللاعبين الذين أدلوا بأصواتهم لمنع التكرار

-- [3] دالة بدء التصويت (StartVoting)
-- تقوم بتصفير البيانات لضمان عدم تداخل الأصوات بين الجولات
function VotingSystem.StartVoting()
    currentVotes = {}
    playersWhoVoted = {}
    isVotingActive = true
    print("🗳️ بدأ نظام التصويت: بانتظار أصوات اللاعبين الأحياء...")
end

-- [4] دالة تسجيل الصوت (CastVote)
-- voter: اللاعب المصوت | target: اللاعب المراد إقصاؤه
function VotingSystem.CastVote(voter, target)
    -- أ. التحقق من حالة نظام التصويت
    if not isVotingActive then
        warn("⚠️ التصويت مغلق حالياً.")
        return
    end

    -- ب. [تصحيح حرج]: التحقق من أن المصوت لا يزال حياً
    if voter:GetAttribute("IsAlive") == false then
        warn("🚫 " .. voter.Name .. " حاول التصويت وهو ميت!")
        return
    end

    -- ج. التحقق من عدم تكرار التصويت
    if playersWhoVoted[voter.UserId] then
        warn("🚫 " .. voter.Name .. " حاول التصويت أكثر من مرة.")
        return
    end

    -- د. التحقق من إعدادات منع التصويت للنفس
    if not Config.VotingMechanics.AllowSelfVote and voter == target then
        warn("🚫 لا يمكنك التصويت لنفسك حسب إعدادات السيرفر.")
        return
    end

    -- هـ. [تصحيح حرج]: حساب قوة الصوت بناءً على السمة الموحدة "Role"
    local voteWeight = 1
    if voter:GetAttribute("Role") == "Judge" then
        voteWeight = Config.VotingMechanics.JudgeVoteWeight or 2
        print("⚖️ القاضي " .. voter.Name .. " أدلى بصوته (قوة مضاعفة: " .. voteWeight .. ").")
    end

    -- و. تسجيل الصوت في الجدول
    local targetName = target.Name
    currentVotes[targetName] = (currentVotes[targetName] or 0) + voteWeight
    playersWhoVoted[voter.UserId] = true

    print("✅ " .. voter.Name .. " صوت ضد " .. targetName .. " (قوة مضافة: " .. voteWeight .. ")")
end

-- [5] دالة استخراج النتيجة (GetResult)
-- خوارزمية البحث عن "الأعلى تصويتاً" مع معالجة حالات التعادل
function VotingSystem.GetResult()
    isVotingActive = false
    local winnerName = nil
    local maxVotes = 0
    local isTie = false

    for targetName, voteCount in pairs(currentVotes) do
        if voteCount > maxVotes then
            maxVotes = voteCount
            winnerName = targetName
            isTie = false
        elseif voteCount == maxVotes then
            isTie = true -- حالة تعادل
        end
    end

    if isTie then
        print("⚖️ النتيجة: تعادل! لن يتم إعدام أحد في هذه الجولة.")
        return nil
    elseif winnerName then
        print("⚖️ النتيجة النهائية: إعدام " .. winnerName .. " بـ " .. maxVotes .. " صوت.")
        return winnerName
    else
        print("⚖️ النتيجة: لم يتم الإدلاء بأي أصوات.")
        return nil
    end
end

return VotingSystem
