-- ShopBuyCtrl.lua
require "resource.script.server.World.Shop.ShopBuyBase"

--ȫ�ֺ���
local pairs = pairs


ShopBuyCtrl = {}

function ShopBuyCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.buyStatu = 0         -- һ������Ʒ״̬
	
	return obj
end

--���߷���һ������Ʒ״̬λ
function ShopBuyCtrl:sendBuyStatu()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_SHOP_SEN_BUYSTATU)
	Au.addUint32(self.buyStatu)        -- ״̬λ
	Au.messageEnd()
end

--������Ʒ
function ShopBuyCtrl:buyShopItem(itemIdx, num)
	local itemCfg = ShopBuyBase:readShopCfgByIdx(itemIdx)
	if isEmpty(itemCfg) or num == 0 or num == nil then
		return
	end
	
	local itemNum = num
	if self:checkOpenCondition(itemCfg) == false then
		return
	end
	
--������Ƿ�һ������Ʒ
	local flag = itemCfg["ITEMFLAG"]
	if flag == 1 then
		if Au.bitCheckState(self.buyStatu, itemIdx) == 1 then
			return
		end
		
		self.buyStatu = Au.bitAddState(self.buyStatu, itemIdx)
		itemNum = 1
	end
	
--���Ľ��
	local money = itemCfg["USE"][1][3]*itemNum
	if self:subPlayerCopper(money) == false then
		return
	end
	
--������Ʒ
	local itemList = itemCfg["GETITEM"]
	for i = 1, itemNum do
		self:createItemList(itemList)
	end
	
--�ظ��ͻ���
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_SHOP_BUY_ITEM)
	Au.addUint32(self.buyStatu) --״̬λ
	Au.addUint8(itemIdx)   --��Ʒ���	
	Au.addUint16(itemNum)   --����
	Au.messageEnd()
	
end

--�����Ʒ�Ƿ񿪷�
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



--�ͻ���API
--������Ʒ
function World_ShopBuyCtrl_buyShopItem(playerID ,itemIdx, num)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	_player:buyShopItem(itemIdx, num)

end