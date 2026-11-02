-- Mineração escassa, NPCs de loja, poções e trabalho durável na ferraria.
local Shared=game.ReplicatedStorage.LittleRPG
local C=require(Shared.Config); local K=require(Shared.Catalog); local E=require(Shared.Economy); local P=require(Shared.Progression)
local W={}
function W.Start(ctx)
 local profiles=ctx.Profiles; local nodes={}
 function W.Near(player,kind)
  local d=profiles.Data[player]; local r=ctx.Runtime[player]; local root=ctx.Character(player)
  if not d or not r or r.Mode~="World" or not root then return false end
  local pos=C.Floors[d.Floor][kind]+C.Floors[d.Floor].Origin
  return (root.Position-pos).Magnitude<=38
 end
 for _,marker in ipairs(workspace.LittleWorld.Interactions:GetChildren()) do
  local kind,floor=marker.Name:match("^(%a+)_(%d+)$"); floor=tonumber(floor)
  if kind=="Shop" or kind=="Forge" then
   ctx.Prompt(marker,kind=="Forge" and "Usar forja" or "Ver mercadorias",kind=="Forge" and "Casa do ferreiro" or "Mercador",function(player)
    local d=profiles.Data[player]
    if d and d.Floor==floor and W.Near(player,kind) then ctx.Feedback:FireClient(player,"Open",kind); ctx.Sync(player) end
   end)
  elseif kind=="Travel" then
   ctx.Prompt(marker,"Viajar entre andares","Elevador da cidade",function(player) ctx.Feedback:FireClient(player,"Open","Travel"); ctx.Sync(player) end)
  end
 end
 for _,node in ipairs(workspace.LittleWorld.OreNodes:GetChildren()) do
  local floor=tonumber(node.Name:match("^(%d)_")); local state={HP=4,Ready=true}; nodes[node]=state
  local prompt=ctx.Prompt(node,"Minerar","Veio de rocha",function(player)
   local d=profiles.Data[player]; local r=ctx.Runtime[player]
   if not d or not r or r.Mode~="World" or d.Floor~=floor or not state.Ready or not d.StarterChosen then return end
   if os.clock()<(r.NextMine or 0) then return end; r.NextMine=os.clock()+1.15
   ctx.Animate(player,"Mine",1)
   ctx.Feedback:FireAllClients("Mine",node.Position)
   state.HP=state.HP-d.Pickaxe
   if state.HP>0 then return end
   state.Ready=false; node.Transparency=.82; node.CanCollide=false
   local ore=E.RollOre(floor,math.random())
   if ore then d.Ores[ore]=(d.Ores[ore] or 0)+1; ctx.Notice(player,"+1 "..E.Ores[ore].Name) else ctx.Notice(player,"Apenas pedra. Procure outro veio.") end
   ctx.Sync(player)
   task.delay(100+floor*10,function() if node.Parent then state.HP=4; state.Ready=true; node.Transparency=0; node.CanCollide=true end end)
  end)
  prompt.HoldDuration=.7
 end
 function W.Action(player,verb,arg)
  local d=profiles.Data[player]; local r=ctx.Runtime[player]; if not d or not r then return end
  if verb=="Forge" then
   if type(arg)~="string" or not W.Near(player,"Forge") or d.PendingForge then return end
   local ok,message=E.BeginForge(d,arg); if not ok then ctx.Notice(player,message); return end
   -- All inputs debited once; PendingForge is recovered on next login if disconnected.
   r.Forging=true; local forgeRoot=ctx.Character(player); if forgeRoot then forgeRoot.Anchored=true end
   ctx.Animate(player,"Forge",10); ctx.Sync(player)
   ctx.Feedback:FireAllClients("Forge",player.UserId,d.Floor,arg)
   task.delay(10,function()
    if profiles.Data[player]==d and not profiles.Closing[player] and not profiles.Travel[player] then
     local result=E.FinishForge(d,math.random()); r.Forging=false
     if forgeRoot and forgeRoot.Parent then forgeRoot.Anchored=false end
     if result then ctx.Notice(player,"Forjado: "..K.Name(result)); ctx.Feedback:FireClient(player,"Forged",result) end
     ctx.Sync(player)
    end
   end)
  elseif verb=="Buy" then
   if type(arg)~="string" or not W.Near(player,"Shop") then return end
   local _,message=E.Buy(d,arg,d.Floor,math.floor(os.time()/C.StockSeconds)); ctx.Notice(player,message); ctx.Sync(player)
  elseif verb=="Supply" then
   local offer=type(arg)=="string" and C.Consumables[arg]
   if not offer or not W.Near(player,"Shop") or d.Gold<offer.Price or d.Floor<(offer.Floor or 1) then return end
   if arg=="health" or arg=="energy" then
    if d.Potions[arg]>=99 then ctx.Notice(player,"Limite de 99 poções."); return end
    d.Potions[arg]=d.Potions[arg]+1
   else
    local tier=arg=="pickaxe2" and 2 or 3
    if d.Pickaxe>=tier then ctx.Notice(player,"Sua picareta já é igual ou melhor."); return end
    d.Pickaxe=tier
   end
   d.Gold=d.Gold-offer.Price; ctx.Sync(player); ctx.Notice(player,offer.Name.." adquirido(a).")
  elseif verb=="Sell" then
   if type(arg)~="string" or not W.Near(player,"Shop") or arg==d.Equipped then return end
   for index,weapon in ipairs(d.Weapons) do
    if weapon.Uid==arg then
     d.Gold=d.Gold+math.floor(K.ById[weapon.Blueprint].Price*C.Rarities[weapon.Rarity].Multiplier*.2)
     table.remove(d.Weapons,index); ctx.Sync(player); ctx.Notice(player,"Arma vendida."); return
    end
   end
  elseif verb=="Potion" then
   if (arg~="health" and arg~="energy") or d.Potions[arg]<1 or os.clock()<(r.NextPotion or 0) then return end
   local _,hum=ctx.Character(player); if not hum then return end
   if arg=="health" and hum.Health>=hum.MaxHealth or arg=="energy" and r.Energy>=100 then return end
   d.Potions[arg]=d.Potions[arg]-1; r.NextPotion=os.clock()+3
   if arg=="health" then hum.Health=math.min(hum.MaxHealth,hum.Health+C.Consumables.health.Amount+hum.MaxHealth*.2)
   else r.Energy=math.min(100,r.Energy+50) end
   ctx.Animate(player,"Drink",.7); ctx.Sync(player)
  end
 end
end
return W
