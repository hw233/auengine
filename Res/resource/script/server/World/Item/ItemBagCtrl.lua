--ItemBagCtrl.lua

require "resource.script.server.World.Item.ItemPropCtrl"
require "resource.script.server.World.Item.ItemEquipCtrl"
require "resource.script.server.World.Item.ItemSourceCtrl"
require "resource.script.server.World.Item.ItemUseCtrl"

--全局函数
local pairs = pairs
local table_insert = table.insert

ItemBagCtrl = {}

function ItemBagCtrl:New()
	local object = setmetatable({},self)
	self.__index = self
	return object
end


--刷新背包物品数量
function ItemCtrl:SendFlushBagNumber(itemDBID,num)
    Au.messageToClientBegin(self.playerID, MacroMsgID.Msg_ID_ITEM_FLUSH_BAG)
	Au.addUint32(itemDBID)
	Au.addUint32(num)
	Au.messageEnd()
end

--批量生产背包物品(加上类型)
function ItemBagCtrl:createBagListWithType(bagList)
	local flag = true
	local temp = 0
	for __, itemTB in pairs(bagList) do
		local itemID = itemTB[2]
		local itemNum = itemTB[3]
		temp = self:getBagItem(itemID, itemNum)
		if temp ~= 2 and temp ~= 3 then
			flag = false
			break
		end
	end
	return flag
end

--批量生产背包物品
function ItemBagCtrl:createBagList(bagList)
	local flag = true
	for __, item in pairs(bagList) do
		local temp = 0
		temp = self:getBagItem(item[1],item[2])
		if temp ~= 2 and temp ~= 3 then
			flag = false
			break
		end
	end
	return flag
end

--生成背包物品
function ItemBagCtrl:getBagItem(itemID,bagNum)
	 if isEmpty(itemID) then	
        return 0
    end
    local curCapacity = self:getBagCapacity()
    local maxCapacity = self:getTravelKitCapacity(1)
    local curNum = maxCapacity - curCapacity
    if curNum <= 0 then
        return 0		--背包满
    end
    local weight = ItemConfigCtrl:getItemWeight(itemID)
    local itemNum = 0
    if bagNum*weight > curNum then
    	itemNum = NumberToInt(curNum/weight)
    else
    	itemNum = bagNum
    end
    if ItemConfigCtrl:IsResource(itemID) then			   --资源
    	return self:getItemResource(itemID,itemNum)
    elseif ItemConfigCtrl:IsProp(itemID) then					--道具
    	return self:getItemBagProp(itemID,itemNum)
    elseif ItemConfigCtrl:IsEquip(itemID) then				--装备
    	return self:getItemBagEquip(itemID,itemNum)
    end
end

--获取背包当前容量
function ItemBagCtrl:getBagCapacity()
	local bagCapacity = 0
	for dbid, prop in pairs(self.itemPropList) do
		if prop.itemBagNum > 0 then
			local weight = ItemConfigCtrl:getItemWeight(prop.itemID)
			bagCapacity = bagCapacity + weight*prop.itemBagNum
		end
	end
	return bagCapacity
end

--判定背包容量是否满
function ItemBagCtrl:IsBagFull()
	local curCapacity = self:getBagCapacity()
	local maxCapacity = self:getTravelKitCapacity(1)
	if curCapacity < maxCapacity then
		return true
	else
		return false
	end
end

--死亡清空背包，物品不放入仓库
function ItemBagCtrl:DeadRemoveAllBagItem()
	for dbid,prop in pairs(self.itemPropList) do
		local itemCfg = ItemConfigCtrl:getItemCfg(prop.itemID)
		local taskCard = itemCfg.itemTaskCard
		if taskCard ~= TaskCard.TASK and prop.itemBagNum > 0 then 			--任务道具不清空
			prop.itemBagNum = 0
			self:SendFlushBagNumber(prop.databaseID,prop.itemBagNum)
		end
	end
end

--背包物品放入仓库,清空背包所有物品 
function ItemBagCtrl:RemoveAllBagItem()
	for dbid,prop in pairs(self.itemPropList) do
		local itemCfg = ItemConfigCtrl:getItemCfg(prop.itemID)
		local taskCard = itemCfg.itemTaskCard
		if taskCard ~= TaskCard.TASK and prop.itemBagNum > 0 then 			--任务道具不清空
    		local maxNum = itemCfg.itemMaxNumber
    		local itemNum = prop.itemNumber + prop.itemBagNum
    		if itemNum >= maxNum then
				prop.itemNumber = maxNum
			else
				prop.itemNumber = itemNum
			end
			prop.itemBagNum = 0
			self:FlushItemNum(dbid, prop.itemNumber, prop.itemBagNum)
		end
	end
end

--根据物品ID清空背包里的数据放入仓库中
function ItemBagCtrl:recoveBagItem(itemID)
	for dbid,prop in pairs(self.itemPropList) do
		if prop.itemID == itemID then
			prop.itemNumber = prop.itemNumber + prop.itemBagNum
			prop.itemBagNum = 0
			break
		end
	end
