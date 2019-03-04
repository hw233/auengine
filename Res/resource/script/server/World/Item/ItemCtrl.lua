--ItemCtrl.lua

require "resource.script.server.World.Item.ItemPropCtrl"
require "resource.script.server.World.Item.ItemEquipCtrl"
require "resource.script.server.World.Item.ItemSourceCtrl"
require "resource.script.server.World.Item.ItemUseCtrl"

--全局函数
local pairs = pairs
local table_insert = table.insert

ItemCtrl = {}

function ItemCtrl:New()
    local object = setmetatable({},self)
    self.__index = self
	
    return object
end

--同时刷新仓库和背包数量
function ItemCtrl:FlushItemNum(itemDBID,num,bagNum)
	 Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FLUSH_ITEM_NUM)
	Au.addUint32(itemDBID)
	Au.addUint32(num)
	Au.addUint32(bagNum)
	Au.messageEnd()
end

--刷新物品仓库数量
function ItemCtrl:SendFlushItemNumber(itemDBID,num)
    Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FLUSH_NUMBER)
	Au.addUint32(itemDBID)
	Au.addUint32(num)
	Au.messageEnd()
end

--删除物品
function ItemCtrl:RemoveItem(databaseID)
	Au.messageToClientBegin(self.playerID,MacroMsgID.MSG_ID_ITEM_DELETE)
    Au.addUint32(databaseID)
    Au.messageEnd()
end

--生成物品
function ItemCtrl:getItem(itemID,itemNum)
    if isEmpty(itemID) then	
        return 0
    end
    if(getTableLength(self.itemPropList) + getTableLength(self.itemEquipList) >= self.itemMaxNum) then	
        return 0
    end
    local tmpValue = 0
    local tmpType = 0
    local tmpSum = 0
    if ItemConfigCtrl:IsResource(itemID) then 				--特殊资源
    	tmpValue = self:getItemResource(itemID,itemNum)
    	tmpType = ItemType.Item_Prop
    	tmpSum = self:getItemSum(itemID)
    elseif ItemConfigCtrl:IsProp(itemID) then				--道具
    	tmpValue = self:getItemProp(itemID,itemNum)
    	tmpType = ItemType.Item_Prop
    	tmpSum = self:getItemSum(itemID)
    elseif ItemConfigCtrl:IsEquip(itemID) then				--装备
    	tmpValue = self:getItemEquip(itemID,itemNum)
    	tmpType = ItemType.Item_Equip
    	tmpSum = self:getItemSum(itemID)
    end
    TaskBase:completeItemTask(self, tmpType, tmpSum)
    return tmpValue
end

--获取物品总数量
function ItemCtrl:getItemSum(itemID)
	if isEmpty(itemID) then								--错误
		return 0									
	end
    local itemSum = 0
	if ItemConfigCtrl:IsResource(itemID) then			--特殊资源
		itemSum = self:getResourceSum(itemID)
	elseif ItemConfigCtrl:IsProp(itemID) then 
		for dbid, prop in pairs(self.itemPropList) do
			if(prop.itemID == itemID) then
				itemSum = prop.itemNumber
				return itemSum
			end
		end
	elseif ItemConfigCtrl:IsEquip(itemID) then
		for dbid, equip in pairs(self.itemEquipList) do
			if(equip.itemID == itemID) then
				itemSum = equip.itemNumber
				return itemSum
			end
		end
	end
	return itemSum
end

--扣除物品
function ItemCtrl:deductItem(itemID,itemNum)
	if isEmpty(itemID) then								--错误
		return 0									
	end
	if itemNum <= 0 then								--错误
		return 0
	end
	if self:IsItemExist(itemID) == false then		--物品不存在
		sendSystemMsg(self.playerID, "物品不存在")
		return 0  									
	end
	if self:getItemSum(itemID) < itemNum then
		return 0 
	end
	if ItemConfigCtrl:IsResource(itemID) then 				--特殊资源
    	return self:deductItemResource(itemID,itemNum)
	elseif ItemConfigCtrl:IsProp(itemID) then				--道具
		return self:deductItemProp(itemID,itemNum)
	elseif ItemConfigCtrl:IsEquip(itemID) then				--装备
		return self:deductItemEquip(itemID,itemNum)
	end
	return 0
