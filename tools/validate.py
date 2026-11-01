"""Syntax and domain tests through system Lua 5.4, plus place structure checks.
Code deliberately uses the Lua subset accepted by Luau. This is NOT a Studio playtest.
"""
from pathlib import Path
import ctypes, ctypes.util, sys, xml.etree.ElementTree as ET
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
scripts=list((ROOT/'src').rglob('*.lua'))
for path in scripts: run(path=path)
run(code=(ROOT/'tests/domain.lua').read_text().replace('__ROOT__',str(ROOT)))
doc=ET.parse(ROOT/'LittleRPG.rbxlx')
items=doc.findall('.//Item')
by_name=lambda name:[o for o in items if o.findtext('Properties/string[@name="Name"]')==name]
assert len(by_name('StarterCharacter'))==1
assert len(by_name('LittleWorld'))==1
assert len(by_name('Floor1'))==len(by_name('Floor2'))==len(by_name('Floor3'))==1
markers=by_name('Spawns')[0].findall('Item')
assert len(markers)==21
assert len(by_name('Portals')[0].findall('Item'))==4
refs={o.attrib['referent'] for o in items}
for ref in doc.findall('.//Ref'): assert ref.text in refs
embedded=doc.findall('.//ProtectedString[@name="Source"]')
assert len(embedded)==len(scripts)
assert sorted(x.text for x in embedded)==sorted(x.read_text() for x in scripts)
for obj in items:
 source=obj.find('Properties/ProtectedString[@name="Source"]')
 if source is not None: assert 'loadstring(' not in source.text and 'HttpGet(' not in source.text
print(f'PASS: {len(scripts)} script syntax checks; domain assertions; {len(items)} instances; 21 spawns; 4 portals; exact source embedding.')
