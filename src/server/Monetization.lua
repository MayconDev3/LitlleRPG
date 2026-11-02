-- Entrega fixa e durável. Nenhuma oferta paga pode conceder raridade 7.
local Marketplace=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local C=require(game.ReplicatedStorage.LittleRPG.Config)
local P=require(game.ReplicatedStorage.LittleRPG.Progression)
local M={}
function M.Start(profiles,sync,notice)
 local offers={}
 for _,offer in ipairs(C.Products) do
  assert(offer.Rarity<=6,"Ultra lendária não pode ser vendida por Robux")
  if offer.ProductId>0 then assert(not offers[offer.ProductId],"ProductId duplicado"); offers[offer.ProductId]=offer end
 end
 Marketplace.ProcessReceipt=function(receipt)
  local pending=Enum.ProductPurchaseDecision.NotProcessedYet
  local player=Players:GetPlayerByUserId(receipt.PlayerId); local offer=offers[receipt.ProductId]
  if not player or not offer or profiles.Temporary or profiles.Travel[player] or profiles.Closing[player] or profiles.ReceiptBusy[player] then return pending end
  local d=profiles.Data[player]; if not d then return pending end
  profiles.ReceiptBusy[player]=true
  local ok,result=pcall(function()
   if not d.Receipts[receipt.PurchaseId] then
    local weapon=P.AddWeapon(d,offer.Blueprint,offer.Rarity)
    if not weapon then notice(player,"Libere espaço na mochila; sua compra será entregue depois."); return pending end
    d.Receipts[receipt.PurchaseId]=true
   end
   if not profiles.Save(player,false) then return pending end
   sync(player); notice(player,"Compra confirmada: "..offer.Name)
   return Enum.ProductPurchaseDecision.PurchaseGranted
  end)
  profiles.ReceiptBusy[player]=nil
  if not ok then warn("LittleRPG receipt failed",result); return pending end
  return result
 end
end
return M
