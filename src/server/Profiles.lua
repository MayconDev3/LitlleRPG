-- PERFIS: migração v1, trava de sessão, autosave e recibos no mesmo documento.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Shared=game.ReplicatedStorage:WaitForChild("LittleRPG")
local P=require(Shared.Progression)
local C=require(Shared.Config)
local K=require(Shared.Catalog)
local E=require(Shared.Economy)
local Profiles={Data={},Saving={},Closing={},Travel={},ReceiptBusy={}}
local store=game:GetService("DataStoreService"):GetDataStore("LittleRPG_Profiles_v1")
local token=game.JobId~="" and game.JobId or Http:GenerateGUID(false)
Profiles.Temporary=Run:IsStudio()
local function migrate(d)
 if not d.Version or d.Version<2 then
  local old=d; d=P.New()
  for _,key in ipairs({"Level","XP","Gold","Floor","Unlocked","Bosses","Kills"}) do if old[key]~=nil then d[key]=old[key] end end
  d.Points=math.max(0,d.Level-1); d.LegacyOwned=old.Owned; d.Lock=old.Lock
  d.Bosses={alpha=old.Bosses and old.Bosses.warden or nil,warden=old.Bosses and old.Bosses.oracle or nil,sovereign=old.Bosses and old.Bosses.echo or nil}
  -- Preserve old inventory as new physical equivalents; no silent deletion.
  local map={"longsword","dagger","heavy_hammer","rapier","light_hammer"}
  for id in pairs(old.Owned or {}) do
   local tier,family=id:match("gear_(%d+)_(%d+)")
   if tier and map[tonumber(family)] then
    local w=P.AddWeapon(d,string.format("%s_%02d",map[tonumber(family)],tonumber(tier)),1)
    if w and old.Equipped==id then d.Equipped=w.Uid end
   end
  end
  d.StarterChosen=#d.Weapons>0
  if d.Equipped=="" and d.Weapons[1] then d.Equipped=d.Weapons[1].Uid end
 end
 for key,value in pairs(P.New()) do if d[key]==nil then d[key]=value end end
 d.Level=math.clamp(math.floor(tonumber(d.Level) or 1),1,C.MaxLevel)
 if not P.CanTravel(d,d.Floor) then d.Floor=1 end
 if d.PendingForge then E.FinishForge(d,math.random()) end -- Recover a paid job after disconnect.
 return d
end
function Profiles.Load(player)
 local data
 if Profiles.Temporary then data=P.New() else
  for attempt=1,4 do
   local ok,result=pcall(function()
    return store:UpdateAsync("u_"..player.UserId,function(old)
     old=old or P.New()
     if old.Lock and old.Lock.Token~=token and os.time()-old.Lock.Time<180 then return nil end
     old=migrate(old); old.Lock={Token=token,Time=os.time()}; return old
    end)
   end)
   if ok and result then data=result; break end
   task.wait(attempt)
  end
  if not data then player:Kick("Seu progresso está em uso ou indisponível. Aguarde e tente novamente."); return nil end
 end
 Profiles.Data[player]=migrate(data)
 return Profiles.Data[player]
end
function Profiles.Save(player,release)
 while Profiles.Saving[player] do task.wait(.1) end
 local d=Profiles.Data[player]; if not d then return false end
 if Profiles.Temporary then if release then Profiles.Data[player]=nil end; return true end
 Profiles.Saving[player]=true
 local snapshot=Http:JSONDecode(Http:JSONEncode(d)); local success=false
 for attempt=1,3 do
  local ok,result=pcall(function()
   return store:UpdateAsync("u_"..player.UserId,function(old)
    if not old or not old.Lock or old.Lock.Token~=token then return nil end
    snapshot.Lock=not release and {Token=token,Time=os.time()} or nil; return snapshot
   end)
  end)
  if ok and result then success=true; break end
  task.wait(attempt)
 end
 Profiles.Saving[player]=nil
 if release and success then Profiles.Data[player]=nil end
 if not success then warn("LittleRPG: falha de salvamento",player.UserId) end
 return success
end
function Profiles.Close(player)
 if Profiles.Closing[player] then return end
 Profiles.Closing[player]=true
 while Profiles.ReceiptBusy[player] do task.wait(.1) end
 Profiles.Save(player,true)
 Profiles.Data[player]=nil; Profiles.Travel[player]=nil; Profiles.Closing[player]=nil
end
Players.PlayerRemoving:Connect(Profiles.Close)
task.spawn(function()
 while task.wait(40) do
  for player in pairs(Profiles.Data) do
   if not Profiles.Travel[player] and not Profiles.Closing[player] then
    task.spawn(function() if not Profiles.Save(player,false) and player.Parent then player:Kick("Salvamento indisponível. Reconecte para proteger seu progresso.") end end)
   end
  end
 end
end)
game:BindToClose(function()
 for player in pairs(Profiles.Data) do task.spawn(Profiles.Close,player) end
 local deadline=os.clock()+25; while next(Profiles.Data) and os.clock()<deadline do task.wait(.1) end
end)
return Profiles
