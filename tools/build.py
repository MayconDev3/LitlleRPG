"""Deterministic, dependency-free Roblox XML place builder. Python 3.10+."""
from pathlib import Path
import math, random, xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[1]
doc=ET.Element('roblox',{'version':'4'})
counter=0
def item(cls,name,parent=doc):
 global counter
 counter+=1
 obj=ET.SubElement(parent,'Item',{'class':cls,'referent':f'RBX{counter}'})
 ET.SubElement(obj,'Properties')
 prop(obj,'string','Name',name)
 return obj
def prop(obj,typ,name,value):
 el=ET.SubElement(obj.find('Properties'),typ,{'name':name})
 if typ in ('Vector3','Color3'):
  for k,v in zip(('X','Y','Z') if typ=='Vector3' else ('R','G','B'),value): ET.SubElement(el,k).text=str(v)
 elif typ=='CoordinateFrame':
  pos,yaw=value; c=math.cos(yaw); s=math.sin(yaw)
  for k,v in zip(('X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'),(*pos,c,0,s,0,1,0,-s,0,c)): ET.SubElement(el,k).text=str(v)
 else: el.text=str(value).lower() if isinstance(value,bool) else str(value)
 return el
def color(hex): return tuple(int(hex[i:i+2],16)/255 for i in (0,2,4))
def part(parent,name,pos,size,tint,material=272,yaw=0,cls='Part',collide=True,transparency=0,anchored=True):
 o=item(cls,name,parent); prop(o,'Vector3','size',size); prop(o,'CoordinateFrame','CFrame',(pos,yaw)); prop(o,'Color3uint8','Color3uint8',int(tint,16)); prop(o,'token','Material',material)
 for k,v in [('Anchored',anchored),('CanCollide',collide),('CanTouch',False),('CastShadow',True)]: prop(o,'bool',k,v)
 prop(o,'float','Transparency',transparency); prop(o,'token','TopSurface',0); prop(o,'token','BottomSurface',0)
 return o
workspace=item('Workspace','Workspace'); prop(workspace,'float','Gravity',196.2); prop(workspace,'float','FallenPartsDestroyHeight',-250)
world=item('Folder','LittleWorld',workspace)
spawns=item('Folder','Spawns',world); portals=item('Folder','Portals',world)
rng=random.Random(91025)
themes=[('Campos da Aurora','718C69','C4C1A7','85EAC5','E4DCC1'),('Jardim Prismático','4D6870','9AABB8','A1BCFF','B4B9D1'),('Cidadela do Eco','565F61','8C8D87','FFC078','C1B49A')]
def sign(parent,text,pos,tint='EAF3E6'):
 anchor=part(parent,'Sign',pos,(1,1,1),tint,collide=False,transparency=1)
 gui=item('BillboardGui','Label',anchor)
 p=prop(gui,'UDim2','Size',''); p.text=None
 for k,v in [('XS',0),('XO',360),('YS',0),('YO',65)]: ET.SubElement(p,k).text=str(v)
 prop(gui,'float','MaxDistance',100); prop(gui,'bool','AlwaysOnTop',False)
 textlabel=item('TextLabel','Text',gui)
 p=prop(textlabel,'UDim2','Size',''); p.text=None
 for k,v in [('XS',1),('XO',0),('YS',1),('YO',0)]: ET.SubElement(p,k).text=str(v)
 prop(textlabel,'string','Text',text); prop(textlabel,'float','BackgroundTransparency',1); prop(textlabel,'Color3','TextColor3',color(tint)); prop(textlabel,'float','TextSize',21); prop(textlabel,'bool','TextWrapped',True); prop(textlabel,'token','Font',18)

