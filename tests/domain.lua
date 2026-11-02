local C=require('Config'); local K=require('Catalog'); local P=require('Progression'); local E=require('Economy'); local M=require('Maze')
assert(C.MaxLevel==15000 and #C.Floors==3 and #K.List==60 and #K.Families==6 and #C.Rarities==7)
local families={}; local ids={}
for _,item in ipairs(K.List) do
 assert(not ids[item.Id] and K.ById[item.Id]==item); ids[item.Id]=true
 families[item.Family]=(families[item.Family] or 0)+1
 assert(item.Level>=1 and item.Damage>0 and item.Cooldown>0 and E.Ores[item.Ore])
end
for _,f in ipairs(K.Families) do assert(families[f.Id]==10) end
for _,family in ipairs(C.StarterFamilies) do
 local d=P.New(); assert(P.Choose(d,family)); assert(not P.Choose(d,family)); assert(#d.Weapons==1)
 local w=P.Weapon(d,d.Equipped)
 assert(K.Damage(w,1,0,false)==10 and K.Damage(w,1,0,true)==34)
 assert(C.Enemies.wolf.HP==100 and C.Enemies.boar.HP==100 and C.Enemies.wolf.XP==2)
end
local d=P.New(); assert(not P.Choose(d,'staff')); assert(P.Required(1)==4)
assert(P.Grant(d,2,1)==0 and d.Level==1 and d.Points==0)
assert(P.Grant(d,2,1)==1 and d.Level==2 and d.Points==1 and d.XP==0)
assert(P.Allocate(d,'Movimento') and d.Points==0 and d.Stats.Movimento==1)
assert(not P.Allocate(d,'Movimento') and not P.Allocate(d,'Unknown'))
local last=0
for level=1,15000 do assert(P.Required(level)>last); last=P.Required(level) end
local capped=P.New(); capped.Level=14999; capped.XP=P.Required(14999)-1
assert(P.Grant(capped,1,0)==1 and capped.Level==15000 and capped.Points==1 and capped.XP==0)
P.Grant(capped,10000000,0); assert(capped.Level==15000 and capped.Points==1 and capped.XP==0)
local gainEarly,gainLate
for _,n in ipairs({0,1,100,101,15000}) do
 d.Stats.Movimento=n; assert(P.Speed(d)>=18 and P.Speed(d)<30 and P.Dash(d)>=16 and P.Dash(d)<40)
 if n==0 then gainEarly=P.Speed(d) elseif n==1 then gainEarly=P.Speed(d)-gainEarly elseif n==100 then gainLate=P.Speed(d) elseif n==101 then gainLate=P.Speed(d)-gainLate end
end
assert(gainEarly>gainLate*10)
d=P.New(); assert(P.CanTravel(d,1) and not P.CanTravel(d,2)); d.Unlocked=2; assert(P.CanTravel(d,2))
for _,bad in ipairs({0,4,1.1,'2'}) do assert(not P.CanTravel(d,bad)) end
assert(not P.CanTravel(d,nil))
for floor=1,100 do
 local pool=E.OreChances(floor); local sum=0
 for id,chance in pairs(pool) do assert(chance>0 and E.Ores[id].MinFloor<=floor); sum=sum+chance end
 assert(sum<1)
 if floor>1 then assert(pool.iron<E.OreChances(floor-1).iron) end
end
assert(E.RollOre(1,0)=='iron' and E.RollOre(1,.999)==nil)
local lastMythic=0
for skill=0,100 do
 local odds=E.ForgeOdds(skill); local sum=0
 for _,chance in ipairs(odds) do assert(chance>0); sum=sum+chance end
 assert(math.abs(sum-1)<.000001 and odds[5]>=lastMythic); lastMythic=odds[5]
 for i=0,999 do assert(E.Roll(odds,i/1000)<=5) end
end
d=P.New(); assert(not E.BeginForge(d,'dagger_01')); d.Gold=100; d.Ores={iron=20,coal=10}
assert(E.BeginForge(d,'dagger_01')); assert(d.Gold==85 and d.Ores.iron==15 and d.Ores.coal==8)
assert(not E.BeginForge(d,'dagger_01')); assert(d.Gold==85)
local weapon=E.FinishForge(d,.9999); assert(weapon.Rarity==5 and not d.PendingForge and d.ForgeXP==5)
assert(E.FinishForge(d,0)==nil and #d.Weapons==1)
local mythicSeen=false
for epoch=1,100 do
 for floor=1,3 do
  local stock=E.Stock(floor,epoch); assert(#stock==60)
  for _,offer in ipairs(stock) do
   assert(offer.Rarity<=5 and (floor==3 or offer.Rarity<5))
   if offer.Rarity==5 and offer.Count>0 then mythicSeen=true end
   if offer.Count>0 and K.ById[offer.Blueprint].Tier==1 then assert(K.ById[offer.Blueprint].Family=='dagger' or K.ById[offer.Blueprint].Family=='longsword' or K.ById[offer.Blueprint].Family=='rapier') end
  end
 end
end
assert(mythicSeen,'Third-floor mythic must actually be in stock sometimes')
d=P.New(); d.Gold=100000
for i=1,5 do assert(E.Buy(d,'dagger_01',1,100)) end
local gold=d.Gold; assert(not E.Buy(d,'dagger_01',1,100) and d.Gold==gold)
assert(E.Buy(d,'dagger_01',1,101))
for _,offer in ipairs(C.Products) do assert(offer.Rarity<=6 and K.ById[offer.Blueprint]) end
-- Check reciprocal walls, full reachability and long goal paths for every shipped maze.
for floor=1,3 do
 local maze=M.Generate(15,9000+floor); local seen={['1,1']=true}; local queue={{1,1}}; local count=0
 local directions={{0,-1,'N','S'},{1,0,'E','W'},{0,1,'S','N'},{-1,0,'W','E'}}
 while #queue>0 do
  local cell=table.remove(queue,1); local x,z=cell[1],cell[2]; count=count+1
  for _,direction in ipairs(directions) do
   local nx,nz=x+direction[1],z+direction[2]
   if not maze.Cells[z][x][direction[3]] then
    assert(nx>=1 and nx<=15 and nz>=1 and nz<=15 and not maze.Cells[nz][nx][direction[4]])
    local key=nx..','..nz; if not seen[key] then seen[key]=true; queue[#queue+1]={nx,nz} end
   end
  end
 end
 assert(count==225 and maze.Length>80 and seen[maze.Goal[1]..','..maze.Goal[2]])
end
print('PASS: 60 weapons, starter damage, XP/points/cap, diminishing returns, 100 ore floors, forge recovery, stock and maze connectivity.')

local full=P.New(); full.Gold=100; full.Ores={iron=10,coal=5}
for i=1,239 do assert(P.AddWeapon(full,'dagger_01',1)) end
assert(E.BeginForge(full,'dagger_01'))
assert(not P.AddWeapon(full,'rapier_01',6),'Pending forge must reserve its last inventory slot')
assert(E.FinishForge(full,0) and #full.Weapons==240 and not full.PendingForge)
print('PASS: pending forge reserves its output slot against concurrent paid grants or drops.')
