"""Automated Lua-subset/domain + generated-place validation; not a Roblox playtest."""
from pathlib import Path
import ctypes, ctypes.util, xml.etree.ElementTree as ET, json, importlib.util
ROOT=Path(__file__).resolve().parents[1]
lib=ctypes.CDLL(ctypes.util.find_library('lua5.4'))
lib.luaL_newstate.restype=ctypes.c_void_p
lib.luaL_openlibs.argtypes=[ctypes.c_void_p]
lib.luaL_loadfilex.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p]
lib.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p]; lib.lua_tolstring.restype=ctypes.c_char_p
lib.lua_close.argtypes=[ctypes.c_void_p]
def run(path=None,code=None):
 state=lib.luaL_newstate(); lib.luaL_openlibs(state)
 status=lib.luaL_loadfilex(state,str(path).encode(),None) if path else lib.luaL_loadstring(state,code.encode())
 if status==0 and code: status=lib.lua_pcallk(state,0,0,0,0,None)
 if status:
  message=lib.lua_tolstring(state,-1,None).decode(); lib.lua_close(state); raise AssertionError(message)
 lib.lua_close(state)
loader='''
Vector3={new=function(x,y,z) return {X=x or 0,Y=y or 0,Z=z or 0} end}
unpack=table.unpack
local cache={}
local parent=setmetatable({},{__index=function(_,key) return key end})
function require(name)
 if cache[name] then return cache[name] end
 local env=setmetatable({script={Parent=parent}},{__index=_G})
 local chunk=assert(loadfile('__ROOT__/src/shared/'..name..'.lua','t',env))
 cache[name]=chunk(); return cache[name]
end
'''.replace('__ROOT__',str(ROOT))
scripts=list((ROOT/'src').rglob('*.lua'))
for path in scripts: run(path=path)
for path in sorted((ROOT/'tests').glob('*.lua')): run(code=loader+path.read_text().replace('__ROOT__',str(ROOT)))
doc=ET.parse(ROOT/'LittleRPG.rbxlx'); items=doc.findall('.//Item')
by_name=lambda name:[o for o in items if o.findtext('Properties/string[@name="Name"]')==name]
for name in ['StarterCharacter','LittleWorld','Floor1','Floor2','Floor3','Dungeon1','Dungeon2','Dungeon3']: assert len(by_name(name))==1,name
markers=by_name('Spawns')[0].findall('Item'); assert len(markers)==60
assert len(by_name('OreNodes')[0].findall('Item'))==90
for floor in range(1,4):
 for key in ['DungeonEntry','DungeonExit','ArenaGate','Forge','Shop','Travel']: assert len(by_name(f'{key}_{floor}'))==1
 for seal in range(1,4): assert len(by_name(f'Seal_{floor}_{seal}'))==1
refs={o.attrib['referent'] for o in items}
for ref in doc.findall('.//Ref'): assert ref.text in refs
for obj in items:
 properties=obj.find('Properties'); names=[p.attrib['name'] for p in properties]; assert len(set(names))==len(names),obj.attrib
embedded=doc.findall('.//ProtectedString[@name="Source"]')
assert len(embedded)==len(scripts)
assert sorted(x.text or '' for x in embedded)==sorted(x.read_text() for x in scripts)
# Readable folders and complete exact source, without dynamic loaders.
for source in embedded: assert 'loadstring(' not in source.text and 'HttpGet(' not in source.text
print(f'PASS: {len(scripts)} script syntax checks; {len(items)} instances; 60 enemy spawns; 90 ore nodes; exact embedded sources and unique properties.')