end

--扣除背包物品
function ItemBagCtrl:deductBagItem(itemID,itemNum)
	if itemNum <= 0 then
		return
	end
	if isEmpty(itemID) then								--错误
		return 0									
	end
	if self:IsItemExist(itemID) == false then		--物品不存在
		sendSystemMsg(self.playerID, "物品不存在")
		return 0  									
	end
	if ItemConfigCtrl:IsResource(itemID) then				--资源
		return self:deductItemResource(itemID,itemNum)
	elseif ItemConfigCtrl:IsProp(itemID) then				--道具
		return self:deductBagProp(itemID,itemNum)
	elseif ItemConfigCtrl:IsEquip(itemID) then				--装备
		return self:deductBagEquip(itemID,itemNum)
	end
	return 0
end

--扣除背包物品(加上类型)
function ItemBagCtrl:deductBagStandard(item)
	if isEmpty(item) then
		return false
	end
	local tmp = 0
	if item[1] == KindType.Item then				--物品类型
		tmp = self:deductBagItem(item[2],item[3])
	elseif item[1] == KindType.Pet then				--宠物类型
		tmp = self:getHero(item[2])
	end
	if tmp == 3 or tmp == 4 then
		return true
	end
	return false
end

--获取物品背包数量
function ItemBagCtrl:getBagSum(itemID)
	if isEmpty(itemID) then								--错误
		return 0									
	end
    local itemSum = 0
	if ItemConfigCtrl:IsProp(itemID) then 
		for dbid, prop in pairs(self.itemPropList) do
			if(prop.itemID == itemID) then
				itemSum = prop.itemBagNum
				return itemSum
			end
		end
	elseif ItemConfigCtrl:IsEquip(itemID) then
		for dbid, equip in pairs(self.itemEquipList) do
			if(equip.itemID == itemID) then
				itemSum = equip.itemBagNum
				return itemSum
			end
		end
	end
	return itemSum
end

--出售背包物品
function ItemBagCtrl:SaleBagItem(itemID,itemNum)
	if isEmpty(itemID) then 
		return 0
	end
	local sale = ItemConfigCtrl:getItemSell(itemID)			--售价
	local sum = self:getBagSum(itemID)
	if itemNum <= sum then
		self:getItem(ResourceType.COPPER,itemNum*sale)
	else
		self:getItem(ResourceType.COPPER,sum*sale)
	end
	self:deductBagItem(itemID,itemNum)
end

--获取背包列表
function ItemBagCtrl:GetBagList()
	local temList = {}
	for dbid,item in pairs(self.itemPropList) do
		local outCity = ItemConfigCtrl:getItemOutCity(item.itemID)
		if outCity == OutCity.OUTCITY then
			table_insert(temList,dbid)
		end
	end
	return tempList

end

--探险出征从仓库携带物品
function ItemBagCtrl:CarryBagItem(itemID,bagNum)
	 if isEmpty(itemID) then	
        return 0
    end
    local curCapacity = self:getBagCapacity()
    local maxCapacity = self:getTravelKitCapacity(1)
    local curNum = maxCapacity - curCapacity
    if curNum <= 0 then
        return 0		--背包满
    end
    local weight = ItemConfigCtrl:getItemWeight(itemID)
    local itemNum = 0
    if bagNum*weight > curNum then
    	itemNum = NumberToInt(curNum/weight)
    else
    	itemNum = bagNum
    end
    if ItemConfigCtrl:IsProp(itemID) then					--道具
    	return self:CarryBagProp(itemID,itemNum)
    elseif ItemConfigCtrl:IsEquip(itemID) then				--装备
    	return self:CarryBagEquip(itemID,itemNum)
    end
end


--探险出征批量从仓库携带物品(加上类型)
function ItemBagCtrl:CarryBagListWithType(bagList)
	local flag = true
	for __, itemTB in pairs(bagList) do
		if itemTB[1] == KindType.Item then				--物品类型
			self:recoveBagItem(itemTB[2])
			if self:CarryBagItem(itemTB[2], itemTB[3]) == false then
				flag = false
				break
			end
		elseif itemTB[1] == KindType.Pet then				--宠物类型
			self:getHero(itemTB[2])
		end
	end
	return flag
end

--探险出征批量从仓库携带物品
function ItemBagCtrl:CarryBagList(bagList)
	local flag = true
	for __, item in pairs(bagList) do
		self:recoveBagItem(item[1])
		if self:CarryBagItem(item[1], item[2]) == false then
			flag = false
			break
		end
	end
	return flag
end

function ItemBagCtrl:test()
	for __, item in pairs(self.itemPropList) do
		if item.itemBagNum ~= 0 then
			print("背包数据：",item.itemID, item.itemBagNum)
		end
	end
end
