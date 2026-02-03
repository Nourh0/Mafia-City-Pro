-- ==========================================
-- الجزء الأول: موديول واجهة المافيا (Modules/MafiaTargetUI.lua)
-- ==========================================
local MafiaTargetUI = {}

-- [1] الخدمات الأساسية
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- [2] إعدادات التصميم (Theme)
local THEME_COLOR = Color3.fromRGB(60, 0, 0) -- أحمر دموي غامق
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

-- [3] إنشاء الواجهة برمجياً
function MafiaTargetUI.CreateUI()
    -- إنشاء الشاشة الرئيسية
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MafiaTargetGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
    MainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
    MainFrame.BackgroundColor3 = THEME_COLOR
    MainFrame.BorderSizePixel = 2
    MainFrame.Parent = ScreenGui

    -- العنوان
    local Title = Instance.new("TextLabel")
    Title.Text = "إختر ضحية الليلة"
    Title.Size = UDim2.new(1, 0, 0.15, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    Title.TextColor3 = TEXT_COLOR
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Parent = MainFrame

    -- قائمة اللاعبين (ScrollingFrame)
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Name = "ScrollList"
    ScrollList.Size = UDim2.new(0.9, 0, 0.75, 0)
    ScrollList.Position = UDim2.new(0.05, 0, 0.2, 0)
    ScrollList.BackgroundTransparency = 1
    ScrollList.CanvasSize = UDim2.new(0, 0, 2, 0)
    ScrollList.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = ScrollList

    return ScreenGui
end

-- [4] تحديث قائمة اللاعبين (Dynamic List)
function MafiaTargetUI.UpdateList(gui)
    local scrollList = gui.MainFrame.ScrollList
    -- مسح القائمة القديمة
    for _, child in pairs(scrollList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- إضافة اللاعبين الأحياء (باستثناء المافيا)
    for _, player in pairs(Players:GetPlayers()) do
        local isAlive = player:GetAttribute("IsAlive")
        local role = player:GetAttribute("Role")
        
        -- الشرط: اللاعب حي وليس من المافيا وليس اللاعب نفسه
        if isAlive and role ~= "Mafia" and role ~= "Godfather" and player ~= LocalPlayer then
            local TargetBtn = Instance.new("TextButton")
            TargetBtn.Text = player.Name
            TargetBtn.Size = UDim2.new(1, 0, 0, 40)
            TargetBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            TargetBtn.TextColor3 = TEXT_COLOR
            TargetBtn.Font = Enum.Font.Gotham
            TargetBtn.Parent = scrollList

            -- عند الضغط: تنفيذ الهجوم
            TargetBtn.MouseButton1Click:Connect(function()
                MafiaTargetUI.ExecuteAttack(player)
                gui.Enabled = false -- إغلاق تلقائي (Auto-Cleanup)
            end)
        end
    end
end

-- [5] تنفيذ الهجوم (Interaction Logic)
function MafiaTargetUI.ExecuteAttack(target)
    print("🎯 تم اختيار الهدف: " .. target.Name)
    -- إرسال الطلب للسيرفر ليقوم EliminationManager بالتنفيذ
    local Events = ReplicatedStorage:WaitForChild("Events")
    local AttackEvent = Events:FindFirstChild("MafiaAttackEvent")
    if AttackEvent then
        AttackEvent:FireServer(target)
    end
end

-- [6] فتح وإغلاق الواجهة
function MafiaTargetUI.Open()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("MafiaTargetGui") or MafiaTargetUI.CreateUI()
    MafiaTargetUI.UpdateList(gui)
    gui.Enabled = true
    print("🌑 واجهة المافيا نشطة الآن.")
end

function MafiaTargetUI.Close()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("MafiaTargetGui")
    if gui then gui.Enabled = false end
end

-- ==========================================
-- الجزء الثاني: الربط المنطقي (Linking Logic)
-- ==========================================
-- هذا الجزء يربط استدعاء "فتح الواجهة" مع بداية مرحلة الليل

-- 1. التأكد أن اللاعب من المافيا قبل الفتح
local function OnNightStarted()
    local role = LocalPlayer:GetAttribute("Role")
    if role == "Mafia" or role == "Godfather" then
        print("🌙 بداية الليل: جاري فتح واجهة الأهداف...")
        MafiaTargetUI.Open() -- الربط هنا
    end
end

-- 2. الاستماع لإشارة السيرفر (بواسطة RemoteEvent)
local Events = ReplicatedStorage:WaitForChild("Events")
local PhaseEvent = Events:WaitForChild("PhaseChanged") -- إيفنت يرسله السيرفر عند تغيير الوقت

PhaseEvent.OnClientEvent:Connect(function(phaseName)
    if phaseName == "Night" then
        OnNightStarted()
    elseif phaseName == "Day" then
        MafiaTargetUI.Close() -- إغلاق الواجهة عند انتهاء الليل
    end
end)

return MafiaTargetUI
