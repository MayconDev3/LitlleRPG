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
 properties=obj.find('Properties')
 for previous in list(properties):
  if previous.attrib.get('name')==name: properties.remove(previous)
 el=ET.SubElement(properties,typ,{'name':name})
 if typ in ('Vector3','Color3'):
  for k,v in zip(('X','Y','Z') if typ=='Vector3' else ('R','G','B'),value): ET.SubElement(el,k).text=str(v)
 elif typ=='CoordinateFrame':
  pos,yaw=value; c=math.cos(yaw); s=math.sin(yaw)
  for k,v in zip(('X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'),(*pos,c,0,s,0,1,0,-s,0,c)): ET.SubElement(el,k).text=str(v)
 else: el.text=str(value).lower() if isinstance(value,bool) else str(value)
 return el
def color(hex): return tuple(int(hex[i:i+2],16)/255 for i in (0,2,4))
def part(parent,name,pos,size,tint,material=272,yaw=0,cls='Part',collide=True,transparency=0,anchored=True):
 o=item(cls,name,parent); prop(o,'Vector3','size',size); prop(o,'CoordinateFrame','CFrame',(pos,yaw)); prop(o,'Color3uint8','Color3uint8',0xFF000000 | int(tint,16)); prop(o,'token','Material',material)
 for k,v in [('Anchored',anchored),('CanCollide',collide),('CanTouch',False),('CastShadow',True)]: prop(o,'bool',k,v)
 prop(o,'float','Transparency',transparency); prop(o,'token','TopSurface',0); prop(o,'token','BottomSurface',0)
 return o
workspace=item('Workspace','Workspace'); prop(workspace,'float','Gravity',196.2); prop(workspace,'float','FallenPartsDestroyHeight',-250)
world=item('Folder','LittleWorld',workspace)
spawns=item('Folder','Spawns',world)
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

# Large worlds: 1,600 x 1,200 studs. Town coverage: 49.375%, then 33.35%.
interactions=item('Folder','Interactions',world)
ore_nodes=item('Folder','OreNodes',world)

def maze_generate(n,seed):
 cells=[[dict(N=True,E=True,S=True,W=True) for _ in range(n)] for _ in range(n)]
 visited={(0,0)}; stack=[(0,0)]; distance={(0,0):0}; farthest=(0,0)
 directions=[(0,-1,'N','S'),(1,0,'E','W'),(0,1,'S','N'),(-1,0,'W','E')]
 while stack:
  x,z=stack[-1]; choices=[d for d in directions if 0<=x+d[0]<n and 0<=z+d[1]<n and (x+d[0],z+d[1]) not in visited]
  if not choices: stack.pop(); continue
  seed=seed*48271%2147483647; d=choices[seed%len(choices)]; nx,nz=x+d[0],z+d[1]
  cells[z][x][d[2]]=False; cells[nz][nx][d[3]]=False
  visited.add((nx,nz)); distance[nx,nz]=distance[x,z]+1
  if distance[nx,nz]>distance[farthest]: farthest=(nx,nz)
  stack.append((nx,nz))
 return cells,distance,farthest

