--ItemSourceCtrl.lua
require "resource.script.server.World.Item.ItemConfigCtrl"

ItemSourceCtrl = {}

function ItemSourceCtrl:New()
	local object = setmetatable({},self)
	self.__index = self
	return object
end

--����������Դ
function ItemSourceCtrl:getItemResource(itemID,itemNum)
	if itemID == ResourceType.DIAMOND then
		local value = self.playerDiamond + itemNum
		self:set_playerDiamond(value)
	elseif itemID == ResourceType.COPPER then
		local value = self.playerCopper + itemNum
		self:set_playerCopper(value)
	end
	return 2		--������Դ
end


--��ȡ������Դ������
function ItemSourceCtrl:getResourceSum(itemID)
	if itemID == ResourceType.DIAMOND then
		return self.playerDiamond
	elseif itemID == ResourceType.COPPER then
		return self.playerCopper
	end
end

--�۳�������Դ
function ItemSourceCtrl:deductItemResource(itemID,itemNum)
	if itemID == ResourceType.DIAMOND then
		 if self:subPlayerDiamond(itemNum) then
		 	return 1
		 else 
		 	return 0
		 end
	elseif itemID == ResourceType.COPPER then
		if self:subPlayerCopper(itemNum) then
			return 1
		else 
		 	return 0
	    end
	end
end