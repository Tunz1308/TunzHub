-- DEBUG SCRIPT: in ra thông tin để fix "ko chạy"
-- Dán vào executor -> Execute -> copy toàn bộ Output/Console gửi mình

local function safePrint(...)
    local args = {...}
    local s = ""
    for i=1,#args do s = s .. tostring(args[i]) .. "\t" end
    print(s)
end

pcall(function()
    safePrint("=== DEBUG HUNTY ZOMBIES START ===")
    safePrint("Time:", os.date("%c"))
    local plr = game:GetService("Players").LocalPlayer
    safePrint("Player:", plr and plr.Name or "nil")
    local char = plr and (plr.Character or plr.CharacterAdded:Wait()) or nil
    safePrint("Character present:", char and "yes" or "no")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    safePrint("HumanoidRootPart:", hrp and "yes" or "no")

    -- Check VirtualInputManager
    local okVIM, VIM = pcall(function() return game:GetService("VirtualInputManager") end)
    safePrint("GetService VirtualInputManager ok:", okVIM, VIM and typeof(VIM) or "nil")
    if okVIM and VIM then
        safePrint("Has SendKeyEvent:", type(VIM.SendKeyEvent) == "function")
        safePrint("Has SendMouseButtonEvent:", type(VIM.SendMouseButtonEvent) == "function")
    end

    -- Check fireproximityprompt
    local hasFireGlobal = (type(fireproximityprompt) == "function") or (type(_G.fireproximityprompt) == "function")
    safePrint("Global fireproximityprompt available:", hasFireGlobal)

    -- List first few Models with Humanoid (possible mobs)
    local count=0
    for _,inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Model") and inst:FindFirstChildWhichIsA("Humanoid") then
            count = count + 1
            local ok, cf = pcall(function()
                if inst:GetPivot then return inst:GetPivot() end
                if inst.PrimaryPart then return inst.PrimaryPart.CFrame end
                if inst:FindFirstChild("HumanoidRootPart") then return inst.HumanoidRootPart.CFrame end
                return nil
            end)
            local pos = (cf and cf.Position) or "no-pivot"
            safePrint(("Mob[%d] name=%s  pos=%s"):format(count, inst.Name, tostring(pos)))
            if count >= 15 then break end
        end
    end
    if count == 0 then safePrint("-> Không thấy Model có Humanoid trong workspace (có thể tên khác hoặc mob spawn ở chỗ khác).") end

    -- List first few ProximityPrompts
    local pcount=0
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcount = pcount + 1
            local parentName = obj.Parent and obj.Parent.Name or "nilParent"
            safePrint(("Prompt[%d] parent=%s name=%s"):format(pcount, parentName, obj.Name))
            if pcount >= 20 then break end
        end
    end
    safePrint("Total Prompts found (scan):", pcount)

    -- List Backpack contents
    local backpack = plr and plr:FindFirstChild("Backpack")
    if backpack then
        local bi=0
        for _,it in ipairs(backpack:GetChildren()) do
            bi = bi + 1
            safePrint(("Backpack[%d] name=%s class=%s"):format(bi, it.Name, it.ClassName))
            if bi >= 30 then break end
        end
        if bi == 0 then safePrint("-> Backpack hiện rỗng") end
    else
        safePrint("-> Không tìm thấy Backpack")
    end

    -- Scan PlayerGui for buttons with text like replay/again/retry
    local pg = plr and plr:FindFirstChild("PlayerGui")
    if pg then
        local found=false
        for _,d in ipairs(pg:GetDescendants()) do
            if (d:IsA("TextButton") or d:IsA("TextLabel") or d:IsA("ImageButton")) then
                local txt = tostring(d.Text or d.Name or "")
                if string.find(string.lower(txt),"replay") or string.find(string.lower(txt),"again") or string.find(string.lower(txt),"retry") then
                    safePrint("Possible Replay Button:", d:GetFullName(), "Text:" , txt)
                    found=true
                end
            end
        end
        if not found then s
