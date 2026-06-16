local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

_G.LatticMM2V2 = _G.LatticMM2V2 or {
    Config = {
        AutoKill = false, AutoFarm = false, AutoShoot = false,
        Fly = false, Noclip = false, Esp = false,
        FlySpeed = 50, FarmSpeed = 75 -- Massively increased farm speed threshold
    },
    Hotkeys = {
        AutoKill = Enum.KeyCode.H, AutoFarm = Enum.KeyCode.K, AutoShoot = Enum.KeyCode.T,
        Fly = Enum.KeyCode.F, Noclip = Enum.KeyCode.N, Esp = Enum.KeyCode.O
    },
    Movement = {Forward = 0, Backward = 0, Left = 0, Right = 0, Velocity = nil, Gyro = nil},
    Connections = {}, Visuals = {}, BindTarget = nil, IsVisible = true, RunLoop = true
}

local M = _G.LatticMM2V2
local lp = Players.LocalPlayer

if CoreGui:FindFirstChild("LatticMM2V2PanelGui") then
    CoreGui.LatticMM2V2PanelGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "LatticMM2V2PanelGui"
gui.ResetOnSpawn = false
if not pcall(function() gui.Parent = CoreGui end) then gui.Parent = lp:WaitForChild("PlayerGui") end
M.GuiInstance = gui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 390, 0, 340)
main.Position = UDim2.new(0.5, -195, 0.4, -170)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.Active, main.Draggable, main.ClipsDescendants = true, true, true
M.MainFrame = main

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Thickness, stroke.ApplyStrokeMode, stroke.LineJoinMode = 1.5, Enum.ApplyStrokeMode.Border, Enum.LineJoinMode.Round
local grad = Instance.new("UIGradient", stroke)
grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))}

local title = Instance.new("TextLabel", main)
title.Size, title.BackgroundTransparency, title.Font, title.TextSize = UDim2.new(1, 0, 0, 40), 1, Enum.Font.GothamBold, 14
title.Text, title.TextColor3 = "LATTIC HUB V2 — MURDER MYSTERY 2", Color3.fromRGB(240, 240, 255)

local function createRow(name, labelText, defaultKey, orderPos)
    local yOffset = 45 + (orderPos * 42)
    local btnT = Instance.new("TextButton", main)
    btnT.Name = "Toggle_" .. name
    btnT.Size, btnT.Position = UDim2.new(0, 175, 0, 34), UDim2.new(0, 15, 0, yOffset)
    btnT.BackgroundColor3, btnT.Text = Color3.fromRGB(35, 25, 30), labelText .. ": OFF"
    btnT.TextColor3, btnT.Font, btnT.TextSize = Color3.fromRGB(255, 90, 90), Enum.Font.GothamBold, 11
    Instance.new("UICorner", btnT).CornerRadius = UDim.new(0, 8)
    local sT = Instance.new("UIStroke", btnT) sT.Thickness, sT.Color, sT.Transparency = 1, Color3.fromRGB(255, 90, 90), 0.5

    local btnB = Instance.new("TextButton", main)
    btnB.Name = "Bind_" .. name
    btnB.Size, btnB.Position = UDim2.new(0, 175, 0, 34), UDim2.new(0, 200, 0, yOffset)
    btnB.BackgroundColor3, btnB.Text = Color3.fromRGB(30, 30, 40), "Key: " .. defaultKey.Name
    btnB.TextColor3, btnB.Font, btnB.TextSize = Color3.fromRGB(200, 200, 220), Enum.Font.GothamBold, 11
    Instance.new("UICorner", btnB).CornerRadius = UDim.new(0, 8)
    local sB = Instance.new("UIStroke", btnB) sB.Thickness, sB.Color, sB.Transparency = 1, Color3.fromRGB(255, 255, 255), 0.8

    return btnT, sT, btnB
end

