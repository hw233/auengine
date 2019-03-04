-- ShopBuyBase.lua
require "resource.script.server.Config.Shop.SHOPITEMS"

ShopBuyBase = {}

--读取商城物品配置
function ShopBuyBase:readShopCfgByIdx(idx)
	local ID = "ID_"..idx
	return SHOPITEMS[ID]
end