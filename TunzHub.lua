-- 🟢 HUNTY ZOMBIES — FULL AUTO (STABLE)
-- Yêu cầu executor (Arceus X Neo / Delta / Codex...). Dùng acc phụ!

-- ===================== CONFIG =====================
local RANGE = 25               -- khoảng cách phát hiện mob
local SAFE_OFFSET_Y = 7        -- đứng "trên đầu" mob cao bao nhiêu
local ATTACK_INTERVAL = 0.30
local SAFE_INTERVAL   = 5
local PERK_INTERVAL   = 4
local RADIO_INTERVAL  = 8
local REPLAY_INTERVAL = 5

-- Tên/chuỗi gợi ý để tìm object (tuỳ map có thể khác)
local MOB_PATTERNS   = {"zombie","zomb"}
local PERK_PATTERNS  = {"perk","cola","soda","jug","doubletap","speed","revive"}
local RADIO_PATTERNS = {"radio"}

-- Phím kỹ năng (đổi nếu game bạn khác)
local KEY_Z = Enum.KeyCode.Z
local KEY_X = Enum.KeyCode.X
local KEY_C = Enum.KeyCode.C
local KEY_ULT = Enum.KeyCode.G -- nếu ult là G thì đổi sang Enum.KeyCode.G

-- ===================== SERVICES & VARS =====================
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local backpack = plr:WaitForChild("Backpack")
local VIM = game:GetService("VirtualInputManager")

-- ===================== UTILS =====================
local function tolower(s) return string.lower(s or "") end

local function matchAny(str, patterns)
    str = tolower(str or "")
    for _, p in ipairs(patterns) do
        if string.find(str, tolower(p)) then return true end
    end
    return false
end

local function getPivotCF(inst)
    if not inst then return nil end
    if inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok and cf then return cf end
        if inst.PrimaryPart then return inst.PrimaryPart.CFrame end
        local hrp2 = inst:FindFirstChild("HumanoidRootPart")
        if hrp2 then return hrp2.CFrame end
    elseif inst.CFrame then
        return inst.CFrame
    end
    return nil
end

local function pressKey(k)
    VIM:SendKeyEvent(true, k, false, game); task.wait(0.08)
    VIM:SendKeyEvent(false, k, false, game)
end

local function mouseClick()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Fire ProximityPrompt an toàn (kể cả khi executor không có fireproximityprompt)
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if typeof(_G.fireproximityprompt) == "function" then
        _G.fireproximityprompt(prompt)
        return
    end
    if typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
        return
    end
    -- fallback: giữ - nhả input
    local old = prompt.HoldDuration
    prompt.HoldDuration = 0
    prompt:InputHoldBegin()
    task.wait(0.1)
    prompt:InputHoldEnd()
    prompt.HoldDuration = old
end

-- Tìm nút GUI có text chứa chuỗi nào đó
local function findGuiButtonByText(rootGui, textPatterns)
    if not rootGui then return nil end
    for _, d in ipairs(rootGui:GetDescendants()) do
        if (d:IsA("TextButton") or d:IsA("TextLabel")) and d.Text then
            if matchAny(d.Text, textPatterns) then
                return d:IsA("TextButton") and d or d.Parent
            end
        end
        if d:IsA("ImageButton") and matchAny(d.Name, textPatterns) then
            return d
        end
    end
    return nil
end

-- Quét mob gần nhất
local function getNearestMob()
    local nearest, bestDist
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Model") and inst:FindFirstChildWhichIsA("Humanoid") then
            if matchAny(inst.Name, MOB_PATTERNS) then
                local cf = getPivotCF(inst)
                if cf then
                    local dist = (cf.Position - hrp.Position).Magnitude
                    if dist <= RANGE and (not bestDist or dist < bestDist) then
            