M.UI = {}
M.UI.tKill, M.UI.sKill, M.UI.bKill = createRow("Kill", "AUTO KILL ALL", M.Hotkeys.AutoKill, 0)
M.UI.tFarm, M.UI.sFarm, M.UI.bFarm = createRow("Farm", "COIN AUTOFARM", M.Hotkeys.AutoFarm, 1)
M.UI.tShoot, M.UI.sShoot, M.UI.bShoot = createRow("Shoot", "PREDICTIVE SHOOT", M.Hotkeys.AutoShoot, 2)
M.UI.tFly, M.UI.sFly, M.UI.bFly = createRow("Fly", "FLY HACK", M.Hotkeys.Fly, 3)
M.UI.tNoclip, M.UI.sNoclip, M.UI.bNoclip = createRow("Noclip", "NOCLIP MODE", M.Hotkeys.Noclip, 4)
M.UI.tEsp, M.UI.sEsp, M.UI.bEsp = createRow("Esp", "ROLE VISUAL ESP", M.Hotkeys.Esp, 5)

local info = Instance.new("TextLabel", main)
info.Size, info.Position, info.BackgroundTransparency = UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 1, -25), 1
info.Text, info.TextColor3, info.Font, info.TextSize = "[RCTRL] Hide GUI | [F1] Kill Cheat Engine", Color3.fromRGB(160, 160, 180), Enum.Font.GothamSemibold, 10
local M = _G.LatticMM2V2
if not M or not M.MainFrame then return end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

function M.getCharData(p)
    local c = p and p.Character or lp.Character
    return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

function M.getPlayerRole(p)
    local box = p:FindFirstChild("PlayerGui") or p:FindFirstChildOfClass("PlayerGui")
    if box and box:FindFirstChild("Local") and box.Local:FindFirstChild("Role") then
        return box.Local.Role.Value
    end
    if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

local function updateRowVisuals(name, active, configKey, toggleBtn, strokeObj, bindBtn)
    toggleBtn.Text = active and name:upper() .. ": ENABLED" or name:upper() .. ": DISABLED"
    toggleBtn.TextColor3 = active and Color3.fromRGB(90, 255, 90) or Color3.fromRGB(255, 90, 90)
    strokeObj.Color = active and Color3.fromRGB(90, 255, 90) or Color3.fromRGB(255, 90, 90)
    if M.BindTarget ~= name then bindBtn.Text = "Key: " .. configKey.Name end
end

function M.refreshAllVisuals()
    updateRowVisuals("Auto Kill All", M.Config.AutoKill, M.Hotkeys.AutoKill, M.UI.tKill, M.UI.sKill, M.UI.bKill)
    updateRowVisuals("Coin Autofarm", M.Config.AutoFarm, M.Hotkeys.AutoFarm, M.UI.tFarm, M.UI.sFarm, M.UI.bFarm)
    updateRowVisuals("Autoshoot Murd", M.Config.AutoShoot, M.Hotkeys.AutoShoot, M.UI.tShoot, M.UI.sShoot, M.UI.bShoot)
    updateRowVisuals("Fly Hack", M.Config.Fly, M.Hotkeys.Fly, M.UI.tFly, M.UI.sFly, M.UI.bFly)
    updateRowVisuals("Noclip Mode", M.Config.Noclip, M.Hotkeys.Noclip, M.UI.tNoclip, M.UI.sNoclip, M.UI.bNoclip)
    updateRowVisuals("Visual ESP", M.Config.Esp, M.Hotkeys.Esp, M.UI.tEsp, M.UI.sEsp, M.UI.bEsp)
end

local function removeForces()
    if M.Movement.Velocity then M.Movement.Velocity:Destroy() M.Movement.Velocity = nil end
    if M.Movement.Gyro then M.Movement.Gyro:Destroy() M.Movement.Gyro = nil end
end

