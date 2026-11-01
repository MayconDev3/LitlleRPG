local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local C=require(game.ReplicatedStorage.LittleRPG.Config)
local Enemies={Active={}}
local function part(model,name,size,position,color)
 local p=Instance.new("Part"); p.Name=name; p.Anchored=true; p.CanCollide=false; p.Size=size; p.Position=position; p.Color=color; p.Material=Enum.Material.Slate; p.Parent=model; return p
end
function Enemies.Start(profiles,feedback,onKill)
 local folder=Instance.new("Folder"); folder.Name="LittleEnemies"; folder.Parent=workspace
 local function spawn(def,home)
  local s=def.Boss and 2.2 or 1
  local model=Instance.new("Model"); model.Name=def.Name; model:SetAttribute("EnemyId",def.Id); model:SetAttribute("Floor",def.Floor)
  local root=part(model,"HumanoidRootPart",Vector3.new(2,2,1)*s,home,def.Color); root.Transparency=1; model.PrimaryPart=root
  part(model,"Torso",Vector3.new(2.6,2.8,1.5)*s,home,def.Color)
  part(model,"Head",Vector3.new(1.6,1.4,1.4)*s,home+Vector3.new(0,2.1*s,0),def.Color)
  for _,side in ipairs({-1,1}) do
   part(model,"Arm",Vector3.new(.8,2.5,1)*s,home+Vector3.new(side*1.8*s,0,0),def.Color)
   part(model,"Leg",Vector3.new(1,2,.95)*s,home+Vector3.new(side*.7*s,-2.2*s,0),def.Color)
   local eye=part(model,"Eye",Vector3.new(.32,.2,.12)*s,home+Vector3.new(side*.38*s,2.2*s,-.75*s),Color3.fromRGB(230,255,246)); eye.Material=Enum.Material.Neon
  end
  if def.Id=="boar" then
   part(model,"Snout",Vector3.new(1.5,.8,1.3),home+Vector3.new(0,1.8,-1),Color3.fromRGB(85,81,76))
  end
  if def.Boss then
   for i=-1,1 do part(model,"Crown",Vector3.new(.5,1.5,.5)*s,home+Vector3.new(i*.7*s,3.3*s,0),Color3.fromRGB(242,216,140)) end
  end
  if def.Id=="sprout" then
   part(model,"LeafCrest",Vector3.new(2,.5,2),home+Vector3.new(0,3,0),Color3.fromRGB(154,197,111))
  elseif def.Id=="shard" then
   for _,side in ipairs({-1,1}) do part(model,"CrystalPauldron",Vector3.new(.7,2.4,.7),home+Vector3.new(side*1.8,1.4,0),Color3.fromRGB(191,225,255)) end
  elseif def.Id=="wisp" then
   for i=1,4 do local angle=i*math.pi/2; local p=part(model,"FloatingShard",Vector3.new(.7,1.7,.7),home+Vector3.new(math.cos(angle)*3,1,math.sin(angle)*3),def.Color); p.Material=Enum.Material.Neon end
  elseif def.Id=="automaton" then
   local core=part(model,"Furnace",Vector3.new(1,1,.2),home+Vector3.new(0,.4,-.85),Color3.fromRGB(255,183,88)); core.Material=Enum.Material.Neon
   part(model,"Backpack",Vector3.new(2,3,1.3),home+Vector3.new(0,.3,1.3),Color3.fromRGB(83,92,99))
  elseif def.Id=="oracle" then
   for _,side in ipairs({-1,1}) do local wing=part(model,"PrismWing",Vector3.new(4,6,.6),home+Vector3.new(side*6,2,1),def.Color); wing.Material=Enum.Material.Glass; wing.Transparency=.25 end
  elseif def.Id=="echo" then
   for _,side in ipairs({-1,1}) do part(model,"RoyalArmor",Vector3.new(3,2.5,3),home+Vector3.new(side*4.5,2,0),Color3.fromRGB(91,99,109)) end
  end
  local hum=Instance.new("Humanoid"); hum.RequiresNeck=false; hum.BreakJointsOnDeath=false; hum.MaxHealth=def.HP; hum.Health=def.HP; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; hum.Parent=model
  local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(def.Boss and 260 or 190,48); gui.StudsOffset=Vector3.new(0,4.8*s,0); gui.AlwaysOnTop=false; gui.MaxDistance=100; gui.Parent=root
  local title=Instance.new("TextLabel"); title.Size=UDim2.fromScale(1,.6); title.BackgroundTransparency=1; title.Text=def.Name.." · "..def.Level; title.TextColor3=Color3.new(1,1,1); title.TextStrokeTransparency=.4; title.Font=Enum.Font.GothamMedium; title.TextSize=12; title.Parent=gui
  local track=Instance.new("Frame"); track.Size=UDim2.new(.8,0,0,5); track.Position=UDim2.fromScale(.1,.8); track.BackgroundColor3=Color3.fromRGB(30,40,50); track.BorderSizePixel=0; track.Parent=gui
  local bar=Instance.new("Frame"); bar.Size=UDim2.fromScale(1,1); bar.BackgroundColor3=def.Color; bar.BorderSizePixel=0; bar.Parent=track
  model.Parent=folder
  Enemies.Active[model]={Def=def,Home=home,Hum=hum,Bar=bar,NextAttack=0,Damage={},Phase=0}
 end
 for _,marker in ipairs(workspace.LittleWorld.Spawns:GetChildren()) do
  local def=C.Enemies[tonumber(marker.Name)]
  if def then spawn(def,marker.Position) end
 end
 function Enemies.Hit(player,model,damage)
  local enemy=Enemies.Active[model]; if not enemy or enemy.Hum.Health<=0 then return end
  local actual=math.min(damage,enemy.Hum.Health)
  enemy.Damage[player]=(enemy.Damage[player] or 0)+actual
  enemy.Hum.Health=math.max(0,enemy.Hum.Health-actual); enemy.Bar.Size=UDim2.fromScale(enemy.Hum.Health/enemy.Def.HP,1)
  feedback:FireAllClients("Hit",model.PrimaryPart.Position,actual)
  if enemy.Hum.Health<=0 then
   Enemies.Active[model]=nil
   for contributor,dealt in pairs(enemy.Damage) do
    local data=profiles.Data[contributor]; local char=contributor.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if data and hrp and contributor.Parent==Players and data.Floor==enemy.Def.Floor and (hrp.Position-model.PrimaryPart.Position).Magnitude<140 and dealt>=enemy.Def.HP*.05 then onKill(contributor,enemy.Def) end
   end
   model:Destroy()
   task.delay(enemy.Def.Boss and 45 or 12,function() spawn(enemy.Def,enemy.Home) end)
  end
 end
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt; if elapsed<.1 then return end
  local step=math.min(elapsed,.25); elapsed=0
  for model,enemy in pairs(Enemies.Active) do
   local root=model.PrimaryPart; local def=enemy.Def; local target; local best=def.Boss and 60 or 38
   for player,data in pairs(profiles.Data) do
    local ch=player.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart"); local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    if data.Floor==def.Floor and hrp and hum and hum.Health>0 and hrp.Position.Z<65 then
     local dist=(hrp.Position-root.Position).Magnitude
     if dist<best then best=dist; target=hrp end
    end
   end
   local homeDistance=(root.Position-enemy.Home).Magnitude
   if homeDistance>80 then target=nil end
   local goal=target and Vector3.new(target.Position.X,enemy.Home.Y,target.Position.Z) or enemy.Home
   local delta=goal-root.Position
   if delta.Magnitude> (target and 5 or 1) and not enemy.Windup then
    local pos=root.Position+delta.Unit*math.min(delta.Magnitude,def.Speed*step)
    model:PivotTo(CFrame.lookAt(pos,Vector3.new(goal.X,pos.Y,goal.Z)))
   end
   if not target and homeDistance>2 then
    enemy.Damage={}; enemy.Hum.Health=def.HP; enemy.Bar.Size=UDim2.fromScale(1,1)
   end
   if target and best<(def.Boss and 24 or 7) and os.clock()>=enemy.NextAttack then
    enemy.NextAttack=os.clock()+(def.Boss and 3.8 or 1.5); enemy.Windup=true
    local radius=def.Boss and 20 or 8
    local center=Vector3.new(root.Position.X,C.Floors[def.Floor].Origin.Y+1,root.Position.Z)
    local disk=Instance.new("Part"); disk.Name="AttackWarning"; disk.Shape=Enum.PartType.Cylinder; disk.Size=Vector3.new(.15,radius*2,radius*2); disk.CFrame=CFrame.new(center)*CFrame.Angles(0,0,math.pi/2); disk.Anchored=true; disk.CanCollide=false; disk.CanQuery=false; disk.Material=Enum.Material.Neon; disk.Color=Color3.fromRGB(255,96,82); disk.Transparency=.7; disk.Parent=workspace
    task.delay(def.Boss and 1.25 or .55,function()
     disk:Destroy(); enemy.Windup=false
     if not Enemies.Active[model] then return end
     for player,data in pairs(profiles.Data) do
      local ch=player.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart"); local hum=ch and ch:FindFirstChildOfClass("Humanoid")
      if hrp and hum and data.Floor==def.Floor and hrp.Position.Z<65 and (Vector3.new(hrp.Position.X,center.Y,hrp.Position.Z)-center).Magnitude<radius and math.abs(hrp.Position.Y-center.Y)<12 then
       hum:TakeDamage(def.Damage); feedback:FireClient(player,"Hurt")
      end
     end
    end)
   end
  end
 end)
end
return Enemies
