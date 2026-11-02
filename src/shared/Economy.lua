-- Regras puras de mineração, estoque e ferraria: servidor é a autoridade.
local C=require(script.Parent.Config)
local K=require(script.Parent.Catalog)
local P=require(script.Parent.Progression)
local E={OreList={
 {Id="iron",Name="Ferro",MinFloor=1,Color={155,151,146}},
 {Id="copper",Name="Cobre",MinFloor=1,Color={198,129,80}},
 {Id="coal",Name="Carvão",MinFloor=1,Color={63,60,67}},
 {Id="silver",Name="Prata",MinFloor=2,Color={191,205,220}},
 {Id="cobalt",Name="Cobalto",MinFloor=3,Color={95,123,199}},
 {Id="obsidian",Name="Obsidiana",MinFloor=3,Color={117,83,150}},
 {Id="nickel",Name="Níquel",MinFloor=10,Color={164,171,142}},
 {Id="titanium",Name="Titânio",MinFloor=20,Color={173,173,199}},
 {Id="tungsten",Name="Tungstênio",MinFloor=35,Color={130,146,161}},
 {Id="chromium",Name="Cromo",MinFloor=50,Color={154,199,186}},
 {Id="iridium",Name="Irídio",MinFloor=65,Color={211,167,212}},
 {Id="osmium",Name="Ósmio",MinFloor=80,Color={142,187,210}},
 {Id="aethersteel",Name="Aço do último horizonte",MinFloor=95,Color={255,222,160}},
},Ores={}}
for _,ore in ipairs(E.OreList) do E.Ores[ore.Id]=ore end
function E.OreChances(floor)
 local pool={iron=.18/(1+.055*(floor-1)),copper=.10/(1+.035*(floor-1)),coal=.24}
 if floor>=2 then pool.silver=.065 end
 if floor>=3 then pool.cobalt=.045; pool.obsidian=.018 end
 for _,ore in ipairs(E.OreList) do if ore.MinFloor>=10 and floor>=ore.MinFloor then pool[ore.Id]=.025/(1+(floor-ore.MinFloor)*.025) end end
 return pool -- Remaining probability is ordinary stone; never reward a paid random roll.
end
function E.RollOre(floor,roll)
 local acc=0; local chances=E.OreChances(floor)
 for _,ore in ipairs(E.OreList) do acc=acc+(chances[ore.Id] or 0); if roll<acc then return ore.Id end end
 return nil
end
function E.ForgeOdds(skill)
 local s=math.max(0,math.min(100,skill))/100
 return {(.78-.28*s),(.18+.1*s),(.035+.10*s),(.004+.065*s),(.001+.015*s)}
end
function E.Roll(weights,roll)
 local total=0; for _,w in ipairs(weights) do total=total+w end
 local target=roll*total; local acc=0
 for i,w in ipairs(weights) do acc=acc+w; if target<acc then return i end end
 return #weights
end
function E.CanForge(d,id)
 local item=K.ById[id]
 if not item then return false,"Molde inválido." end
 if #d.Weapons>=C.MaxInventory then return false,"Mochila cheia. Venda uma arma." end
 if d.Level<item.Level then return false,"Requer nível "..item.Level end
 if d.Gold<item.GoldCost or (d.Ores[item.Ore] or 0)<item.OreCost or (d.Ores.coal or 0)<2 then return false,"Faltam minérios, carvão ou moedas." end
 return true
end
function E.BeginForge(d,id)
 if d.PendingForge then return false,"Você já tem uma forja em andamento." end
 local ok,message=E.CanForge(d,id); if not ok then return false,message end
 local item=K.ById[id]
 d.Ores[item.Ore]=d.Ores[item.Ore]-item.OreCost; d.Ores.coal=d.Ores.coal-2; d.Gold=d.Gold-item.GoldCost
 d.PendingForge={Blueprint=id}; return true
end
function E.FinishForge(d,roll)
 local job=d.PendingForge; if not job then return nil end
 local rarity=E.Roll(E.ForgeOdds(P.ForgeSkill(d)),roll)
 local weapon=P.AddWeapon(d,job.Blueprint,rarity,true)
 if weapon then d.PendingForge=nil; d.ForgeXP=d.ForgeXP+5 end
 return weapon
end
function E.Stock(floor,epoch)
 local list={}; local maxRarity=floor==3 and 5 or floor==2 and 4 or 3
 for index,item in ipairs(K.List) do
  local starter=item.Tier==1 and (item.Family=="dagger" or item.Family=="longsword" or item.Family=="rapier")
  local permitted=item.Tier<=floor*3 and (starter or item.Tier>1)
  local seed=(epoch*7919+index*104729+floor*137)%1000
  local rarity=starter and 1 or math.min(maxRarity,1+math.floor(((epoch*3571+index*4271+floor*79)%1000)/190))
  local available=permitted and (starter or seed<200+floor*70)
  list[#list+1]={Key=item.Id,Blueprint=item.Id,Rarity=rarity,Count=available and (starter and 5 or rarity==5 and 1 or 2) or 0,Price=math.floor(item.Price*C.Rarities[rarity].Multiplier*1.5)}
 end
 return list
end
function E.Buy(d,key,floor,epoch)
 if #d.Weapons>=C.MaxInventory then return false,"Mochila cheia." end
 if d.StockEpoch~=epoch then d.StockEpoch=epoch; d.StockBought={} end
 for _,offer in ipairs(E.Stock(floor,epoch)) do
  if offer.Key==key then
   local bought=d.StockBought[floor..":"..key] or 0
   if offer.Count<=bought then return false,"Fora de estoque." end
   if d.Level<K.ById[key].Level then return false,"Seu nível é insuficiente." end
   if d.Gold<offer.Price then return false,"Moedas insuficientes." end
   local weapon=P.AddWeapon(d,key,offer.Rarity)
   if not weapon then return false,"A última vaga está reservada para sua forja." end
   d.Gold=d.Gold-offer.Price; d.StockBought[floor..":"..key]=bought+1
   return true,"Arma comprada."
  end
 end
 return false,"Oferta inválida."
end
return E
