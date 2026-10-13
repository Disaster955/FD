local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local MAX_ITEM_HL = 35
local CHECK_INTERVAL = 4
local FILL_TRANSP = 0.55
local OUTLINE_TRANSP = 0.2

local itemHL = {}
local playerHL = {}
local hookedPrompts = setmetatable({}, {__mode = "k"})
local itemCount = 0

local function safeDestroy(obj)
    if obj and typeof(obj) == "Instance" and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function isValidPart(obj)
    return obj and obj:IsA("BasePart") and obj.Parent
end

local function forcePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or hookedPrompts[prompt] then return end
    hookedPrompts[prompt] = true

    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        if prompt.MaxActivationDistance < 18 then
            prompt.MaxActivationDistance = 18
        end
    end)

    local conn1 = prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
        if prompt.Parent and prompt.HoldDuration ~= 0 then
            prompt.HoldDuration = 0
        end
    end)
    local conn2 = prompt:GetPropertyChangedSignal("RequiresLineOfSight"):Connect(function()
        if prompt.Parent and prompt.RequiresLineOfSight ~= false then
            prompt.RequiresLineOfSight = false
        end
    end)

    prompt.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if conn1 then conn1:Disconnect() end
            if conn2 then conn2:Disconnect() end
            hookedPrompts[prompt] = nil
        end
    end)
end

local function createItemHighlight(part)
    if not isValidPart(part) then return end
    if itemHL[part] then return itemHL[part] end
    if itemCount >= MAX_ITEM_HL then return end

    local hl = Instance.new("Highlight")
    hl.Name = "MItemHL"
    hl.Adornee = part
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = Color3.fromRGB(255, 40, 40)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = FILL_TRANSP
    hl.OutlineTransparency = OUTLINE_TRANSP
    hl.Enabled = true
    hl.Parent = part

    itemHL[part] = hl
    itemCount += 1

    hl:GetPropertyChangedSignal("Enabled"):Connect(function()
        if hl.Parent and not hl.Enabled then
            hl.Enabled = true
        end
    end)

    part.AncestryChanged:Connect(function(_, parent)
        if not parent then
            safeDestroy(itemHL[part])
            itemHL[part] = nil
            itemCount = math.max(0, itemCount - 1)
        end
    end)

    return hl
end

local function setupItem(part)
    if not isValidPart(part) then return end
    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end
    forcePrompt(prompt)
    createItemHighlight(part)
end

local function scanContainer(container)
    if not container then return end
    for _, v in ipairs(container:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            forcePrompt(v)
            local base = v.Parent
            if base and base:IsA("Attachment") then
                base = base.Parent
            end
            if isValidPart(base) then
                setupItem(base)
            end
        end
    end
end

local function hookMap(map)
    local items = map:FindFirstChild("Items")
    if not items then
        items = map:WaitForChild("Items", 6)
    end
    if not items then return end

    scanContainer(items)

    items.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if obj:IsA("ProximityPrompt") then
                forcePrompt(obj)
                local base = obj.Parent
                if base and base:IsA("Attachment") then
                    base = base.Parent
                end
                if isValidPart(base) then
                    setupItem(base)
                end
            elseif obj:IsA("BasePart") then
                setupItem(obj)
            end
        end)
    end)
end

local function watchItems()
    local gd = workspace:FindFirstChild("GameDebris") or workspace:WaitForChild("GameDebris", 10)
    if not gd then return end

    local current = gd:FindFirstChild("CurrentMap")
    if current then
        task.spawn(hookMap, current)
    end

    gd.ChildAdded:Connect(function(child)
        if child.Name == "CurrentMap" then
            task.wait(1.2)
            hookMap(child)
        end
    end)
end

local function protectCharacter(char)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Highlight") and v.Name ~= "MPlayerHL" then
            safeDestroy(v)
        end
    end
    char.DescendantAdded:Connect(function(v)
        if v:IsA("Highlight") and v.Name ~= "MPlayerHL" then
            task.defer(safeDestroy, v)
        end
    end)
end

local function createPlayerHighlight(plr, char)
    if not char then return end
    if playerHL[plr] then
        safeDestroy(playerHL[plr])
        playerHL[plr] = nil
    end

    local hl = Instance.new("Highlight")
    hl.Name = "MPlayerHL"
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0.15
    hl.Enabled = true
    hl.Parent = char

    local team = plr.Team
    if team and team.Name == "Survivors" then
        hl.FillColor = Color3.fromRGB(240, 240, 240)
        hl.OutlineColor = Color3.fromRGB(180, 180, 180)
    else
        hl.FillColor = Color3.fromRGB(255, 30, 30)
        hl.OutlineColor = Color3.fromRGB(255, 120, 120)
    end

    hl:GetPropertyChangedSignal("Enabled"):Connect(function()
        if hl.Parent and not hl.Enabled then
            hl.Enabled = true
        end
    end)

    playerHL[plr] = hl
    return hl
end

local function updatePlayer(plr)
    if plr == LP then return end

    local team = plr.Team
    local char = plr.Character

    if not team or (team.Name ~= "Survivors" and team.Name ~= "Killers") then
        if playerHL[plr] then
            safeDestroy(playerHL[plr])
            playerHL[plr] = nil
        end
        return
    end

    if not char then return end

    protectCharacter(char)

    local hl = playerHL[plr]
    if not hl or not hl.Parent then
        createPlayerHighlight(plr, char)
    else
        hl.Adornee = char
        hl.Enabled = true
        if team.Name == "Survivors" then
            hl.FillColor = Color3.fromRGB(240, 240, 240)
        else
            hl.FillColor = Color3.fromRGB(255, 30, 30)
        end
    end
end

local function hookPlayer(plr)
    if plr == LP then return end

    plr:GetPropertyChangedSignal("Team"):Connect(function()
        updatePlayer(plr)
    end)

    plr.CharacterAdded:Connect(function()
        task.wait(0.8)
        updatePlayer(plr)
    end)

    if plr.Character then
        updatePlayer(plr)
    end
end

task.spawn(function()
    while true do
        task.wait(CHECK_INTERVAL)

        for part, hl in pairs(itemHL) do
            if not part or not part.Parent then
                safeDestroy(hl)
                itemHL[part] = nil
                itemCount = math.max(0, itemCount - 1)
            elseif not hl or not hl.Parent then
                itemHL[part] = nil
                itemCount = math.max(0, itemCount - 1)
                createItemHighlight(part)
            elseif not hl.Enabled then
                hl.Enabled = true
            end
        end

        for plr, hl in pairs(playerHL) do
            if not plr or not plr.Parent or not plr.Character then
                safeDestroy(hl)
                playerHL[plr] = nil
            elseif not hl or not hl.Parent then
                createPlayerHighlight(plr, plr.Character)
            elseif not hl.Enabled then
                hl.Enabled = true
            end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(hookPlayer, p)
end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(plr)
    safeDestroy(playerHL[plr])
    playerHL[plr] = nil
end)

watchItems()