end

--直接修改某个物品数量
function ItemCtrl:modifyItemNum(itemID,itemNum)
	if itemNum < 0 then
		return false
	end
	for dbid,item in paris(self.itemPropList) do
		if itemID == item.itemID then
			item.itemNumber = itemNum
			self:SendFlushItemNumber(item.databaseID,item.itemNumber)
			return true
		end
	end
	return false
end

--删除物品
function ItemCtrl:deleteItem(itemObject)
    if isEmpty(itemObject) then
    	sendSystemMsg(self.playerID, "空值")
         return 0
    end
    itemObject:RemoveItemFromDB()
    if ItemConfigCtrl:IsEquip(itemObject.itemID) then
        self.itemEquipList[itemObject.databaseID] = nil
    elseif ItemConfigCtrl:IsProp(itemObject.itemID) then
        self.itemPropList[itemObject.databaseID] = nil
    end
    self:RemoveItem(itemObject.databaseID)
end

--出售物品
function ItemCtrl:SaleItem(itemID,itemNum)
	if isEmpty(itemID) then 
		return 0
	end
	local sale = ItemConfigCtrl:getItemSell(itemID)			--售价
	local sum = self:getItemSum(itemID)
	if itemNum <= sum then
		self:getItem(ResourceType.COPPER,itemNum*sale)
	else
		self:getItem(ResourceType.COPPER,sum*sale)
	end
	self:deductItem(itemID,itemNum)
end

--返回玩家身上的装备列表
function ItemCtrl:GetEquipList()
	local equipList = {}
	for dbid, equip in pairs(self.itemEquipList) do
		if equip.itemPosition == ItemPosition.Position_Player then
			table.insert(equipList,equip)
		end
	end
	return equipList
end

--装备等级是否正确
function ItemCtrl:IsEquipRight(itemID,level)
	if isEmpty(itemID) then
		return false
	end
	if ItemConfigCtrl:IsEquip(itemID) then
		for __,equip in pairs(self.itemEquipList) do
			if equip.itemID == itemID then
				if level <= equip.itemStrengthenLevel then
					return true
				else 
					return false
				end
			end
		end
	end
	return false
end

--穿戴装备
function ItemCtrl:DressEquip(equip)
	if ItemConfigCtrl:IsEquip(equip.itemID) then
		equip.itemPosition = ItemPosition.Position_Player
	end
end

function ItemCtrl:DressItemEquip(itemID)
	if isEmpty(itemID) then
		return
	end
	if ItemConfigCtrl:IsEquip(itemID) then
		for dbid,equip in pairs(self.itemEquipList) do
			if equip.itemID == itemID then
				equip.itemPosition = ItemPosition.Position_Player
				self:SendItemEquipToClient(equip)			--客户端同步更新数据
				return 1
			end
		end
	end
end

--装备属性值的添加操作
function ItemCtrl:GetEquitValue()
	local playerEquitTB = self:GetEquipList()--保存玩家身上的装备
	for __,propID in pairs(ItemEquipPropertyType) do
		self.equitPropList[propID] = 0
	end
	--装备属性添加
	for i=1,table.getn(playerEquitTB) do
		local playerEquit = playerEquitTB[i]
		local propertyList = ItemConfigCtrl:getItemProperty(playerEquit.itemID)
		for j=1,table.getn(propertyList) do
			local property = propertyList[j]
			local propID = property[1]
			local propValue = property[2] + playerEquit.itemStrengthenLevel*property[3]
			if not isEmpty(self.equitPropList[propID]) then
				self.equitPropList[propID] = self.equitPropList[propID] + propValue
			else
				self.equitPropList[propID] = propValue
			end
		end
	end
	
--	self.leadObject:updateHeroProp(self.equitPropList)
end

