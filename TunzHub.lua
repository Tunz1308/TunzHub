-- ================== TunzHub.lua (safe boot) ==================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Fallback notify (nếu SetCore lỗi)
local function notify(txt)
    local ok = pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title="TunzHub", Text=txt, Duration=4})
    end)
    if not ok then
        local parent = game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.IgnoreGuiInset, sg.ResetOnSpawn = true, false
        sg.Name = "TunzHubNotify"
        sg.Parent = parent
        local lb = Instance.new("TextLabel")
        lb.Size, lb.BackgroundTransparency = UDim2.fromScale(1,0), 0.2
        lb.Position, lb.TextSize = UDim2.new(0,0,0,0), 22
        lb.Font, lb.TextColor3, lb.Text = Enum.Font.GothamBold, Color3.new(1,1,1), "TunzHub: "..txt
        lb.Parent = sg
        task.delay(4, function() if sg then sg:Destroy() end end)
    end
end

print("[TunzHub] PlaceId:", game.PlaceId)
notify("Script đã chạy ✅")

-- ======= Kiểm tra PlaceId (để test TẠM thời tắt đi) =======
local FORCE_RUN_ANY_GAME = true   -- set = false khi xong test
local TARGET_PLACEID = 103754275310547 -- ĐỔI thành PlaceId thật của bạn!
if (not FORCE_RUN_ANY_GAME) and (game.PlaceId ~= TARGET_PLACEID) then
    warn("[TunzHub] Sai game -> dừng")
    notify("Sai game, dừng chạy ❌")
    return
end

-- ======= Chờ nhân vật sẵn sàng =======
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end
pcall(getHRP)

-- ======= Load UI lib (Kavo) có chống lỗi =======
local Library
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    end)
    if ok and lib then
        Library = lib
    else
        warn("[TunzHub] Kavo UI load fail:", lib)
        notify("Kavo UI không tải được, dùng UI đơn giản.")
    end
end

-- ======= Nếu có Kavo: tạo UI; nếu không: tạo UI tối giản =======
local function createSimpleUI()
    local parent = game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui"); sg.Name="TunzHubLite"; sg.Parent=parent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,40)
    btn.Position = UDim2.new(0,20,0,60)
    btn.Text = "Test nút (OK)"
    btn.Parent = sg
    btn.MouseButton1Click:Connect(function() notify("Nút hoạt động ✅") end)
end

if Library then
    local Window = Library.CreateLib("Tunz Hub", "DarkTheme")
    local Tab = Window:NewTab("Test")
    local Sec = Tab:NewSection("Khởi động")
    Sec:NewButton("Kiểm tra nút", "Nhấn để test notify", function()
        notify("Nút hoạt động ✅")
    end)
else
    createSimpleUI()
end
-- ================== /end ==================
