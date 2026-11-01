local Players=game:GetService("Players")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("LittleRPG")
local C=require(Shared.Config); local P=require(Shared.Progression)
local Profiles=require(script.Parent.Profiles); local Equipment=require(script.Parent.Equipment); local Enemies=require(script.Parent.Enemies)
local remotes=Instance.new("Folder"); remotes.Name="Remotes"; remotes.Parent=Shared
local function remote(name) local r=Instance.new("RemoteEvent"); r.Name=name; r.Parent=remotes; return r end
local action=remote("Action"); local state=remote("State"); local feedback=remote("Feedback")
local cooldowns={}; local ready={}
local function sync(player,message)
 local d=Profiles.Data[player]; if not d then return end
 state:FireClient(player,{Level=d.Level,XP=d.XP,Required=P.Required(d.Level),Gold=d.Gold,Floor=d.Floor,Unlocked=d.Unlocked,Owned=d.Owned,Equipped=d.Equipped,Bosses=d.Bosses,Kills=d.Kills,Temporary=game:GetService("RunService"):IsStudio()})
 local stats=player:FindFirstChild("leaderstats"); if stats then stats:FindFirstChild("Nível").Value=d.Level end
 if message then feedback:FireClient(player,"Notice",message) end
end
local function travel(player,floor)
 local d=Profiles.Data[player]; if not d or not P.CanTravel(d,floor,C) then if d then sync(player,"Derrote o chefe anterior e alcance o nível necessário.") end; return end
 local ch=player.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 then return end
 d.Floor=floor; ch:PivotTo(CFrame.new(C.Floors[floor].Origin+C.Spawn)); hum.Health=hum.MaxHealth; sync(player)
 feedback:FireClient(player,"Floor",floor)
end
local function onCharacter(player,ch)
 if ch:GetAttribute("LittleSetup") then return end; ch:SetAttribute("LittleSetup",true)
 local hum=ch:WaitForChild("Humanoid",10); local root=ch:WaitForChild("HumanoidRootPart",10)
 while player.Parent and not Profiles.Data[player] do task.wait(.1) end
 local d=Profiles.Data[player]; if not hum or not root or not d then return end
 hum.MaxHealth=P.MaxHP(d.Level); hum.Health=hum.MaxHealth; hum.WalkSpeed=22
 ch:PivotTo(CFrame.new(C.Floors[d.Floor].Origin+C.Spawn))
 task.wait(.2); Equipment.Give(player,d.Equipped); sync(player)
end
local function join(player)
 player.CharacterAdded:Connect(function(ch) onCharacter(player,ch) end)
 local d=Profiles.Load(player); if not d then return end
 if not player.Parent then Profiles.Close(player); return end
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
 local level=Instance.new("IntValue"); level.Name="Nível"; level.Value=d.Level; level.Parent=stats
 if player.Character then task.spawn(onCharacter,player,player.Character) end
 if ready[player] then sync(player) end
