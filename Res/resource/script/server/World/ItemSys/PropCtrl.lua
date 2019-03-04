--PropCtrl.lua

PropCtrl = {}

function PropCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	obj.propDBIDList = {}         --道具databaseID列表
	
	return obj
end

--创建道具物品
function PropCtrl:ceatePropItem(playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
	 local databaseID = Au.getDatateID("tb_ItemProp")
	 local _prop = ItemSysBase:createItem(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
	return _prop
end

--生成仓库道具
function PropCtrl:getItemProp( itemID, itemNum )
	local propCfg = ItemSysBase:readPropCfg(itemID)
	local maxNum = propCfg["MAXNUM"]
	local propNum = itemNum
	if itemNum >= maxNum then
		propNum = maxNum
	end
	
	local propDBID = self.propDBIDList[itemID]
	local propObj = self.itemPropList[propDBID]    --获取道具对象
	if isEmpty(propObj) then
		local _prop = self:ceatePropItem(self.databaseID, itemID, propCfg["QUALITY"], propNum, 0, 0)   
		self.itemPropList[_prop.databaseID] = _prop
		self.propDBIDList[_prop.itemID] = _prop.databaseID
		self:SendItemPropToClient(_prop)      --生成新道具通知客户端
		return true
	end
	
	propObj.itemNumber = propObj.itemNumber + propNum    --数量累加 
	if propObj.itemNumber > maxNum then
		propObj.itemNumber = maxNum 
	end
--刷新数量
	self:SendFlushItemNumber(propObj.databaseID, propObj.itemNumber)
	return true
end

--生成背包道具
function PropCtrl:getBagProp( itemID, itemNum )
	local propCfg = ItemSysBase:readPropCfg(itemID)
	local maxNum = propCfg["MAXNUM"]
	local propNum = itemNum
	if itemNum >= maxNum then
		propNum = maxNum
	end
	
	local propDBID = self.propDBIDList[itemID]
	local propObj = self.itemPropList[propDBID]    --获取道具对象
	if isEmpty(propObj) then
		local _prop = self:ceatePropItem(self.databaseID, itemID, propCfg["QUALITY"], 0, propNum, 0) 
		self.itemPropList[_prop.databaseID] = _prop
		self.propDBIDList[_prop.itemID] = _prop.databaseID
		self.bagItemList[_prop.itemID] = _prop.databaseID
		self:SendItemPropToClient(_prop)      --生成新道具通知客户端
		return true
	end
	
	propObj.itemBagNum = propObj.itemBagNum + propNum    --数量累加 
	if propObj.itemBagNum > maxNum then
		propObj.itemBagNum = maxNum 
	end
	self.bagItemList[propObj.itemID] = propObj.databaseID
	
--刷新背包数量
	self:SendFlushBagNumber(propObj.databaseID, propObj.itemBagNum)
	return true
end

--消耗仓库道具
function PropCtrl:deductItemProp( itemID, itemNum )
	local propDBID = self.propDBIDList[itemID]
	local propObj = self.itemPropList[propDBID]
	if isEmpty(propObj) then
		return false
	end
	
	if itemNum > propObj.itemNumber then
		return false
	end
	
	propObj.itemNumber = propObj.itemNumber - itemNum         -- 扣除道具
	self:SendFlushItemNumber(propObj.databaseID, propObj.itemNumber)  --通知客户端
	self:deleteItem( propObj )
	
	return true
end

--消耗背包道具
function PropCtrl:deductBagProp( itemID, itemNum )
	local propDBID = self.bagItemList[itemID]
	local propObj = self.itemPropList[propDBID]
	if isEmpty(propObj) then
		return false
	end
	
	if itemNum > propObj.itemBagNum then
		return false
	end
	
	propObj.itemBagNum = propObj.itemBagNum - itemNum         -- 扣除道具
	self:SendFlushBagNumber(propObj.databaseID, propObj.itemBagNum)  --通知客户端
	if self:deleteItem(propObj) == false then
		if propObj.itemBagNum <= 0 then
			self.bagItemList[itemID] = nil
		end
	end
	
	return true

end
	
--删除道具
function PropCtrl:deleteItem ( itemObj )
	if itemObj.itemNumber == 0 and itemObj.itemBagNum == 0 then   --(仓库和背包数量都为0时删除)
		local itemDatabaseID = itemObj.databaseID
		self.propDBIDList[itemObj.itemID] = nil
		self.itemPropList[itemDatabaseID] = nil
		self.bagItemList[itemObj.itemID] = nil
		itemObj:RemoveItemFromDB()
		self:SendRemoveItemToClient(itemDatabaseID)   --通知客户端删除物品
		return true
	end
	
	return false
end

--出售仓库道具
function PropCtrl:saleProp( itemID, itemNum )
	local itemCfg = ItemSysBase:readPropCfg(itemID)
	if isEmpty(itemCfg) then
		return false
	end
	local price = itemCfg["PRICE"]
	if price <= 0 then
		return false
	end
	
	local propDBID = self.propDBIDList[itemID]
	local propObj = self.itemPropList[propDBID]
	if isEmpty(propObj) then
		return false
	end
	if itemNum > propObj.itemNumber then
		return false
	end
	
	propObj.itemNumber = propObj.itemNumber - itemNum
	price = self.playerCopper + itemNum * price
	self:set_playerCopper(price)
	self:SendFlushItemNumber(propObj.databaseID, propObj.itemNumber)  --通知客户端
	self:deleteItem( propObj )
	return true
end

--仓库道具放到背包
function PropCtrl:CarryBagProp(itemID, itemNum)
	local itemDBID = self.bagItemList[itemID]
	local itemObj = self.itemPropList[itemDBID]
	if isEmpty(itemObj) then
		itemDBID = self.propDBIDList[itemID]
		itemObj = self.itemPropList[itemDBID]
		if isEmpty(itemObj) then
			return false
		end
	end
	
	if itemNum > itemObj.itemNumber  then
		itemNum = itemObj.itemNumber
	end
	itemObj.itemNumber = itemObj.itemNumber - itemNum
	itemObj.itemBagNum = itemNum
	self.bagItemList[itemObj.itemID] = itemObj.databaseID
	self:FlushItemNum(itemObj.databaseID,itemObj.itemNumber,itemObj.itemBagNum)
	return true
end

--发送道具
function PropCtrl:SendItemPropToClient(item)
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

--删除道具通知
function PropCtrl:SendRemoveItemToClient(databaseID)
	Au.messageToClientBegin(self.playerID,MacroMsgID.MSG_ID_ITEM_DELETE)
    Au.addUint32(databaseID)
    Au.messageEnd()
end

--道具合成操作
function PropCtrl:PropCompound(propID)
	local propCfg = ItemSysBase:getPropCfg(propID)
	local itemCfg = ItemSysBase:readPropCfg(propID)
	if isEmpty(propCfg) or isEmpty(itemCfg) then
		return 
	end
	
	if self:CheckPropCondition(propCfg) == false then
		return 
	end
	
	local maxNum = itemCfg["MAXNUM"]
	local propSum = self:getItemSum(propID)
	if propSum >= maxNum then
		return 
	end
	
	local useCfg = propCfg["USE"]
	if	not self:checkOutAndTakeawaySource(useCfg) then
		return 
	end
	
--生成物品
	local itemNum = propCfg["OUTPUT"]
	self:getItem(propID, itemNum)
--回复客户端
	Au.messageToClientBegin(self.playerID, MacroMsgID.Msg_ID_NEW_PROPCOMPOUND)
	Au.addUint32(propID)
	Au.messageEnd()
end

--检测道具开放前置条件
function PropCtrl:CheckPropCondition(propCfg)
	local isBool = true
	local preCondition = propCfg["CONDITION"]
	for _, preTB in pairs(preCondition) do
		if not self:checkPrecondition(preTB) then
			isBool = false
		end
	end
	return isBool
end

--判断物品总数与给定值大小
function PropCtrl:IsItemEqualToValue(itemID,itemNum)
	local itemSum = self:getItemSum(itemID)
	if(itemSum >= itemNum) then
		return true
	end
	return false
end