-- Receipt fault injection. A durable save must precede purchase acknowledgement.
local C=require('Config'); local P=require('Progression')
local marketplace={}; local player={UserId=17,Parent=true}
local players={GetPlayerByUserId=function(_,id) if id==17 then return player end end}
local fakeGame={ReplicatedStorage={LittleRPG={Config='Config',Progression='Progression'}}}
function fakeGame:GetService(name) if name=='MarketplaceService' then return marketplace elseif name=='Players' then return players end end
local profiles={Data={[player]=P.New()},Travel={},Closing={},ReceiptBusy={},Temporary=false}
local saveOK=false; local saves=0; local notified=0
function profiles.Save() saves=saves+1; return saveOK end
local env=setmetatable({game=fakeGame,Enum={ProductPurchaseDecision={NotProcessedYet='pending',PurchaseGranted='granted'}},require=require,assert=assert,pcall=pcall,warn=function() end},{__index=_G})
local module=assert(loadfile('__ROOT__/src/server/Monetization.lua','t',env))()
C.Products[1].ProductId=123
module.Start(profiles,function() end,function() notified=notified+1 end)
local receipt={PlayerId=17,ProductId=123,PurchaseId='receipt-1'}
assert(marketplace.ProcessReceipt(receipt)=='pending')
assert(#profiles.Data[player].Weapons==1 and profiles.Data[player].Receipts['receipt-1'])
assert(marketplace.ProcessReceipt(receipt)=='pending' and #profiles.Data[player].Weapons==1)
saveOK=true
assert(marketplace.ProcessReceipt(receipt)=='granted' and #profiles.Data[player].Weapons==1 and saves==3)
assert(marketplace.ProcessReceipt(receipt)=='granted' and #profiles.Data[player].Weapons==1)
assert(marketplace.ProcessReceipt({PlayerId=17,ProductId=999,PurchaseId='bad'})=='pending')
profiles.Travel[player]=true; assert(marketplace.ProcessReceipt(receipt)=='pending'); profiles.Travel[player]=nil
profiles.Temporary=true; assert(marketplace.ProcessReceipt(receipt)=='pending'); profiles.Temporary=false
assert(not profiles.ReceiptBusy[player])
C.Products[1].ProductId=0
print('PASS: receipt retries do not duplicate weapons; acknowledgement requires successful durable save; travel and Studio block receipts.')
-- Teleport fault injection: release durable profile before teleport; validate arrival ticket.
local started,failHandler,teleportArgs; local studio=false; local guid=0
local teleport={TeleportInitFailed={Connect=function(_,fn) failHandler=fn end}}
function teleport:TeleportAsync(place,party,options) teleportArgs={place,party,options}; if self.Fail then error('network failure') end end
local root={Anchored=false}; local hum={WalkSpeed=18}; local target={Parent=true}
local game2={PlaceId=1234,PrivateServerId='',PrivateServerOwnerId=0,ReplicatedStorage={LittleRPG={Config='Config'}}}
local services={TeleportService=teleport,HttpService={GenerateGUID=function() guid=guid+1; return 'guid-'..guid end},RunService={IsStudio=function() return studio end}}
function game2:GetService(name) return services[name] end
function target:GetJoinData() return {TeleportData={DungeonToken='guid-2'}} end
function target:Kick(message) self.Kicked=message end
local profile={Data={[target]=P.New()},Travel={},ReceiptBusy={},Closing={}}
local saved
function profile.Save(p,release) saved=profile.Data[p]; if release then profile.Data[p]=nil end; return true end
function profile.Load(p) profile.Data[p]=saved; return saved end
local runtime={[target]={Mode='World'}}
local ctx={Profiles=profile,Runtime=runtime,Character=function() return root,hum end,Speed=function() return 18 end,Notice=function() end,Sync=function() end,RespawnAt=function() started=true end}
local env2=setmetatable({game=game2,workspace={LittleWorld={Interactions={GetChildren=function() return {} end}}},Instance={new=function() return {SetTeleportData=function(self,value) self.Data=value end} end},require=require,warn=function() end},{__index=_G})
local D=assert(loadfile('__ROOT__/src/server/Dungeons.lua','t',env2))()
D.Start(ctx); D.Enter(target)
assert(profile.Data[target]==nil and root.Anchored and profile.Travel[target])
assert(teleportArgs[1]==1234 and teleportArgs[3].ReservedServerId=='guid-1' and teleportArgs[3].Data.DungeonToken=='guid-2')
assert(saved.DungeonTicket.Floor==1 and saved.DungeonTicket.Server=='guid-1')
failHandler(target); assert(profile.Data[target]==saved and not root.Anchored and not profile.Travel[target])
game2.PrivateServerId='guid-1'; assert(D.Arrive(target,saved) and runtime[target].Mode=='Dungeon')
saved.DungeonTicket.Token='invalid'; assert(not D.Arrive(target,saved) and target.Kicked)
game2.PrivateServerId=''; runtime[target].Mode='World'; studio=true; started=false
D.Enter(target); assert(runtime[target].Mode=='Dungeon' and started and profile.Data[target])
D.Exit(target); assert(runtime[target].Mode=='World')
print('PASS: reserved-server ticket, durable release, failed-teleport recovery, invalid arrival rejection and Studio local fallback.')
