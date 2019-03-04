--ItemPropCtrl.lua

require "resource.script.server.World.Item.ItemProp"
require "resource.script.server.World.Item.ItemConfigCtrl"

ItemPropCtrl = {}

function ItemPropCtrl:New()
	local object = setmetatable({},self)
    self.__index = self
    return object
end

--���͵���
function ItemPropCtrl:SendItemPropToClient(item)
    if(isEmpty(item)) then
        return 0
    end
    Au.messageToClientBegin(self.playerID,MacroMsgID.MSG_ID_ITEM_PROP_SEND)
    Au.addUint32(item.databaseID)
    Au.addUint32(item.itemID)
    Au.addUint8(item.itemQuality)
    Au.addUint32(item.itemNumber)
    Au.addUint32(item.itemBagNum)
    Au.addUint8(item.itemPosition)
    Au.messageEnd()
end

--���ɵ���
function ItemPropCtrl:getItemProp(itemID,itemNum)
    local itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    local maxNum = itemCfg.itemMaxNumber
    for dbid,item in pairs(self.itemPropList) do 
        if item.itemID == itemID  then
            if(item.itemNumber + itemNum < maxNum) then
                item.itemNumber = item.itemNumber + itemNum
			 	self:SendFlushItemNumber(item.databaseID,item.itemNumber)
				return 3--��Ʒ���� 
            else
				item.itemNumber = maxNum
				self:SendFlushItemNumber(item.databaseID,item.itemNumber)
				return 3--��Ʒ���� 
            end
      	end
    end 
    local lastNum = 0
    if itemNum <= maxNum then
    	lastNum = itemNum
    else
    	lastNum = maxNum
    end
    local itemObject = ItemProp:CreateItem(self.databaseID,itemID,itemCfg.itemQuality,lastNum,0,0)	
    self.itemPropList[itemObject.databaseID] = itemObject
	
    self:SendItemPropToClient(itemObject)
    return 2    --���ɵ���
end

--�۳�����
function ItemPropCtrl:deductItemProp(itemID,itemNum)
	for dbid, item in pairs(self.itemPropList) do
		if item.itemID == itemID then
			if itemNum < item.itemNumber then
				item.itemNumber = item.itemNumber - itemNum	
				self:SendFlushItemNumber(item.databaseID,item.itemNumber)
				return 3   				--�۳��ɹ�
			else
				if item.itemBagNum > 0 then
					item.itemNumber = 0
					self:SendFlushItemNumber(item.databaseID,item.itemNumber)
					return 3  			--�۳��ɹ�
				else 			
					self:deleteItem(item)
					return 4				--ɾ���ɹ�
				end
			end
		end
	end	
end

--���ɱ�������
function ItemPropCtrl:getItemBagProp(itemID, itemNum)
 	local itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    local maxNum = itemCfg.itemMaxNumber
    for dbid,item in pairs(self.itemPropList) do
        if item.itemID == itemID then
            if(item.itemBagNum + itemNum < maxNum) then
                item.itemBagNum = item.itemBagNum + itemNum
			 	self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
				return 3--��Ʒ���� 
            else
				item.itemBagNum = maxNum
				self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
				return 3--��Ʒ���� 
            end
      	end
    end 
    local lastNum = 0
    if itemNum <= maxNum then
    	lastNum = itemNum
    else
    	lastNum = maxNum
    end
    local itemObject = ItemProp:CreateItem(self.databaseID,itemID,itemCfg.itemQuality,0,lastNum,0)	
    self.itemPropList[itemObject.databaseID] = itemObject
    self:SendItemPropToClient(itemObject)
    return 2    --���ɵ���
end

--�۳���������
function ItemPropCtrl:deductBagProp(itemID,itemNum)
	for dbid, bagItem in pairs(self.itemPropList) do
		if bagItem.itemID == itemID then
			if itemNum < bagItem.itemBagNum then
				bagItem.itemBagNum = bagItem.itemBagNum - itemNum	
				self:SendFlushBagNumber(bagItem.databaseID,bagItem.itemBagNum)
				return 3   				--�۳��ɹ�
			else
				if bagItem.itemNumber > 0 then
					bagItem.itemBagNum = 0
					self:SendFlushBagNumber(bagItem.databaseID,bagItem.itemBagNum)
					return 3  			--�۳��ɹ�
				else 			
					self:deleteItem(bagItem)
					return 4				--ɾ���ɹ�
				end
			end
		end
	end
end

--�����Ӳֿ�Я����Ʒ������
function ItemPropCtrl:CarryBagProp(itemID,itemNum)
    for dbid,item in pairs(self.itemPropList) do
        if item.itemID == itemID then
            if item.itemNumber <= itemNum then
                item.itemBagNum = item.itemNumber
                item.itemNumber = 0
			 	self:FlushItemNum(item.databaseID,item.itemNumber,item.itemBagNum)
				return true
            else
				item.itemBagNum = itemNum
				item.itemNumber = item.itemNumber - itemNum
				self:FlushItemNum(item.databaseID,item.itemNumber,item.itemBagNum)
				return true
            end
      	end
    end 
    return false
end
