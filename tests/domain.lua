Vector3={new=function(x,y,z) return {X=x,Y=y,Z=z} end}
Color3={fromRGB=function(r,g,b) return {R=r,G=g,B=b} end}
local C=dofile('__ROOT__/src/shared/Config.lua')
local P=dofile('__ROOT__/src/shared/Progression.lua')
assert(#C.ItemList==50 and #C.Enemies==8 and #C.Floors==3)
local ids={}; local families={}; local bosses={}
for _,item in ipairs(C.ItemList) do
 assert(not ids[item.Id]); ids[item.Id]=true
 assert(C.Items[item.Id]==item and item.Damage>0 and item.Range>0 and item.Cooldown>0)
 families[item.Family]=(families[item.Family] or 0)+1
end
for i=1,5 do assert(families[i]==10) end
for _,enemy in ipairs(C.Enemies) do if enemy.Boss then bosses[enemy.Floor]=(bosses[enemy.Floor] or 0)+1 end end
for i=1,3 do assert(bosses[i]==1) end
local d=P.New()
assert(d.Owned[d.Equipped] and P.CanTravel(d,1,C))
for _,floor in ipairs({0,2,3,4,1.5,'2'}) do assert(not P.CanTravel(d,floor,C)) end
assert(not P.CanTravel(d,nil,C))
d.Unlocked=3; assert(not P.CanTravel(d,2,C)); d.Level=30; assert(P.CanTravel(d,2,C)); assert(not P.CanTravel(d,3,C))
d.Level=65; assert(P.CanTravel(d,3,C))
d=P.New(); local required=P.Required(1)
assert(not P.Grant(d,required-1,7) and d.Level==1 and d.Gold==7)
assert(P.Grant(d,1,3) and d.Level==2 and d.XP==0 and d.Gold==10)
P.Grant(d,10000000,0); assert(d.Level==100 and d.XP==0)
P.Grant(d,9999,0); assert(d.Level==100 and d.XP==0)
d=P.New(); assert(not P.Buy(d,'unknown',C)); assert(not P.Buy(d,'gear_10_5',C)); assert(not P.Buy(d,'gear_01_2',C))
d.Gold=100; assert(P.Buy(d,'gear_01_2',C)); assert(d.Gold==65 and d.Owned.gear_01_2)
assert(not P.Buy(d,'gear_01_2',C)); assert(d.Gold==65)
d.Level=100; d.Gold=1000000
for _,item in ipairs(C.ItemList) do if not d.Owned[item.Id] then assert(P.Buy(d,item.Id,C)) end end
local total=0; for _ in pairs(d.Owned) do total=total+1 end; assert(total==50)
for level=1,99 do assert(P.Required(level+1)>P.Required(level) and P.MaxHP(level+1)>P.MaxHP(level)) end
print('PASS: catalog, floor gates, XP boundaries, level cap, purchases, duplicate protection and full collection.')
