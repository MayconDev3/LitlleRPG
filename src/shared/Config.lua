-- CONFIGURAÇÃO CENTRAL. Edite aqui os limites, cidades e IDs de sua experiência.
local C = {}
C.Version = 2
C.MaxLevel = 15000
C.MaxFloors = 3 -- Apenas três andares publicados; minérios já têm planejamento até 100.
C.MaxInventory = 240
C.StockSeconds = 1800
C.FloorHeight = 800
C.MapHalfSize = Vector3.new(800,0,600)
C.DungeonX = 6000
C.MazeSize = 15
C.MazeCell = 26
C.Floors = {
 {Name="01 · VALE DOS PIONEIROS",MinLevel=1,Origin=Vector3.new(0,0,0),Spawn=Vector3.new(-475,6,125),Town={X=-405,Z=0,W=790,D=1200},Forge=Vector3.new(-500,0,-135),Shop=Vector3.new(-500,0,20),Boss="alpha"},
 {Name="02 · CIDADE DE ARDÓSIA",MinLevel=10,Origin=Vector3.new(0,800,0),Spawn=Vector3.new(0,6,180),Town={X=0,Z=0,W=924,D=693},Forge=Vector3.new(-180,0,90),Shop=Vector3.new(180,0,90),Boss="warden"},
 {Name="03 · BASTIÃO OBSIDIANA",MinLevel=25,Origin=Vector3.new(0,1600,0),Spawn=Vector3.new(0,6,180),Town={X=0,Z=0,W=924,D=693},Forge=Vector3.new(-180,0,90),Shop=Vector3.new(180,0,90),Boss="sovereign"},
}
C.StarterFamilies = {"dagger","longsword","rapier"}
C.Rarities = {
 {Name="Comum",Color={185,190,205},Multiplier=1},
 {Name="Incomum",Color={80,250,123},Multiplier=1.12},
 {Name="Rara",Color={139,233,253},Multiplier=1.3},
 {Name="Épica",Color={189,147,249},Multiplier=1.6},
 {Name="Mítica",Color={255,121,198},Multiplier=2},
 {Name="Lendária",Color={255,184,108},Multiplier=2.5},
 {Name="Ultra lendária",Color={255,85,85},Multiplier=3.2},
}
C.Enemies = {
 wolf={Name="Lobo cinzento",Floor=1,Level=1,HP=100,Damage=7,XP=2,Gold=3,Speed=13,Shape="Wolf",Color={133,145,156}},
 boar={Name="Javali selvagem",Floor=1,Level=1,HP=100,Damage=9,XP=2,Gold=4,Speed=10,Shape="Boar",Color={133,99,73}},
 alpha={Name="ALFA DA PEDRA",Floor=1,Level=8,HP=900,Damage=18,XP=70,Gold=140,Speed=12,Shape="Wolf",Boss=true,Color={159,168,178}},
 bandit={Name="Saqueador das ruínas",Floor=2,Level=12,HP=220,Damage=15,XP=28,Gold=18,Speed=13,Shape="Knight",Color={103,114,136}},
 beetle={Name="Besouro de ardósia",Floor=2,Level=18,HP=300,Damage=19,XP=44,Gold=24,Speed=10,Shape="Beetle",Color={113,128,149}},
 warden={Name="CARCEREIRO DE ARDÓSIA",Floor=2,Level=22,HP=2400,Damage=32,XP=420,Gold=450,Speed=9,Shape="Knight",Boss=true,Color={155,143,184}},
 construct={Name="Autômato de obsidiana",Floor=3,Level=32,HP=530,Damage=29,XP=110,Gold=44,Speed=11,Shape="Construct",Color={83,80,97}},
 sovereign={Name="SOBERANO DA FORJA",Floor=3,Level=45,HP=5200,Damage=44,XP=1300,Gold=1100,Speed=10,Shape="Construct",Boss=true,Color={255,184,108}},
}
C.DropChance = {Normal=.02,Boss=.15}
-- Probabilidades condicionais após cair uma arma. A ultra só sai do chefe 3.
C.DropWeights = {6000,2600,1000,320,70,9,1}
C.Consumables = {
 health={Name="Poção de cura",Price=15,Amount=45},
 energy={Name="Poção de energia",Price=12,Amount=50},
 pickaxe2={Name="Picareta de aço",Price=220,Floor=2},
 pickaxe3={Name="Picareta reforçada",Price=750,Floor=3},
}
-- Compras DIRETAS, sem sorteio. ID 0 mantém a oferta desativada.
C.Products = {
 {Key="legendary_rapier",ProductId=0,Name="Rapieira do Horizonte · Lendária",Blueprint="rapier_06",Rarity=6},
 {Key="epic_longsword",ProductId=0,Name="Espada do Crepúsculo · Épica",Blueprint="longsword_04",Rarity=4},
}
C.Audio = {Menu="",Hit="",LevelUp="",Ambient="",Machine=""}
return C
