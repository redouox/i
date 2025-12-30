-- Hello guys, I decided to open source this autofarm because I don't really care about updating it anymore,
-- so go ahead if you want to stick with it. I decided to let ChatGPT explain what every function does. Bye.

-- =====================
-- SERVICES
-- =====================
-- These lines get the main Roblox services we need.
local Players = game:GetService("Players")  -- To access player objects
local ReplicatedStorage = game:GetService("ReplicatedStorage")  -- To access remote events/functions

-- Get the local player and their character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")  -- Used to move the character in the world

-- Reference to the remote event used for "ice skating" in the game
local iceSkateRemote = ReplicatedStorage
    :WaitForChild("adoptme_new_net")
    :WaitForChild("adoptme_legacy_shared.ContentPacks.Winter2025.Game.IceSkating.IceSkatingNet:16")

-- Autofarm control variables
local enabled = false  -- Tracks whether autofarm is ON or OFF
local insideDelay = 0.05  -- Small delay between actions to prevent errors

-- =====================
-- HELPER FUNCTIONS
-- =====================
-- This function finds the closest Gingerbread Rig in the workspace
local function getNearestGingerbread()
    local nearest, shortest = nil, math.huge  -- Start with no nearest object and infinite distance
    for _, obj in ipairs(workspace:GetDescendants()) do  -- Loop through everything in the workspace
        if obj.Name == "GingerbreadRig" then  -- Only check objects named GingerbreadRig
            local pos
            if obj:IsA("Model") then
                pos = obj:GetPivot().Position  -- Get the position if it's a Model
            elseif obj:IsA("BasePart") then
                pos = obj.Position  -- Or get position directly if it's a part
            end
            if pos then
                local dist = (hrp.Position - pos).Magnitude  -- Calculate distance from player
                if dist < shortest then
                    shortest = dist  -- Update shortest distance
                    nearest = obj  -- Update nearest object
                end
            end
        end
    end
    return nearest  -- Return the closest GingerbreadRig
end

-- =====================
-- UI CREATION (Modern Style)
-- =====================
-- Create a screen GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ModernGingerbreadUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")  -- Add it to the player's GUI

-- Create main frame for the UI
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 380)
frame.Position = UDim2.fromScale(0.35,0.25)
frame.BackgroundColor3 = Color3.fromRGB(38,38,38)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true  -- Makes the frame draggable
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)  -- Rounded corners

-- Shadow effect for the frame
local shadow = Instance.new("UIStroke")
shadow.Thickness = 2
shadow.Color = Color3.fromRGB(60,60,60)
shadow.Parent = frame

-- Layout for elements in the frame
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,12)
layout.Parent = frame

-- Title text
local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(250,40)
title.BackgroundTransparency = 1
title.Text = "GINGERBREAD AUTOFARM"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

-- Game label
local gameLabel = Instance.new("TextLabel")
gameLabel.Size = UDim2.fromOffset(250,30)
gameLabel.BackgroundTransparency = 1
gameLabel.Text = "Game: Adopt Me"
gameLabel.Font = Enum.Font.Gotham
gameLabel.TextScaled = true
gameLabel.TextColor3 = Color3.fromRGB(200,200,200)
gameLabel.Parent = frame

-- Autofarm status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.fromOffset(250,25)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Autofarm: OFF"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
statusLabel.Parent = frame

-- Buttons container
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.fromOffset(240,180)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = frame

local buttonsLayout = Instance.new("UIListLayout")
buttonsLayout.FillDirection = Enum.FillDirection.Vertical
buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonsLayout.Padding = UDim.new(0,12)
buttonsLayout.Parent = buttonsFrame

-- Helper function to create buttons
local function createButton(text, color, sizeY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(180, sizeY)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = color
    btn.Parent = buttonsFrame
    Instance.new("UICorner", btn)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Parent = btn
    return btn
end

-- Create ON, OFF, DELETE buttons
local onButton = createButton("ON", Color3.fromRGB(0,170,0), 55)
local offButton = createButton("OFF", Color3.fromRGB(170,0,0), 55)
local deleteButton = createButton("DELETE", Color3.fromRGB(60,60,60), 40)

-- =====================
-- BUTTON LOGIC
-- =====================
onButton.MouseButton1Click:Connect(function()
    enabled = true
    statusLabel.Text = "Autofarm: ON"
    statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
end)

offButton.MouseButton1Click:Connect(function()
    enabled = false
    statusLabel.Text = "Autofarm: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
end)

deleteButton.MouseButton1Click:Connect(function()
    enabled = false
    gui:Destroy()
end)

-- =====================
-- CREDITS LABEL
-- =====================
local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.fromOffset(250,25)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Credits: Johnwiz:3"
creditsLabel.Font = Enum.Font.Gotham
creditsLabel.TextScaled = true
creditsLabel.TextColor3 = Color3.fromRGB(180,180,180)
creditsLabel.Parent = frame

-- =====================
-- AUTOFARM LOOP
-- =====================
task.spawn(function()
    while true do
        if enabled then
            local gingerbread = getNearestGingerbread()
            if gingerbread then
                local pos
                if gingerbread:IsA("Model") then
                    pos = gingerbread:GetPivot().Position
                else
                    pos = gingerbread.Position
                end
                hrp.CFrame = CFrame.new(pos)  -- Move player to GingerbreadRig
                task.wait(insideDelay)
                pcall(function()
                    iceSkateRemote:FireServer()  -- Fire the remote event to collect/interact
                end)
            else
                task.wait(0.1)  -- Wait a bit if nothing is nearby
            end
        else
            task.wait(0.1)  -- Wait a bit if autofarm is disabled
        end
    end
end)
