local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local Lighting=game:GetService("Lighting")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local Shared=game.ReplicatedStorage:WaitForChild("LittleRPG")
local C=require(Shared:WaitForChild("Config")); local P=require(Shared.Progression)
local remotes=Shared:WaitForChild("Remotes"); local Action=remotes:WaitForChild("Action"); local State=remotes:WaitForChild("State"); local Feedback=remotes:WaitForChild("Feedback")
local palette={Ink=Color3.fromRGB(12,24,32),Panel=Color3.fromRGB(24,40,48),Text=Color3.fromRGB(232,241,235),Muted=Color3.fromRGB(153,178,181),Mint=Color3.fromRGB(152,237,197),Gold=Color3.fromRGB(235,205,140)}
local gui=Instance.new("ScreenGui"); gui.Name="LittleRPGInterface"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
local function make(class,parent,props)
 local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end; o.Parent=parent; return o
end
local function round(o,r) make("UICorner",o,{CornerRadius=UDim.new(0,r or 10)}) end
local function label(parent,text,size,pos,fontSize,color)
 return make("TextLabel",parent,{Text=text,Size=size,Position=pos,BackgroundTransparency=1,TextColor3=color or palette.Text,Font=Enum.Font.GothamMedium,TextSize=fontSize or 16,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
end
local function button(parent,text,size,pos,callback)
 local b=make("TextButton",parent,{Text=text,Size=size,Position=pos,BackgroundColor3=palette.Panel,TextColor3=palette.Text,Font=Enum.Font.GothamMedium,TextSize=15,AutoButtonColor=true,BorderSizePixel=0}); round(b,8)
 b.Activated:Connect(callback); return b
end
local sounds={}; local muted=false; local lowGraphics=false
for name,id in pairs(C.Audio) do
 if id~="" then local s=make("Sound",game:GetService("SoundService"),{Name="Little"..name,SoundId=id,Volume=name=="Ambient" and .23 or .4,Looped=name=="Ambient" or name=="Machine"}); sounds[name]=s end
end
local function sound(name) local s=sounds[name]; if s and not muted then s:Play() end end
sound("Ambient")
local hud=make("Frame",gui,{Size=UDim2.fromOffset(320,126),Position=UDim2.fromOffset(22,22),BackgroundColor3=palette.Ink,BackgroundTransparency=.1,BorderSizePixel=0}); round(hud)
local brand=label(hud,"LITTLE RPG  /  ECOS DE AETHER",UDim2.new(1,-32,0,22),UDim2.fromOffset(16,10),11,palette.Mint)
local levelText=label(hud,"Conectando à torre…",UDim2.new(1,-32,0,26),UDim2.fromOffset(16,34),20)
local hpTrack=make("Frame",hud,{Size=UDim2.new(1,-32,0,6),Position=UDim2.fromOffset(16,75),BackgroundColor3=palette.Panel,BorderSizePixel=0}); round(hpTrack)
local hpBar=make("Frame",hpTrack,{Size=UDim2.fromScale(1,1),BackgroundColor3=palette.Mint,BorderSizePixel=0}); round(hpBar)
local xpTrack=make("Frame",hud,{Size=UDim2.new(1,-32,0,3),Position=UDim2.fromOffset(16,89),BackgroundColor3=palette.Panel,BorderSizePixel=0})
local xpBar=make("Frame",xpTrack,{Size=UDim2.fromScale(0,1),BackgroundColor3=palette.Gold,BorderSizePixel=0})
local hpText=label(hud,"",UDim2.new(1,-32,0,20),UDim2.fromOffset(16,98),11,palette.Muted)
local floorText=label(gui,"",UDim2.fromOffset(360,50),UDim2.new(1,-382,0,25),15,palette.Text); floorText.TextXAlignment=Enum.TextXAlignment.Right
local objective=label(gui,"Siga pela estrada e enfrente os sentinelas.\nM: menu  ·  Clique: atacar  ·  Espaço: pular",UDim2.fromOffset(440,48),UDim2.new(0,22,1,-72),13,palette.Text)
local toast=label(gui,"",UDim2.new(.6,0,0,52),UDim2.fromScale(.2,.18),18,palette.Gold); toast.TextXAlignment=Enum.TextXAlignment.Center
local toastToken=0
local function notice(message)
 toastToken=toastToken+1; local token=toastToken; toast.Text=message
 task.delay(4,function() if token==toastToken then toast.Text="" end end)
end
local veil=make("TextButton",gui,{Text="",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.4,Visible=false,AutoButtonColor=false,BorderSizePixel=0})
local modal=make("Frame",gui,{Size=UDim2.fromOffset(940,590),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=palette.Ink,BorderSizePixel=0,Visible=false}); round(modal,16)
make("UIStroke",modal,{Color=palette.Mint,Transparency=.7,Thickness=1})
local scaler=make("UIScale",modal,{Scale=1})
local function resize()
 local v=workspace.CurrentCamera.ViewportSize; scaler.Scale=math.min(1,(v.X-24)/940,(v.Y-50)/590)
 hud.Size=UDim2.fromOffset(math.min(320,v.X*.53),126)
 floorText.Size=UDim2.fromOffset(math.min(360,v.X*.4),50); floorText.Position=UDim2.new(1,-math.min(360,v.X*.4)-22,0,25)
 objective.Size=UDim2.new(.68,0,0,48)
end
resize(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
label(modal,"LITTLE\nRPG",UDim2.fromOffset(170,88),UDim2.fromOffset(28,25),32,palette.Mint)
label(modal,"E C O S  D E  A E T H E R",UDim2.fromOffset(180,30),UDim2.fromOffset(28,110),10,palette.Muted)
label(modal,"SEU REGISTRO NA TORRE",UDim2.fromOffset(480,30),UDim2.fromOffset(236,25),12,palette.Muted)
local heading=label(modal,"Inventário",UDim2.fromOffset(530,45),UDim2.fromOffset(236,58),30)
local purse=label(modal,"",UDim2.fromOffset(220,40),UDim2.fromOffset(28,490),14,palette.Gold)
local saveLabel=label(modal,"",UDim2.fromOffset(180,35),UDim2.fromOffset(28,535),11,palette.Muted)
local content=make("Frame",modal,{Size=UDim2.fromOffset(680,450),Position=UDim2.fromOffset(236,118),BackgroundTransparency=1})
local data; local tab="Inventário"; local selected="gear_01_1"; local catalog=false; local render
local tabButtons={}
local function toggle()
 modal.Visible=not modal.Visible; veil.Visible=modal.Visible
 if modal.Visible then sound("Menu"); if render then render() end; UIS.MouseIconEnabled=true end
end
button(modal,"×",UDim2.fromOffset(38,38),UDim2.fromOffset(875,24),toggle)
veil.Activated:Connect(toggle)
for i,name in ipairs({"Inventário","Personagem","Eventos"}) do
 tabButtons[name]=button(modal,string.format("0%d   %s",i,name),UDim2.fromOffset(180,48),UDim2.fromOffset(24,164+(i-1)*60),function() tab=name; sound("Menu"); render() end)
end
local menuButton=button(gui,"MENU  [M]",UDim2.fromOffset(136,46),UDim2.new(1,-158,1,-72),toggle)
local attackButton=button(gui,"ATACAR",UDim2.fromOffset(112,54),UDim2.new(1,-134,1,-138),function() if not modal.Visible then Action:FireServer("Attack") end end)
attackButton.Visible=UIS.TouchEnabled
local function clear() for _,o in ipairs(content:GetChildren()) do o:Destroy() end end
render=function()
 clear(); heading.Text=tab
 for name,b in pairs(tabButtons) do b.BackgroundColor3=name==tab and Color3.fromRGB(48,81,76) or palette.Panel end
 if not data then label(content,"Carregando seu registro…",UDim2.fromScale(1,1),UDim2.new(),18); return end
 if tab=="Eventos" then
  label(content,"NENHUM EVENTO ATIVO",UDim2.fromOffset(620,45),UDim2.fromOffset(20,150),23,palette.Muted)
  label(content,"Os próximos eventos aparecerão aqui.",UDim2.fromOffset(620,35),UDim2.fromOffset(20,202),15,palette.Muted)
 elseif tab=="Personagem" then
  label(content,"VIAJANTE  /  "..player.DisplayName,UDim2.fromOffset(640,36),UDim2.new(),23,palette.Mint)
  local equipped=C.Items[data.Equipped]
  label(content,string.format("Nível %d / 100     •     Vida máxima %d\n\n%d cristais     •     %d inimigos vencidos\n\nEquipado: %s\nDano %d   ·   Alcance %d   ·   Intervalo %.2fs",data.Level,P.MaxHP(data.Level),data.Gold,data.Kills,equipped.Name,equipped.Damage+math.floor(data.Level*.9),equipped.Range,equipped.Cooldown),UDim2.fromOffset(640,170),UDim2.fromOffset(0,46),17)
  for i,f in ipairs(C.Floors) do
   local unlocked=P.CanTravel(data,i,C)
   label(content,(unlocked and "◆  " or "◇  ")..f.Name.."  ·  Nível "..f.MinLevel,UDim2.fromOffset(650,28),UDim2.fromOffset(0,225+(i-1)*30),13,unlocked and f.Accent or palette.Muted)
  end
  button(content,lowGraphics and "Gráficos: leves" or "Gráficos: completos",UDim2.fromOffset(210,42),UDim2.fromOffset(0,340),function()
   lowGraphics=not lowGraphics
   Lighting.GlobalShadows=not lowGraphics
   for _,effect in ipairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") then effect.Enabled=not lowGraphics end end
   render()
  end)
  button(content,muted and "Som: desligado" or "Som: ligado",UDim2.fromOffset(190,42),UDim2.fromOffset(222,340),function()
   muted=not muted
   for _,s in pairs(sounds) do s.Volume=muted and 0 or (s.Name=="LittleAmbient" and .23 or .4) end
   if not muted then sound("Ambient") end; render()
  end)
  button(content,"Curar no santuário",UDim2.fromOffset(220,42),UDim2.fromOffset(424,340),function() Action:FireServer("Heal") end)
  label(content,"Portais no fim de cada andar. Saia do círculo vermelho antes do ataque do chefe.",UDim2.fromOffset(650,44),UDim2.fromOffset(0,395),13,palette.Muted)
 else
  button(content,catalog and "FORJA  /  50 equipamentos" or "MOCHILA  /  seus equipamentos",UDim2.fromOffset(402,36),UDim2.new(),function() catalog=not catalog; render() end)
  label(content,"Clique acima para alternar mochila / forja",UDim2.fromOffset(402,25),UDim2.fromOffset(0,40),11,palette.Muted)
  local scroll=make("ScrollingFrame",content,{Size=UDim2.fromOffset(410,378),Position=UDim2.fromOffset(0,70),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=palette.Mint,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()})
  make("UIGridLayout",scroll,{CellSize=UDim2.fromOffset(194,84),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder})
  for order,item in ipairs(C.ItemList) do
   if catalog or data.Owned[item.Id] then
    local owned=data.Owned[item.Id]
    local b=button(scroll,item.Name.."\nNv. "..item.Level..(data.Equipped==item.Id and "  ·  EM USO" or owned and "  ·  SEU" or "  ·  "..item.Price.." ◈"),UDim2.new(),UDim2.new(),function() selected=item.Id; render() end)
    b.LayoutOrder=order; b.TextSize=13; b.TextWrapped=true; b.TextColor3=item.Color
    if selected==item.Id then make("UIStroke",b,{Color=item.Color,Thickness=1.5}) end
   end
  end
  local item=C.Items[selected] or C.Items[data.Equipped]
  local side=make("Frame",content,{Size=UDim2.fromOffset(250,448),Position=UDim2.fromOffset(430,0),BackgroundColor3=palette.Panel,BorderSizePixel=0}); round(side)
  label(side,string.upper(item.Shape).." / "..string.format("%02d",item.Tier),UDim2.fromOffset(218,30),UDim2.fromOffset(16,15),11,item.Color)
  -- A clean geometric weapon glyph; no external images or asset dependencies.
  local glyph=make("Frame",side,{Size=UDim2.fromOffset(item.Shape=="Hammer" and 60 or 12,105),Position=UDim2.fromOffset(118,60),Rotation=30,BackgroundColor3=item.Color,BorderSizePixel=0})
  make("Frame",glyph,{Size=UDim2.fromOffset(52,6),Position=UDim2.new(.5,-26,1,-18),BackgroundColor3=palette.Gold,BorderSizePixel=0})
  label(side,item.Name,UDim2.fromOffset(218,62),UDim2.fromOffset(16,190),22,item.Color)
  label(side,string.format("NÍVEL %d\n\nDano base    %d\nAlcance        %d\nIntervalo      %.2fs",item.Level,item.Damage,item.Range,item.Cooldown),UDim2.fromOffset(218,130),UDim2.fromOffset(16,255),15)
  local owned=data.Owned[item.Id]; local caption=owned and (data.Equipped==item.Id and "EQUIPADO" or "EQUIPAR") or "CRIAR  ·  "..item.Price.." ◈"
  button(side,caption,UDim2.fromOffset(218,44),UDim2.fromOffset(16,390),function() Action:FireServer(owned and "Equip" or "Buy",item.Id) end)
 end
end
State.OnClientEvent:Connect(function(snapshot)
 data=snapshot; local f=C.Floors[data.Floor]
 levelText.Text="Viajante  ·  Nível "..data.Level; floorText.Text=f.Name.."\n"..f.Subtitle
 xpBar.Size=UDim2.fromScale(data.Level==100 and 1 or math.clamp(data.XP/data.Required,0,1),1)
 purse.Text=data.Gold.."  ◈  CRISTAIS"; saveLabel.Text=data.Temporary and "STUDIO · sessão temporária" or "PROGRESSO PERSISTENTE"
 objective.Text=data.Bosses.echo and "A torre foi conquistada. Complete sua coleção!" or "Explore o andar e derrote seu guardião.\nM: menu  ·  Clique: atacar  ·  Espaço: pular"
 if modal.Visible then render() end
end)
local healthConnection
local function bindCharacter(ch)
 if healthConnection then healthConnection:Disconnect() end
 local hum=ch:WaitForChild("Humanoid")
 local function health() hpBar.Size=UDim2.fromScale(math.clamp(hum.Health/hum.MaxHealth,0,1),1); hpText.Text=string.format("VIDA  %d / %d",math.ceil(hum.Health),hum.MaxHealth) end
 healthConnection=hum.HealthChanged:Connect(health); health()
end
player.CharacterAdded:Connect(bindCharacter); if player.Character then task.spawn(bindCharacter,player.Character) end
Feedback.OnClientEvent:Connect(function(kind,a,b)
 if kind=="Notice" then notice(a)
 elseif kind=="Level" then sound("LevelUp"); notice("NÍVEL "..a.."  ·  Sua vida foi restaurada")
 elseif kind=="Reward" then notice("+"..a.." XP    +"..b.." cristais")
 elseif kind=="Floor" then
  notice(C.Floors[a].Name); if sounds.Machine then if a==3 then sound("Machine") else sounds.Machine:Stop() end end
 elseif kind=="Hit" then
  if (workspace.CurrentCamera.CFrame.Position-a).Magnitude>130 then return end
  sound("Hit")
  local anchor=make("Part",workspace,{Anchored=true,CanCollide=false,CanQuery=false,Transparency=1,Size=Vector3.one,Position=a+Vector3.new(0,3,0)})
  local bill=make("BillboardGui",anchor,{Size=UDim2.fromOffset(100,60),AlwaysOnTop=true})
  local t=label(bill,tostring(b),UDim2.fromScale(1,1),UDim2.new(),25,palette.Gold); t.TextXAlignment=Enum.TextXAlignment.Center
  Tween:Create(anchor,TweenInfo.new(.7),{Position=anchor.Position+Vector3.new(0,3,0)}):Play(); Tween:Create(t,TweenInfo.new(.7),{TextTransparency=1}):Play(); Debris:AddItem(anchor,.8)
 elseif kind=="Swing" then
  local ch=player.Character; local tool=ch and ch:FindFirstChildOfClass("Tool")
  if tool then
   local original=tool.Grip; tool.Grip=original*CFrame.Angles(0,0,math.rad(-65))
   Tween:Create(tool,TweenInfo.new(math.min(a*.7,.3)),{Grip=original}):Play()
  end
 elseif kind=="Hurt" then
  local flash=make("Frame",gui,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(230,80,70),BackgroundTransparency=.86,BorderSizePixel=0})
  Tween:Create(flash,TweenInfo.new(.35),{BackgroundTransparency=1}):Play(); Debris:AddItem(flash,.4)
 end
end)
CAS:BindAction("LittleMenu",function(_,state) if state==Enum.UserInputState.Begin then toggle() end; return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.M,Enum.KeyCode.ButtonY)
CAS:BindAction("LittleAttack",function(_,state)
 if state==Enum.UserInputState.Begin and not modal.Visible and not UIS:GetFocusedTextBox() then Action:FireServer("Attack") end
 return modal.Visible and Enum.ContextActionResult.Pass or Enum.ContextActionResult.Sink
end,false,Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2)
-- Ready handshake is retried until the server finishes loading the profile.
task.spawn(function() while not data do Action:FireServer("Ready"); task.wait(2) end end)
