-- Criaturas físicas, telegraph de golpes e navegação com orçamento limitado.
local Run=game:GetService("RunService")
local Paths=game:GetService("PathfindingService")
local C=require(game.ReplicatedStorage.LittleRPG.Config)
local P=require(game.ReplicatedStorage.LittleRPG.Progression)
local Enemies={Active={}}
function Enemies.Start(ctx)
 local folder=Instance.new("Folder"); folder.Name="LittleEnemies"; folder.Parent=workspace
 local function spawn(id,home,mode)
  local def=C.Enemies[id]; local s=def.Boss and 1.8 or 1
  local model=Instance.new("Model"); model.Name=def.Name
  model:SetAttribute("EnemyId",id); model:SetAttribute("Floor",def.Floor); model:SetAttribute("Mode",mode)
  local limbs={}; local root
  local function part(name,size,offset,color)
   local p=Instance.new("Part"); p.Name=name; p.Size=size*s; p.CFrame=CFrame.new(home+offset*s); p.Color=color or Color3.fromRGB(unpack(def.Color)); p.Material=Enum.Material.Slate; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.Parent=model
   if name=="HumanoidRootPart" then root=p; p.Transparency=1; model.PrimaryPart=p end
   if name=="Leg" then limbs[#limbs+1]={Part=p,Offset=CFrame.new(offset*s)} end
   return p
  end
  part("HumanoidRootPart",Vector3.new(2,2,2),Vector3.new())
  if def.Shape=="Wolf" or def.Shape=="Boar" or def.Shape=="Beetle" then
   part("Body",Vector3.new(2.6,2,4.4),Vector3.new(0,.4,0))
   part("Head",Vector3.new(1.8,1.6,1.7),Vector3.new(0,1,-2.5))
   part("Muzzle",Vector3.new(1.2,.7,1.2),Vector3.new(0,.6,-3.5),Color3.fromRGB(65,66,76))
   for _,side in ipairs({-1,1}) do
    part("Ear",Vector3.new(.45,1,.65),Vector3.new(side*.7,2,-2.3))
    part("Eye",Vector3.new(.2,.2,.15),Vector3.new(side*.6,1.2,-3.4),Color3.fromRGB(255,220,132))
    for _,z in ipairs({-1.3,1.3}) do part("Leg",Vector3.new(.55,2,.65),Vector3.new(side*.95,-1,z)) end
    if def.Shape=="Boar" then part("Tusk",Vector3.new(.25,.8,.25),Vector3.new(side*.8,.5,-3.6),Color3.fromRGB(242,228,200)) end
   end
   part("Tail",Vector3.new(.5,.5,2),Vector3.new(0,.7,3))
   if def.Shape=="Beetle" then part("Carapace",Vector3.new(3.5,1.3,4.5),Vector3.new(0,1.5,0),Color3.fromRGB(72,86,112)) end
  else
   part("Torso",Vector3.new(2.6,2.8,1.7),Vector3.new(0,.5,0))
   part("Head",Vector3.new(1.6,1.4,1.4),Vector3.new(0,2.6,0))
   for _,side in ipairs({-1,1}) do
    part("Arm",Vector3.new(.9,2.7,1),Vector3.new(side*1.8,.3,0))
    part("Leg",Vector3.new(1,2,1),Vector3.new(side*.7,-1.8,0))
    part("Shoulder",Vector3.new(1.4,.7,1.6),Vector3.new(side*1.7,1.8,0),Color3.fromRGB(58,58,72))
   end
   part("Weapon",Vector3.new(.6,4,.4),Vector3.new(2,1.4,-.7),Color3.fromRGB(195,190,190))
   if def.Shape=="Construct" then local core=part("Furnace",Vector3.new(.8,.9,.2),Vector3.new(0,.7,-.96),Color3.fromRGB(255,184,108)); core.Material=Enum.Material.Neon end
  end
  if def.Boss then for i=-1,1 do part("Crown",Vector3.new(.4,1.2,.4),Vector3.new(i*.6,3.7,0),Color3.fromRGB(211,176,106)) end end
  local hum=Instance.new("Humanoid"); hum.RequiresNeck=false; hum.BreakJointsOnDeath=false; hum.MaxHealth=def.HP; hum.Health=def.HP; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; hum.Parent=model
  local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(def.Boss and 270 or 180,44); gui.StudsOffset=Vector3.new(0,5*s,0); gui.MaxDistance=100; gui.Parent=root
  local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,.65); label.BackgroundTransparency=1; label.Text=def.Name.." · Nv. "..def.Level; label.TextColor3=Color3.fromRGB(248,248,242); label.TextStrokeTransparency=.3; label.Font=Enum.Font.GothamMedium; label.TextSize=12; label.Parent=gui
  local bar=Instance.new("Frame"); bar.Size=UDim2.fromScale(1,.12); bar.Position=UDim2.fromScale(0,.8); bar.BackgroundColor3=Color3.fromRGB(255,85,85); bar.BorderSizePixel=0; bar.Parent=gui
  model.Parent=folder
  Enemies.Active[model]={Def=def,Id=id,Mode=mode,Home=home,Hum=hum,Bar=bar,Limbs=limbs,NextAttack=0,NextPath=0,Damage={},HomeY=home.Y}
 end
 for _,marker in ipairs(workspace.LittleWorld.Spawns:GetChildren()) do
  local id,mode=marker.Name:match("^(%a+)_(%a+)_")
  if id and C.Enemies[id] then spawn(id,marker.Position,mode) end
 end
 function Enemies.Hit(player,model,damage)
  local e=Enemies.Active[model]; if not e or e.Hum.Health<=0 then return end
  local actual=math.min(damage,e.Hum.Health); e.Damage[player]=(e.Damage[player] or 0)+actual
  e.Hum.Health=math.max(0,e.Hum.Health-actual); e.Bar.Size=UDim2.fromScale(e.Hum.Health/e.Def.HP,.12)
  ctx.Feedback:FireAllClients("Hit",model.PrimaryPart.Position,actual)
  if e.Hum.Health<=0 then
   Enemies.Active[model]=nil
   for player,dealt in pairs(e.Damage) do
    local d=ctx.Profiles.Data[player]; local r=ctx.Runtime[player]; local root=ctx.Character(player)
    if d and r and root and not ctx.Profiles.Travel[player] and d.Floor==e.Def.Floor and r.Mode==e.Mode and dealt>=e.Def.HP*.05 and (root.Position-model.PrimaryPart.Position).Magnitude<140 then ctx.OnKill(player,e.Id) end
   end
   ctx.Feedback:FireAllClients("Defeat",model.PrimaryPart.Position); model:Destroy()
   task.delay(e.Def.Boss and 60 or 25,function() spawn(e.Id,e.Home,e.Mode) end)
  end
 end
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt; if elapsed<.1 then return end
  local step=math.min(.2,elapsed); elapsed=0
  for model,e in pairs(Enemies.Active) do
   local root=model.PrimaryPart; local target; local best=e.Def.Boss and 100 or 65
   for player,d in pairs(ctx.Profiles.Data) do
    local r=ctx.Runtime[player]; local hrp,hum=ctx.Character(player)
    if r and hrp and hum and not ctx.Profiles.Travel[player] and d.Floor==e.Def.Floor and r.Mode==e.Mode and (r.Mode=="Dungeon" or not P.InTown(hrp.Position,d.Floor)) then
     local dist=(hrp.Position-root.Position).Magnitude
     if dist<best then best=dist; target=hrp end
    end
   end
   if (root.Position-e.Home).Magnitude>150 then target=nil end
   local destination=target and Vector3.new(target.Position.X,e.HomeY,target.Position.Z) or e.Home
   if not target and e.Targeted then e.Hum.Health=e.Def.HP; e.Bar.Size=UDim2.fromScale(1,.12); e.Damage={} end
   e.Targeted=target~=nil
   local delta=destination-root.Position
   local moving=delta.Magnitude>6 and not e.Windup
   if moving then
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={folder,target and target.Parent or folder}
    local obstruction=workspace:Raycast(root.Position,delta.Unit*math.min(8,delta.Magnitude),params)
    if obstruction and os.clock()>e.NextPath and not e.PathBusy then
     e.NextPath=os.clock()+2.5; e.PathBusy=true
     task.spawn(function()
      local path=Paths:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=5})
      local ok=pcall(function() path:ComputeAsync(root.Position,destination) end)
      if ok and path.Status==Enum.PathStatus.Success then e.Waypoints=path:GetWaypoints(); e.Waypoint=2 end
      e.PathBusy=false
     end)
    end
    local goal=destination
    if e.Waypoints and e.Waypoints[e.Waypoint] then
     local waypoint=e.Waypoints[e.Waypoint].Position; goal=Vector3.new(waypoint.X,e.HomeY,waypoint.Z)
     if (goal-root.Position).Magnitude<4 then e.Waypoint=e.Waypoint+1 end
    end
    local direction=goal-root.Position
    if direction.Magnitude>.1 then
     local travel=direction.Unit*math.min(direction.Magnitude,e.Def.Speed*step)
     local hit=workspace:Raycast(root.Position,travel+direction.Unit*2,params)
     if not hit then local pos=root.Position+travel; model:PivotTo(CFrame.lookAt(pos,pos+direction.Unit)) end
    end
   end
   for i,limb in ipairs(e.Limbs) do limb.Part.CFrame=root.CFrame*limb.Offset*CFrame.Angles(moving and math.sin(os.clock()*10+i*math.pi)*.5 or 0,0,0) end
   if target and best<(e.Def.Boss and 24 or 8) and os.clock()>=e.NextAttack then
    e.NextAttack=os.clock()+(e.Def.Boss and 3.5 or 1.8); e.Windup=true
    local radius=e.Def.Boss and 22 or 9; local center=root.Position
    ctx.Feedback:FireAllClients("Warning",center,radius,e.Def.Boss and 1.2 or .65)
    task.delay(e.Def.Boss and 1.2 or .65,function()
     e.Windup=false; if not Enemies.Active[model] then return end
     for player,d in pairs(ctx.Profiles.Data) do
      local r=ctx.Runtime[player]; local hrp,hum=ctx.Character(player)
      if r and hrp and hum and not ctx.Profiles.Travel[player] and d.Floor==e.Def.Floor and r.Mode==e.Mode and os.clock()>(r.Invulnerable or 0) and (r.Mode=="Dungeon" or not P.InTown(hrp.Position,d.Floor)) and (hrp.Position-center).Magnitude<radius then
       local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={folder,hrp.Parent}
       if not workspace:Raycast(center,hrp.Position-center,params) then
        hum:TakeDamage(math.max(1,math.floor(e.Def.Damage*(1-P.Reduction(d))))); r.InCombatUntil=os.clock()+8; ctx.Animate(player,"Hurt",.35); ctx.Feedback:FireClient(player,"Hurt")
       end
      end
     end
    end)
   end
  end
 end)
end
return Enemies
