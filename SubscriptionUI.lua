-- =============================================================================
-- الجزء الأول: موديول واجهة الاشتراكات (Modules/SubscriptionUI.lua)
-- الوظيفة: إنشاء الواجهة برمجياً وإدارة ألوان النخبة والبلاتينيوم
-- =============================================================================

local SubscriptionUI = {}

-- [1] الخدمات الأساسية
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- [2] إعدادات الهوية البصرية (Visual Identity)
local COLORS = {
    Background = Color3.fromRGB(25, 25, 25), -- أسود فاخر
    Elite_Gold = Color3.fromRGB(255, 215, 0), -- ذهبي (250 ريال)
    Plat_Silver = Color3.fromRGB(192, 192, 192), -- فضي (150 ريال)
    White = Color3.fromRGB(255, 255, 255)
}

-- [3] الدالة المساعدة لإنشاء بطاقة عرض (Helper Function)
function SubscriptionUI.CreatePackageCard(parent, name, price, pos, color)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0.43, 0, 0.6, 0)
    Card.Position = pos
    Card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Card.Parent = parent

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = color
    UIStroke.Parent = Card

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Text = name
    NameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextColor3 = color
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 18
    NameLabel.Parent = Card

    local PriceLabel = Instance.new("TextLabel")
    PriceLabel.Text = price
    PriceLabel.Size = UDim2.new(1, 0, 0.2, 0)
    PriceLabel.Position = UDim2.new(0, 0, 0.3, 0)
    PriceLabel.BackgroundTransparency = 1
    PriceLabel.TextColor3 = COLORS.White
    PriceLabel.TextSize = 22
    PriceLabel.Parent = Card

    local BuyBtn = Instance.new("TextButton")
    BuyBtn.Text = "اشتراك الآن"
    BuyBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
    BuyBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
    BuyBtn.BackgroundColor3 = color
    BuyBtn.TextColor3 = COLORS.Background
    BuyBtn.Font = Enum.Font.GothamBold
    BuyBtn.Parent = Card
    
    return Card
end

-- [4] الدالة الرئيسية لإنشاء الواجهة برمجياً (CreateShopFrame)
function SubscriptionUI.CreateShopFrame()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- إنشاء الشاشة الرئيسية
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SubscriptionGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- الإطار الرئيسي
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.6, 0, 0.7, 0) 
    MainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "متجر اشتراكات مدينة المافيا"
    Title.Size = UDim2.new(1, 0, 0.15, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = COLORS.Elite_Gold
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 28
    Title.Parent = MainFrame

    -- إنشاء البطاقات (250 و 150 ريال)
    SubscriptionUI.CreatePackageCard(MainFrame, "باقة النخبة (ELITE)", "250 ريال", UDim2.new(0.05, 0, 0.2, 0), COLORS.Elite_Gold)
    SubscriptionUI.CreatePackageCard(MainFrame, "باقة البلاتينيوم (PLATINUM)", "150 ريال", UDim2.new(0.52, 0, 0.2, 0), COLORS.Plat_Silver)

    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "إغلاق"
    CloseBtn.Size = UDim2.new(0.2, 0, 0.1, 0)
    CloseBtn.Position = UDim2.new(0.4, 0, 0.85, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    CloseBtn.TextColor3 = COLORS.White
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = MainFrame
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    return ScreenGui
end

-- [5] فتح الواجهة
function SubscriptionUI.Open()
    SubscriptionUI.CreateShopFrame()
    print("💎 تم فتح متجر الاشتراكات.")
end

-- =============================================================================
-- الجزء الثاني: سكريبت الربط (LocalScript)
-- الوظيفة: الاستماع لضغط الزر وتشغيل الموديول
-- =============================================================================

-- ملاحظة: هذا الجزء يوضع عادة داخل زر المتجر في واجهة المستخدم
local function InitializeButtonLogic()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    -- نستخدم pcall للتأكد من وجود الموديول في المسار الصحيح
    local success, module = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SubscriptionUI"))
    end)

    if success then
        local button = script.Parent -- الزر الذي يحتوي على السكريبت
        if button:IsA("GuiButton") then
            button.MouseButton1Click:Connect(function()
                -- استدعاء وظيفة الفتح من الموديول الذي برمجته
                module.Open()
            end)
        end
    end
end

-- تشغيل منطق الربط
task.spawn(InitializeButtonLogic)

return SubscriptionUI
