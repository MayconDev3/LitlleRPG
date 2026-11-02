-- DFS determinístico: cada célula é alcançável, com salas mortas e rotas longas.
-- Sem Random do Roblox: o mesmo algoritmo pode ser testado fora do Studio.
local M={}
function M.Generate(size,seed)
 local cells={}; for z=1,size do cells[z]={}; for x=1,size do cells[z][x]={N=true,E=true,S=true,W=true} end end
 local function random(n) seed=(seed*48271)%2147483647; return seed%n+1 end
 local directions={{0,-1,"N","S"},{1,0,"E","W"},{0,1,"S","N"},{-1,0,"W","E"}}
 local visited={['1,1']=true}; local stack={{1,1}}; local distances={['1,1']=0}; local farthest={1,1}; local longest=0
 while #stack>0 do
  local current=stack[#stack]; local x,z=current[1],current[2]; local choices={}
  for _,dir in ipairs(directions) do local nx,nz=x+dir[1],z+dir[2]; if nx>=1 and nx<=size and nz>=1 and nz<=size and not visited[nx..","..nz] then choices[#choices+1]=dir end end
  if #choices==0 then table.remove(stack) else
   local dir=choices[random(#choices)]; local nx,nz=x+dir[1],z+dir[2]
   cells[z][x][dir[3]]=false; cells[nz][nx][dir[4]]=false; visited[nx..","..nz]=true
   local distance=distances[x..","..z]+1; distances[nx..","..nz]=distance
   if distance>longest then longest=distance; farthest={nx,nz} end
   stack[#stack+1]={nx,nz}
  end
 end
 return {Cells=cells,Goal=farthest,Length=longest,Size=size}
end
return M