for floor,(name,grass,stone,accent,ivory) in enumerate(themes,1):
 y=(floor-1)*650; zone=item('Folder',f'Floor{floor}',world)
 def p(name,x,dy,z,sx,sy,sz,tint=stone,mat=816,**kw): return part(zone,name,(x,y+dy,z),(sx,sy,sz),tint,mat,**kw)
 p('FloatingFoundation',0,-12,0,306,24,306,'3D4A4C',800)
 p('Landscape',0,-1,0,300,2,300,grass,1280 if floor<3 else 800)
 p('LowerTerrace',0,-31,0,258,16,258,'344143',800,yaw=.07)
 p('Underside',0,-46,0,192,18,192,'2A363C',800,yaw=.15)
 # Continuous unobstructed routes and contrasting geometric plazas.
 p('PilgrimRoad',0,.08,-10,18,.16,242,ivory)
 p('Sanctuary',0,.2,104,118,.4,64,stone)
 p('SanctuaryInlay',0,.43,103,95,.06,2,accent,288,collide=False)
 p('Arena',0,.12,-83,78,.24,70,stone)
 for x in [-38,38]: p('ArenaLine',x,.3,-83,.5,.1,70,accent,288,collide=False)
 for z in [-117,-49]: p('ArenaLine',0,.3,z,76,.1,.5,accent,288,collide=False)
 # Tower ribs and a distant skyline visible between floating land masses.
 for x in [-144,144]:
  for z in [-140,-48,48,140]:
   p('TowerPillar',x,25,z,7,50,7,stone)
   p('PillarCap',x,51,z,11,3,11,ivory)
   p('EnergySeam',x,27,z-3.55,1,34,.15,accent,288,collide=False)
  p('OuterBalustrade',x,3,0,3,6,280,stone)
 for z in [-144,144]: p('OuterBalustrade',0,3,z,280,6,3,stone)
 # Ruined arches along the processional road.
 for z in [55,5,-40]:
  for x in [-15,15]: p('ArchPier',x,9,z,3,18,4,ivory)
  p('ArchLintel',0,19,z,34,3,5,ivory)
  p('Rune',0,19,z+2.6,2,1.3,.16,accent,288,collide=False)
 # Safe hub with angular forge, aether crystal and seating.
 p('ForgeBase',40,2,105,13,4,10,'3D484D',1088)
 p('ForgeAnvil',40,5,105,9,2,5,ivory,1088)
 p('ForgeCore',40,6.6,105,3,1,3,accent,288,collide=False)
 sign(zone,'FORJA\nMenu → Inventário → Forja',(40,y+13,105),accent)
 for x in [-45,45]:
  p('Bench',x,2,127,13,1,4,ivory,512)
  for xx in [x-4,x+4]: p('BenchFoot',xx,1,127,1,2,3,stone)
 sign(zone,f'{floor:02d}  /  {name.upper()}\nSANTUÁRIO · recuperação de vida',(0,y+13,126),accent)
 # Tall faceted forms keep the Roblox silhouette, without spherical foliage.
 for j in range(26):
  x=rng.choice([-1,1])*rng.uniform(77,130); z=rng.uniform(-127,69)
  if floor==1:
   h=rng.uniform(8,16); p('TreeTrunk',x,h/2,z,2,h,2,'695D4B',512)
   for k in range(3): p('AngularCanopy',x,h+k*2,z,13-k*3,4,13-k*3,rng.choice(['739B73','8DAE80','ABC390']),1280,yaw=rng.random())
  elif floor==2:
   h=rng.uniform(7,20); p('Crystal',x,h/2,z,3,h,3,accent,288,yaw=rng.random(),transparency=.18)
   p('CrystalFoot',x,1,z,7,2,7,'6D8196',800,yaw=.6)
  else:
   h=rng.uniform(9,24); p('MachineTower',x,h/2,z,6,h,6,'626B70',1088)
   p('MachineVent',x,h,z,8,2,8,accent,288,collide=False)
   p('Conduit',x,1,z,2,2,13,'937C5A',1088)
 # Flowers / mineral shards grouped away from movement corridors.
 for j in range(48):
  x=rng.choice([-1,1])*rng.uniform(24,130); z=rng.uniform(-130,65)
  if abs(x)<50 and z<-48: continue
  p('SmallRelic',x,.45,z,.6,.9,.6,rng.choice([accent,ivory,grass]),272,collide=False,yaw=.5)
 for j in range(5):
  x=rng.choice([-1,1])*rng.uniform(175,240); z=rng.uniform(-190,130); alt=rng.uniform(12,65)
  p('DistantIsland',x,alt,z,25,8,25,'586965',800,yaw=.4)
  p('DistantIslandTop',x,alt+4.2,z,24,.4,24,grass,1280,yaw=.4)
 # Gate arches: actual travel is checked by the server.
 gates=[]
 if floor<3: gates.append(('Next',0,-126))
 if floor>1: gates.append(('Previous',-23,104))
 for direction,x,z in gates:
  for offset in [-6,6]: p('GatePier',x+offset,8,z,2,16,3,ivory)
  p('GateCrown',x,17,z,15,3,4,ivory)
  gate=part(portals,f'{floor}{direction}',(x,y+6,z),(9,12,.4),accent,288,collide=False,transparency=.5)
  sign(zone,'SUBIR ANDAR' if direction=='Next' else 'ANDAR ANTERIOR',(x,y+21,z),accent)
 if floor==3:
  p('AetherHeart',0,14,-128,7,18,7,accent,288,yaw=math.pi/4)
  sign(zone,'O CORAÇÃO DE AETHER',(0,y+28,-128),accent)
 defs=[1,2,3] if floor==1 else [4,5,6] if floor==2 else [7,7,8]
 for i,(x,z) in enumerate([(-34,35),(34,35),(-48,4),(48,4),(-46,-30),(46,-30)]):
  part(spawns,str(defs[0 if i<2 else 1]),(x,y+3.4,z),(1,1,1),accent,collide=False,transparency=1)
 part(spawns,str(defs[2]),(0,y+7.2,-83),(1,1,1),accent,collide=False,transparency=1)

