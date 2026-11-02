-- Animações procedurais R6: renderizadas em todos os personagens por cada cliente.
-- Estados replicados por atributos do servidor; nenhuma dependência de IDs externos.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local rigs={}
local function register(character)
 task.spawn(function()
  local torso=character:WaitForChild("Torso",10); local root=character:WaitForChild("HumanoidRootPart",10); local hum=character:WaitForChild("Humanoid",10)
  if not torso or not root or not hum then return end
  local joints={}
  for _,name in ipairs({"Left Shoulder","Right Shoulder","Left Hip","Right Hip","Neck"}) do local joint=torso:WaitForChild(name,5); if joint then joints[name]=joint end end
  rigs[character]={Root=root,Hum=hum,Joints=joints}
 end)
end
local function watch(player) player.CharacterAdded:Connect(register); if player.Character then register(player.Character) end end
Players.PlayerAdded:Connect(watch); for _,player in ipairs(Players:GetPlayers()) do watch(player) end
local function rotation(x,y,z) return CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0)) end
Run.PreSimulation:Connect(function(dt)
 local now=workspace:GetServerTimeNow()
 for char,rig in pairs(rigs) do
  if not char.Parent then rigs[char]=nil else
   local velocity=rig.Root.AssemblyLinearVelocity; local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
   local phase=now*(speed>23 and 14 or 10); local swing=speed>1 and math.sin(phase)*(speed>23 and 48 or 32) or math.sin(now*2)*2
   local left=rotation(swing,0,-3); local right=rotation(-swing,0,3); local leftLeg=rotation(-swing); local rightLeg=rotation(swing); local neck=CFrame.new()
   local airborne=rig.Hum.FloorMaterial==Enum.Material.Air
   if airborne then left=rotation(-25,0,-25); right=rotation(-25,0,25); leftLeg=rotation(-20); rightLeg=rotation(20) end
   if char:FindFirstChildOfClass("Tool") then right=rotation(-58,0,7) end
   local started=char:GetAttribute("ActionStart") or 0; local duration=char:GetAttribute("ActionDuration") or .5; local t=(now-started)/duration
   if t>=0 and t<1 then
    local action=char:GetAttribute("ActionName"); local pulse=math.sin(t*math.pi)
    if action=="Attack1" then right=rotation(-65-70*pulse,45-100*t,15)
    elseif action=="Attack2" then right=rotation(-100+70*pulse,-45+100*t,-20)
    elseif action=="Attack3" then right=rotation(-60-110*pulse,0,10); left=rotation(-35)
    elseif action=="DualCut" then right=rotation(-80,math.sin(t*math.pi*4)*70,20); left=rotation(-70,0,-25)
    elseif action=="Uppercut" then right=rotation(30-200*t,0,15)
    elseif action=="Thrust" then right=CFrame.new(0,0,-pulse*.8)*rotation(-90,0,5); left=rotation(25)
    elseif action=="Bash" then right=rotation(-40-100*pulse,0,25)
    elseif action=="Slam" then right=rotation(-170+155*t,0,5); left=rotation(-160+145*t,15,-10)
    elseif action=="Cleave" then right=rotation(-95,-100+200*t,20); left=rotation(-90,-30+60*t,-15)
    elseif action=="Dash" then left=rotation(35,0,-20); right=rotation(35,0,20); leftLeg=rotation(-55); rightLeg=rotation(45); neck=rotation(15)
    elseif action=="Mine" then right=rotation(-50-100*pulse,0,5); left=rotation(-55-40*pulse,0,-15)
    elseif action=="Forge" then
     if t<.3 then left=rotation(-45,0,-15); right=rotation(-60+math.sin(t*60)*25)
     elseif t<.6 then left=rotation(-90,0,-10); right=rotation(-90,0,20)
     else right=rotation(-70-70*math.abs(math.sin(t*65))); left=rotation(-65,15,-10) end
    elseif action=="Drink" then right=rotation(-135,0,-30); neck=rotation(-12)
    elseif action=="Interact" then right=rotation(-90*pulse)
    elseif action=="Hurt" then left=rotation(-20,0,-25*pulse); right=rotation(-20,0,25*pulse); neck=rotation(-15*pulse)
    end
   end
   if rig.Hum.Health<=0 then left=rotation(0,0,-70); right=rotation(0,0,70); neck=rotation(30) end
   local targets={['Left Shoulder']=left,['Right Shoulder']=right,['Left Hip']=leftLeg,['Right Hip']=rightLeg,Neck=neck}
   for name,joint in pairs(rig.Joints) do joint.Transform=joint.Transform:Lerp(targets[name],math.min(1,dt*22)) end
  end
 end
end)