floor_info=[('Vale dos Pioneiros',-405,0,790,1200,(-500,-135),(-500,20)),('Cidade de Ardósia',0,0,924,693,(-180,90),(180,90)),('Bastião Obsidiana',0,0,924,693,(-180,90),(180,90))]
for floor,(name,cx,cz,cw,cd,forge,shop) in enumerate(floor_info,1):
 y=(floor-1)*800
 zone=item('Folder',f'Floor{floor}',world)
 tint=['79916B','657381','595A69'][floor-1]; stone=['C0B49B','9D9DAE','92909A'][floor-1]; roof=['525F73','4B526B','4C435A'][floor-1]; accent=['8BE9FD','BD93F9','FFB86C'][floor-1]
 def p(name,x,dy,z,sx,sy,sz,color=stone,mat=816,**kw): return part(zone,name,(x,y+dy,z),(sx,sy,sz),color,mat,**kw)
 def marker(name,x,z,dy=4,parent=interactions): return part(parent,name,(x,y+dy,z),(2,2,2),accent,collide=False,transparency=1)
 def house(x,z,w=32,d=26,h=18,kind='Home'):
  # Modular open-front architecture with accessible interiors and gabled roofs.
  model=item('Model',kind,zone)
  def hp(n,xx,yy,zz,sx,sy,sz,col=stone,mat=816,**kw): return part(model,n,(x+xx,y+yy,z+zz),(sx,sy,sz),col,mat,**kw)
  hp('Foundation',0,.5,0,w+2,1,d+2,'726D6C')
  hp('BackWall',0,h/2,-d/2,w,h,1.5)
  for xx in [-w/2,w/2]: hp('SideWall',xx,h/2,0,1.5,h,d)
  for xx in [-w*.34,w*.34]: hp('FrontWall',xx,h/2,d/2,w*.32,h,1.5)
  hp('DoorLintel',0,h-2,d/2,w*.38,4,1.5)
  for xx in [-w/2,w/2]:
   for zz in [-d/2,d/2]: hp('OakBeam',xx,h/2,zz,1.8,h+1,1.8,'514549',512)
  hp('RoofSlab',0,h+.6,0,w+6,1.2,d+6,roof,512)
  # Tiered angular roof, avoiding non-portable mesh IDs.
  for step in range(5): hp('RoofTier',0,h+1.5+step,0,w+5-step*5,1.2,d+5,roof,512)
  for xx in [-w*.32,w*.32]:
   hp('WindowFrame',xx,h*.58,d/2+1,w*.21,5,.6,'393943',512)
   hp('WindowGlow',xx,h*.58,d/2+1.4,w*.16,3.8,.2,'F1D6A0',288,collide=False)
  hp('DoorStep',0,.3,d/2+3,10,.6,6,'9F9590')
  hp('Chimney',w*.26,h+5,-d*.2,4,11,4,'807A7A')
  if kind=='Blacksmith':
   hp('Hearth',-w*.27,3,-d*.22,11,6,9,'514D55',800)
   hp('Firebed',-w*.27,4.5,-d*.22+3,7,1.5,5,'FF984F',288,collide=False)
   hp('Hood',-w*.27,10,-d*.22,12,3,10,'595660',1088)
   hp('AnvilStand',w*.22,2,2,6,4,6,'6F5141',512)
   hp('Anvil',w*.22,4.7,2,9,1.5,4,'797F8D',1088)
   hp('MoldBench',0,2.8,d*.22,12,1.4,5,'695044',512)
   hp('CoolingTrough',w*.28,1.5,-d*.25,7,3,8,'5D6572',1088)
   hp('Water',w*.28,3,-d*.25,6,.2,7,'698CA4',272,collide=False,transparency=.25)
   for xx in [-8,-4,0]: hp('CoalSack',xx,1.5,-d*.35,3,3,3,'44434B',800)
  elif kind=='Merchant':
   hp('Counter',0,2.5,4,w*.7,5,4,'795B4E',512)
   for i in range(5): hp('Goods',-w*.28+i*w*.14,6,4,1,2,1,['FF5555','8BE9FD','50FA7B','BD93F9','FFB86C'][i],288,collide=False)
  else:
   hp('Table',0,3,0,8,.7,5,'755F4C',512)
  return model
 def npc(x,z,title,color='BD93F9'):
  model=item('Model',title,zone)
  for n,pos,size,col in [('Body',(0,3.6,0),(2,2.5,1.3),color),('Head',(0,5.5,0),(1.6,1.4,1.4),'D7B898'),('LeftArm',(-1.5,3.5,0),(.8,2.4,1),color),('RightArm',(1.5,3.5,0),(.8,2.4,1),color),('LeftLeg',(-.5,1.3,0),(.9,2.5,1),'353542'),('RightLeg',(.5,1.3,0),(.9,2.5,1),'353542')]:
   part(model,n,(x+pos[0],y+pos[1],z+pos[2]),size,col)
  sign(zone,title,(x,y+9,z),accent)
 # Floating foundation with visual terraces and broad landscape.
 foundation=p('Foundation',0,-15,0,1600,30,1200,'41464C',800); prop(foundation,'bool','CastShadow',False)
 ground=p('Ground',0,-1,0,1600,2,1200,tint,1280 if floor<3 else 800); prop(ground,'bool','CastShadow',False)
 underside=p('Underside',0,-45,0,1510,30,1110,'343A42',800); prop(underside,'bool','CastShadow',False)
 district=p('CityDistrict',cx,.12,cz,cw,.24,cd,stone); prop(district,'bool','CastShadow',False)
 for z in [-cd*.38,0,cd*.38]: p('TownAvenue',cx,.3,cz+z,cw-16,.15,20,'7E7C84')
 for x in [-cw*.32,0,cw*.32]: p('TownAvenue',cx+x,.31,cz,20,.15,cd-16,'7E7C84')
 # City edge palisades with four deliberate gates.
 for x in [cx-cw/2+4,cx+cw/2-4]:
  for z in [cz-cd*.29,cz+cd*.29]: p('CityWall',x,6,z,4,12,cd*.4,'777482')
 for z in [cz-cd/2+4,cz+cd/2-4]:
  for x in [cx-cw*.29,cx+cw*.29]: p('CityWall',x,6,z,cw*.4,12,4,'777482')
 # District houses leave spacious streets, plazas and gardens.
 for ix in [-.37,-.18,.18,.37]:
  for iz in [-.37,-.19,.19,.37]:
   x=cx+cw*ix; z=cz+cd*iz
   if math.hypot(x-forge[0],z-forge[1])<95 or math.hypot(x-shop[0],z-shop[1])<95 or math.hypot(x,z)<95: continue
   house(x,z,w=rng.choice([30,36,42]),d=rng.choice([26,30]),h=rng.choice([16,20]))
 house(*forge,w=64,d=48,h=21,kind='Blacksmith'); npc(forge[0]+19,forge[1]+28,'FERREIRO · MESTRE ORIN','7A6378'); marker(f'Forge_{floor}',*forge)
 house(*shop,w=58,d=42,h=20,kind='Merchant'); npc(shop[0],shop[1]+27,'MERCADOR · ESTOQUE ROTATIVO','5B6A88'); marker(f'Shop_{floor}',*shop)
 # Markers at workstations have open doorways; additional labels explain approach.
 sign(zone,'CASA DO FERREIRO\nMinério → molde → arma',(forge[0],y+36,forge[1]+26),accent)
 sign(zone,'EMPÓRIO\nArmas · poções · ferramentas',(shop[0],y+34,shop[1]+23),accent)
 travel=(cx+100,130)
 p('LiftBase',travel[0],.5,travel[1],30,1,30,'535563')
 for xx in [-13,13]: p('LiftPillar',travel[0]+xx,10,travel[1],2,20,2,'9A93AA')
 p('LiftArch',travel[0],20,travel[1],30,3,3,'9A93AA'); marker(f'Travel_{floor}',*travel)
 sign(zone,'ELEVADOR\nLibere andares nas dungeons',(travel[0],y+26,travel[1]),accent)
 # Town gardens, fountain, banners, street lights.
 fountain_x=cx+100; fountain_z=-125
 p('FountainBase',fountain_x,.8,fountain_z,32,1.6,32,'8A8790'); p('FountainWater',fountain_x,1.7,fountain_z,27,.2,27,'6C95AB',272,collide=False)
 p('FountainMonolith',fountain_x,8,fountain_z,4,16,4,'C2BBCD'); p('FountainCap',fountain_x,16,fountain_z,7,1,7,accent,288)
 for i in range(22):
  x=cx+rng.uniform(-cw*.44,cw*.44); z=cz+rng.uniform(-cd*.44,cd*.44)
  if abs(x)<90 and abs(z)<90: continue
  p('LampPost',x,7,z,.9,14,.9,'4B4654',1088)
  lamp=p('Lantern',x,14,z,2,2,2,'FFD3A2',288,collide=False)
  if i%4==0:
   light=item('PointLight','WarmLight',lamp); prop(light,'float','Range',22); prop(light,'float','Brightness',.7); prop(light,'Color3','Color',color('FFD3A2'))
  p('Banner',x+2,10,z,.3,5,2,accent,512,collide=False)
 # Central dungeon pylon on EVERY map, independent of town position.
 p('PillarPlaza',0,.6,0,100,1.2,100,'6E6A78')
 for xx,zz in [(-25,-25),(25,-25),(-25,25),(25,25)]:
  p('DungeonButtress',xx,28,zz,10,56,10,'514F5B',800)
 p('DungeonBack',0,30,-25,50,60,8,'615C6A',800)
 for xx in [-22,22]: p('DungeonSide',xx,30,0,8,60,50,'615C6A',800)
 p('DungeonLintel',0,48,25,52,24,8,'696372',800)
 p('PillarUpper',0,78,0,45,36,45,'4F4B58',800)
 for xx in [-15,0,15]: p('PillarSpire',xx,108,0,7,28,7,'8F879B',800)
 p('EntryThreshold',0,1,28,22,2,10,'9E97AA')
 marker(f'DungeonEntry_{floor}',0,18)
 sign(zone,'DUNGEON DO ANDAR '+str(floor)+'\nEntre no pilar para desafiar o guardião',(0,y+39,36),accent)
 # Roads connect the sanctuary to wilderness and the pylon.
 if floor==1: p('PillarRoad',-200,.2,0,400,.2,16,'A79E89')
 p('EastRoad',480,.15,0,600,.18,14,'9D978A')
 p('NorthRoad',0,.15,-440,14,.18,300,'9D978A')
 def in_town(x,z): return abs(x-cx)<=cw/2+18 and abs(z-cz)<=cd/2+18
 # Angular groves, rocks, distant hills; open combat clearings remain walkable.
 for i in range(95):
  x=rng.uniform(-760,760); z=rng.uniform(-560,560)
  if in_town(x,z) or abs(x)<95 or abs(z)<24: continue
  h=rng.uniform(10,20)
  p('TreeTrunk',x,h/2,z,2,h,2,'665344',512)
  for tier in range(3): p('AngularCanopy',x,h+tier*3,z,16-tier*4,5,16-tier*4,['68846C','728B89','666A7D'][floor-1],1280,yaw=rng.uniform(0,1))
 for i in range(24):
  x=rng.uniform(-750,750); z=rng.uniform(-550,550)
  if in_town(x,z) or math.hypot(x,z)<110: continue
  p('RockCluster',x,3,z,12,6,10,'77717C',800,yaw=rng.random())
 # Mining sites are explicit, shared scarce resource nodes.
 for i in range(30):
  while True:
   x=rng.uniform(-730,730); z=rng.uniform(-530,530)
   if not in_town(x,z) and math.hypot(x,z)>130 and abs(z)>30: break
  part(ore_nodes,f'{floor}_{i}',(x,y+2.5,z),(5,5,5),['8A817A','8C8B9A','726C83'][floor-1],800,yaw=rng.random())
 # Wildlife distribution and physical dungeon guardians.
 ids=['wolf','boar'] if floor==1 else ['bandit','beetle'] if floor==2 else ['construct','construct']
 for i in range(16):
  while True:
   x=rng.uniform(-700,700); z=rng.uniform(-500,500)
   if not in_town(x,z) and math.hypot(x,z)>110: break
  part(spawns,f'{ids[i%2]}_World_{i}',(x,y+3.5,z),(1,1,1),accent,collide=False,transparency=1)
 sign(zone,f'{floor:02d} / {name.upper()}\nCIDADE SEGURA',(cx,y+22,200),accent)
 # Labyrinth: 225 connected cells, distant goal and three seals on long branches.
 dungeon=item('Folder',f'Dungeon{floor}',world); n=15; cell=26; half=n*cell/2
 cells,dist,goal=maze_generate(n,9000+floor)
 def dp(name,x,dy,z,sx,sy,sz,col='57515F',**kw): return part(dungeon,name,(6000+x,y+dy,z),(sx,sy,sz),col,800,**kw)
 dp('MazeFloor',0,-1,0,n*cell+8,2,n*cell+8,'55515B')
 dp('MazeCeiling',0,20,0,n*cell+8,2,n*cell+8,'3D3945')
 for z in range(n):
  for x in range(n):
   xx=-half+x*cell+cell/2; zz=-half+z*cell+cell/2; walls=cells[z][x]
   if walls['N']: dp('StoneWall',xx,9,zz-cell/2,cell+2,18,2)
   if walls['W']: dp('StoneWall',xx-cell/2,9,zz,2,18,cell+2)
   if z==n-1 and walls['S']: dp('StoneWall',xx,9,zz+cell/2,cell+2,18,2)
   if x==n-1 and walls['E']: dp('StoneWall',xx+cell/2,9,zz,2,18,cell+2)
   if (x+z)%3==0:
    torch=dp('Torch',xx,9,zz,1,1,1,'FFB86C',collide=False)
    prop(torch,'token','Material',288)
    light=item('PointLight','Torchlight',torch); prop(light,'float','Range',31); prop(light,'float','Brightness',1.3); prop(light,'Color3','Color',color('FFC390'))
 entry=(-half+cell/2,-half+cell/2)
 marker(f'DungeonExit_{floor}',6000+entry[0],entry[1])
 ordered=sorted(dist,key=dist.get)
 for number,fraction in enumerate([.33,.62,.85],1):
  sx,sz=ordered[int((len(ordered)-1)*fraction)]; px=-half+sx*cell+cell/2; pz=-half+sz*cell+cell/2
  dp('SealPedestal',px,2,pz,5,4,5,'8C829B'); marker(f'Seal_{floor}_{number}',6000+px,pz)
  sign(dungeon,'SELO '+str(number),(6000+px,y+8,pz),accent)
 gx=-half+goal[0]*cell+cell/2; gz=-half+goal[1]*cell+cell/2
 marker(f'ArenaGate_{floor}',6000+gx,gz); dp('ArenaDoor',gx,6,gz,5,12,2,'9C8EAE',collide=False)
 sign(dungeon,'PORTÃO DOS TRÊS SELOS',(6000+gx,y+14,gz),accent)
 # The arena is isolated from the maze; access requires three server-tracked seals.
 dp('BossFloor',520,-1,0,150,2,150,'68616D'); dp('BossCeiling',520,42,0,150,2,150,'3D3945')
 for xx in [445,595]: dp('ArenaWall',xx,20,0,4,40,150)
 for zz in [-75,75]: dp('ArenaWall',520,20,zz,150,40,4)
 for xx in [465,575]:
  for zz in [-55,55]:
   dp('ArenaPillar',xx,16,zz,6,32,6,'8A7E94')
   torch=dp('ArenaTorch',xx,23,zz,2,2,2,'FFB86C',collide=False); prop(torch,'token','Material',288)
   light=item('PointLight','Light',torch); prop(light,'float','Range',65); prop(light,'float','Brightness',2)
 boss=['alpha','warden','sovereign'][floor-1]
 part(spawns,f'{boss}_Dungeon_0',(6520,y+6,0),(1,1,1),accent,collide=False,transparency=1)
 # Arena exit is distinct so it can return the player without requiring a reverse maze run.
 marker(f'DungeonExit_{floor}_Arena',6520,58)
 for i,fraction in enumerate([.2,.45,.7]):
  ex,ez=ordered[int((len(ordered)-1)*fraction)]; px=6000-half+ex*cell+cell/2; pz=-half+ez*cell+cell/2
  part(spawns,f'{ids[i%2]}_Dungeon_{i+1}',(px,y+3.5,pz),(1,1,1),accent,collide=False,transparency=1)

spawn=part(workspace,'SanctuarySpawn',(-475,1,125),(8,1,8),'85EAC5',288,cls='SpawnLocation',transparency=1)
prop(spawn,'bool','Neutral',True); prop(spawn,'float','Duration',0)
lighting=item('Lighting','Lighting')
for name,value in [('Brightness',2.5),('ClockTime',16.7),('EnvironmentDiffuseScale',.65),('EnvironmentSpecularScale',.7)]: prop(lighting,'float',name,value)
prop(lighting,'bool','GlobalShadows',True); prop(lighting,'Color3','Ambient',color('727D8C')); prop(lighting,'Color3','OutdoorAmbient',color('A2AFAA'))
atmos=item('Atmosphere','Atmosphere',lighting)
prop(atmos,'float','Density',.13); prop(atmos,'float','Offset',.2); prop(atmos,'Color3','Color',color('C5DEDB')); prop(atmos,'Color3','Decay',color('95ACBE')); prop(atmos,'float','Haze',1.2)
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
