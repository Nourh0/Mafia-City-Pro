-- Modules/RoleManager.lua
-- نظام إدارة وتوزيع الأدوار المتقدم (Advanced Role Manager)
-- الوظيفة: توزيع الأدوار بناءً على احتمالات الاشتراك (60/40) وضمان العشوائية

local RoleManager = {}

-- [1] إعدادات الاحتمالات بناءً على فئة الاشتراك
local TIER_LOGIC = {
    ["Premium_250"] = { -- فئة Elite
        PriorityRoles = {"Mafia", "Godfather"}, -- أدوار القيادة والسيطرة
        Probability = 60 -- احتمال 60% للحصول على دور قيادي
    },
    ["Platinum_150"] = { -- فئة Platinum
        PriorityRoles = {"Judge", "Mafia"}, -- أدوار العدالة والمافيا
        Probability = 60 -- احتمال 60% للحصول على دور خاص
    }
}

-- [2] دالة خلط الجدول (Shuffle) لضمان العشوائية الكاملة
local function ShuffleTable(t)
    math.randomseed(os.time() ^ math.random()) -- تأمين بذور عشوائية متغيرة
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- [3] الدالة الرئيسية لتوزيع الأدوار (AssignRoles)
function RoleManager.AssignRoles(players)
    if #players == 0 then return end

    -- أ. تجهيز سلة الأدوار المتاحة (Role Pool)
    local rolePool = {}
    local totalPlayers = #players
    
    -- حساب عدد المافيا (1 لكل 4 لاعبين بحد أدنى 1)
    local mafiaCount = math.max(1, math.floor(totalPlayers / 4))
    table.insert(rolePool, "Godfather") -- زعيم واحد
    for i = 1, mafiaCount - 1 do table.insert(rolePool, "Mafia") end
    
    table.insert(rolePool, "Judge")     -- قاضي واحد
    table.insert(rolePool, "Doctor")    -- طبيب واحد
    table.insert(rolePool, "Detective") -- محقق واحد
    
    -- ملء بقية الأدوار بالمواطنين (Citizens)
    while #rolePool < totalPlayers do
        table.insert(rolePool, "Citizen")
    end
    
    rolePool = ShuffleTable(rolePool) -- خلط الأدوار أولاً

    -- ب. مصفوفة تتبع الأدوار التي تم حجزها
    local assignedPlayers = {} -- اللاعبين الذين استلموا أدواراً
    local roleCounts = {} -- تتبع عدد الأدوار الموزعة من كل نوع
    
    for _, role in ipairs(rolePool) do
        roleCounts[role] = (roleCounts[role] or 0) + 1
    end

    -- ج. المرحلة الأولى: محاولة إعطاء المشتركين أدوارهم المفضلة (60% Probability)
    for _, player in ipairs(players) do
        local subStatus = player:GetAttribute("SubStatus") or "Guest"
        local logic = TIER_LOGIC[subStatus]

        if logic then
            local roll = math.random(1, 100)
            if roll <= logic.Probability then
                -- محاولة إيجاد دور متاح من قائمة الأولوية
                for _, prefRole in ipairs(logic.PriorityRoles) do
                    if roleCounts[prefRole] and roleCounts[prefRole] > 0 then
                        player:SetAttribute("CurrentRole", prefRole)
                        roleCounts[prefRole] = roleCounts[prefRole] - 1
                        assignedPlayers[player.UserId] = true
                        print("💎 " .. player.Name .. " (" .. subStatus .. ") فاز بالقرعة: " .. prefRole)
                        break
                    end
                end
            end
        end
    end

    -- د. المرحلة الثانية: توزيع بقية الأدوار على اللاعبين المتبقين (بما فيهم الـ Guests)
    -- تحديث مصفوفة الأدوار المتبقية
    local remainingRoles = {}
    for role, count in pairs(roleCounts) do
        for i = 1, count do table.insert(remainingRoles, role) end
    end
    remainingRoles = ShuffleTable(remainingRoles)

    local roleIndex = 1
    for _, player in ipairs(players) do
        if not assignedPlayers[player.UserId] then
            local assignedRole = remainingRoles[roleIndex]
            player:SetAttribute("CurrentRole", assignedRole)
            roleIndex = roleIndex + 1
            print("👤 " .. player.Name .. " حصل على دور: " .. assignedRole)
        end
    end

    print("✅ تم الانتهاء من توزيع كافة الأدوار بنجاح.")
end

return RoleManager
