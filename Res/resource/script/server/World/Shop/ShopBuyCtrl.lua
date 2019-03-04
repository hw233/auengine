-- ShopBuyCtrl.lua
require "resource.script.server.World.Shop.ShopBuyBase"

--全局函数
local pairs = pairs


ShopBuyCtrl = {}

function ShopBuyCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.buyStatu = 0         -- 一次性物品状态
	
	return obj
end

--上线发送一次性物品状态位
function ShopBuyCtrl:sendBuyStatu()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_SHOP_SEN_BUYSTATU)
	Au.addUint32(self.buyStatu)        -- 状态位
	Au.messageEnd()
end

--购买物品
function ShopBuyCtrl:buyShopItem(itemIdx, num)
	local itemCfg = ShopBuyBase:readShopCfgByIdx(itemIdx)
	if isEmpty(itemCfg) or num == 0 or num == nil then
		return
	end
	
	local itemNum = num
	if self:checkOpenCondition(itemCfg) == false then
		return
	end
	
--购买的是否一次性物品
	local flag = itemCfg["ITEMFLAG"]
	if flag == 1 then
		if Au.bitCheckState(self.buyStatu, itemIdx) == 1 then
			return
		end
		
		self.buyStatu = Au.bitAddState(self.buyStatu, itemIdx)
		itemNum = 1
	end
	
--消耗金币
	local money = itemCfg["USE"][1][3]*itemNum
	if self:subPlayerCopper(money) == false then
		return
	end
	
--生成物品
	local itemList = itemCfg["GETITEM"]
	for i = 1, itemNum do
		self:createItemList(itemList)
	end
	
--回复客户端
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_SHOP_BUY_ITEM)
	Au.addUint32(self.buyStatu) --状态位
	Au.addUint8(itemIdx)   --物品编号	
	Au.addUint16(itemNum)   --数量
	Au.messageEnd()
	
end

--检测物品是否开放
function ShopBuyCtrl:checkOpenCondition(itemCfg)
	local isBool = true
	local preCondition = itemCfg["CONDITION"]
	for _, preTB in pairs(preCondition) do
		if self:checkPrecondition(preTB) == false then
			isBool = false
		end
	end
	
	return isBool
end



--客户端API
--购买物品
function World_ShopBuyCtrl_buyShopItem(playerID ,itemIdx, num)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	_player:buyShopItem(itemIdx, num)

end