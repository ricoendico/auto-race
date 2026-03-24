-- AUTO RACE PRO (SAFE STYLE)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local running = false
local speed = 70

-- WAYPOINT (EDIT SESUAI MAP!)
local waypoints = {
    Vector3.new(0,5,0),
    Vector3.new(100,5,50),
    Vector3.new(300,5,200),
    Vector3.new(600,5,400),
    Vector3.new(1000,5,800)
}

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,150)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "AUTO RACE PRO"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,40)
toggle.Position = UDim2.new(0,10,0,50)
toggle.Text = "START"
toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
toggle.TextColor3 = Color3.new(1,1,1)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,30)
status.Position = UDim2.new(0,0,0,100)
status.Text = "Status: OFF"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1

-- DETEKSI RACE (SIMPLE)
local function findRacePart()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("race") and v:IsA("BasePart") then
            return v
        end
    end
end

-- AUTO JOIN (natural style)
local function autoJoinRace()
    local race = findRacePart()
    if race then
        root.CFrame = race.CFrame + Vector3.new(0,3,0)
        task.wait(2) -- delay biar natural
    end
end

-- GERAK KE WAYPOINT
local function moveTo(target)
    while running and (root.Position - target).Magnitude > 10 do
        task.wait(0.05)

        local direction = (target - root.Position).Unit

        -- smooth movement
        local currentLook = root.CFrame.LookVector
        local newDir = currentLook:Lerp(direction, 0.15)

        root.Velocity = newDir * speed
        root.CFrame = CFrame.new(root.Position, root.Position + newDir)

        -- anti stuck
        if root.Velocity.Magnitude < 5 then
            char.Humanoid.Jump = true
        end
    end
end

-- LOOP UTAMA
task.spawn(function()
    while true do
        task.wait()

        if running then
            status.Text = "Status: JOINING..."
            autoJoinRace()

            status.Text = "Status: RACING..."
            for _,point in ipairs(waypoints) do
                if not running then break end
                moveTo(point)
            end

            status.Text = "Status: FINISH"
            task.wait(3) -- delay biar nggak spam
        end
    end
end)

-- TOGGLE
toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "STOP" or "START"
    toggle.BackgroundColor3 = running and Color3.fromRGB(170,0,0) or Color3.fromRGB(0,170,0)
    status.Text = running and "Status: ON" or "Status: OFF"
end)
