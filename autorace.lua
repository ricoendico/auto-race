-- AUTO RACE + EVENT + RESET GUI

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local runningRace = false
local runningEvent = false
local speed = 75

-- posisi awal (buat reset)
local startPos = root.Position

-- fallback event (opsional)
local manualEvent = Vector3.new(0,5,0)

-- 🖥️ GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,250,0,240)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "CDID FARM HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- AUTO RACE BUTTON
local raceBtn = Instance.new("TextButton", frame)
raceBtn.Size = UDim2.new(1,-20,0,40)
raceBtn.Position = UDim2.new(0,10,0,50)
raceBtn.Text = "AUTO RACE: OFF"
raceBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
raceBtn.TextColor3 = Color3.new(1,1,1)

-- EVENT BUTTON
local eventBtn = Instance.new("TextButton", frame)
eventBtn.Size = UDim2.new(1,-20,0,40)
eventBtn.Position = UDim2.new(0,10,0,100)
eventBtn.Text = "AUTO EVENT: OFF"
eventBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
eventBtn.TextColor3 = Color3.new(1,1,1)

-- RESET BUTTON
local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(1,-20,0,40)
resetBtn.Position = UDim2.new(0,10,0,150)
resetBtn.Text = "RESET"
resetBtn.BackgroundColor3 = Color3.fromRGB(200,120,0)
resetBtn.TextColor3 = Color3.new(1,1,1)

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,30)
status.Position = UDim2.new(0,0,0,200)
status.Text = "Status: Idle"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1

-- 🔍 CHECKPOINT
local function getCheckpoints()
    local cps = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:find("checkpoint") or name:find("cp") then
                table.insert(cps, v)
            end
        end
    end
    return cps
end

local function sortCheckpoints(cps)
    table.sort(cps, function(a,b)
        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
    end)
    return cps
end

-- 🚗 MOVE
local function moveTo(target)
    while runningRace and (root.Position - target).Magnitude > 8 do
        task.wait(0.05)

        local dir = (target - root.Position).Unit
        local smooth = root.CFrame.LookVector:Lerp(dir,0.2)

        root.Velocity = smooth * speed
        root.CFrame = CFrame.new(root.Position, root.Position + smooth)

        if root.Velocity.Magnitude < 5 then
            char.Humanoid.Jump = true
        end
    end
end

-- 🎯 EVENT TELEPORT
local function teleportEvent()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("event") then
            root.CFrame = v.CFrame + Vector3.new(0,3,0)
            return
        end
    end
    root.CFrame = CFrame.new(manualEvent)
end

-- 🔁 LOOP
task.spawn(function()
    while true do
        task.wait()

        if runningEvent then
            status.Text = "Teleporting Event..."
            teleportEvent()
            task.wait(5)
        end

        if runningRace then
            status.Text = "Scanning Checkpoint..."
            local cps = sortCheckpoints(getCheckpoints())

            if #cps > 0 then
                status.Text = "Racing..."
                for i,cp in ipairs(cps) do
                    if not runningRace then break end
                    status.Text = "CP "..i.."/"..#cps
                    moveTo(cp.Position + Vector3.new(0,3,0))
                end
                status.Text = "Finish!"
                task.wait(3)
            else
                status.Text = "No Checkpoint!"
                task.wait(2)
            end
        end
    end
end)

-- 🎮 BUTTON CONTROL

raceBtn.MouseButton1Click:Connect(function()
    runningRace = not runningRace
    raceBtn.Text = runningRace and "AUTO RACE: ON" or "AUTO RACE: OFF"
    raceBtn.BackgroundColor3 = runningRace and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

eventBtn.MouseButton1Click:Connect(function()
    runningEvent = not runningEvent
    eventBtn.Text = runningEvent and "AUTO EVENT: ON" or "AUTO EVENT: OFF"
    eventBtn.BackgroundColor3 = runningEvent and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
end)

-- 🔄 RESET FUNCTION
resetBtn.MouseButton1Click:Connect(function()
    runningRace = false
    runningEvent = false

    raceBtn.Text = "AUTO RACE: OFF"
    eventBtn.Text = "AUTO EVENT: OFF"

    raceBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
    eventBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)

    -- balik ke posisi awal
    root.CFrame = CFrame.new(startPos)

    status.Text = "Status: RESET"
end)
