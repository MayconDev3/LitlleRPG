-- Feedback físico e sequência completa da forja, sem carregar código ou assets externos.
local Shared=game.ReplicatedStorage:WaitForChild("LittleRPG")
local C=require(Shared:WaitForChild("Config")); local K=require(Shared:WaitForChild("Catalog"))
local Feedback=Shared:WaitForChild("Remotes"):WaitForChild("Feedback")
local Tween=game:GetService("TweenService"); local Debris=game:GetService("Debris"); local Players=game:GetService("Players")
local function piece(parent,size,cf,color,material)
 local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.Neon; p.Parent=parent; return p
end
local function ring(position,radius,duration,color)
 local p=piece(workspace,Vector3.new(.15,radius*2,radius*2),CFrame.new(position.X,position.Y-2.7,position.Z)*CFrame.Angles(0,0,math.pi/2),color)
 p.Shape=Enum.PartType.Cylinder; p.Transparency=.65
 Tween:Create(p,TweenInfo.new(duration),{Transparency=1}):Play(); Debris:AddItem(p,duration)
end
local function shards(position,color,count)
 for i=1,count do
  local p=piece(workspace,Vector3.new(.18,.18,.5),CFrame.new(position),color)
  local target=position+Vector3.new(math.random(-4,4),math.random(1,5),math.random(-4,4))
  Tween:Create(p,TweenInfo.new(.45),{Position=target,Transparency=1}):Play(); Debris:AddItem(p,.5)
 end
end
Feedback.OnClientEvent:Connect(function(kind,a,b,c)
 local cam=workspace.CurrentCamera
 if kind=="Warning" then if (cam.CFrame.Position-a).Magnitude<180 then ring(a,b,c,Color3.fromRGB(255,85,85)) end
 elseif kind=="Mine" or kind=="Defeat" then if (cam.CFrame.Position-a).Magnitude<150 then shards(a,kind=="Mine" and Color3.fromRGB(196,184,166) or Color3.fromRGB(255,184,108),8) end
 elseif kind=="Hit" then
  if (cam.CFrame.Position-a).Magnitude>150 then return end
  shards(a,Color3.fromRGB(248,248,242),5)
  local anchor=piece(workspace,Vector3.one,CFrame.new(a+Vector3.new(0,3,0)),Color3.new(1,1,1)); anchor.Transparency=1
  local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(100,50); gui.AlwaysOnTop=true; gui.Parent=anchor
  local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text=tostring(b); text.TextColor3=Color3.fromRGB(255,184,108); text.Font=Enum.Font.GothamBold; text.TextSize=24; text.Parent=gui
  Tween:Create(anchor,TweenInfo.new(.7),{Position=anchor.Position+Vector3.new(0,4,0)}):Play(); Tween:Create(text,TweenInfo.new(.7),{TextTransparency=1}):Play(); Debris:AddItem(anchor,.8)
 elseif kind=="Swing" then
  local player=Players:GetPlayerByUserId(a); local char=player and player.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
  if not root or (cam.CFrame.Position-root.Position).Magnitude>100 then return end
  local count=b and 9 or 4
  for i=1,count do
   local angle=(i/count-.5)*1.7
   local cf=root.CFrame*CFrame.Angles(0,angle,0)*CFrame.new(0,.5,-4)
   local streak=piece(workspace,Vector3.new(.12,.12,b and 3 or 1.5),cf,b and Color3.fromRGB(189,147,249) or Color3.fromRGB(248,248,242))
   Tween:Create(streak,TweenInfo.new(.22),{Transparency=1}):Play(); Debris:AddItem(streak,.25)
  end
 elseif kind=="Forge" then
  local floor=b; local origin=C.Floors[floor].Origin+C.Floors[floor].Forge
  if (cam.CFrame.Position-origin).Magnitude>150 then return end
  local model=Instance.new("Model"); model.Name="ForgeSequence"; model.Parent=workspace; Debris:AddItem(model,11)
  local crucible=piece(model,Vector3.new(4,3,4),CFrame.new(origin+Vector3.new(-17,7,-7)),Color3.fromRGB(73,69,79),Enum.Material.Metal)
  local metal=piece(model,Vector3.new(3.5,.25,3.5),crucible.CFrame*CFrame.new(0,1.6,0),Color3.fromRGB(120,59,39))
  local light=Instance.new("PointLight"); light.Color=Color3.fromRGB(255,122,60); light.Range=22; light.Brightness=0; light.Parent=metal
  Tween:Create(metal,TweenInfo.new(3),{Color=Color3.fromRGB(255,218,111)}):Play(); Tween:Create(light,TweenInfo.new(3),{Brightness=4}):Play()
  task.spawn(function()
   for _=1,6 do if not model.Parent then return end; shards(origin+Vector3.new(-17,7,-7),Color3.fromRGB(255,144,61),4); task.wait(.45) end
   if not model.Parent then return end
   local target=CFrame.new(origin+Vector3.new(0,8,8))*CFrame.Angles(0,0,math.rad(-55))
   Tween:Create(crucible,TweenInfo.new(1),{CFrame=target}):Play(); Tween:Create(metal,TweenInfo.new(1),{CFrame=target*CFrame.new(0,1.6,0)}):Play()
   task.wait(1)
   local stream=piece(model,Vector3.new(.45,4,.45),CFrame.new(origin+Vector3.new(-1,5.8,8)),Color3.fromRGB(255,211,109))
   local shape=K.ById[c].Shape
   local mold=piece(model,Vector3.new(shape=="Rapier" and .22 or .9,.3,shape=="Dagger" and 2.2 or shape=="Greatsword" and 7 or 5),CFrame.new(origin+Vector3.new(0,3.7,9)),Color3.fromRGB(255,190,90))
   if shape=="LightHammer" or shape=="HeavyHammer" then
    local head=piece(model,Vector3.new(shape=="HeavyHammer" and 3.2 or 2,.4,1.5),CFrame.new(origin+Vector3.new(0,3.7,7)),Color3.fromRGB(255,190,90))
    Tween:Create(head,TweenInfo.new(5),{Color=Color3.fromRGB(165,172,186)}):Play()
   end
   task.wait(1.4); stream:Destroy(); crucible:Destroy(); metal:Destroy()
   Tween:Create(mold,TweenInfo.new(4),{Color=Color3.fromRGB(165,172,186)}):Play()
   for _=1,5 do
    shards(mold.Position,Color3.fromRGB(255,205,110),6)
    local hammer=piece(model,Vector3.new(2,1,1),CFrame.new(mold.Position+Vector3.new(0,3,0)),Color3.fromRGB(100,105,119),Enum.Material.Metal)
    Tween:Create(hammer,TweenInfo.new(.15),{Position=mold.Position+Vector3.new(0,.6,0)}):Play(); Debris:AddItem(hammer,.4); task.wait(.6)
   end
  end)
 end
end)
