local C=require(script.Parent.Config)
local P={}
function P.Required(level) return math.floor(4*level^1.35*(1+(level-1)/250)) end
function P.New()
 return {Version=2,Level=1,XP=0,Gold=25,Floor=1,Unlocked=1,StarterChosen=false,Weapons={},NextWeapon=1,Equipped="",Bosses={},Kills=0,
  Points=0,Stats={Forca=0,Defesa=0,Movimento=0,Ferraria=0},ForgeXP=0,Ores={},Potions={health=2,energy=2},Pickaxe=1,Receipts={},StockBought={}}
end
function P.MaxHP(d) return 100+(d.Level-1)*3+(d.Stats.Defesa or 0)*2 end
function P.Speed(d) local n=d.Stats.Movimento; return 18+12*n/(n+15) end
function P.Dash(d) local n=d.Stats.Movimento; return 16+24*n/(n+30) end
function P.Reduction(d) local n=d.Stats.Defesa; return .65*n/(n+80) end
function P.ForgeSkill(d) return math.min(100,d.Stats.Ferraria*.4+math.sqrt(d.ForgeXP)*2) end
function P.Grant(d,xp,gold)
 d.Gold=d.Gold+gold; d.XP=d.XP+xp; local before=d.Level
 while d.Level<C.MaxLevel and d.XP>=P.Required(d.Level) do d.XP=d.XP-P.Required(d.Level); d.Level=d.Level+1; d.Points=d.Points+1 end
 if d.Level==C.MaxLevel then d.XP=0 end
 return d.Level-before
end
function P.Allocate(d,key)
 if d.Points<1 or d.Stats[key]==nil then return false end
 d.Points=d.Points-1; d.Stats[key]=d.Stats[key]+1; return true
end
function P.CanTravel(d,floor)
 return type(floor)=="number" and floor==math.floor(floor) and C.Floors[floor]~=nil and floor<=d.Unlocked
end
function P.InTown(pos,floor)
 local f=C.Floors[floor]; if not f then return false end
 local t=f.Town
 return math.abs(pos.Y-f.Origin.Y)<80 and math.abs(pos.X-t.X)<=t.W/2 and math.abs(pos.Z-t.Z)<=t.D/2
end
function P.AddWeapon(d,blueprint,rarity,completingForge)
 local reserved=d.PendingForge and not completingForge and 1 or 0
 if #d.Weapons>=C.MaxInventory-reserved then return nil end
 local uid=tostring(d.NextWeapon); d.NextWeapon=d.NextWeapon+1
 local weapon={Uid=uid,Blueprint=blueprint,Rarity=rarity}; table.insert(d.Weapons,weapon); return weapon
end
function P.Weapon(d,uid) for _,w in ipairs(d.Weapons) do if w.Uid==uid then return w end end end
function P.Choose(d,family)
 if d.StarterChosen then return false end
 local valid=false; for _,v in ipairs(C.StarterFamilies) do if family==v then valid=true end end
 if not valid then return false end
 local w=P.AddWeapon(d,family.."_01",1); if not w then return false end
 d.Equipped=w.Uid; d.StarterChosen=true; return true
end
return P