function M.handleFly()
    local root, hum = M.getCharData()
    if M.Config.Fly then
        if root and hum then
            hum.PlatformStand = true
            M.Movement.Gyro = Instance.new("BodyGyro", root)
            M.Movement.Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            M.Movement.Gyro.P = 15000
            M.Movement.Velocity = Instance.new("BodyVelocity", root)
            M.Movement.Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
    else
        if hum then hum.PlatformStand = false end removeForces()
    end
end

M.UI.tKill.MouseButton1Click:Connect(function() M.Config.AutoKill = not M.Config.AutoKill M.refreshAllVisuals() end)
M.UI.tFarm.MouseButton1Click:Connect(function() M.Config.AutoFarm = not M.Config.AutoFarm M.refreshAllVisuals() end)
M.UI.tShoot.MouseButton1Click:Connect(function() M.Config.AutoShoot = not M.Config.AutoShoot M.refreshAllVisuals() end)
M.UI.tFly.MouseButton1Click:Connect(function() M.Config.Fly = not M.Config.Fly M.handleFly() M.refreshAllVisuals() end)
M.UI.tNoclip.MouseButton1Click:Connect(function() M.Config.Noclip = not M.Config.Noclip M.refreshAllVisuals() end)
M.UI.tEsp.MouseButton1Click:Connect(function() M.Config.Esp = not M.Config.Esp M.refreshAllVisuals() end)

M.UI.bKill.MouseButton1Click:Connect(function() M.BindTarget = "Kill" M.UI.bKill.Text = "Press a key..." end)
M.UI.bFarm.MouseButton1Click:Connect(function() M.BindTarget = "Farm" M.UI.bFarm.Text = "Press a key..." end)
M.UI.bShoot.MouseButton1Click:Connect(function() M.BindTarget = "Shoot" M.UI.bShoot.Text = "Press a key..." end)
M.UI.bFly.MouseButton1Click:Connect(function() M.BindTarget = "Fly" M.UI.bFly.Text = "Press a key..." end)
M.UI.bNoclip.MouseButton1Click:Connect(function() M.BindTarget = "Noclip" M.UI.bNoclip.Text = "Press a key..." end)
M.UI.bEsp.MouseButton1Click:Connect(function() M.BindTarget = "Esp" M.UI.bEsp.Text = "Press a key..." end)

table.insert(M.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        M.RunLoop = false M.Config.Fly = false M.handleFly()
        for _, c in ipairs(M.Connections) do pcall(function() c:Disconnect() end) end
        for _, v in pairs(M.Visuals) do pcall(function() v:Destroy() v:Remove() end) end
        if M.GuiInstance then M.GuiInstance:Destroy() end _G.LatticMM2V2 = nil return
    end
    if M.BindTarget and input.KeyCode ~= Enum.KeyCode.Unknown then
        if M.BindTarget == "Kill" then M.Hotkeys.AutoKill = input.KeyCode
        elseif M.BindTarget == "Farm" then M.Hotkeys.AutoFarm = input.KeyCode
        elseif M.BindTarget == "Shoot" then M.Hotkeys.AutoShoot = input.KeyCode
        elseif M.BindTarget == "Fly" then M.Hotkeys.Fly = input.KeyCode
        elseif M.BindTarget == "Noclip" then M.Hotkeys.Noclip = input.KeyCode
        elseif M.BindTarget == "Esp" then M.Hotkeys.Esp = input.KeyCode end
        M.BindTarget = nil M.refreshAllVisuals() return
    end
    if input.KeyCode == M.Hotkeys.AutoKill then M.Config.AutoKill = not M.Config.AutoKill
    elseif input.KeyCode == M.Hotkeys.AutoFarm then M.Config.AutoFarm = not M.Config.AutoFarm
    elseif input.KeyCode == M.Hotkeys.AutoShoot then M.Config.AutoShoot = not M.Config.AutoShoot
    elseif input.KeyCode == M.Hotkeys.Fly then M.Config.Fly = not M.Config.Fly M.handleFly()
    elseif input.KeyCode == M.Hotkeys.Noclip then M.Config.Noclip = not M.Config.Noclip
    elseif input.KeyCode == M.Hotkeys.Esp then M.Config.Esp = not M.Config.Esp end
    M.refreshAllVisuals()
    if input.KeyCode == Enum.KeyCode.W then M.Movement.Forward = 1
    elseif input.KeyCode == Enum.KeyCode.S then M.Movement.Backward = 1
    elseif input.KeyCode == Enum.KeyCode.A then M.Movement.Left = 1
    elseif input.KeyCode == Enum.KeyCode.D then M.Movement.Right = 1 end
end))

