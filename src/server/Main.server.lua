-- ORQUESTRADOR. Todos os valores de dano, dinheiro, itens e recompensas são do servidor.
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Shared=game.ReplicatedStorage:WaitForChild("LittleRPG")
local C=require(Shared.Config); local K=require(Shared.Catalog); local P=require(Shared.Progression); local E=require(Shared.Economy)
local Profiles=require(script.Parent.Profiles); local Equipment=require(script.Parent.Equipment); local Enemies=require(script.Parent.Enemies)
local WorldActions=require(script.Parent.WorldActions); local Dungeons=require(script.Parent.Dungeons); local Monetization=require(script.Parent.Monetization)
local folder=Instance.new("Folder"); folder.Name="Remotes"; folder.Parent=Shared
local function remote(name) local o=Instance.new("RemoteEvent"); o.Name=name; o.Parent=folder; return o end
local Action=remote("Action"); local State=remote("State"); local Feedback=remote("Feedback")
local ctx={Profiles=Profiles,Runtime={},Feedback=Feedback}
function ctx.Character(player)
 local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
 if root and hum and hum.Health>0 then return root,hum end
end
function ctx.Speed(player)
 local d=Profiles.Data[player]; local r=ctx.Runtime[player]
 return d and P.Speed(d)*(r and r.Sprinting and r.Energy>0 and 1.35 or 1) or 18
end
function ctx.Notice(player,message) if player.Parent then Feedback:FireClient(player,"Notice",message) end end
function ctx.Animate(player,name,duration)
 local char=player.Character; if not char then return end
 char:SetAttribute("ActionName",name); char:SetAttribute("ActionStart",workspace:GetServerTimeNow()); char:SetAttribute("ActionDuration",duration)
end
function ctx.Sync(player)
 local d=Profiles.Data[player]; local r=ctx.Runtime[player]; if not d or not r then return end
 local epoch=math.floor(os.time()/C.StockSeconds)
 if d.StockEpoch~=epoch then d.StockEpoch=epoch; d.StockBought={} end
 local stock=E.Stock(d.Floor,epoch)
 for _,offer in ipairs(stock) do offer.Count=math.max(0,offer.Count-(d.StockBought[d.Floor..":"..offer.Key] or 0)) end
 State:FireClient(player,{Level=d.Level,XP=d.XP,Required=P.Required(d.Level),Gold=d.Gold,Floor=d.Floor,Unlocked=d.Unlocked,StarterChosen=d.StarterChosen,
  Weapons=d.Weapons,Equipped=d.Equipped,Stats=d.Stats,Points=d.Points,ForgeXP=d.ForgeXP,ForgeSkill=P.ForgeSkill(d),Ores=d.Ores,Potions=d.Potions,Pickaxe=d.Pickaxe,
  Kills=d.Kills,Bosses=d.Bosses,Temporary=Profiles.Temporary,Mode=r.Mode,Stock=stock,StockEnds=(epoch+1)*C.StockSeconds,ServerTime=os.time(),Forging=d.PendingForge~=nil,Seals=r.Seals or {}})
 player:SetAttribute("Energy",math.floor(r.Energy)); player:SetAttribute("Floor",d.Floor); player:SetAttribute("GameMode",r.Mode)
 local stats=player:FindFirstChild("leaderstats"); if stats then stats:FindFirstChild("Nível").Value=d.Level end
end
function ctx.Prompt(part,action,title,callback)
 local prompt=Instance.new("ProximityPrompt"); prompt.ActionText=action; prompt.ObjectText=title; prompt.MaxActivationDistance=14; prompt.HoldDuration=.3; prompt.RequiresLineOfSight=false; prompt.Parent=part
 prompt.Triggered:Connect(function(player)
  local d=Profiles.Data[player]; local r=ctx.Runtime[player]; local root=ctx.Character(player)
  if not d or not r or not root or Profiles.Travel[player] or Profiles.Closing[player] or r.Forging or (root.Position-part.Position).Magnitude>18 then return end
  if os.clock()<(r.NextPrompt or 0) then return end; r.NextPrompt=os.clock()+.2
  callback(player)
 end)
 return prompt
