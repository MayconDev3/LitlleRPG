-- Modelagem procedural original, compartilhada pela mão do jogador e pelos previews 3D.
local K=require(script.Parent.Catalog)
local C=require(script.Parent.Config)
local V={}
function V.Build(weapon,asTool)
 local item=K.ById[weapon.Blueprint]; local rarity=C.Rarities[weapon.Rarity]
 local container=Instance.new(asTool and "Tool" or "Model"); container.Name=K.Name(weapon)
 if asTool then container.CanBeDropped=false; container:SetAttribute("LittleGear",true); container:SetAttribute("WeaponUid",weapon.Uid); container.Grip=CFrame.Angles(math.rad(90),0,0) end
 local tint=Color3.fromRGB(unpack(rarity.Color)); local steel=Color3.fromRGB(152,164,181)
 if item.Tier>=8 then steel=Color3.fromRGB(39,40,55) end
 local handle
 local function piece(name,size,cf,color,cls)
  local p=Instance.new(cls or "Part"); p.Name=name; p.Size=size; p.Color=color; p.Material=Enum.Material.Metal; p.CanCollide=false; p.CanTouch=false; p.Massless=true; p.Anchored=not asTool; p.CFrame=cf; p.Parent=container
  if name=="Handle" then handle=p elseif asTool then local w=Instance.new("WeldConstraint"); w.Part0=handle; w.Part1=p; w.Parent=p end
  return p
 end
 local two=item.Shape=="Greatsword" or item.Shape=="HeavyHammer"
 piece("Handle",Vector3.new(.27,two and 2 or 1.25,.27),CFrame.new(),Color3.fromRGB(53,42,49))
 for i=1,5 do piece("LeatherWrap",Vector3.new(.3,.07,.3),CFrame.new(0,-.55+i*.18,0),Color3.fromRGB(94,71,78)) end
 piece("Pommel",Vector3.new(.42,.35,.42),CFrame.new(0,two and -1.1 or -.8,0),tint)
 if item.Shape=="LightHammer" or item.Shape=="HeavyHammer" then
  local scale=two and 1.5 or 1
  piece("Shaft",Vector3.new(.3,2.5,.3),CFrame.new(0,1.4,0),steel)
  piece("HammerHead",Vector3.new(2.2,1.4,1.2)*scale,CFrame.new(0,3,0),steel)
  for _,side in ipairs({-1,1}) do piece("StrikingFace",Vector3.new(.2,1.5,1.3)*scale,CFrame.new(side*1.15*scale,3,0),tint) end
 else
  local length=item.Shape=="Dagger" and 1.8 or item.Shape=="Rapier" and 4.7 or two and 6.5 or 3.9
  local width=item.Shape=="Rapier" and .16 or two and .9 or .5
  piece("Blade",Vector3.new(width,length,.15),CFrame.new(0,1+length/2,0),steel)
  piece("Edge",Vector3.new(.06,length,.17),CFrame.new(width/2,1+length/2,0),Color3.fromRGB(211,219,226))
  piece("Point",Vector3.new(width,.7,.15),CFrame.new(0,1+length+.35,0)*CFrame.Angles(0,math.pi/2,0),steel,"WedgePart")
  piece("Crossguard",Vector3.new(two and 2.4 or 1.3,.2,.35),CFrame.new(0,.8,0),tint)
  if item.Shape=="Rapier" then
   for i=0,7 do local a=i*math.pi/4; piece("BasketGuard",Vector3.new(.12,.38,.12),CFrame.new(math.cos(a)*.45,.65,math.sin(a)*.45)*CFrame.Angles(0,0,a),tint) end
  end
  if two then
   for _,side in ipairs({-1,1}) do piece("SweptGuard",Vector3.new(.25,1.3,.3),CFrame.new(side*1.1,1.25,0)*CFrame.Angles(0,0,side*-.45),tint) end
   if item.Tier==10 then
    piece("Fuller",Vector3.new(.12,length-.8,.19),CFrame.new(0,1.5+length/2,0),tint)
    for i=1,4 do piece("EngravedPlate",Vector3.new(.6,.13,.2),CFrame.new(0,2+i*.9,0)*CFrame.Angles(0,0,.5),Color3.fromRGB(106,104,124)) end
   end
  end
 end
 if not asTool then container.PrimaryPart=handle end
 return container
end
return V
