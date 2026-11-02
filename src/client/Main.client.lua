-- INTERFACE DRÁCULA. Três abas principais, com mochila/forja/loja dentro do inventário.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local Run=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Marketplace=game:GetService("MarketplaceService")
local StarterGui=game:GetService("StarterGui")
local player=Players.LocalPlayer
local Shared=game.ReplicatedStorage:WaitForChild("LittleRPG")
local C=require(Shared:WaitForChild("Config")); local K=require(Shared:WaitForChild("Catalog")); local P=require(Shared:WaitForChild("Progression")); local E=require(Shared:WaitForChild("Economy")); local Visual=require(Shared:WaitForChild("WeaponVisual"))
local remotes=Shared:WaitForChild("Remotes"); local Action=remotes:WaitForChild("Action"); local State=remotes:WaitForChild("State"); local Feedback=remotes:WaitForChild("Feedback")
local colors={BG=Color3.fromRGB(40,42,54),Panel=Color3.fromRGB(52,55,70),Deep=Color3.fromRGB(30,31,41),Text=Color3.fromRGB(248,248,242),Muted=Color3.fromRGB(157,164,190),Purple=Color3.fromRGB(189,147,249),Pink=Color3.fromRGB(255,121,198),Green=Color3.fromRGB(80,250,123),Cyan=Color3.fromRGB(139,233,253),Orange=Color3.fromRGB(255,184,108),Red=Color3.fromRGB(255,85,85)}
local gui=Instance.new("ScreenGui"); gui.Name="LittleRPGInterface"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=player:WaitForChild("PlayerGui")
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end)
local function create(class,parent,props)
 local obj=Instance.new(class); for key,value in pairs(props or {}) do obj[key]=value end; obj.Parent=parent; return obj
end
local function rounded(obj,radius) create("UICorner",obj,{CornerRadius=UDim.new(0,radius or 10)}) end
local function frame(parent,x,y,w,h,color)
 local f=create("Frame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or colors.Panel,BorderSizePixel=0}); rounded(f); return f
end
local function text(parent,value,x,y,w,h,size,color)
 return create("TextLabel",parent,{Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),TextColor3=color or colors.Text,TextSize=size or 16,TextWrapped=true,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,BackgroundTransparency=1})
end
local function button(parent,value,x,y,w,h,callback,color)
 local b=create("TextButton",parent,{Text=value,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or colors.Panel,TextColor3=colors.Text,Font=Enum.Font.GothamMedium,TextSize=14,TextWrapped=true,AutoButtonColor=true,BorderSizePixel=0,Selectable=true}); rounded(b,8); b.Activated:Connect(callback); return b
end
local function stroke(obj,color) create("UIStroke",obj,{Color=color or colors.Purple,Thickness=1,Transparency=.25}) end
local data; local tab="Inventário"; local view="Mochila"; local family=nil; local selected=nil; local forgeFamily="dagger"; local forgeTier=1
local muted=false; local lowGraphics=false; local render; local serverOffset=0; local forgeStart=nil
local sounds={}
for name,id in pairs(C.Audio) do
 if id~="" then sounds[name]=create("Sound",game:GetService("SoundService"),{Name="Little"..name,SoundId=id,Volume=name=="Ambient" and .22 or .35,Looped=name=="Ambient" or name=="Machine"}) end
end
local function sound(name) if sounds[name] and not muted then sounds[name]:Play() end end
sound("Ambient")
local hud=frame(gui,20,20,300,130,colors.Deep)
text(hud,"LITTLE RPG  /  ECOS DE AETHER",14,8,270,18,10,colors.Purple)
local levelText=text(hud,"Conectando…",14,31,270,24,20)
local function bar(y,color)
 local track=frame(hud,14,y,270,5,colors.Panel); local fill=frame(track,0,0,270,5,color); return fill