table.insert(M.Connections, UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then M.Movement.Forward = 0
    elseif input.KeyCode == Enum.KeyCode.S then M.Movement.Backward = 0
    elseif input.KeyCode == Enum.KeyCode.A then M.Movement.Left = 0
    elseif input.KeyCode == Enum.KeyCode.D then M.Movement.Right = 0 end
end))
local M = _G.LatticMM2V2
if not M or not M.MainFrame then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

table.insert(M.Connections, RunService.RenderStepped:Connect(function()
    local root, _ = M.getCharData()
    if M.Config.Fly and root and M.Movement.Velocity and M.Movement.Gyro then
        local camCF = cam.CFrame local movVec = Vector3.new(0, 0, 0)
        if M.Movement.Forward == 1 then movVec = movVec + camCF.LookVector end
        if M.Movement.Backward == 1 then movVec = movVec - camCF.LookVector end
        if M.Movement.Left == 1 then movVec = movVec - camCF.RightVector end
        if M.Movement.Right == 1 then movVec = movVec + camCF.RightVector end
        local _, camY, _ = camCF:ToEulerAnglesYXZ() M.Movement.Gyro.CFrame = CFrame.fromEulerAnglesYXZ(0, camY, 0)
        M.Movement.Velocity.Velocity = (movVec.Magnitude > 0) and (movVec.Unit * M.Config.FlySpeed) or Vector3.new(0, 0, 0)
    end
    if M.Config.Noclip and lp.Character then
        for _, v in ipairs(lp.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end))

local function findActiveCoins()
    local cList = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent:IsA("BasePart") then
            local n = v.Parent.Name:lower()
            if n:find("coin") or n:find("snow") or n:find("candy") or n:find("gem") or v.Parent:FindFirstChild("CoinVisual") then
                table.insert(cList, v.Parent)
            end
        end
    end
    return cList
end

task.spawn(function()
    while M.RunLoop do
        task.wait(0.02) -- Maximum execution update frequency
        pcall(function()
            local myRoot, myHum = M.getCharData()
            
            -- AUTO KILL ALL
            if M.Config.AutoKill and (lp.Backpack:FindFirstChild("Knife") or (lp.Character and lp.Character:FindFirstChild("Knife"))) then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if p.Character.Humanoid.Health > 0 and myRoot then
                            myRoot.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                            task.wait(0.02)
                        end
                    end
                end
            end
            
            -- HYPER-FAST VELOCITY GLIDE AUTOFARM
            if M.Config.AutoFarm and myRoot and myHum and myHum.Health > 0 then
                local coins = findActiveCoins()
                for _, coin in ipairs(coins) do
                    if not M.Config.AutoFarm or not M.RunLoop or myHum.Health <= 0 then break end
                    if coin and coin.Parent and coin:FindFirstChildOfClass("TouchTransmitter") then
                        -- Safe below-ground positioning vectors to optimize pickup arcs
                        local targetCFrame = coin.CFrame * CFrame.new(0, -0.4, 0)
                        
                        -- Instant dynamic spatial shift mapping
                        local oldN = M.Config.Noclip M.Config.Noclip = true
                        myRoot.CFrame = targetCFrame
                        M.Config.Noclip = oldN
                        
                        -- Immediate overlap physical transaction triggering
                        pcall(function()
                            firetouchinterest(myRoot, coin, 0)
                            RunService.Heartbeat:Wait()
                            firetouchinterest(myRoot, coin, 1)
                        end)
                        task.wait(0.08) -- Optimized humanization buffer limit to bypass new heuristics
                    end
                end
            end
            
            -- PREDICATIVE INTERCEPT AIM AUTO-SHOOT
            if M.Config.AutoShoot and (lp.Backpack:FindFirstChild("Gun") or (lp.Character and lp.Character:FindFirstChild("Gun"))) then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and M.getPlayerRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local mRoot = p.Character.HumanoidRootPart
                        local tool = lp.Character:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun")
                        if tool and tool.Parent == lp.Backpack then lp.Character.Humanoid:EquipTool(tool) end
                        
                        -- Interception Vector Math: Evaluates enemy velocity to fire exactly where their head travels
                        local targetVelocity = mRoot.AssemblyLinearVelocity or mRoot.Velocity
                        local predictedPosition = mRoot.Position + (targetVelocity * 0.14) -- 140ms server latency prediction
                        
                        local shootRemote = ReplicatedStorage:FindFirstChild("ShootGun") or ReplicatedStorage:FindFirstChild("UseSkill")
                        if shootRemote then 
                            shootRemote:FireServer(predictedPosition) 
                        else 
                            cam.CFrame = CFrame.new(cam.CFrame.Position, predictedPosition) 
                        end
                        task.wait(0.1)
                    end
                end
            end
        end)
    end
end)

local function buildESP(p)
    if p == lp then return end
    local function added(char)
        task.wait(0.4)
        if not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local h = char:FindFirstChild("LatticHighlight") or Instance.new("Highlight", char)
        h.Name = "LatticHighlight" h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop h.FillTransparency = 0.4 h.OutlineTransparency = 0.1
        table.insert(M.Visuals, h)

        local label = Drawing.new("Text") label.Size = 18 label.Center = true label.Outline = true label.Color = Color3.fromRGB(255, 255, 255) label.Visible = false
        table.insert(M.Visuals, label)

        local cEvent
        cEvent = RunService.RenderStepped:Connect(function()
            if not M.RunLoop or not M.Config.Esp or not char.Parent or not root.Parent then label.Visible = false h.Enabled = false return end
            local role = M.getPlayerRole(p)
            local color = (role == "Murderer" and Color3.fromRGB(255, 50, 50)) or (role == "Sheriff" and Color3.fromRGB(50, 100, 255)) or Color3.fromRGB(50, 255, 100)
            h.Enabled = true h.FillColor = color h.OutlineColor = Color3.fromRGB(255,255,255)
            
            local myRoot, _ = M.getCharData()
            local sPos, on = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            if on and myRoot then
                local dist = math.floor((root.Position - myRoot.Position).Magnitude)
                label.Position = Vector2.new(sPos.X, sPos.Y)
                label.Text = string.format("%s\n[%s] - %dm", p.DisplayName, role:upper(), dist)
                label.Visible = true
            else label.Visible = false end
        end)
        table.insert(M.Connections, cEvent)
    end
    if p.Character then task.spawn(added, p.Character) end
    table.insert(M.Connections, p.CharacterAdded:Connect(added))
end
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
table.insert(M.Connections, Players.PlayerAdded:Connect(buildESP))

table.insert(M.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= Enum.KeyCode.RightControl then return end
    M.IsVisible = not M.IsVisible
    if M.IsVisible then
        M.MainFrame.Visible = true TweenService:Create(M.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 390, 0, 340), BackgroundTransparency = 0.25}):Play()
    else
        local t = TweenService:Create(M.MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 390, 0, 0), BackgroundTransparency = 1})
        t:Play() t.Completed:Connect(function() if not M.IsVisible then M.MainFrame.Visible = false end end)
    end
end))
M.refreshAllVisuals()
