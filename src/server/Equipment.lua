local C=require(game.ReplicatedStorage.LittleRPG.Config)
local E={}
function E.Give(player,id)
 local item=C.Items[id]; local character=player.Character
 local backpack=player:FindFirstChildOfClass("Backpack")
 if not character or not backpack or not item then return end
 for _,container in ipairs({character,backpack}) do
  for _,obj in ipairs(container:GetChildren()) do if obj:IsA("Tool") and obj:GetAttribute("LittleGear") then obj:Destroy() end end
 end
 local tool=Instance.new("Tool"); tool.Name=item.Name; tool.CanBeDropped=false; tool:SetAttribute("LittleGear",true); tool:SetAttribute("ItemId",id)
 local handle=Instance.new("Part"); handle.Name="Handle"; handle.Size=Vector3.new(.28,1.4,.28); handle.Color=Color3.fromRGB(45,54,62)
 handle.CanCollide=false; handle.Massless=true; handle.Parent=tool
 local function piece(name,size,offset,color,material)
  local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Color=color; p.Material=material or Enum.Material.Metal
  p.CanCollide=false; p.Massless=true; p.CFrame=handle.CFrame*CFrame.new(offset); p.Parent=tool
  local weld=Instance.new("WeldConstraint"); weld.Part0=handle; weld.Part1=p; weld.Parent=p
 end
 local c=item.Color
 if item.Shape=="Sword" or item.Shape=="Dagger" then
  local length=item.Shape=="Sword" and 3.8 or 2
  piece("Blade",Vector3.new(.48,length,.16),Vector3.new(0,1+length/2,0),c)
  piece("Guard",Vector3.new(1.4,.2,.3),Vector3.new(0,.85,0),c)
 elseif item.Shape=="Axe" then
  piece("Shaft",Vector3.new(.25,3,.25),Vector3.new(0,1.6,0),c)
  piece("Head",Vector3.new(2,1.5,.3),Vector3.new(.5,3,0),c)
 elseif item.Shape=="Spear" then
  piece("Shaft",Vector3.new(.2,5,.2),Vector3.new(0,1.8,0),Color3.fromRGB(94,77,61))
  piece("Tip",Vector3.new(.55,1.4,.18),Vector3.new(0,4.7,0),c)
 else
  piece("Shaft",Vector3.new(.3,2.4,.3),Vector3.new(0,1.5,0),c)
  piece("Head",Vector3.new(2.5,1.3,1.4),Vector3.new(0,2.8,0),c)
 end
 if item.Tier>=4 then piece("Core",Vector3.new(.16,.6,.35),Vector3.new(0,.3,0),c,Enum.Material.Neon) end
 tool.Grip=CFrame.Angles(math.rad(90),0,0)
 tool.Parent=backpack
 local hum=character:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(tool) end
end
return E
