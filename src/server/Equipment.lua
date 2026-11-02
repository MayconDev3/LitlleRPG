local V=require(game.ReplicatedStorage.LittleRPG.WeaponVisual)
local P=require(game.ReplicatedStorage.LittleRPG.Progression)
local E={}
function E.Give(player,data)
 local character=player.Character; local backpack=player:FindFirstChildOfClass("Backpack")
 if not character or not backpack then return end
 for _,parent in ipairs({character,backpack}) do for _,o in ipairs(parent:GetChildren()) do if o:IsA("Tool") and o:GetAttribute("LittleGear") then o:Destroy() end end end
 local weapon=P.Weapon(data,data.Equipped); if not weapon then return end
 local tool=V.Build(weapon,true); tool.Parent=backpack
 local hum=character:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(tool) end
end
return E
