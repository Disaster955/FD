-- Tixjam | Fluent UI
-- Author: Scream Jam
-- Full version + Mobile Floating Button (draggable)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/1dontgiveaf/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/1dontgiveaf/Fluent/main/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Tixjam",
    SubTitle = "by Scream Jam",
    TabWidth = 140,
    Size = UDim2.fromOffset(520, 500),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Stamina = Window:AddTab({ Title = "Stamina", Icon = "person-standing" }),
    Items = Window:AddTab({ Title = "Items", Icon = "package" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

-- ============================================================
-- GLOBALS (todo empieza vacío / off)
-- ============================================================
_G.ESPS = false
_G.ESPK = false
_G.ItemESP = false

_G.ColorSurvivors = Color3.fromRGB(255, 255, 255)
_G.ColorKillers   = Color3.fromRGB(255, 30, 30)
_G.ColorItems     = Color3.fromRGB(255, 40, 40)

_G.SurvFillTrans  = 0.35
_G.SurvOutTrans   = 0
_G.KillFillTrans  = 0.35
_G.KillOutTrans   = 0
_G.ItemFillTrans  = 0.3
_G.ItemOutTrans   = 0

_G.SMax   = nil
_G.SLoss  = nil
_G.SGain  = nil
_G.SDelay = false
_G.Run    = nil
_G.Item   = false

-- ============================================================
-- ESP TAB
-- ============================================================
Tabs.ESP:AddToggle("ESPS", {
    Title = "Esp Survivors",
    Default = false,
    Callback = function(v) _G.ESPS = v end
})

Tabs.ESP:AddToggle("ESPK", {
    Title = "Esp Killers",
    Default = false,
    Callback = function(v) _G.ESPK = v end
})

Tabs.ESP:AddColorpicker("ColorSurvivors", {
    Title = "Survivors Color",
    Default = _G.ColorSurvivors,
    Callback = function(v) _G.ColorSurvivors = v end
})

Tabs.ESP:AddColorpicker("ColorKillers", {
    Title = "Killers Color",
    Default = _G.ColorKillers,
    Callback = function(v) _G.ColorKillers = v end
})

Tabs.ESP:AddInput("SurvFillTrans", {
    Title = "S Fill Transparency",
    Default = "",
    Placeholder = "0 a 1 (ej: 0.35)",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        _G.SurvFillTrans = n ~= nil and math.clamp(n, 0, 1) or 0.35
    end
})

Tabs.ESP:AddInput("SurvOutTrans", {
    Title = "S Outline Transparency",
    Default = "",
    Placeholder = "0 a 1 (ej: 0)",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        _G.SurvOutTrans = n ~= nil and math.clamp(n, 0, 1) or 0
    end
})

Tabs.ESP:AddInput("KillFillTrans", {
    Title = "K Fill Transparency",
    Default = "",
    Placeholder = "0 a 1 (ej: 0.35)",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        _G.KillFillTrans = n ~= nil and math.clamp(n, 0, 1) or 0.35
    end
})

Tabs.ESP:AddInput("KillOutTrans", {
    Title = "K Outline Transparency",
    Default = "",
    Placeholder = "0 a 1 (ej: 0)",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        _G.KillOutTrans = n ~= nil and math.clamp(n, 0, 1) or 0
    end
})

Tabs.ESP:AddToggle("ItemESP", {
    Title = "Esp Items",
    Default = false,
    Callback = function(v) _G.ItemESP = v end
})

Tabs.ESP:AddColorpicker("ColorItems", {
    Title = "Items Color",
    Default = _G.ColorItems,
    Callback = function(v) _G.ColorItems = v end
})

Tabs.ESP:AddInput("ItemFillTrans", {
    Title = "Items Fill Transparency",
    Default = "",
    Placeholder = "0 a 1 (ej: 0.3)",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        _G.ItemFillTrans = n ~= nil and math.clamp(n, 0, 1) or 0.3
    end
})

Tabs.ESP:AddInput("ItemOutTrans", {
    Title = "Items Outline Transparency",
    Default = "",
    Placeholder = "0 a 1 (ej: 0)",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        _G.ItemOutTrans = n ~= nil and math.clamp(n, 0, 1) or 0
    end
})

-- ============================================================
-- STAMINA TAB
-- ============================================================
Tabs.Stamina:AddInput("SMaxInput", {
    Title = "Stamina Max",
    Default = "",
    Placeholder = "Ej: 100",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        _G.SMax = tonumber(v)
    end
})

Tabs.Stamina:AddInput("SLossInput", {
    Title = "Stamina Loss",
    Default = "",
    Placeholder = "Ej: 10",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        _G.SLoss = tonumber(v)
    end
})

Tabs.Stamina:AddInput("SGainInput", {
    Title = "Stamina Gain",
    Default = "",
    Placeholder = "Ej: 20",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        _G.SGain = tonumber(v)
    end
})

Tabs.Stamina:AddToggle("SDelayToggle", {
    Title = "No Stamina Delay",
    Default = false,
    Callback = function(v)
        _G.SDelay = v
    end
})

Tabs.Stamina:AddInput("RunInput", {
    Title = "Run Speed",
    Default = "",
    Placeholder = "Ej: 2",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        _G.Run = tonumber(v)
    end
})

-- ============================================================
-- ITEMS TAB
-- ============================================================
Tabs.Items:AddToggle("InstantPick", {
    Title = "Instan Item Pick",
    Default = false,
    Callback = function(v)
        _G.Item = v
    end
})

-- ============================================================
-- SISTEMAS
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TixjamESP_" .. tostring(math.random(100000,999999))
ESPFolder.Parent = CoreGui

-- ========== STAMINA FINDER ==========
local systems = nil
local function findSystems()
    local char = LP.Character
    if not char then return nil end
    for _, v in getgc(true) do
        if type(v) == "table" and rawget(v, "maxStamina") and rawget(v, "staminaLossRate") and rawget(v, "character") == char and rawget(v, "isActive") then
            return v
        end
    end
    return nil
end
local function refreshSystems()
    systems = findSystems()
end
LP.CharacterAdded:Connect(function()
    systems = nil
    task.wait(1.2)
    refreshSystems()
end)
refreshSystems()

-- ========== ESP ==========
local playerHL, itemHL = {}, {}

local function isSurvivorName(n)
    if not n then return false end
    return string.lower(tostring(n)):find("survivor") ~= nil
end
local function isKillerName(n)
    if not n then return false end
    return string.lower(tostring(n)):find("killer") ~= nil
end

local function getRoleFromModel(model)
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and plr.Team then
        if isKillerName(plr.Team.Name) then return "Killer" end
        if isSurvivorName(plr.Team.Name) then return "Survivor" end
    end
    local parent = model.Parent
    if parent then
        if isKillerName(parent.Name) then return "Killer" end
        if isSurvivorName(parent.Name) then return "Survivor" end
        if parent.Parent then
            if isKillerName(parent.Parent.Name) then return "Killer" end
            if isSurvivorName(parent.Parent.Name) then return "Survivor" end
        end
    end
    local role = model:GetAttribute("Role") or model:GetAttribute("role") or model:GetAttribute("Team")
    if role then
        if isKillerName(role) then return "Killer" end
        if isSurvivorName(role) then return "Survivor" end
    end
    return nil
end

local function protectModel(model)
    if not model or not model:IsA("Model") then return end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("Highlight") and v.Name ~= "TixjamPlayerHL" and v.Name ~= "TixjamItemHL" then
            v:Destroy()
        end
    end
    if not model:GetAttribute("TixjamProtected") then
        model:SetAttribute("TixjamProtected", true)
        model.DescendantAdded:Connect(function(v)
            if v:IsA("Highlight") and v.Name ~= "TixjamPlayerHL" and v.Name ~= "TixjamItemHL" then
                task.defer(function() if v and v.Parent then v:Destroy() end end)
            end
        end)
    end
end

local function forceHL(hl, enabled, fill, outline, fillT, outT)
    if not hl or not hl.Parent then return end
    pcall(function()
        hl.Enabled = enabled
        hl.FillColor = fill
        hl.OutlineColor = outline
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = fillT or 0.35
        hl.OutlineTransparency = outT or 0
    end)
end

local function createPlayerHL(model, role)
    if not model or not model:IsA("Model") or model == LP.Character then return end
    protectModel(model)

    local hl = playerHL[model]
    if hl and hl.Parent then
        if role == "Killer" then
            forceHL(hl, _G.ESPK, _G.ColorKillers, _G.ColorKillers, _G.KillFillTrans, _G.KillOutTrans)
        elseif role == "Survivor" then
            forceHL(hl, _G.ESPS, _G.ColorSurvivors, _G.ColorSurvivors, _G.SurvFillTrans, _G.SurvOutTrans)
        end
        return hl
    end

    hl = Instance.new("Highlight")
    hl.Name = "TixjamPlayerHL"
    hl.Adornee = model
    hl.Parent = ESPFolder
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local conns = {}
    local function lock()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        table.clear(conns)
        table.insert(conns, hl:GetPropertyChangedSignal("Enabled"):Connect(function()
            if role == "Killer" and _G.ESPK and not hl.Enabled then hl.Enabled = true end
            if role == "Survivor" and _G.ESPS and not hl.Enabled then hl.Enabled = true end
        end))
        table.insert(conns, hl:GetPropertyChangedSignal("DepthMode"):Connect(function()
            if hl.DepthMode ~= Enum.HighlightDepthMode.AlwaysOnTop then
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end))
    end
    lock()

    if role == "Killer" then
        forceHL(hl, _G.ESPK, _G.ColorKillers, _G.ColorKillers, _G.KillFillTrans, _G.KillOutTrans)
    else
        forceHL(hl, _G.ESPS, _G.ColorSurvivors, _G.ColorSurvivors, _G.SurvFillTrans, _G.SurvOutTrans)
    end

    playerHL[model] = hl
    model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if playerHL[model] then playerHL[model]:Destroy() playerHL[model] = nil end
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        end
    end)
    return hl
end

local function scanForPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local role = getRoleFromModel(plr.Character)
            if role then createPlayerHL(plr.Character, role) end
        end
    end
    local roots = {workspace:FindFirstChild("Players"), workspace:FindFirstChild("Characters"), workspace:FindFirstChild("GameDebris"), workspace}
    for _, root in ipairs(roots) do
        if root then
            for _, child in ipairs(root:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    local name = child.Name
                    if isSurvivorName(name) or isKillerName(name) then
                        for _, model in ipairs(child:GetChildren()) do
                            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
                                createPlayerHL(model, isKillerName(name) and "Killer" or "Survivor")
                            end
                        end
                    end
                end
            end
        end
    end
end

local function createItemHL(obj)
    if itemHL[obj] and itemHL[obj].Parent then
        forceHL(itemHL[obj], _G.ItemESP, _G.ColorItems, _G.ColorItems, _G.ItemFillTrans, _G.ItemOutTrans)
        return itemHL[obj]
    end
    local hl = Instance.new("Highlight")
    hl.Name = "TixjamItemHL"
    hl.Adornee = obj
    hl.Parent = ESPFolder
    forceHL(hl, _G.ItemESP, _G.ColorItems, _G.ColorItems, _G.ItemFillTrans, _G.ItemOutTrans)
    itemHL[obj] = hl
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent and itemHL[obj] then itemHL[obj]:Destroy() itemHL[obj] = nil end
    end)
    return hl
end

local function setupItem(obj)
    if not obj or not obj:IsA("BasePart") then return end
    if not obj:FindFirstChildWhichIsA("ProximityPrompt", true) then return end
    createItemHL(obj)
end

local function scanItems(container)
    if not container then return end
    for _, v in ipairs(container:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local base = v.Parent
            if base and base:IsA("Attachment") then base = base.Parent end
            if base and base:IsA("BasePart") then setupItem(base) end
        end
    end
end

local function watchItems()
    local gd = workspace:WaitForChild("GameDebris", 10)
    if not gd then return end
    local function hook(map)
        local items = map:FindFirstChild("Items") or map:WaitForChild("Items", 5)
        if items then
            scanItems(items)
            items.DescendantAdded:Connect(function(v)
                if v:IsA("ProximityPrompt") then
                    local base = v.Parent
                    if base and base:IsA("Attachment") then base = base.Parent end
                    if base and base:IsA("BasePart") then setupItem(base) end
                end
            end)
        end
    end
    local current = gd:FindFirstChild("CurrentMap")
    if current then hook(current) end
    gd.ChildAdded:Connect(function(v)
        if v.Name == "CurrentMap" then task.wait(0.8) hook(v) end
    end)
end

RunService.Heartbeat:Connect(function()
    scanForPlayers()
    for model, hl in pairs(playerHL) do
        if hl and hl.Parent and model and model.Parent then
            local role = getRoleFromModel(model)
            if role == "Killer" then
                forceHL(hl, _G.ESPK, _G.ColorKillers, _G.ColorKillers, _G.KillFillTrans, _G.KillOutTrans)
            elseif role == "Survivor" then
                forceHL(hl, _G.ESPS, _G.ColorSurvivors, _G.ColorSurvivors, _G.SurvFillTrans, _G.SurvOutTrans)
            end
            protectModel(model)
        else
            if hl then pcall(function() hl:Destroy() end) end
            playerHL[model] = nil
        end
    end
    for obj, hl in pairs(itemHL) do
        if hl and hl.Parent then
            forceHL(hl, _G.ItemESP, _G.ColorItems, _G.ColorItems, _G.ItemFillTrans, _G.ItemOutTrans)
        end
    end
end)

watchItems()

-- ========== STAMINA SYSTEMS ==========
task.spawn(function()
    while true do
        task.wait(0.12)
        if not systems or not systems.isActive then
            refreshSystems()
            if not systems then continue end
        end

        if _G.SMax ~= nil then
            systems.maxStamina = _G.SMax
            pcall(function()
                systems.character:SetAttribute("MaxStamina", _G.SMax)
                if systems.stamina > _G.SMax then
                    systems.stamina = _G.SMax
                    systems.character:SetAttribute("Stamina", _G.SMax)
                end
            end)
        end

        if _G.SLoss ~= nil then
            systems.staminaLossRate = _G.SLoss
        end

        if _G.SGain ~= nil then
            systems.staminaGainRate = _G.SGain
        end

        if _G.SDelay == true then
            systems.staminaRegenDelayUntil = 0
        end
    end
end)

-- ========== RUN ==========
local runSys = nil
local function findRunSystem()
    local char = LP.Character
    if not char then return nil end
    for _, v in getgc(true) do
        if type(v) == "table" and rawget(v, "baseRunSpeed") and rawget(v, "running") and rawget(v, "character") == char and rawget(v, "isActive") then
            return v
        end
    end
    return nil
end
local function refreshRun()
    runSys = findRunSystem()
end
LP.CharacterAdded:Connect(function()
    runSys = nil
    task.wait(1.2)
    refreshRun()
end)
refreshRun()

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)
mt.__newindex = newcclosure(function(self, key, value)
    if typeof(self) == "Instance" and self:IsA("Humanoid") and key == "WalkSpeed"
        and _G.Run ~= nil and _G.Run ~= 0
        and runSys and runSys.running and runSys.runningInputActive and runSys._canRun then
        return oldNewIndex(self, key, value + _G.Run)
    end
    return oldNewIndex(self, key, value)
end)
setreadonly(mt, true)

task.spawn(function()
    while true do
        task.wait(0.8)
        if not runSys or not runSys.isActive then
            refreshRun()
        end
    end
end)

-- ========== INSTANT ITEM PICK ==========
local function forcePrompt(prompt)
    if not prompt or not prompt.Parent then return end
    if _G.Item then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end)
    end
    if prompt:GetAttribute("PromptHooked") then return end
    prompt:SetAttribute("PromptHooked", true)
    prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
        if _G.Item and prompt.Parent and prompt.HoldDuration ~= 0 then
            prompt.HoldDuration = 0
        end
    end)
    prompt:GetPropertyChangedSignal("RequiresLineOfSight"):Connect(function()
        if _G.Item and prompt.Parent and prompt.RequiresLineOfSight ~= false then
            prompt.RequiresLineOfSight = false
        end
    end)
