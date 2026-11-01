local P = {}
function P.Required(level) return math.floor(90 + level*28 + level*level*.65) end
function P.MaxHP(level) return 110+(level-1)*8 end
function P.New() return {Version=1,Level=1,XP=0,Gold=0,Floor=1,Unlocked=1,Owned={gear_01_1=true},Equipped="gear_01_1",Bosses={},Kills=0} end
function P.Grant(data,xp,gold)
 data.Gold=data.Gold+gold
 data.XP=data.XP+xp
 local previous=data.Level
 while data.Level<100 and data.XP>=P.Required(data.Level) do
  data.XP=data.XP-P.Required(data.Level); data.Level=data.Level+1
 end
 if data.Level==100 then data.XP=0 end
 return data.Level>previous
end
function P.CanTravel(data,floor,config)
 return type(floor)=="number" and floor==math.floor(floor) and config.Floors[floor]~=nil
  and floor<=data.Unlocked and data.Level>=config.Floors[floor].MinLevel
end
function P.Buy(data,id,config)
 local item=config.Items[id]
 if not item then return false,"Equipamento inexistente." end
 if data.Owned[id] then return false,"Este equipamento já é seu." end
 if data.Level<item.Level then return false,"Requer nível "..item.Level end
 if data.Gold<item.Price then return false,"Cristais insuficientes." end
 data.Gold=data.Gold-item.Price; data.Owned[id]=true
 return true,"Equipamento adquirido."
end
return P
