-- Little RPG: Ecos de Aether. Content is original; no franchise assets.
local C = {}
C.MaxLevel = 100
C.SaveVersion = 1
C.Floors = {
 {Name="01 · CAMPOS DA AURORA", Subtitle="Onde a torre toca o céu", MinLevel=1, Origin=Vector3.new(0,0,0), Accent=Color3.fromRGB(141,233,185)},
 {Name="02 · JARDIM PRISMÁTICO", Subtitle="A floresta guarda suas memórias", MinLevel=30, Origin=Vector3.new(0,650,0), Accent=Color3.fromRGB(147,177,255)},
 {Name="03 · CIDADELA DO ECO", Subtitle="O coração da máquina ainda pulsa", MinLevel=65, Origin=Vector3.new(0,1300,0), Accent=Color3.fromRGB(255,192,112)},
}
C.Families = {
 {Name="Espada", Damage=14, Cooldown=.65, Range=11, Shape="Sword"},
 {Name="Adaga", Damage=9, Cooldown=.36, Range=8, Shape="Dagger"},
 {Name="Machado", Damage=23, Cooldown=1.05, Range=10, Shape="Axe"},
 {Name="Lança", Damage=16, Cooldown=.85, Range=17, Shape="Spear"},
 {Name="Martelo", Damage=32, Cooldown=1.45, Range=10, Shape="Hammer"},
}
C.Tiers = {
 {Name="do Viajante", Level=1, Color=Color3.fromRGB(177,189,186)},
 {Name="de Cobre", Level=10, Color=Color3.fromRGB(205,145,103)},
 {Name="do Bosque", Level=20, Color=Color3.fromRGB(133,205,130)},
 {Name="da Aurora", Level=30, Color=Color3.fromRGB(106,232,195)},
 {Name="de Cristal", Level=40, Color=Color3.fromRGB(134,202,247)},
 {Name="do Crepúsculo", Level=50, Color=Color3.fromRGB(173,144,232)},
 {Name="Prismático", Level=60, Color=Color3.fromRGB(238,154,239)},
 {Name="da Forja", Level=70, Color=Color3.fromRGB(245,168,93)},
 {Name="do Eclipse", Level=85, Color=Color3.fromRGB(239,110,134)},
 {Name="de Aether", Level=100, Color=Color3.fromRGB(255,230,155)},
}
C.Items, C.ItemList = {}, {}
for tier,t in ipairs(C.Tiers) do
 for family,f in ipairs(C.Families) do
  local id = string.format("gear_%02d_%d",tier,family)
  local item = {Id=id, Name=f.Name.." "..t.Name, Tier=tier, Family=family, Level=t.Level, Color=t.Color,
   Damage=math.floor(f.Damage*(1+(tier-1)*.65)), Cooldown=f.Cooldown, Range=f.Range,
   Price=tier==1 and (family-1)*35 or math.floor(180*tier^1.65), Shape=f.Shape}
  C.Items[id]=item; table.insert(C.ItemList,item)
 end
end
C.Enemies = {
 {Id="sprout", Name="Sentinela de Musgo", Floor=1, Level=3, HP=85, Damage=7, XP=65, Gold=18, Speed=10, Color=Color3.fromRGB(99,155,93)},
 {Id="boar", Name="Javali de Pedra", Floor=1, Level=15, HP=230, Damage=14, XP=200, Gold=48, Speed=14, Color=Color3.fromRGB(151,137,116)},
 {Id="warden", Name="GUARDIÃO DA AURORA", Floor=1, Level=28, HP=1500, Damage=23, XP=2200, Gold=800, Speed=8, Boss=true, Color=Color3.fromRGB(107,204,163)},
 {Id="shard", Name="Cavaleiro de Vidro", Floor=2, Level=36, HP=460, Damage=24, XP=700, Gold=110, Speed=11, Color=Color3.fromRGB(146,189,234)},
 {Id="wisp", Name="Espectro Prismático", Floor=2, Level=49, HP=650, Damage=30, XP=1000, Gold=150, Speed=16, Color=Color3.fromRGB(186,134,221)},
 {Id="oracle", Name="ORÁCULO FRAGMENTADO", Floor=2, Level=62, HP=4200, Damage=40, XP=6500, Gold=1800, Speed=9, Boss=true, Color=Color3.fromRGB(179,160,255)},
 {Id="automaton", Name="Autômato da Forja", Floor=3, Level=76, HP=1050, Damage=42, XP=2100, Gold=250, Speed=12, Color=Color3.fromRGB(198,147,94)},
 {Id="echo", Name="SOBERANO DO ECO", Floor=3, Level=98, HP=8500, Damage=58, XP=16000, Gold=4000, Speed=10, Boss=true, Color=Color3.fromRGB(255,187,98)},
}
-- Upload the supplied original WAVs in Creator Dashboard, then paste your own IDs.
C.Audio = {Menu="", Hit="", LevelUp="", Ambient="", Machine=""}
C.Spawn = Vector3.new(0,6,104)
C.Portals = {Vector3.new(0,4,-126), Vector3.new(-23,4,104)}
return C
