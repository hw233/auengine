--ItemEquipCtrl.lua

require "resource.script.server.World.Item.ItemEquip"
require "resource.script.server.World.Item.ItemConfigCtrl"

ItemEquipCtrl = {}

function ItemEquipCtrl:New()
	local object = setmetatable({},self)
    self.__index = self
    return object
end

--����װ��
function ItemEquipCtrl:SendItemEquipToClient(item)
    if isEmpty(item) then
        return 0
    end
    Au.messageToClientBegin(self.playerID,MacroMsgID.MSG_ID_ITEM_EQUIP_SEND)
    Au.addUint32(item.databaseID)
    Au.addUint32(item.itemID)
    Au.addUint8(item.itemQuality)
    Au.addUint32(item.itemNumber)
    Au.addUint32(item.itemBagNum)
    Au.addUint16(item.itemStrengthenLevel)
     Au.addUint8(item.itemPosition)
    Au.messageEnd()
end

--����װ��
function ItemEquipCtrl:getItemEquip(itemID,itemNum)
    local itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    local maxNum = itemCfg.itemMaxNumber
    for dbid,item in pairs(self.itemEquipList) do
        if item.itemID == itemID then
            if item.itemNumber + itemNum < maxNum then
                item.itemNumber = item.itemNumber + itemNum
                self:SendFlushItemNumber(item.databaseID,item.itemNumber)
                return 3 -- װ������
            else
                item.itemNumber = maxNum
                self:SendFlushItemNumber(item.databaseID,item.itemNumber)
                return 3 --װ������
            end
        end
    end
    local lastNum = 0
    if itemNum < maxNum then
    	lastNum = itemNum
    else 
    	lastNum = maxNum
    end
    local itemObject = ItemEquip:CreateItem(self.databaseID,itemID,itemCfg.itemQuality,lastNum,0,0,0)
    self:DressEquip(itemObject)
    self.itemEquipList[itemObject.databaseID] = itemObject
    self:SendItemEquipToClient(itemObject)
    return 2 -- ����װ��
end

--�۳�װ��
function ItemEquipCtrl:deductItemEquip(itemID,itemNum)
	for dbid, item in pairs(self.itemEquipList) do
		if item.itemID == itemID then
			if itemNum < item.itemNumber then
				item.itemNumber = item.itemNumber - itemNum	
				self:SendFlushItemNumber(item.databaseID,item.itemNumber)
				return 3   				--�۳��ɹ�
			else 
				if item.itemBagNum > 0 then
					item.itemNumber = 0
					self:SendFlushItemNumber(item.databaseID,item.itemNumber)
					return 3   				--�۳��ɹ�
				else 
					self:deleteItem(item)
					return 4				--ɾ���ɹ�
				end
			end
		end
	end
end

--���ɱ���װ��
function ItemEquipCtrl:getItemBagEquip(itemID,bagNum)
 	local itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    local maxNum = itemCfg.itemMaxNumber
    for dbid,item in pairs(self.itemEquipList) do 
        if item.itemID == itemID  then
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
    local itemObject = ItemEquip:CreateItem(self.databaseID,itemID,itemCfg.itemQuality,0,lastNum,0,0)	
    self.itemEquipList[itemObject.databaseID] = itemObject
    self:SendItemEquipToClient(itemObject)
    return 2    --���ɵ���
end

--�۳���������
function ItemEquipCtrl:deductBagEquip()
	for dbid, item in pairs(self.itemEquipList) do
		if item.itemID == itemID then
			if itemNum < item.itemBagNum then
				item.itemBagNum = item.itemBagNum - itemNum	
				self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
				return 3   				--�۳��ɹ�
			else 
				if item.itemNumber > 0 then
					item.itemBagNum = 0
					self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
					return 3   				--�۳��ɹ�
				else 
					self:deleteItem(item)
					return 4				--ɾ���ɹ�
				end
			end
		end
	end
end

--�����Ӳֿ�Я����Ʒ������
function ItemEquipCtrl:CarryBagEquip(itemID,itemNum)
    for dbid,item in pairs(self.itemEquipList) do
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