end
Players.PlayerAdded:Connect(join); for _,player in ipairs(Players:GetPlayers()) do task.spawn(join,player) end
Players.PlayerRemoving:Connect(function(p) cooldowns[p]=nil; ready[p]=nil end)
Enemies.Start(Profiles,feedback,function(player,def)
 local d=Profiles.Data[player]; if not d then return end
 d.Kills=d.Kills+1
 local leveled=P.Grant(d,def.XP,def.Gold)
 if def.Boss then
  d.Bosses[def.Id]=true; d.Unlocked=math.max(d.Unlocked,math.min(3,def.Floor+1))
  sync(player,def.Floor==3 and "O Eco foi silenciado. A torre é sua!" or "Chefe vencido! O portal do próximo andar foi liberado.")
 end
 -- Guaranteed gear progression through the forge; drops are an additional reward.
 if math.random()<.16 or def.Boss then
  local eligible={}; for _,item in ipairs(C.ItemList) do if item.Level<=d.Level and not d.Owned[item.Id] then table.insert(eligible,item) end end
  if #eligible>0 then local item=eligible[math.random(#eligible)]; d.Owned[item.Id]=true; feedback:FireClient(player,"Notice","Encontrou: "..item.Name) end
 end
 if leveled then
  local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if hum and hum.Health>0 then hum.MaxHealth=P.MaxHP(d.Level); hum.Health=hum.MaxHealth end
  feedback:FireClient(player,"Level",d.Level)
 end
 sync(player); feedback:FireClient(player,"Reward",def.XP,def.Gold)
end)
action.OnServerEvent:Connect(function(player,verb,arg)
 if type(verb)~="string" then return end
 local now=os.clock(); local cd=cooldowns[player] or {}; cooldowns[player]=cd
 if now<(cd.Any or 0) then return end; cd.Any=now+.06
 if verb=="Ready" then ready[player]=true; sync(player); return end
 local d=Profiles.Data[player]; if not d or Profiles.Closing[player] then return end
 local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart")
 if not hum or hum.Health<=0 or not root then return end
 if verb=="Equip" and type(arg)=="string" then
  local item=C.Items[arg]; if item and d.Owned[arg] and d.Level>=item.Level and now>=(cd.Equip or 0) then
   cd.Equip=now+.5; d.Equipped=arg; Equipment.Give(player,arg); sync(player)
  end
 elseif verb=="Buy" and type(arg)=="string" then
  local _,message=P.Buy(d,arg,C); sync(player,message)
 elseif verb=="Attack" then
  local item=C.Items[d.Equipped]; local tool=char:FindFirstChildOfClass("Tool")
  if not item or not tool or tool:GetAttribute("ItemId")~=d.Equipped or now<(cd.Attack or 0) or root.Position.Z>65 then return end
  cd.Attack=now+item.Cooldown
  local target; local nearest=item.Range
  for model,enemy in pairs(Enemies.Active) do
   if enemy.Def.Floor==d.Floor then
    local delta=model.PrimaryPart.Position-root.Position
    local dist=delta.Magnitude
    if dist<nearest and dist>.01 and root.CFrame.LookVector:Dot(delta.Unit)>-.1 then target=model; nearest=dist end
   end
  end
  feedback:FireClient(player,"Swing",item.Cooldown)
  if target then
   local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={char}
   local hit=workspace:Raycast(root.Position,target.PrimaryPart.Position-root.Position,params)
   if not hit or hit.Instance:IsDescendantOf(target) then Enemies.Hit(player,target,item.Damage+math.floor(d.Level*.9)) end
  end
 elseif verb=="Heal" and root.Position.Z>65 and now>=(cd.Heal or 0) then
  cd.Heal=now+4; hum.Health=hum.MaxHealth; sync(player,"Vida restaurada no santuário.")
 end
end)
for _,p in ipairs(workspace.LittleWorld.Portals:GetChildren()) do
 local floor=tonumber(p.Name:match("^(%d)")); local direction=p.Name:find("Next") and 1 or -1
 local prompt=Instance.new("ProximityPrompt"); prompt.ActionText=direction==1 and "Subir andar" or "Voltar andar"; prompt.ObjectText="Portal de Aether"; prompt.HoldDuration=.4; prompt.MaxActivationDistance=14; prompt.RequiresLineOfSight=false; prompt.Parent=p
 prompt.Triggered:Connect(function(player)
  local d=Profiles.Data[player]; local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if d and d.Floor==floor and root and (root.Position-p.Position).Magnitude<=18 then travel(player,floor+direction) end
 end)
end
task.spawn(function()
 while task.wait(1) do
  for player,d in pairs(Profiles.Data) do
   local ch=player.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart"); local hum=ch and ch:FindFirstChildOfClass("Humanoid")
   if root and hum and hum.Health>0 then
    local origin=C.Floors[d.Floor].Origin
    if root.Position.Y<origin.Y-45 or root.Position.Y>origin.Y+100 or math.abs(root.Position.X)>190 or math.abs(root.Position.Z)>190 then
     ch:PivotTo(CFrame.new(origin+C.Spawn)); hum:TakeDamage(hum.MaxHealth*.1)
    elseif root.Position.Z>65 then hum.Health=math.min(hum.MaxHealth,hum.Health+hum.MaxHealth*.04) end
   end
  end
 end
end)
