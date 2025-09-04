-- ✅ Debug PlaceId
print("Game PlaceId:", game.PlaceId)

-- 🔒 Chỉ chạy trong game có ID này (bạn thay số cho đúng game của bạn)
if game.PlaceId ~= 103754275310547 then
    warn("⛔ Script stopped: wrong game!")
    return
end

-- 🖥️ Load UI Library (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Tunz Hub", "DarkTheme")

-- Tabs
local FarmTab = Window:NewTab("Farm")
local FarmSection = FarmTab:NewSection("Zombie")

local AutoTab = Window:NewTab("Auto")
local AutoSection = AutoTab:NewSection("Perks & Replay")

-- 📌 Common
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- 🧟 Auto Farm Zombie
FarmSection:NewButton("Farm Zombie", "Auto find & attack zombie", function()
    print("⚡ Auto Farm Zombie ON")
    task.spawn(function()
        while task.wait(1) do
            local closest, dist = nil, math.huge
            for _, mob in pairs(workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Name:lower():find("zombie") then
                    local root = mob:FindFirstChild("HumanoidRootPart")
                    if root then
                        local mag = (getHRP().Position - root.Position).Magnitude
                        if mag < dist then
                            closest = root
                            dist = mag
                        end
                    end
                end
            end
            if closest then
                getHRP().CFrame = closest.CFrame + Vector3.new(0, 3, 0)
                for _, key in ipairs({Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C}) do
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.2)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
            end
        end
    end)
end)

-- 🎁 Auto Perks
AutoSection:NewButton("Auto Perks", "Auto activate perks", function()
    print("⚡ Auto Perks ON")
    task.spawn(function()
        while task.wait(5) do
            for _, perk in pairs(LocalPlayer.Backpack:GetChildren()) do
                if perk:IsA("Tool") and perk.Name:lower():find("perk") then
                    perk.Parent = LocalPlayer.Character
                    task.wait(0.2)
                    perk:Activate()
                end
            end
        end
    end)
end)

-- 📻 Auto Radio
AutoSection:NewButton("Auto Radio", "Find nearest radio & activate", function()
    print("📻 Auto Radio ON")
    task.spawn(function()
        while task.wait(10) do
            local closest, dist = nil, math.huge
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ClickDetector") and obj.Parent and obj.Parent.Name:lower():find("radio") then
                    local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local mag = (getHRP().Position - part.Position).Magnitude
                        if mag < dist then
                            closest = obj
                            dist = mag
                        end
                    end
                end
            end
            if closest then
                local part = closest.Parent:IsA("BasePart") and closest.Parent or closest.Parent:FindFirstChildWhichIsA("BasePart")
                if part then
                    getHRP().CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    task.wait(1)
                    fireclickdetector(closest)
                end
            end
        end
 
