-- Modules/RoleDistributor.lua
-- نظام توزيع الأدوار (RoleDistributor)
-- الوظيفة: توزيع الأدوار عشوائياً وحفظها كـ Attributes على اللاعبين

local RoleDistributor = {}

-- [1] دالة خلط الجدول (Fisher-Yates Shuffle)
-- تضمن هذه الدالة عشوائية تامة في توزيع الأدوار
local function ShuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- [2] الدالة الرئيسية لتوزيع الأدوار
function RoleDistributor.DistributeRoles(players)
    if #players == 0 then return end
    
    local rolePool = {}
    local totalPlayers = #players

    -- أ. حساب عدد المافيا (حد أدنى 3، أو لاعب لكل 4 لاعبين)
    local mafiaCount = math.max(3, math.floor(totalPlayers / 4))
    for i = 1, mafiaCount do
        table.insert(rolePool, "Mafia")
    end

    -- ب. إضافة الجواسيس (2 ثابت كما هو مطلوب)
    for i = 1, 2 do
        table.insert(rolePool, "Spy")
    end

    -- ج. إضافة الأدوار الخاصة (ثابتة)
    table.insert(rolePool, "Judge")     -- القاضي
    table.insert(rolePool, "Doctor")    -- الطبيب
    table.insert(rolePool, "Detective") -- المحقق
    table.insert(rolePool, "Joker")     -- الجوكر

    -- د. ملء بقية الأدوار بالمواطنين (Citizens)
    local rolesAssignedSo far = #rolePool
    if totalPlayers > rolesAssignedSo far then
        for i = 1, (totalPlayers - rolesAssignedSo far) do
            table.insert(rolePool, "Citizen")
        end
    end

    -- [3] خلط مصفوفة الأدوار عشوائياً
    rolePool = ShuffleTable(rolePool)

    -- [4] تعيين الأدوار للاعبين وحفظها كـ Attribute
    for i, player in ipairs(players) do
        local roleName = rolePool[i]
        
        -- حفظ الدور برمجياً ليسهل الوصول إليه من أي ملف آخر
        player:SetAttribute("Role", roleName)
        
        -- طباعة النتائج في السجل (للمبرمج فقط)
        print("🎭 اللاعب: " .. player.Name .. " | الدور المعين: " .. roleName)
    end
    
    print("✅ تم توزيع الأدوار على " .. totalPlayers .. " لاعب بنجاح.")
end

return RoleDistributor
