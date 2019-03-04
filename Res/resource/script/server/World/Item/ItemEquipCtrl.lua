--ItemEquipCtrl.lua

require "resource.script.server.World.Item.ItemEquip"
require "resource.script.server.World.Item.ItemConfigCtrl"

ItemEquipCtrl = {}

function ItemEquipCtrl:New()
	local object = setmetatable({},self)
    self.__index = self
    return object
end

--发送装备
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

--生成装备
function ItemEquipCtrl:getItemEquip(itemID,itemNum)
    local itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    local maxNum = itemCfg.itemMaxNumber
    for dbid,item in pairs(self.itemEquipList) do
        if item.itemID == itemID then
            if item.itemNumber + itemNum < maxNum then
                item.itemNumber = item.itemNumber + itemNum
                self:SendFlushItemNumber(item.databaseID,item.itemNumber)
                return 3 -- 装备叠加
            else
                item.itemNumber = maxNum
                self:SendFlushItemNumber(item.databaseID,item.itemNumber)
                return 3 --装备叠加
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
    return 2 -- 生成装备
end

--扣除装备
function ItemEquipCtrl:deductItemEquip(itemID,itemNum)
	for dbid, item in pairs(self.itemEquipList) do
		if item.itemID == itemID then
			if itemNum < item.itemNumber then
				item.itemNumber = item.itemNumber - itemNum	
				self:SendFlushItemNumber(item.databaseID,item.itemNumber)
				return 3   				--扣除成功
			else 
				if item.itemBagNum > 0 then
					item.itemNumber = 0
					self:SendFlushItemNumber(item.databaseID,item.itemNumber)
					return 3   				--扣除成功
				else 
					self:deleteItem(item)
					return 4				--删除成功
				end
			end
		end
	end
end

--生成背包装备
function ItemEquipCtrl:getItemBagEquip(itemID,bagNum)
 	local itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    local maxNum = itemCfg.itemMaxNumber
    for dbid,item in pairs(self.itemEquipList) do 
        if item.itemID == itemID  then
            if(item.itemBagNum + itemNum < maxNum) then
                item.itemBagNum = item.itemBagNum + itemNum
			 	self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
				return 3--物品叠加 
            else
				item.itemBagNum = maxNum
				self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
				return 3--物品叠加 
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
    return 2    --生成道具
end

--扣除背包道具
function ItemEquipCtrl:deductBagEquip()
	for dbid, item in pairs(self.itemEquipList) do
		if item.itemID == itemID then
			if itemNum < item.itemBagNum then
				item.itemBagNum = item.itemBagNum - itemNum	
				self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
				return 3   				--扣除成功
			else 
				if item.itemNumber > 0 then
					item.itemBagNum = 0
					self:SendFlushBagNumber(item.databaseID,item.itemBagNum)
					return 3   				--扣除成功
				else 
					self:deleteItem(item)
					return 4				--删除成功
				end
			end
		end
	end
end

--出征从仓库携带物品到背包
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