spawn=part(workspace,'SanctuarySpawn',(0,1,104),(8,1,8),'85EAC5',288,cls='SpawnLocation',transparency=1)
prop(spawn,'bool','Neutral',True); prop(spawn,'float','Duration',0)
lighting=item('Lighting','Lighting')
for name,value in [('Brightness',2.5),('ClockTime',15.3),('EnvironmentDiffuseScale',.65),('EnvironmentSpecularScale',.7)]: prop(lighting,'float',name,value)
prop(lighting,'bool','GlobalShadows',True); prop(lighting,'Color3','Ambient',color('727D8C')); prop(lighting,'Color3','OutdoorAmbient',color('A2AFAA'))
atmos=item('Atmosphere','Atmosphere',lighting)
prop(atmos,'float','Density',.22); prop(atmos,'float','Offset',.2); prop(atmos,'Color3','Color',color('C5DEDB')); prop(atmos,'Color3','Decay',color('95ACBE')); prop(atmos,'float','Haze',1.2)
bloom=item('BloomEffect','AetherBloom',lighting); prop(bloom,'float','Intensity',.22); prop(bloom,'float','Size',24); prop(bloom,'float','Threshold',1.3)
grading=item('ColorCorrectionEffect','AetherColor',lighting); prop(grading,'float','Contrast',.07); prop(grading,'float','Saturation',.09); prop(grading,'Color3','TintColor',color('FFF6E5'))
sun=item('SunRaysEffect','AetherSun',lighting); prop(sun,'float','Intensity',.035); prop(sun,'float','Spread',.7)

def script_file(parent,path,cls,name):
 o=item(cls,name,parent); prop(o,'ProtectedString','Source',(ROOT/path).read_text()); return o
rep=item('ReplicatedStorage','ReplicatedStorage'); shared=item('Folder','LittleRPG',rep)
for path in sorted((ROOT/'src/shared').glob('*.lua')): script_file(shared,path.relative_to(ROOT),'ModuleScript',path.stem)
server=item('ServerScriptService','ServerScriptService'); scripts=item('Folder','LittleRPGServer',server)
for path in sorted((ROOT/'src/server').glob('*.lua')):
 script_file(scripts,path.relative_to(ROOT),'Script' if '.server.' in path.name else 'ModuleScript',path.name.split('.')[0])
starter=item('StarterPlayer','StarterPlayer'); prop(starter,'bool','LoadCharacterAppearance',False); prop(starter,'float','CameraMaxZoomDistance',50); prop(starter,'float','CameraMinZoomDistance',6)
clients=item('StarterPlayerScripts','StarterPlayerScripts',starter)
for path in sorted((ROOT/'src/client').glob('*.lua')): script_file(clients,path.relative_to(ROOT),'LocalScript',path.name.split('.')[0])
# Original R6 avatar with real Motor6D joints and an explicit animation controller.
char=item('Model','StarterCharacter',starter)
rig={}
specs=[('HumanoidRootPart',(0,4,0),(2,2,1),'334E59'),('Torso',(0,4,0),(2,2,1),'334E59'),('Head',(0,5.5,0),(2,1,1),'D9BA94'),('Left Arm',(-1.5,4,0),(1,2,1),'557C80'),('Right Arm',(1.5,4,0),(1,2,1),'557C80'),('Left Leg',(-.5,2,0),(1,2,1),'303D46'),('Right Leg',(.5,2,0),(1,2,1),'303D46')]
for name,pos,size,tint in specs:
 rig[name]=part(char,name,pos,size,tint,anchored=False,collide=name in ['Torso','Head'],transparency=1 if name=='HumanoidRootPart' else 0)
 if name!='HumanoidRootPart': prop(rig[name],'bool','Massless',True)
prop(char,'Ref','PrimaryPart',rig['HumanoidRootPart'].attrib['referent'])
hum=item('Humanoid','Humanoid',char); prop(hum,'token','RigType',0); prop(hum,'float','WalkSpeed',22); prop(hum,'float','JumpPower',50); prop(hum,'bool','UseJumpPower',True)
for name,a,b,c0,c1 in [('RootJoint','HumanoidRootPart','Torso',(0,0,0),(0,0,0)),('Neck','Torso','Head',(0,1,0),(0,-.5,0)),('Left Shoulder','Torso','Left Arm',(-1,1,0),(.5,1,0)),('Right Shoulder','Torso','Right Arm',(1,1,0),(-.5,1,0)),('Left Hip','Torso','Left Leg',(-.5,-1,0),(0,1,0)),('Right Hip','Torso','Right Leg',(.5,-1,0),(0,1,0))]:
 joint=item('Motor6D',name,rig[a]); prop(joint,'Ref','Part0',rig[a].attrib['referent']); prop(joint,'Ref','Part1',rig[b].attrib['referent']); prop(joint,'CoordinateFrame','C0',(c0,0)); prop(joint,'CoordinateFrame','C1',(c1,0))
script_file(char,Path('src/Animate.client.lua'),'LocalScript','Animate')
ET.indent(doc)
output=ROOT/'LittleRPG.rbxlx'
ET.ElementTree(doc).write(output,encoding='utf-8',xml_declaration=True)
print(f'Built {output.name}: {counter} instances, {output.stat().st_size:,} bytes')