--强化@itemDBID 装备databaseID @return 无
function ItemCtrl:OnEquitLevelUp(itemDBID)
	local _equitItem = self.itemEquipList[itemDBID]
	if isEmpty(_equitItem) then
		return
	end
	if ItemConfigCtrl:IsEquip(_equitItem.itemID) == false then
		return
	end
	local maxItemLevel = ItemConfigCtrl:getItemMaxStrengthenLevel(_equitItem.itemID)--装备最高强化等级
	if _equitItem.itemStrengthenLevel >= maxItemLevel then
		return
	end
	local lvUp = _equitItem.itemStrengthenLevel--强化多少级
	local useCfg = ItemConfigCtrl:getStrengthenUse(_equitItem.itemQuality, lvUp + 1)
	if self:checkOutAndTakeawaySource(useCfg) == false then
		sendSystemMsg(self.playerID, "资源不足")
		return
	end
	lvUp = lvUp + 1
	_equitItem.itemStrengthenLevel = lvUp
	self:GetEquitValue()--进行属性加成操作
	
	self:sendStrengthSucessToClient(_equitItem.databaseID, _equitItem.itemStrengthenLevel)
	TaskBase:completeOnEquitLevelUp(self, _equitItem.itemID, _equitItem.itemStrengthenLevel)
	print("强化后", lvUp,_equitItem.itemStrengthenLevel)
end

--进阶
function ItemCtrl:OnEquitMoveForward( itemDBID )
	-- body
	local _equitItem = self.itemEquipList[itemDBID]
	if isEmpty(_equitItem) then
		return
	end
	local advanceCfg = ItemConfigCtrl:getAdvanceCfg(_equitItem.itemID)
	if isEmpty(advanceCfg) then
		return
	end
	if advanceCfg["ISADVANCE"] == 0 then
		sendSystemMsg(self.playerID, "该装备不可进阶")
		return
	end
	if _equitItem.itemStrengthenLevel < advanceCfg["STRENGTHEN"] then
		sendSystemMsg(self.playerID, "该装备强化等级不足不可进阶")
		return
	end
	if self.playerLevel < advanceCfg["ADVANCElEVEL"] then
		sendSystemMsg(self.playerID,"玩家等级不够")
		return 
	end
	local useCfg = advanceCfg["USE"]
	if self:checkOutAndTakeawaySource(useCfg) == false then
		sendSystemMsg(self.playerID, "资源不足")
		return
	end
	local getEquitID = advanceCfg["ADVANCEEQUIT"]
	self:deleteItem(_equitItem)
	self:getItem(getEquitID,1)
	self:DressItemEquip(getEquitID)
	self:GetEquitValue()
	self:sendAdanceSuccessToClient(getEquitID)
end

--道具合成操作
function ItemCtrl:PropCompound(propID)
	local propCfg = ItemConfigCtrl:getPropCfg(propID)
	local itemCfg = ItemConfigCtrl:getItemCfg(propID)
	if isEmpty(propCfg) or isEmpty(itemCfg) then
		return 
	end
	
	if self:CheckPropCondition(propCfg) == false then
		return 
	end
	
	local maxNum = itemCfg.itemMaxNumber
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
function ItemCtrl:CheckPropCondition(propCfg)
	local isBool = true
	local preCondition = propCfg["CONDITION"]
	for _, preTB in pairs(preCondition) do
		if not self:checkPrecondition(preTB) then
			isBool = false
		end
	end
	return isBool
end

function ItemCtrl:sendStrengthSucessToClient( itemDBID, itemLevel )
	-- body
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_EQUIT_STRENGTHEN)
	Au.addUint32(itemDBID)
	Au.addUint8(itemLevel)
	Au.messageEnd()
end

function ItemCtrl:sendAdanceSuccessToClient( equipID )
	-- body
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_EQUIT_ADVANCE)
	Au.addUint32(equipID)
	Au.messageEnd()
end

function ItemCtrl:buyItem(itemID,itemNum)
	local tradeCfg = ItemConfigCtrl:getTradeCfg(itemID)
	if isEmpty(tradeCfg) then
		return 
	end
	local cost = tradeCfg["COST"]
	if self:checkOutAndTakeawaySource(cost) == false then
		sendSystemMsg(self.playerID, "资源不足")
		return
	end
	self:getItem(itemID,itemNum)
	self:SendTradeItemToClient(itemID)
end

function ItemCtrl:SendTradeItemToClient(itemID)
	Au.messageToClientBegin(self.playerID, MacroMsgID.Msg_ID_ITEM_TRADE)
	Au.addUint32(itemID)
	Au.messageEnd()
end

