-- Instância solo por servidor reservado. No Studio, mesma dungeon em modo local.
local Teleport=game:GetService("TeleportService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local C=require(game.ReplicatedStorage.LittleRPG.Config)
local D={}
function D.Start(ctx)
 local profiles=ctx.Profiles; local restoring={}
 local function restore(player,message)
  if not profiles.Travel[player] or not player.Parent or restoring[player] then return end
  restoring[player]=true
  -- Loading is necessary only after the old session was durably released.
  if not profiles.Data[player] then profiles.Load(player) end
  profiles.Travel[player]=nil; restoring[player]=nil
  local root,hum=ctx.Character(player); if root then root.Anchored=false end
  if hum then hum.WalkSpeed=ctx.Speed(player) end
  ctx.Notice(player,message); ctx.Sync(player)
 end
 local function transfer(player,toDungeon)
  local d=profiles.Data[player]; local r=ctx.Runtime[player]
  if not d or not r or profiles.Travel[player] or profiles.ReceiptBusy[player] or d.PendingForge then return end
  if Run:IsStudio() then
   r.Mode=toDungeon and "Dungeon" or "World"; r.InCombatUntil=0
   ctx.RespawnAt(player); ctx.Sync(player)
   ctx.Notice(player,toDungeon and "Dungeon local de teste — em produção: servidor reservado." or "Você voltou à cidade.")
   return
  end
  profiles.Travel[player]=true
  local root=ctx.Character(player); if root then root.Anchored=true end
  local options=Instance.new("TeleportOptions")
  if toDungeon then
   local serverId=Http:GenerateGUID(false); local ticket=Http:GenerateGUID(false)
   d.DungeonTicket={Token=ticket,Server=serverId,Floor=d.Floor,Expires=os.time()+600}
   options.ReservedServerId=serverId
   options:SetTeleportData({DungeonToken=ticket})
  else d.DungeonTicket=nil end
  if not profiles.Save(player,true) then restore(player,"Não foi possível salvar antes da viagem. Tente novamente."); return end
  local ok,err=pcall(function() Teleport:TeleportAsync(game.PlaceId,{player},options) end)
  if not ok then warn("Dungeon teleport",err); restore(player,"O teleporte falhou. Seu progresso foi preservado; tente novamente.") end
 end
 function D.Arrive(player,d)
  local r=ctx.Runtime[player]; r.Mode="World"
  if game.PrivateServerId~="" and game.PrivateServerOwnerId==0 then
   local join=player:GetJoinData(); local data=join.TeleportData; local ticket=d.DungeonTicket
   if ticket and data and ticket.Token==data.DungeonToken and ticket.Server==game.PrivateServerId and ticket.Expires>=os.time() and ticket.Floor<=d.Unlocked then
    d.Floor=ticket.Floor; r.Mode="Dungeon"
   else player:Kick("Esta dungeon não tem uma entrada válida. Entre pela página principal do jogo."); return false end
  end
  return true
 end
 function D.Enter(player) transfer(player,true) end
 function D.Exit(player) transfer(player,false) end
 Teleport.TeleportInitFailed:Connect(function(player) restore(player,"A conexão com a dungeon falhou. Tente entrar novamente.") end)
 local folder=workspace.LittleWorld.Interactions
 for _,marker in ipairs(folder:GetChildren()) do
  if marker.Name:match("^DungeonEntry_") then
   local floor=tonumber(marker.Name:match("_(%d+)$"))
   ctx.Prompt(marker,"Entrar na dungeon","Pilar central",function(player)
    local d=profiles.Data[player]; local r=ctx.Runtime[player]
    if d and r and r.Mode=="World" and d.Floor==floor and d.StarterChosen then D.Enter(player) end
   end)
  elseif marker.Name:match("^DungeonExit_") then
   ctx.Prompt(marker,"Voltar à cidade","Saída da dungeon",function(player)
    if ctx.Runtime[player] and ctx.Runtime[player].Mode=="Dungeon" then D.Exit(player) end
   end)
  end
 end
end
return D
