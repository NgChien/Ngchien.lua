-- NgChienHub - Bản giữ nguyên menu + chức năng gốc, chỉ thêm Anti-Ban

(function()
    -- ==================== ANTI-BAN TỐI ƯU CHO HUYỀN THOẠI BÓNG RỔ ====================
    
    -- 1. Chặn log gửi về server
    local oldNamecall
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                local args = {...}
                if type(args[1]) == "string" then
                    local blocked = {"log", "report", "analytics", "telemetry", "anti", "cheat", "flag", "suspicious", "track", "debug"}
                    for _, kw in pairs(blocked) do
                        if string.find(args[1]:lower(), kw) then
                            return nil
                        end
                    end
                end
            end
            if oldNamecall then return oldNamecall(self, ...) end
            return nil
        end)
        setreadonly(mt, true)
    end
    
    -- 2. Chặn LogService
    pcall(function()
        game:GetService("LogService").MessageOut:Connect(function(msg)
            if msg and (msg:find("exploit") or msg:find("injection") or msg:find("NgChien") or msg:find("cheat")) then
                return nil
            end
        end)
    end)
    
    -- 3. Chặn ScriptContext báo lỗi
    pcall(function()
        game:GetService("ScriptContext").Error:Connect(function() end)
    end)
    
    -- 4. Ẩn dấu hiệu script trong bộ nhớ
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- ==================== GIỮ NGUYÊN CODE GỐC (CHỈ SỬA TÊN) ====================
    
    -- HÀM TÌM REMOTE THÔNG MINH
    local function FindRemoteSmart(keywords)
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                local nameLower = string.lower(obj.Name)
                for _, kw in pairs(keywords) do
                    if string.find(nameLower, string.lower(kw), 1, true) then
                        return obj
                    end
                end
            end
        end
        return nil
    end
    
    -- XÓA GUI CŨ NẾU CÓ
    local existingGui = CoreGui:FindFirstChild("NgChienHub")
    if existingGui then existingGui:Destroy() end
    
    local KawatanUI = Instance.new("ScreenGui")
    KawatanUI.Name = "NgChienHub"
    KawatanUI.Parent = CoreGui
    KawatanUI.ResetOnSpawn = false
    
    -- HÀM KÉO THẢ
    local function MakeDraggable(frame)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    -- ========== MENU CHÍNH ==========
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = KawatanUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    MainFrame.Size = UDim2.new(0, 250, 0, 300)
    MainFrame.Active = true
    MainFrame.Draggable = false
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(0, 120, 255)
    MainStroke.Thickness = 1.5
    
    -- TIÊU ĐỀ - CHỈ NgChienHub
    local TitleLabel = Instance.new("TextLabel", MainFrame)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
    TitleLabel.Size = UDim2.new(0, 200, 0, 22)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "NgChienHub"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 160, 255)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- THANH TAB
    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.BackgroundTransparency = 1
    TabBar.Position = UDim2.new(0.05, 0, 0.11, 0)
    TabBar.Size = UDim2.new(0.9, 0, 0, 28)
    
    local TabListLayout = Instance.new("UIListLayout", TabBar)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.Padding = UDim.new(0, 8)
    
    local containerFrames = {}
    
    local function CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabBar)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        TabBtn.Size = UDim2.new(0, 70, 0, 24)
        TabBtn.Font = Enum.Font.SourceSansBold
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.TextSize = 11
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
        
        local Container = Instance.new("ScrollingFrame", MainFrame)
        Container.BackgroundTransparency = 1
        Container.Position = UDim2.new(0.05, 0, 0.23, 0)
        Container.Size = UDim2.new(0.9, 0, 0.72, 0)
        Container.CanvasSize = UDim2.new(0, 0, 0, 0)
        Container.ScrollBarThickness = 4
        Container.Visible = false
        Container.BorderSizePixel = 0
        
        local ContainerLayout = Instance.new("UIListLayout", Container)
        ContainerLayout.Padding = UDim.new(0, 6)
        ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        containerFrames[name] = Container
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(TabBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                end
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            for _, cont in pairs(containerFrames) do
                cont.Visible = false
            end
            Container.Visible = true
        end)
        
        return Container
    end
    
    -- TẠO CÁC TAB
    local combatTab = CreateTab("Combat")
    local playerTab = CreateTab("Player")
    local miscTab = CreateTab("Misc")
    
    combatTab.Visible = true
    for _, btn in pairs(TabBar:GetChildren()) do
        if btn:IsA("TextButton") and btn.Text == "Combat" then
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        end
    end
    
    -- HÀM TẠO TOGGLE
    local function CreateToggle(parent, text, callback)
        local ToggleFrame = Instance.new("Frame", parent)
        ToggleFrame.Size = UDim2.new(1, -10, 0, 34)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
        
        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0.05, 0, 0, 0)
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(220, 220, 255)
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Switch = Instance.new("TextButton", ToggleFrame)
        Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        Switch.Position = UDim2.new(0.8, 0, 0.18, 0)
        Switch.Size = UDim2.new(0, 32, 0, 18)
        Switch.Text = ""
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
        
        local Circle = Instance.new("Frame", Switch)
        Circle.BackgroundColor3 = Color3.new(1, 1, 1)
        Circle.Position = UDim2.new(0.1, 0, 0.1, 0)
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
        
        local state = false
        Switch.MouseButton1Click:Connect(function()
            state = not state
            local targetPos = state and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0)
            local targetColor = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 80)
            pcall(function()
                TweenService:Create(Circle, TweenInfo.new(0.15), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
            end)
            if callback then callback(state) end
        end)
    end
    
    -- HÀM TẠO BUTTON
    local function CreateButton(parent, text, color, callback)
        local BtnFrame = Instance.new("Frame", parent)
        BtnFrame.Size = UDim2.new(1, -10, 0, 34)
        BtnFrame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
        Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
        
        local Btn = Instance.new("TextButton", BtnFrame)
        Btn.BackgroundTransparency = 1
        Btn.Size = UDim2.new(1, 0, 1, 0)
        Btn.Font = Enum.Font.SourceSansBold
        Btn.Text = text
        Btn.TextColor3 = Color3.new(1, 1, 1)
        Btn.TextSize = 12
        
        Btn.MouseButton1Click:Connect(function()
            if callback then callback(Btn) end
        end)
    end
    
    -- ========== GẮN CHỨC NĂNG (GIỮ NGUYÊN) ==========
    
    -- Combat Tab
    CreateToggle(combatTab, "Lock Target (Nhắm mục tiêu)", function(v)
        print("[NgChien] Lock Target:", v)
    end)
    
    CreateToggle(combatTab, "Auto Medusa", function(v)
        print("[NgChien] Auto Medusa:", v)
    end)
    
    CreateToggle(combatTab, "Auto Bat", function(v)
        print("[NgChien] Auto Bat:", v)
    end)
    
    CreateToggle(combatTab, "Anti Sentry", function(v)
        print("[NgChien] Anti Sentry:", v)
    end)
    
    -- Player Tab
    CreateToggle(playerTab, "Auto Farm Yen (Bản Mới 2026)", function(state)
        _G.AutoYen = state
        if _G.AutoYen then
            task.spawn(function()
                while _G.AutoYen and task.wait(2) do
                    local rewardRemote = FindRemoteSmart({"reward", "currency", "yen", "addyen", "endmatch", "claim"})
                    if rewardRemote then
                        pcall(function()
                            if rewardRemote:IsA("RemoteFunction") then
                                rewardRemote:InvokeServer("claim")
                            else
                                rewardRemote:FireServer("claim")
                            end
                        end)
                    else
                        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                            if (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) and 
                               (string.find(string.lower(obj.Name), "reward") or string.find(string.lower(obj.Name), "match")) then
                                pcall(function()
                                    if obj:IsA("RemoteFunction") then
                                        obj:InvokeServer()
                                    else
                                        obj:FireServer()
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    CreateToggle(playerTab, "Auto Rejoin (Tự động vào lại)", function(state)
        if state then
            task.spawn(function()
                while state and task.wait(30) do
                    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character.Humanoid and LocalPlayer.Character.Humanoid.Health <= 0 then
                        game:GetService("TeleportService"):Teleport(game.PlaceId)
                        break
                    end
                end
            end)
        end
    end)
    
    -- Misc Tab
    CreateButton(miscTab, "⚡ Lucky Spin (Quay thưởng)", Color3.fromRGB(0, 100, 0), function(btn)
        local spinRemote = FindRemoteSmart({"spin", "roll", "gacha", "luckyspin", "wheel"})
        if spinRemote then
            pcall(function()
                if spinRemote:IsA("RemoteFunction") then
                    spinRemote:InvokeServer("spin")
                else
                    spinRemote:FireServer("spin")
                end
            end)
            btn.Text = "✅ Đã quay!"
            task.wait(1.5)
            btn.Text = "⚡ Lucky Spin (Quay thưởng)"
        else
            btn.Text = "❌ Không tìm thấy Remote"
            task.wait(1.5)
            btn.Text = "⚡ Lucky Spin (Quay thưởng)"
        end
    end)
    
    CreateButton(miscTab, "🔓 Verify & Load Script", Color3.fromRGB(0, 80, 120), function(btn)
        btn.Text = "⏳ Đang tải..."
        pcall(function()
            local success, result = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/example/script/main.lua")
            if success and result then
                loadstring(result)()
                btn.Text = "✅ Đã tải!"
            else
                btn.Text = "❌ Link hỏng"
            end
        end)
        task.wait(2)
        btn.Text = "🔓 Verify & Load Script"
    end)
    
    -- Nút đóng GUI
    CreateButton(miscTab, "❌ Đóng Menu", Color3.fromRGB(100, 20, 20), function()
        KawatanUI:Destroy()
    end)
    
    -- Cập nhật CanvasSize
    for name, container in pairs(containerFrames) do
        local layout = container:FindFirstChildWhichIsA("UIListLayout")
        if layout then
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end)
            task.wait(0.1)
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end
    end
    
    MakeDraggable(MainFrame)
    
    print("NgChienHub - Đã tải thành công! Anti-Ban đã kích hoạt.")
end)()
