-- Modules/RoleUI.lua
-- نظام عرض بطاقة الدور (RoleUI)
-- الوظيفة: العمل كجسر برمي لإظهار الهوية السرية للاعب عبر واجهة المستخدم

local RoleUI = {}

-- [1] الخدمات الأساسية
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [2] إعداد أحداث التواصل (RemoteEvents)
-- ننتظر وجود مجلد Events والحدث ShowRoleEvent لإرسال البيانات للعميل
local Events = ReplicatedStorage:WaitForChild("Events")
local ShowRoleEvent = Events:FindFirstChild("ShowRoleEvent")

-- [3] الدالة الرئيسية: ShowRole
-- playerName: اسم اللاعب المستهدف
-- roleName: اسم الدور المراد عرضه (مافيا، طبيب، إلخ)
-- roleColor: لون الفريق (أحمر للمافيا، أزرق للمواطنين، إلخ)
function RoleUI.ShowRole(player, roleName, roleColor)
    -- التحقق من صحة البيانات قبل الإرسال
    if not player or not roleName then
        warn("⚠️ RoleUI Error: بيانات اللاعب أو الدور ناقصة.")
        return
    end

    -- إعداد اللون الافتراضي في حال لم يتم تحديده
    local finalColor = roleColor or Color3.fromRGB(255, 255, 255)

    -- [4] المنطق: تمرير البيانات إلى جهاز اللاعب (Client)
    -- يتم إرسال اسم اللاعب، اسم الدور، واللون المخصص للواجهة
    if ShowRoleEvent then
        ShowRoleEvent:FireClient(player, player.Name, roleName, finalColor)
        print("📡 تم إرسال بيانات الهوية بنجاح للاعب: " .. player.Name)
    else
        warn("❌ ShowRoleEvent غير موجود في ReplicatedStorage.Events")
    end
end

-- ملاحظة برمجية:
-- هذه الدالة يتم استدعاؤها من GameManager.lua فور توزيع الأدوار.
-- ستقوم واجهة المستخدم (GUI) في جانب العميل بالاستماع لهذا الحدث وعرض البطاقة.

return RoleUI