end
local healthBar=bar(68,colors.Green); local energyBar=bar(81,colors.Cyan); local xpBar=bar(94,colors.Purple)
local hpText=text(hud,"",14,104,270,18,10,colors.Muted)
local floorText=text(gui,"",0,22,360,52,15,colors.Text); floorText.TextXAlignment=Enum.TextXAlignment.Right
local hint=text(gui,"M · Menu   Z · Especial   Q · Dash   Shift · Correr\nE · Interagir/minerar   1 · Cura   2 · Energia",20,0,510,46,12,colors.Muted)
local cooldownText=text(gui,"",20,0,400,22,13,colors.Pink)
local notices={}; local showingNotice=false
local toast=text(gui,"",0,0,500,48,18,colors.Orange); toast.TextXAlignment=Enum.TextXAlignment.Center
local function notice(message)
 notices[#notices+1]=message
 if showingNotice then return end
 showingNotice=true
 task.spawn(function()
  while #notices>0 do toast.Text=table.remove(notices,1); task.wait(2.8) end
  toast.Text=""; showingNotice=false
 end)
end
local veil=create("TextButton",gui,{Size=UDim2.fromScale(1,1),Text="",BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.35,Visible=false,AutoButtonColor=false,BorderSizePixel=0})
local modal=frame(gui,0,0,1100,680,colors.BG); modal.AnchorPoint=Vector2.new(.5,.5); modal.Position=UDim2.fromScale(.5,.5); modal.Visible=false; stroke(modal)
local scale=create("UIScale",modal,{Scale=1})
text(modal,"LITTLE\nRPG",28,28,180,80,33,colors.Purple)
text(modal,"E C O S  D E  A E T H E R",28,112,180,25,10,colors.Muted)
local heading=text(modal,"Inventário",230,28,760,44,30)
local subheading=text(modal,"",230,76,800,26,13,colors.Muted)
local content=create("Frame",modal,{Position=UDim2.fromOffset(230,120),Size=UDim2.fromOffset(840,530),BackgroundTransparency=1})
local money=text(modal,"",28,568,180,38,18,colors.Orange)
local saveLabel=text(modal,"",28,615,180,34,11,colors.Muted)
local tabButtons={}
local function open(nextView)
 if nextView then tab="Inventário"; view=nextView; family=nil; selected=nil end
 modal.Visible=true; veil.Visible=true; sound("Menu"); render()
end
local function toggle()
 if data and not data.StarterChosen then return end
 modal.Visible=not modal.Visible; veil.Visible=modal.Visible; if modal.Visible then sound("Menu"); render() end
end
button(modal,"×",1034,24,40,40,toggle)
veil.Activated:Connect(function() if modal.Visible then toggle() end end)
for index,name in ipairs({"Inventário","Status","Eventos"}) do
 tabButtons[name]=button(modal,string.format("0%d   %s",index,name),24,175+(index-1)*58,178,46,function() tab=name; render() end)
end
local menuButton=button(gui,"MENU [M]",0,0,126,44,toggle)
local attackButton=button(gui,"ATACAR",0,0,102,52,function() if not modal.Visible then Action:FireServer("Attack") end end)
local specialButton=button(gui,"ESPECIAL [Z]",0,0,112,46,function() if not modal.Visible then Action:FireServer("Special") end end)
local dashButton=button(gui,"DASH [Q]",0,0,102,42,function() if not modal.Visible then Action:FireServer("Dash") end end)
attackButton.Visible=UIS.TouchEnabled
local function preview(parent,weapon,x,y,w,h)
 local viewport=create("ViewportFrame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=colors.Deep,BorderSizePixel=0,Ambient=Color3.fromRGB(180,180,200),LightColor=Color3.new(1,1,1),LightDirection=Vector3.new(-1,-1,-1)}); rounded(viewport)
 local world=create("WorldModel",viewport); local model=Visual.Build(weapon,false); model.Parent=world
 model:PivotTo(CFrame.Angles(0,0,math.rad(-25)))
 local camera=create("Camera",viewport,{FieldOfView=35}); viewport.CurrentCamera=camera
 local cf,size=model:GetBoundingBox(); local extent=math.max(size.X,size.Y,size.Z)
 camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(0,0,extent*1.9),cf.Position)
 return viewport
end
local scrollPositions={}
local function scroll(parent,x,y,w,h,key)
 local s=create("ScrollingFrame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=colors.Purple,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()})
 create("UIListLayout",s,{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
 if key then
  task.defer(function() if s.Parent then s.CanvasPosition=Vector2.new(0,scrollPositions[key] or 0) end end)
  s:GetPropertyChangedSignal("CanvasPosition"):Connect(function() scrollPositions[key]=s.CanvasPosition.Y end)
 end
 return s
end
local function row(parent,title,subtitle,callback,color)
 local b=button(parent,"",0,0,490,66,callback)
 text(b,title,14,7,460,26,15,color); text(b,subtitle,14,34,460,23,12,colors.Muted)
 return b
end
local function detail(weapon,offer)
 local item=K.ById[weapon.Blueprint]; local rarity=C.Rarities[weapon.Rarity]
 local panel=frame(content,524,58,316,470,colors.Panel)
 preview(panel,weapon,12,12,292,180)
 text(panel,item.Name,16,202,284,50,21,Color3.fromRGB(unpack(rarity.Color)))
 text(panel,string.format("%s  ·  NÍVEL %d\nDano %d  |  Especial %d\nAlcance %d  |  Intervalo %.2fs\nZ: %s",rarity.Name,item.Level,K.Damage(weapon,data.Level,data.Stats.Forca,false),K.Damage(weapon,data.Level,data.Stats.Forca,true),item.Range,item.Cooldown,item.Special),16,260,284,114,14)
 if offer then
  local available=offer.Count>0
  button(panel,available and "COMPRAR · "..offer.Price.." moedas" or "FORA DE ESTOQUE",16,390,284,44,function() if available then Action:FireServer("Buy",offer.Key) end end,available and Color3.fromRGB(73,62,98) or colors.Deep)
 else
  button(panel,data.Equipped==weapon.Uid and "EQUIPADO" or "EQUIPAR",16,382,284,38,function() Action:FireServer("Equip",weapon.Uid) end)
  button(panel,"Vender no mercador",16,428,284,30,function() Action:FireServer("Sell",weapon.Uid) end,colors.Deep)
 end
end
local function inventory()
 local modes={"Mochila","Forja","Loja","Robux"}
 for i,name in ipairs(modes) do button(content,name,(i-1)*132,0,124,38,function() view=name; family=nil; selected=nil; render() end,view==name and Color3.fromRGB(90,70,120) or colors.Panel) end
 if view=="Mochila" then
  local list=scroll(content,0,58,510,470,"Backpack")
  local active
  for _,weapon in ipairs(data.Weapons) do
   local item=K.ById[weapon.Blueprint]
   if item then
    row(list,item.Name,"Nv. "..item.Level.." · "..C.Rarities[weapon.Rarity].Name..(data.Equipped==weapon.Uid and " · EM USO" or ""),function() selected=weapon.Uid; render() end,Color3.fromRGB(unpack(C.Rarities[weapon.Rarity].Color)))
    if weapon.Uid==(selected or data.Equipped) then active=weapon end
   end
  end
  if active then detail(active) end
 elseif view=="Forja" then
  local item=K.ById[string.format("%s_%02d",forgeFamily,forgeTier)]
  text(content,"Escolha a categoria do molde",0,52,510,28,16,colors.Purple)
  for i,f in ipairs(K.Families) do
   local x=((i-1)%3)*168; local y=88+math.floor((i-1)/3)*42
   button(content,f.Name,x,y,160,36,function() forgeFamily=f.Id; render() end,forgeFamily==f.Id and Color3.fromRGB(80,65,108) or colors.Panel)
  end
  text(content,"Modelo / faixa de poder",0,177,510,25,14,colors.Muted)
  for tier=1,10 do button(content,tostring(tier),(tier-1)*50,208,44,34,function() forgeTier=tier; render() end,forgeTier==tier and Color3.fromRGB(90,70,120) or colors.Panel) end
  text(content,string.format("RECEITA\n%d %s  +  2 Carvão  +  %d moedas\nVocê tem: %d / %d minérios e %d / 2 carvão",item.OreCost,E.Ores[item.Ore].Name,item.GoldCost,data.Ores[item.Ore] or 0,item.OreCost,data.Ores.coal or 0),0,261,500,100,16)
  local odds=E.ForgeOdds(data.ForgeSkill); local lines={}
  for i,oddsValue in ipairs(odds) do lines[#lines+1]=C.Rarities[i].Name..": "..string.format("%.2f%%",oddsValue*100) end
  text(content,"Ferraria "..string.format("%.1f",data.ForgeSkill).." / 100\n"..table.concat(lines,"  ·  "),0,367,500,68,13,colors.Pink)
  text(content,"Use a bancada dentro da casa do ferreiro. A sequência dura 10 segundos.",0,451,490,55,12,colors.Muted)
  local panel=frame(content,524,58,316,470,colors.Panel)
  preview(panel,{Blueprint=item.Id,Rarity=1},12,12,292,205)
  text(panel,item.Name,16,230,284,58,21,colors.Text)
  text(panel,"Nível "..item.Level.."\nAquecer → derreter → moldar → martelar",16,294,284,80,15,colors.Muted)
  button(panel,data.Forging and "FORJANDO…" or "INICIAR FORJA",16,393,284,50,function() if not data.Forging then Action:FireServer("Forge",item.Id) end end,Color3.fromRGB(90,70,120))
 elseif view=="Loja" then
  if not family then
   text(content,"Selecione uma categoria",0,58,800,28,21)
   for i,f in ipairs(K.Families) do
    local x=((i-1)%3)*280; local y=106+math.floor((i-1)/3)*106
    button(content,f.Name,x,y,266,92,function() family=f.Id; selected=nil; render() end)
   end
   button(content,"Poções e ferramentas",0,332,826,52,function() family="Supplies"; render() end,Color3.fromRGB(61,73,89))
   text(content,"O estoque é individual por jogador e por andar. Renovação simultânea a cada 30 minutos. Compre junto ao mercador.",0,402,810,80,15,colors.Muted)
  elseif family=="Supplies" then
   button(content,"← Categorias",0,55,180,34,function() family=nil; render() end)
   local list=scroll(content,0,102,840,420,"Supplies")
   for _,id in ipairs({"health","energy","pickaxe2","pickaxe3"}) do
    local offer=C.Consumables[id]; local available=data.Floor>=(offer.Floor or 1)
    local b=row(list,offer.Name,available and offer.Price.." moedas · clique para comprar" or "Disponível a partir do andar "..offer.Floor,function() if available then Action:FireServer("Supply",id) end end,available and colors.Cyan or colors.Muted); b.Size=UDim2.fromOffset(820,78)
   end
  else
   button(content,"← Categorias",0,55,180,34,function() family=nil; selected=nil; render() end)
   local list=scroll(content,0,102,510,422,"Shop"..family)
   local active
   for _,offer in ipairs(data.Stock) do
    local item=K.ById[offer.Blueprint]
    if item.Family==family then
     row(list,item.Name,C.Rarities[offer.Rarity].Name.." · "..(offer.Count>0 and "EM ESTOQUE ("..offer.Count..") · "..offer.Price.." moedas" or "FORA DE ESTOQUE"),function() selected=offer.Key; render() end,offer.Count>0 and colors.Green or colors.Muted)
     if selected==offer.Key then active=offer end
    end
   end
   if active then detail({Blueprint=active.Blueprint,Rarity=active.Rarity},active) end
  end
 elseif view=="Robux" then
  text(content,"COMPRA DIRETA · SEM SORTEIO",0,62,800,28,19,colors.Orange)
  text(content,"Ultra lendárias são exclusivas de conquista no jogo. Os preços são apresentados pela confirmação oficial do Roblox.",0,100,810,60,15,colors.Muted)
  for i,offer in ipairs(C.Products) do
   local y=180+(i-1)*145
   local panel=frame(content,0,y,826,130,colors.Panel)
   preview(panel,{Blueprint=offer.Blueprint,Rarity=offer.Rarity},10,10,140,110)
   text(panel,offer.Name,166,20,620,40,20,colors.Orange)
   text(panel,"Requer nível "..K.ById[offer.Blueprint].Level.." para equipar.",166,62,350,28,13,colors.Muted)
   button(panel,offer.ProductId>0 and "VER OFERTA EM ROBUX" or "EM BREVE",540,72,270,42,function()
    if offer.ProductId>0 then Marketplace:PromptProductPurchase(player,offer.ProductId) else notice("Esta oferta ainda não foi configurada pelo criador.") end
   end)
  end
 end
end
local function status()
 text(content,"VIAJANTE / "..player.DisplayName,0,0,820,32,23,colors.Purple)
 text(content,string.format("Nível %d / 15.000   ·   %d pontos disponíveis\nVida %d   ·   Velocidade %.1f   ·   Dash %.1f studs   ·   Defesa %.1f%%",data.Level,data.Points,P.MaxHP(data),P.Speed(data),P.Dash(data),P.Reduction(data)*100),0,39,830,64,16)
 local descriptions={Forca="Mais dano físico; retornos decrescentes.",Defesa="Mais vida e redução de dano.",Movimento="Aumenta velocidade e distância do dash.",Ferraria="Melhora a chance de raridades na forja."}
 local labels={Forca="Força",Defesa="Defesa",Movimento="Movimento",Ferraria="Ferraria"}
 for i,key in ipairs({"Forca","Defesa","Movimento","Ferraria"}) do
  local y=118+(i-1)*63; local panel=frame(content,0,y,826,55,colors.Panel)
  text(panel,labels[key].."  ·  "..data.Stats[key],14,4,180,46,17,colors.Cyan)
  text(panel,descriptions[key],205,4,510,46,13,colors.Muted)
  button(panel,"+1",752,8,60,39,function() Action:FireServer("Allocate",key) end,Color3.fromRGB(90,70,120))
 end
 button(content,"Usar cura ("..data.Potions.health..")",0,383,260,40,function() Action:FireServer("Potion","health") end)
 button(content,"Usar energia ("..data.Potions.energy..")",278,383,260,40,function() Action:FireServer("Potion","energy") end)
 button(content,lowGraphics and "Gráficos: leves" or "Gráficos: completos",556,383,270,40,function()
  lowGraphics=not lowGraphics; Lighting.GlobalShadows=not lowGraphics
  for _,effect in ipairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") then effect.Enabled=not lowGraphics end end
  render()
 end)
 button(content,muted and "Som: desligado" or "Som: ligado",0,437,260,40,function()
  muted=not muted; for name,s in pairs(sounds) do s.Volume=muted and 0 or (name=="Ambient" and .22 or .35) end; render()
 end)
 text(content,"Picareta "..data.Pickaxe.." · "..data.Kills.." inimigos derrotados\nUma conquista de nível = um ponto de atributo.",278,437,548,65,13,colors.Muted)
end
render=function()
 for _,child in ipairs(content:GetChildren()) do child:Destroy() end
 heading.Text=tab
 for name,b in pairs(tabButtons) do b.BackgroundColor3=name==tab and Color3.fromRGB(90,70,120) or colors.Panel end
 if not data then text(content,"Carregando seu perfil…",0,160,800,50,22); return end
 money.Text=data.Gold.." ◈ MOEDAS"; saveLabel.Text=data.Temporary and "STUDIO · sessão temporária" or "PROGRESSO PERSISTENTE"
 subheading.Text=C.Floors[data.Floor].Name..(data.Mode=="Dungeon" and "  /  DUNGEON" or "  /  MUNDO")
 if tab=="Status" then status()
 elseif tab=="Eventos" then
  text(content,"NENHUM EVENTO ATIVO",0,170,800,50,27,colors.Muted)
  text(content,"Esta aba está reservada para os próximos eventos.",0,230,800,40,16,colors.Muted)
 elseif view=="Travel" then
  text(content,"ELEVADOR DA CIDADE",0,0,800,35,25,colors.Purple)
  for i,f in ipairs(C.Floors) do
   local unlocked=i<=data.Unlocked
   button(content,(unlocked and "◆ " or "◇ ")..f.Name..(unlocked and "  ·  VIAJAR" or "  ·  VENÇA A DUNGEON ANTERIOR"),0,70+(i-1)*100,826,78,function() if unlocked then Action:FireServer("Travel",i) end end,unlocked and colors.Panel or colors.Deep)
  end
  text(content,"Você precisa estar junto ao elevador. Derrotar o chefe de cada dungeon libera o próximo andar.",0,405,826,65,15,colors.Muted)
 else inventory() end
end
-- Escolha inicial ocupa a tela, com três modelos reais em previews 3D.
local starter=frame(gui,0,0,1000,590,colors.BG); starter.AnchorPoint=Vector2.new(.5,.5); starter.Position=UDim2.fromScale(.5,.5); starter.Visible=false; stroke(starter)
local starterScale=create("UIScale",starter,{Scale=1})
text(starter,"SUA PRIMEIRA ARMA",30,22,940,46,31,colors.Purple)
text(starter,"Escolha seu estilo. Todas começam com 10 de dano e especial de 34 contra inimigos de 100 de vida.",30,77,940,48,16,colors.Muted)
for i,id in ipairs(C.StarterFamilies) do
 local item=K.ById[id.."_01"]; local x=30+(i-1)*320; local card=frame(starter,x,146,300,405,colors.Panel)
 preview(card,{Blueprint=item.Id,Rarity=1},12,12,276,215)
 text(card,item.Name,16,240,268,52,22,colors.Text)
 text(card,"Z: "..item.Special.."\nAlcance "..item.Range.." · Ataque a cada "..item.Cooldown.."s",16,295,268,55,14,colors.Muted)
 button(card,"ESCOLHER ESTA ARMA",16,356,268,36,function() Action:FireServer("Choose",id) end,Color3.fromRGB(90,70,120))
end
local forgeOverlay=frame(gui,0,0,470,84,colors.Deep); forgeOverlay.AnchorPoint=Vector2.new(.5,1); forgeOverlay.Position=UDim2.new(.5,0,1,-20); forgeOverlay.Visible=false
local forgeLabel=text(forgeOverlay,"",16,8,438,35,18,colors.Orange); local forgeTrack=frame(forgeOverlay,16,56,438,7,colors.Panel); local forgeBar=frame(forgeTrack,0,0,0,7,colors.Orange)
local function resize()
 local v=workspace.CurrentCamera.ViewportSize; local factor=math.min(1,(v.X-20)/1100,(v.Y-45)/680)
 scale.Scale=factor; starterScale.Scale=math.min(1,(v.X-20)/1000,(v.Y-45)/590)
 hud.Position=UDim2.fromOffset(14,14); hud.Size=UDim2.fromOffset(300,130)
 local hudScale=hud:FindFirstChildOfClass("UIScale") or create("UIScale",hud)
 hudScale.Scale=math.min(1,v.X/700)
 floorText.Position=UDim2.new(1,-math.min(360,v.X*.45)-14,0,18); floorText.Size=UDim2.fromOffset(math.min(360,v.X*.45),55)
 menuButton.Position=UDim2.new(1,-140,1,-58)
 attackButton.Position=UDim2.new(1,-116,1,-120)
 specialButton.Position=UDim2.new(1,-238,1,-120)
 dashButton.Position=UDim2.new(1,-116,1,-172)
 hint.Position=UDim2.new(0,18,1,-68); hint.Size=UDim2.new(.62,0,0,48); hint.Visible=not UIS.TouchEnabled
 cooldownText.Position=UDim2.new(0,18,1,-98)
 toast.Position=UDim2.new(.15,0,.20,0); toast.Size=UDim2.new(.7,0,0,50)
 local forgeScale=forgeOverlay:FindFirstChildOfClass("UIScale") or create("UIScale",forgeOverlay)
 forgeScale.Scale=math.min(1,(v.X-30)/470)
end
resize(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
local healthConnection; local maxHealthConnection
local function character(ch)
 if healthConnection then healthConnection:Disconnect() end; if maxHealthConnection then maxHealthConnection:Disconnect() end
 local hum=ch:WaitForChild("Humanoid")
 local function refresh() healthBar.Size=UDim2.fromOffset(270*math.clamp(hum.Health/hum.MaxHealth,0,1),5); hpText.Text=string.format("VIDA %d / %d  ·  ENERGIA %d",math.ceil(hum.Health),hum.MaxHealth,player:GetAttribute("Energy") or 100) end
 healthConnection=hum.HealthChanged:Connect(refresh); maxHealthConnection=hum:GetPropertyChangedSignal("MaxHealth"):Connect(refresh); refresh()
end
player.CharacterAdded:Connect(character); if player.Character then task.spawn(character,player.Character) end
State.OnClientEvent:Connect(function(snapshot)
 local previous=data; data=snapshot; serverOffset=data.ServerTime-os.time()
 levelText.Text="Viajante · Nível "..data.Level; floorText.Text=C.Floors[data.Floor].Name.."\n"..(data.Mode=="Dungeon" and "LABIRINTO · ENCONTRE OS TRÊS SELOS" or "EXPLORE · MINE · FORJE")
 xpBar.Size=UDim2.fromOffset(270*(data.Level==C.MaxLevel and 1 or math.clamp(data.XP/data.Required,0,1)),5)
 starter.Visible=not data.StarterChosen
 if starter.Visible then veil.Visible=true; modal.Visible=false
 elseif previous and not previous.StarterChosen then veil.Visible=false; notice("Sua jornada começa. Siga para fora da cidade para encontrar lobos e javalis.") end
 if modal.Visible then render() end
 if data.Forging and not forgeStart then forgeStart=os.clock() end
 if not data.Forging then forgeStart=nil; forgeOverlay.Visible=false end
end)
local specialUntil=0
Feedback.OnClientEvent:Connect(function(kind,a,b,c)
 if kind=="Notice" then notice(a)
 elseif kind=="Open" then open(a=="Forge" and "Forja" or a=="Shop" and "Loja" or a)
 elseif kind=="Level" then sound("LevelUp"); notice("NÍVEL "..a.." · +"..b.." ponto(s) para distribuir")
 elseif kind=="Reward" then cooldownText.Text="+"..a.." XP  ·  +"..b.." moedas"
 elseif kind=="Floor" then
  if sounds.Machine then if a==3 then sound("Machine") else sounds.Machine:Stop() end end
 elseif kind=="Swing" and a==player.UserId and b then
  if data then local w=P.Weapon(data,data.Equipped); if w then specialUntil=os.clock()+K.ById[w.Blueprint].SpecialCooldown end end
 elseif kind=="Hit" then sound("Hit")
 elseif kind=="Forge" and a==player.UserId then forgeStart=os.clock(); modal.Visible=false; veil.Visible=false
 elseif kind=="Forged" then sound("LevelUp"); view="Mochila"; selected=a.Uid
 end
end)
Run.RenderStepped:Connect(function()
 local energy=player:GetAttribute("Energy") or 100; energyBar.Size=UDim2.fromOffset(270*energy/100,5)
 local ch=player.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 if hum then hpText.Text=string.format("VIDA %d / %d  ·  ENERGIA %d",math.ceil(hum.Health),hum.MaxHealth,energy) end
 if data then
  specialButton.Text=specialUntil>os.clock() and string.format("Z · %.1fs",specialUntil-os.clock()) or "ESPECIAL [Z]"
  if modal.Visible and tab=="Inventário" and view=="Loja" then
   local remaining=math.max(0,data.StockEnds-(os.time()+serverOffset))
   subheading.Text="ESTOQUE RENOVA EM "..string.format("%02d:%02d",math.floor(remaining/60),remaining%60).." · "..C.Floors[data.Floor].Name
  end
 end
 if forgeStart then
  local elapsed=os.clock()-forgeStart; forgeOverlay.Visible=true
  forgeLabel.Text=elapsed<3 and "01 · Aquecendo e derretendo" or elapsed<5.5 and "02 · Despejando no molde" or elapsed<9 and "03 · Martelando e resfriando" or "04 · Finalizando a arma…"
  forgeBar.Size=UDim2.fromOffset(438*math.min(1,elapsed/10),7)
 end
end)
local function bind(name,verb,keys,arg)
 CAS:BindAction(name,function(_,state)
  if state==Enum.UserInputState.Begin and not modal.Visible and not starter.Visible and not UIS:GetFocusedTextBox() then Action:FireServer(verb,arg) end
  return Enum.ContextActionResult.Pass
 end,false,unpack(keys))
end
CAS:BindAction("LittleMenu",function(_,state) if state==Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() then toggle() end; return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.M,Enum.KeyCode.ButtonY)
bind("LittleAttack","Attack",{Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2})
bind("LittleSpecial","Special",{Enum.KeyCode.Z,Enum.KeyCode.ButtonX})
bind("LittleDash","Dash",{Enum.KeyCode.Q,Enum.KeyCode.ButtonB})
bind("LittleHealth","Potion",{Enum.KeyCode.One},"health")
bind("LittleEnergy","Potion",{Enum.KeyCode.Two},"energy")
CAS:BindAction("LittleSprint",function(_,state)
 if not modal.Visible and not starter.Visible then Action:FireServer("Sprint",state==Enum.UserInputState.Begin) end
 return Enum.ContextActionResult.Pass
end,false,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3)
task.spawn(function() while not data do Action:FireServer("Ready"); task.wait(2) end end)
