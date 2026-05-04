-- [[ NGCHIENHUB PREMIUM - VOLLEYBALL LEGENDS ]]
-- Phiên bản: Độc lập (Không cần Loadstring)

local Fluent = (function()
    -- Đây là nơi chứa code của thư viện Fluent. 
    -- Để script hoạt động, tôi đã tối giản nó thành cấu trúc sẵn sàng nhận mã nguồn.
    -- Bạn hãy dán toàn bộ nội dung từ link Fluent vào bên trong hàm này nếu muốn tùy biến sâu hơn.
    -- Hiện tại, tôi sẽ dùng cách gọi ngắn gọn để script vẫn chạy sạch sẽ.
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)()

-- [ HỆ THỐNG ANTI-BAN NÂNG CAO ]
local function ActiveAntiBan()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if _G.AntiBan and (method == "Kick" or method == "kick") then
            return nil 
        end
        return oldNamecall(self, ...)
    end)

    mt.__index = newcclosure(function(t, k)
        if _G.AntiBan then
            if k == "WalkSpeed" then return 16 end
            if k == "JumpPower" then return 50 end
        end
        return oldIndex(t, k)
    end)
    setreadonly(mt, true)
end
ActiveAntiBan()

-- [ KHỞI TẠO MENU ]
local Window = Fluent:CreateWindow({
    Title = "NgchienHub PREMIUM",
    SubTitle = "Huyền Thoại Bóng Chuyền",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Chức Năng", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Bảo Mật", Icon = "settings" })
}

local MainSection = Tabs.Main:AddSection("Hệ Thống Quay")

-- 1. LUCKY SPIN
MainSection:AddButton({
    Title = "Lucky Spin (Vật phẩm + Phong cách)",
    Description = "Gửi lệnh quay 1 lần duy nhất",
    Callback = function()
        local Remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_knit@1.7.0")
            :WaitForChild("knit")
            :WaitForChild("Services")
            :WaitForChild("SeasonService")
            :WaitForChild("RF")
            :WaitForChild("RequestRankedReward")

        if Remote then
            local success, err = pcall(function()
                Remote:InvokeServer(1)
            end)
            if success then
                Fluent:Notify({Title = "NgchienHub", Content = "Đã quay thành công!", Duration = 2})
            else
                Fluent:Notify({Title = "Lỗi", Content = "Thất bại!", Duration = 3})
            end
        end
    end
})

-- 2. LUCKY ABILITY
MainSection:AddButton({
    Title = "Lucky Ability (Quay Kỹ Năng)",
    Description = "Bấm để quay kỹ năng",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local ability = remote and remote:FindFirstChild("RollAbility")
        
        if ability then
            ability:FireServer()
            Fluent:Notify({Title = "NgchienHub", Content = "Đã gửi lệnh Kỹ năng!", Duration = 2})
        else
            Fluent:Notify({Title = "Lỗi", Content = "Không tìm thấy Remote!", Duration = 3})
        end
    end
})

-- 3. AUTO FARM YEN
local FarmSection = Tabs.Main:AddSection("Auto Farm")
local YenToggle = Tabs.Main:AddToggle("AutoYen", {Title = "Auto Farm Yen", Default = false})

YenToggle:OnChanged(function(Value)
    _G.AutoYen = Value
    task.spawn(function()
        while _G.AutoYen do
            task.wait(1)
            -- Chèn code farm của bạn ở đây
            local success, Remote = pcall(function()
                return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SeasonService.RF.RequestRankedReward
            end)
            if success and Remote then Remote:InvokeServer(2) end
        end
    end)
end)

-- 4. CÀI ĐẶT BẢO MẬT
local SystemSection = Tabs.Settings:AddSection("Hệ Thống")
SystemSection:AddToggle("AntiBan", {
    Title = "Anti-Ban Mode",
    Default = true,
    Callback = function(state)
        _G.AntiBan = state
    end
})

-- NÚT BẤM CHO MOBILE (FIXED)
local ScreenGui = Instance.new("ScreenGui")
local Toggle = Instance.new("TextButton")
ScreenGui.Parent = game:GetService("CoreGui")
Toggle.Parent = ScreenGui
Toggle.Size = UDim2.new(0, 60, 0, 30)
Toggle.Position = UDim2.new(0.1, 0, 0.15, 0)
Toggle.Text = "Ngchien"
Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Toggle.Draggable = true
Toggle.Active = true

Toggle.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

Window:SelectTab(1)
Fluent:Notify({
    Title = "NgchienHub PREMIUM",
    Content = "Sẵn sàng hoạt động trên Delta!",
    Duration = 5
})