end
function ctx.RespawnAt(player)
 local d=Profiles.Data[player]; local r=ctx.Runtime[player]; local root,hum=ctx.Character(player)
 if not d or not r or not root then return end
 local position=C.Floors[d.Floor].Origin+C.Floors[d.Floor].Spawn
 if r.Mode=="Dungeon" then position=workspace.LittleWorld.Interactions:FindFirstChild("DungeonExit_"..d.Floor).Position+Vector3.new(0,4,0) end
 player.Character:PivotTo(CFrame.new(position)); hum.Health=hum.MaxHealth; r.Energy=100; r.Sprinting=false; r.Seals={}; root.Anchored=false
 Feedback:FireClient(player,"Floor",d.Floor)
end
function ctx.OnKill(player,id)
 local d=Profiles.Data[player]; local r=ctx.Runtime[player]; local def=C.Enemies[id]
 if not d or not r or Profiles.Closing[player] then return end
 d.Kills=d.Kills+1; local gained=P.Grant(d,def.XP,def.Gold)
 if def.Boss and r.Mode=="Dungeon" then
  d.Bosses[id]=true; d.Unlocked=math.max(d.Unlocked,math.min(3,def.Floor+1))
  ctx.Notice(player,def.Floor==3 and "Soberano vencido! Você conquistou os três andares." or "Dungeon vencida! Novo andar liberado no elevador da cidade.")
 end
 if math.random()<(def.Boss and C.DropChance.Boss or C.DropChance.Normal) then
  local rarity=E.Roll(C.DropWeights,math.random())
  local blueprint
  if rarity==7 and id=="sovereign" then blueprint="greatsword_10"
  else
   rarity=math.min(6,rarity); local pool={}
   for _,item in ipairs(K.List) do if item.Tier<=math.min(9,def.Floor*3) then pool[#pool+1]=item.Id end end
   blueprint=pool[math.random(#pool)]
  end
  local weapon=P.AddWeapon(d,blueprint,rarity)
  if weapon then ctx.Notice(player,"DROP: "..K.Name(weapon)) else ctx.Notice(player,"Mochila cheia: não foi possível recolher a arma.") end
 end
 if gained>0 then
  local _,hum=ctx.Character(player); if hum then hum.MaxHealth=P.MaxHP(d); hum.Health=hum.MaxHealth end
  Feedback:FireClient(player,"Level",d.Level,gained)
 end
 Feedback:FireClient(player,"Reward",def.XP,def.Gold); ctx.Sync(player)
end
WorldActions.Start(ctx); Dungeons.Start(ctx); Monetization.Start(Profiles,ctx.Sync,ctx.Notice); Enemies.Start(ctx)
-- Selos em becos diferentes exigem explorar o labirinto antes de acessar a arena.
for _,marker in ipairs(workspace.LittleWorld.Interactions:GetChildren()) do
 local floor,number=marker.Name:match("^Seal_(%d+)_(%d+)$")
 if floor then
  floor=tonumber(floor); number=tonumber(number)
  ctx.Prompt(marker,"Ativar selo","Mecanismo de pedra",function(player)
   local d=Profiles.Data[player]; local r=ctx.Runtime[player]
   if r.Mode=="Dungeon" and d.Floor==floor then r.Seals[number]=true; ctx.Animate(player,"Interact",.6); ctx.Notice(player,"Selo "..number.." ativado."); ctx.Sync(player) end
  end)
 end
 local arenaFloor=tonumber(marker.Name:match("^ArenaGate_(%d+)$"))
 if arenaFloor then
  ctx.Prompt(marker,"Abrir a arena","Portão dos três selos",function(player)
   local d=Profiles.Data[player]; local r=ctx.Runtime[player]
   if r.Mode~="Dungeon" or d.Floor~=arenaFloor then return end
   for i=1,3 do if not r.Seals[i] then ctx.Notice(player,"Encontre e ative os três selos do labirinto."); return end end
   player.Character:PivotTo(CFrame.new(C.DungeonX+520,C.Floors[arenaFloor].Origin.Y+6,55)); ctx.Notice(player,"O guardião espera.")
  end)
 end
end
local function setupCharacter(player,char)
 if char:GetAttribute("LittleSetup") then return end; char:SetAttribute("LittleSetup",true)
 local hum=char:WaitForChild("Humanoid",10); char:WaitForChild("HumanoidRootPart",10)
 while player.Parent and not Profiles.Data[player] do task.wait(.1) end
 local d=Profiles.Data[player]; if not d or not hum or not ctx.Runtime[player] then return end
 hum.MaxHealth=P.MaxHP(d); hum.Health=hum.MaxHealth; hum.WalkSpeed=ctx.Speed(player)
 ctx.RespawnAt(player); Equipment.Give(player,d); ctx.Sync(player)
end
local function join(player)
 ctx.Runtime[player]={Mode="World",Energy=100,Seals={}}
 player.CharacterAdded:Connect(function(char) setupCharacter(player,char) end)
 local d=Profiles.Load(player); if not d then return end
 if not player.Parent then Profiles.Close(player); return end
 if not Dungeons.Arrive(player,d) then return end
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
 local level=Instance.new("IntValue"); level.Name="Nível"; level.Value=d.Level; level.Parent=stats
 if player.Character then task.spawn(setupCharacter,player,player.Character) end
 ctx.Sync(player)
end
Players.PlayerAdded:Connect(join); for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
Players.PlayerRemoving:Connect(function(player) ctx.Runtime[player]=nil end)
Action.OnServerEvent:Connect(function(player,verb,arg)
 if type(verb)~="string" then return end
 local r=ctx.Runtime[player]; if not r then return end
 if verb=="Sprint" and arg==false then r.Sprinting=false; local _,hum=ctx.Character(player); if hum then hum.WalkSpeed=ctx.Speed(player) end; return end
 local now=os.clock(); if now<(r.NextRemote or 0) then return end; r.NextRemote=now+.08
 if verb=="Ready" then ctx.Sync(player); return end
 local d=Profiles.Data[player]; local root,hum=ctx.Character(player)
 if not d or not root or Profiles.Travel[player] or Profiles.Closing[player] then return end
 if verb=="Choose" then if type(arg)=="string" and P.Choose(d,arg) then Equipment.Give(player,d); ctx.Sync(player) end; return end
 if not d.StarterChosen then return end
 if verb=="Allocate" then
  if type(arg)=="string" and P.Allocate(d,arg) then hum.MaxHealth=P.MaxHP(d); hum.WalkSpeed=ctx.Speed(player); ctx.Sync(player) end
 elseif verb=="Equip" then
  if r.Forging or now<(r.NextEquip or 0) then return end
  local weapon=type(arg)=="string" and P.Weapon(d,arg)
  if weapon and d.Level>=K.ById[weapon.Blueprint].Level then d.Equipped=weapon.Uid; r.NextEquip=now+.5; Equipment.Give(player,d); ctx.Sync(player) end
 elseif verb=="Attack" or verb=="Special" then
  if r.Forging or r.Dashing or (r.Mode=="World" and P.InTown(root.Position,d.Floor)) then return end
  local weapon=P.Weapon(d,d.Equipped); local tool=player.Character:FindFirstChildOfClass("Tool")
  if not weapon or not tool or tool:GetAttribute("WeaponUid")~=weapon.Uid then return end
  local item=K.ById[weapon.Blueprint]; local special=verb=="Special"
  if now<(r.NextAttack or 0) or (special and (now<(r.NextSpecial or 0) or r.Energy<item.Energy)) then return end
  r.NextAttack=now+item.Cooldown
  if special then r.NextSpecial=now+item.SpecialCooldown; r.Energy=r.Energy-item.Energy; ctx.Sync(player) end
  r.Combo=(r.Combo or 0)%3+1; ctx.Animate(player,special and item.Style or "Attack"..r.Combo,math.min(.6,item.Cooldown))
  Feedback:FireAllClients("Swing",player.UserId,special,item.Style); r.InCombatUntil=now+6
  local candidates={}
  for model,e in pairs(Enemies.Active) do
   if e.Mode==r.Mode and e.Def.Floor==d.Floor then
    local delta=model.PrimaryPart.Position-root.Position; local dist=delta.Magnitude
    if dist>0 and dist<item.Range+(special and 4 or 0) and root.CFrame.LookVector:Dot(delta.Unit)>(special and -.15 or .05) then candidates[#candidates+1]={Model=model,Dist=dist} end
   end
  end
  table.sort(candidates,function(a,b) return a.Dist<b.Dist end)
  local count=0
  for _,target in ipairs(candidates) do
   local model=target.Model; local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={player.Character}
   local hit=workspace:Raycast(root.Position,model.PrimaryPart.Position-root.Position,params)
   if not hit or hit.Instance:IsDescendantOf(model) then Enemies.Hit(player,model,K.Damage(weapon,d.Level,d.Stats.Forca,special)); count=count+1 end
   if count>=(special and (item.Style=="Slam" or item.Style=="Cleave") and 3 or 1) then break end
  end
 elseif verb=="Dash" then
  if r.Forging or r.Dashing or now<(r.NextDash or 0) or r.Energy<18 then return end
  r.NextDash=now+2.2; r.Energy=r.Energy-18; r.Invulnerable=now+.22; r.Dashing=true
  local direction=hum.MoveDirection.Magnitude>.1 and hum.MoveDirection.Unit or root.CFrame.LookVector
  direction=Vector3.new(direction.X,0,direction.Z).Unit
  local distance=P.Dash(d); local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={player.Character}
  local obstruction=workspace:Blockcast(root.CFrame,Vector3.new(3,4,2),direction*distance,params)
  if obstruction then distance=math.max(0,obstruction.Distance-2) end
  pcall(function() root:SetNetworkOwner(nil) end)
  Tween:Create(root,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=root.CFrame+direction*distance}):Play()
  ctx.Animate(player,"Dash",.25); ctx.Sync(player)
  task.delay(.22,function() r.Dashing=false; if root.Parent then pcall(function() root:SetNetworkOwner(player) end) end end)
 elseif verb=="Sprint" then r.Sprinting=arg==true; hum.WalkSpeed=ctx.Speed(player)
 elseif verb=="Travel" then
  if r.Mode~="World" or now<(r.InCombatUntil or 0) or r.Forging or not P.CanTravel(d,arg) then return end
  local marker=workspace.LittleWorld.Interactions:FindFirstChild("Travel_"..d.Floor)
  if not marker or (root.Position-marker.Position).Magnitude>20 then return end
  d.Floor=arg; ctx.RespawnAt(player); ctx.Sync(player)
 elseif not r.Forging then WorldActions.Action(player,verb,arg) end
end)
task.spawn(function()
 local stockEpoch=math.floor(os.time()/C.StockSeconds)
 while task.wait(1) do
  local epoch=math.floor(os.time()/C.StockSeconds); local refresh=epoch~=stockEpoch; stockEpoch=epoch
  for player,d in pairs(Profiles.Data) do
   local r=ctx.Runtime[player]; local root,hum=ctx.Character(player)
   if r and root and not Profiles.Travel[player] then
    if r.Sprinting and hum.MoveDirection.Magnitude>.1 then r.Energy=math.max(0,r.Energy-5); if r.Energy==0 then r.Sprinting=false end else r.Energy=math.min(100,r.Energy+8) end
    hum.WalkSpeed=ctx.Speed(player); player:SetAttribute("Energy",math.floor(r.Energy))
    local y=C.Floors[d.Floor].Origin.Y
    local outside=r.Mode=="World" and (math.abs(root.Position.X)>850 or math.abs(root.Position.Z)>650) or r.Mode=="Dungeon" and (root.Position.X<C.DungeonX-240 or root.Position.X>C.DungeonX+610 or math.abs(root.Position.Z)>240)
    if root.Position.Y<y-50 or root.Position.Y>y+120 or outside then ctx.RespawnAt(player); hum:TakeDamage(hum.MaxHealth*.1)
    elseif r.Mode=="World" and P.InTown(root.Position,d.Floor) then hum.Health=math.min(hum.MaxHealth,hum.Health+hum.MaxHealth*.03) end
    if refresh then ctx.Sync(player) end
   end
  end
 end
end)
