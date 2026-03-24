-- AUTO CHECKPOINT DETECT + AUTO RACE

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local running = false
local speed = 75

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,230,0,160)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "AUTO CHECKPOINT PRO"
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

-- 🔍 SCAN CHECKPOINT
local function getCheckpoints()
    local checkpoints = {}

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:find("checkpoint") or name:find("cp") then
                table.insert(checkpoints, v)
            end
        end
    end

    return checkpoints
end

-- 📊 URUTKAN CHECKPOINT (berdasarkan jarak dari player)
local function sortCheckpoints(list)
    table.sort(list, function(a, b)
        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
    end)
    return list
end

-- 🚗 GERAK
local function moveTo(target)
    while running and (root.Position - target).Magnitude > 8 do
        task.wait(0.05)

        local direction = (target - root.Position).Unit

        -- smooth arah
        local newDir = root.CFrame.LookVector:Lerp(direction, 0.2)

        root.Velocity = newDir * speed
        root.CFrame = CFrame.new(root.Position, root.Position + newDir)

        -- anti stuck
        if root.Velocity.Magnitude < 5 then
            char.Humanoid.Jump = true
        end
    end
end

-- 🔁 LOOP UTAMA
task.spawn(function()
    while true do
        task.wait()

        if running then
            status.Text = "Scanning checkpoint..."

            local cps = getCheckpoints()
            cps = sortCheckpoints(cps)

            if #cps == 0 then
                status.Text = "Checkpoint not found!"
                task.wait(3)
                continue
            end

            status.Text = "Racing..."

            for i,cp in ipairs(cps) do
                if not running then break end
                status.Text = "Checkpoint "..i.."/"..#cps
                moveTo(cp.Position + Vector3.new(0,3,0))
            end

            status.Text = "Finish! Looping..."
            task.wait(3)
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