end

local function scanAndHook(container)
    if not container then return end
    for _, v in ipairs(container:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            forcePrompt(v)
        end
    end
end

local function watchItemsHold()
    local gd = workspace:WaitForChild("GameDebris", 8)
    if not gd then return end
    local function hook(map)
        local items = map:FindFirstChild("Items") or map:WaitForChild("Items", 4)
        if items then
            scanAndHook(items)
            items.DescendantAdded:Connect(function(v)
                if v:IsA("ProximityPrompt") then forcePrompt(v) end
            end)
        end
    end
    local current = gd:FindFirstChild("CurrentMap")
    if current then hook(current) end
    gd.ChildAdded:Connect(function(v)
        if v.Name == "CurrentMap" then
            task.wait(0.7)
            hook(v)
        end
    end)
end
watchItemsHold()

task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.Item then
            local gd = workspace:FindFirstChild("GameDebris")
            if gd then
                local map = gd:FindFirstChild("CurrentMap")
                if map then
                    local items = map:FindFirstChild("Items")
                    if items then
                        scanAndHook(items)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- CONFIG
-- ============================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Tixjam")
SaveManager:SetFolder("Tixjam/ScreamJam")
InterfaceManager:BuildInterfaceSection(Tabs.Config)
SaveManager:BuildConfigSection(Tabs.Config)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

-- ============================================================
-- BOTÓN FLOTANTE MÓVIL (arrastrable solo cuando lo mueves tú)
-- ============================================================
local isMobile = UserInputService.TouchEnabled

if isMobile then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TixjamMobileToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = CoreGui

    local Button = Instance.new("TextButton")
    Button.Name = "ToggleUI"
    Button.Size = UDim2.new(0, 58, 0, 58)
    Button.Position = UDim2.new(1, -75, 0.45, 0)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Button.BackgroundTransparency = 0.15
    Button.Text = "TJ"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Button

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 40, 40)
    UIStroke.Thickness = 2.2
    UIStroke.Parent = Button

    local uiVisible = true

    -- Toggle UI
    Button.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        pcall(function()
            if Window.Root then
                Window.Root.Visible = uiVisible
            end
        end)
        Button.Text = uiVisible and "TJ" or "OFF"
        Button.BackgroundColor3 = uiVisible and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(60, 20, 20)
    end)

    -- Drag system (solo se mueve si realmente arrastras el botón)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragThreshold = 8 -- píxeles mínimos para considerar que es drag (evita clicks accidentales)

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragStart = input.Position
            startPos = Button.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragStart then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart

            -- Solo activa el drag si moviste más de X píxeles
            if not dragging and (math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold) then
                dragging = true
            end

            if dragging then
                Button.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragStart = nil
        end
    end)
end

Fluent:Notify({
    Title = "Tixjam",
    Content = "Cargado | Botón móvil listo",
    Duration = 4
})

print("[Tixjam] Full loaded + Mobile Button")
