local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("LittleRPG")
local P=require(Shared.Progression)
local C=require(Shared.Config)
local Profiles={Data={},Saving={},Closing={}}
local store=game:GetService("DataStoreService"):GetDataStore("LittleRPG_Profiles_v1")
local token=game.JobId~="" and game.JobId or Http:GenerateGUID(false)
-- Studio deliberately uses an isolated temporary session; never touch live saves in Studio.
local temporary=RunService:IsStudio()
function Profiles.Load(player)
 local data
 if temporary then data=P.New() else
  local ok,result=pcall(function()
   return store:UpdateAsync("u_"..player.UserId,function(old)
    old=old or P.New()
    if old.Lock and old.Lock.Token~=token and os.time()-old.Lock.Time<180 then return nil end
    old.Lock={Token=token,Time=os.time()}; return old
   end)
  end)
  if not ok or not result then player:Kick("Não foi possível abrir seu progresso com segurança. Aguarde um momento e entre novamente."); return nil end
  data=result
 end
 data.Level=math.clamp(tonumber(data.Level) or 1,1,100)
 data.XP=math.max(0,tonumber(data.XP) or 0); data.Gold=math.max(0,tonumber(data.Gold) or 0)
 data.Unlocked=math.clamp(tonumber(data.Unlocked) or 1,1,3)
 data.Bosses=type(data.Bosses)=="table" and data.Bosses or {}
 data.Owned=type(data.Owned)=="table" and data.Owned or {}; data.Owned.gear_01_1=true
 if not C.Items[data.Equipped] or not data.Owned[data.Equipped] or C.Items[data.Equipped].Level>data.Level then data.Equipped="gear_01_1" end
 data.Kills=tonumber(data.Kills) or 0
 if not P.CanTravel(data,data.Floor,C) then data.Floor=1 end
 Profiles.Data[player]=data
 return data
end
function Profiles.Save(player,release)
 if Profiles.Saving[player] then
  if not release then return end
  while Profiles.Saving[player] do task.wait(.1) end
 end
 local data=Profiles.Data[player]; if not data then return end
 if temporary then if release then Profiles.Data[player]=nil end; return end
 Profiles.Saving[player]=true
 local snapshot=Http:JSONDecode(Http:JSONEncode(data))
 local success=false
 for attempt=1,3 do
  local ok,result=pcall(function()
   return store:UpdateAsync("u_"..player.UserId,function(old)
    if not old or not old.Lock or old.Lock.Token~=token then return nil end
    snapshot.Lock=not release and {Token=token,Time=os.time()} or nil
    return snapshot
   end)
  end)
  if ok and result then success=true; break end
  task.wait(attempt)
 end
 Profiles.Saving[player]=nil
 if not success then
  warn("LittleRPG: save failed for user",player.UserId)
  if player.Parent then player:Kick("A conexão com o salvamento falhou. Entre novamente em alguns instantes para proteger seu progresso.") end
 end
 if release then Profiles.Data[player]=nil end
end
task.spawn(function()
 while task.wait(45) do
  for player in pairs(Profiles.Data) do
   if not Profiles.Closing[player] then task.spawn(Profiles.Save,player,false) end
  end
 end
end)
function Profiles.Close(player)
 if Profiles.Closing[player] then
  while Profiles.Data[player] do task.wait(.1) end
  return
 end
 Profiles.Closing[player]=true; Profiles.Save(player,true); Profiles.Closing[player]=nil
end
Players.PlayerRemoving:Connect(Profiles.Close)
game:BindToClose(function()
 for player in pairs(Profiles.Data) do task.spawn(Profiles.Close,player) end
 local deadline=os.clock()+25
 while next(Profiles.Data) and os.clock()<deadline do task.wait(.1) end
end)
return Profiles
