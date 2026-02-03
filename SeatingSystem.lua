-- Modules/SeatingSystem.lua
-- نظام الجلوس الدائري (SeatingSystem) - النسخة المصححة والمحسنة

local SeatingSystem = {}

-- [1] الإعدادات الفنية (Technical Details)
local CENTER_POINT = Vector3.new(0, 5, 0) -- نقطة مركز طاولة النقاش
local Y_OFFSET = 3 -- ارتفاع اللاعب عن الأرض عند الجلوس

-- [2] دالة حساب التوزيع الدائري (Mathematical Logic)
function SeatingSystem.ArrangePlayers(players)
    local totalPlayers = #players
    if totalPlayers == 0 then return end

    -- التوسيع الديناميكي للقطر بناءً على عدد اللاعبين
    local radius = totalPlayers * 2 
    
    print("📐 جاري تنظيم الجلسة لـ " .. totalPlayers .. " لاعب. القطر المستخدم: " .. radius)

    for i, player in ipairs(players) do
        -- حساب الزاوية لكل لاعب (تقسيم 360 درجة بالتساوي)
        local angle = (i - 1) * (2 * math.pi / totalPlayers)
        
        -- [تصحيح الرياضيات]: استخدام math.cos و math.sin مباشرة
        local x = CENTER_POINT.X + math.cos(angle) * radius
        local z = CENTER_POINT.Z + math.sin(angle) * radius
        local position = Vector3.new(x, CENTER_POINT.Y, z)

        -- تطبيق الوضعية على شخصية اللاعب
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            -- نقل اللاعب وتوجيه وجهه مباشرة نحو مركز الطاولة (LookAt)
            hrp.CFrame = CFrame.lookAt(position + Vector3.new(0, Y_OFFSET, 0), CENTER_POINT)
        end
        
        -- ميزة إضافية: تعيين سمة نوع الكرسي (Royal أو Basic) بناءً على بيانات المتجر
        local chairTier = player:GetAttribute("ChairTier") or "Basic"
        print("💺 اللاعب " .. player.Name .. " يجلس بكرسي من فئة: " .. chairTier)
    end
end

-- [3] دالة إخلاء المقاعد (Cleanup)
function SeatingSystem.ClearSeats()
    print("🧹 انتهى النقاش.. جاري تحرير اللاعبين من أماكنهم.")
    -- يمكن إضافة كود هنا لإعادة اللاعبين لموقع عشوائي في المدينة
end

return SeatingSystem
