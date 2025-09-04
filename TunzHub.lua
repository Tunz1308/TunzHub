--// Load thư viện UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua")))()
local Window = Library.CreateLib("Tunz Hub", "DarkTheme")

--// Tab
local Tab = Window:NewTab("Farm")
local Section = Tab:NewSection("Điều khiển")

--// Biến trạng thái
getgenv().AutoFarm = false

--// Hàm tìm zombie gần nhất
local function getNearestZombie()
    local closest, dist = nil, math.huge
    for _, mob in pairs(workspace:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Name:lower():find("zombie") then
            local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                dist = mag
                closest = mob
            end
        end
    end
    return closest
end

--// Auto farm loop
local function startFarm()
    spawn(function()
        while getgenv().AutoFarm do
            task.wait(0.2)
            local zombie = getNearestZombie()
            if zombie and zombie:FindFirstChild("HumanoidRootPart") then
                -- Dịch chuyển tới zombie
                game.Players.LocalPlayer.Character:MoveTo(zombie.HumanoidRootPart.Position + Vector3.new(0,3,0))
                -- Gửi attack (tuỳ game có thể khác)
                pcall(function()
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                end)
            end
        end
    end)
end

--// Bật farm
Section:NewButton("Khởi động", "Bật auto farm zombie", function()
    getgenv().AutoFarm = true
    startFarm()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Tunz Hub";
        Text = "Đã bật auto farm!";
        Duration = 5;
    })
end)

--// Dừng farm
Section:NewButton("Dừng", "Tắt auto farm", function()
    getgenv().AutoFarm = false
    game.StarterGui:SetCore("SendNotification", {
        Title = "Tunz Hub";
        Text = "Đã tắt auto farm!";
        Duration = 5;
    })
end)
