-- ShopBuyBase.lua
require "resource.script.server.Config.Shop.SHOPITEMS"

ShopBuyBase = {}

--��ȡ�̳���Ʒ����
function ShopBuyBase:readShopCfgByIdx(idx)
	local ID = "ID_"..idx
	return SHOPITEMS[ID]
end