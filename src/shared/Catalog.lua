-- Seis famílias físicas. Dez modelos por família; raridade é separada do modelo.
local C=require(script.Parent.Config)
local K={List={},ById={},Families={
 {Id="dagger",Name="Adaga",Shape="Dagger",Cooldown=.5,Range=9,Damage=10,Special="Corte duplo",Style="DualCut"},
 {Id="longsword",Name="Espada de uma mão",Shape="Sword",Cooldown=.8,Range=12,Damage=10,Special="Corte ascendente",Style="Uppercut"},
 {Id="rapier",Name="Rapieira",Shape="Rapier",Cooldown=.65,Range=15,Damage=10,Special="Estocada precisa",Style="Thrust"},
 {Id="light_hammer",Name="Martelo leve",Shape="LightHammer",Cooldown=.9,Range=10,Damage=13,Special="Quebra-guarda",Style="Bash"},
 {Id="heavy_hammer",Name="Martelo pesado",Shape="HeavyHammer",Cooldown=1.4,Range=12,Damage=21,Special="Impacto sísmico",Style="Slam"},
 {Id="greatsword",Name="Espada de duas mãos",Shape="Greatsword",Cooldown=1.2,Range=16,Damage=18,Special="Arco do executor",Style="Cleave"},
}}
K.Tiers={
 {Name="do Aprendiz",Level=1,Ore="iron"}, {Name="de Aço",Level=5,Ore="iron"},
 {Name="do Guardião",Level=10,Ore="copper"},{Name="do Crepúsculo",Level=15,Ore="silver"},
 {Name="de Ardósia",Level=22,Ore="silver"},{Name="do Horizonte",Level=30,Ore="cobalt"},
 {Name="da Forja",Level=40,Ore="cobalt"},{Name="de Obsidiana",Level=55,Ore="obsidian"},
 {Name="do Eclipse",Level=75,Ore="obsidian"},{Name="do Abismo",Level=100,Ore="obsidian"},
}
for _,family in ipairs(K.Families) do
 for tier,t in ipairs(K.Tiers) do
  local id=string.format("%s_%02d",family.Id,tier)
  local item={Id=id,Name=family.Name.." "..t.Name,Family=family.Id,Shape=family.Shape,Tier=tier,Level=t.Level,
   Damage=math.floor(family.Damage*(1+(tier-1)*.7)),Cooldown=family.Cooldown,Range=family.Range,Special=family.Special,Style=family.Style,
   Energy=20+tier,SpecialCooldown=8+family.Cooldown*2,Ore=t.Ore,OreCost=3+tier*2,GoldCost=15*tier*tier,Price=50*tier*tier}
  if family.Id=="greatsword" and tier==10 then item.Name="Noctífera · Lâmina dos Dois Horizontes" end
  K.ById[id]=item; table.insert(K.List,item)
 end
end
function K.Damage(weapon,level,strength,special)
 local item=K.ById[weapon.Blueprint]
 local rank=C.Rarities[weapon.Rarity or 1]
 local bonus=1+.45*(strength or 0)/((strength or 0)+60)
 local result=item.Damage*rank.Multiplier*bonus*(1+math.min(14999,level-1)*.007)
 return math.floor(result*(special and (3.4+(item.Tier-1)*.06) or 1)+.5)
end
function K.Name(weapon) return K.ById[weapon.Blueprint].Name.." · "..C.Rarities[weapon.Rarity].Name end
return K
