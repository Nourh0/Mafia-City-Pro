-- Location: ReplicatedStorage/Modules/RoleManager.lua
-- الإصدار المحدث: نظام إدارة الأدوار المتقدم (مع تصحيح التوافق)
-- الوظيفة: توزيع الأدوار بناءً على احتمالات الاشتراك (60/40) وتوحيد البيانات لجميع الأنظمة

local RoleManager = {}

-- [1] إعدادات الاحتمالات بناءً على فئة الاشتراك (250 و 150 ريال)
local TIER_LOGIC = {
    ["Premium_250"] = { -- فئة النخبة (Elite)
        PriorityRoles = {"Mafia", "Godfather"}, -- أدوار القيادة
        Probability = 60 -- احتمال 60%
    },
    ["Platinum_150"] = { -- فئة البلاتينيوم (Platinum)
        PriorityRoles = {"Judge", "Mafia"}, -- أدوار خاصة
        Probability = 60 -- احتمال 60%
    }
}

-- [2] دالة خلط الجدول لضمان العشوائية الكاملة
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

    print("🎭 جاري توزيع الأدوار على " .. #players .. " لاعب...")

    -- أ. تجهيز سلة الأدوار المتاحة (Role Pool) بناءً على عدد اللاعبين
    local rolePool = {}
    local totalPlayers = #players
    
    -- حساب عدد المافيا (1 لكل 4 لاعبين بحد أدنى 1)
    local mafiaCount = math.max(1, math.floor(totalPlayers / 4))
    
    table.insert(rolePool, "Godfather") -- زعيم واحد ثابت
    for i = 1, mafiaCount - 1 do table.insert(rolePool, "Mafia") end
    
    table.insert(rolePool, "Judge")     -- قاضي واحد ثابت
    table.insert(rolePool, "Doctor")    -- طبيب واحد ثابت
    table.insert(rolePool, "Detective") -- محقق واحد ثابت
    
    -- ملء بقية الأدوار بالمواطنين (Citizens)
    while #rolePool < totalPlayers do
        table.insert(rolePool, "Citizen")
    end
    
    rolePool = ShuffleTable(rolePool)

    -- ب. مصفوفات التتبع
    local assignedPlayers = {} -- اللاعبين الذين استلموا أدواراً
    local roleCounts = {}      -- تتبع كمية كل دور متبقية في السلة
    
    for _, role in ipairs(rolePool) do
        roleCounts[role] = (roleCounts[role] or 0) + 1
    end

    -- ج. المرحلة الأولى: توزيع الأولوية للمشتركين (نظام 60/40)
    for _, player in ipairs(players) do
        local subStatus = player:GetAttribute("SubStatus") or "Guest"
        local logic = TIER_LOGIC[subStatus]

        if logic then
            local roll = math.random(1, 100)
            if roll <= logic.Probability then
                for _, prefRole in ipairs(logic.PriorityRoles) do
                    if roleCounts[prefRole] and roleCounts[prefRole] > 0 then
                        -- [تصحيح حرج]: توحيد الاسم إلى "Role" لضمان التوافق
                        player:SetAttribute("Role", prefRole)
                        player:SetAttribute("IsAlive", true) -- تهيئة الحالة كـ "حي"
                        
                        roleCounts[prefRole] = roleCounts[prefRole] - 1
                        assignedPlayers[player.UserId] = true
                        print("💎 " .. player.Name .. " (" .. subStatus .. ") حصل على دور أولوية: " .. prefRole)
                        break
                    end
                end
            end
        end
    end

    -- د. المرحلة الثانية: توزيع بقية الأدوار عشوائياً (بما فيهم الـ Guests)
    local remainingRoles = {}
    for role, count in pairs(roleCounts) do
        for i = 1, count do table.insert(remainingRoles, role) end
    end
    remainingRoles = ShuffleTable(remainingRoles)

    local roleIndex = 1
    for _, player in ipairs(players) do
        if not assignedPlayers[player.UserId] then
            local assignedRole = remainingRoles[roleIndex]
            
            -- [تصحيح حرج]: توحيد الاسم إلى "Role"
            player:SetAttribute("Role", assignedRole)
            player:SetAttribute("IsAlive", true) -- تهيئة الحالة كـ "حي"
            
            roleIndex = roleIndex + 1
            assignedPlayers[player.UserId] = true
            print("👤 " .. player.Name .. " حصل على دور عشوائي: " .. assignedRole)
        end
    end

    print("✅ تم الانتهاء من توزيع كافة الأدوار بنجاح وتوحيد البيانات.")
    return true
end

return RoleManager
