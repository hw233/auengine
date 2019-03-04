--ItemBagCtrl.lua
local specialItemTB = require "resource.script.server.World.ItemSys.ItemSysBase"

--全局函数
local pairs = pairs
local table_insert = table.insert

ItemBagCtrl = {}

function ItemBagCtrl:New()
	local object = setmetatable({},self)
	self.__index = self
	object.bagItemList = {}
	return object
end


--刷新背包物品数量
function ItemBagCtrl:SendFlushBagNumber(itemDBID,num)
    Au.messageToClientBegin(self.playerID, MacroMsgID.Msg_ID_ITEM_FLUSH_BAG)
	Au.addUint32(itemDBID)
	Au.addUint32(num)
	Au.messageEnd()
end

--死亡后刷新背包数量(打包发送)
function ItemBagCtrl:SendFlushBagNumbers()
    Au.messageToClientBegin(self.playerID, MacroMsgID.Msg_ID_ITEM_FLUSH_BAG)
	for itemID, itemDBID in pairs(self.bagItemList) do
		local num = self.itemPropList[itemDBID].itemBagNum
		Au.addUint32(itemDBID)
		Au.addUint32(num)
	end
	Au.messageEnd()
end

--清空背包后刷新数量(打包发送)
function ItemBagCtrl:FlushItemNumOutBag()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FLUSH_ITEM_NUM)
	for itemID, itemDBID in pairs(self.bagItemList) do
		local bagNum = self.itemPropList[itemDBID].itemBagNum    --背包数量
		local num = self.itemPropList[itemDBID].itemNumber       --仓库数量
		Au.addUint32(itemDBID)
		Au.addUint32(num)
		Au.addUint32(bagNum)
	end
	Au.messageEnd()
end

--批量生产背包物品(加上类型)
function ItemBagCtrl:createBagListWithType(bagList)
	local tempList = {}
	tempList = ItemSysBase:itemCount(bagList)
	
 	for itemID,itemNum in pairs(tempList) do
        if self:getBagItem(itemID, itemNum) == false then
			return false
		end
    end
	
	return true
end

--批量生产背包物品(bagList: 物品的Id，物品数量)
function ItemBagCtrl:createBagList(bagList)
	for __, item in pairs(bagList) do
		if self:getBagItem(item[1],item[2]) == false then
			return false
		end
	end
	
	return true
end

--生成背包物品
function ItemBagCtrl:getBagItem(itemID, bagNum )
	 if isEmpty(itemID) then	
        return false
    end
    local curCapacity = self:getBagCapacity()
    local maxCapacity = self:getTravelKitCapacity(1)
    local curNum = maxCapacity - curCapacity
    if curNum <= 0 then
        return false		--背包满
    end
    local weight = ItemSysBase:getItemWeight(itemID)
    local itemNum = 0
    if bagNum*weight > curNum then
    	itemNum = NumberToInt(curNum/weight)
    else
    	itemNum = bagNum
    end
	
	local flag = false
	if ItemSysBase:IsResource( itemID ) then
		flag = specialItemTB.specialItem[itemID](self, itemNum)  --特殊资源(金币，宝石)
	elseif ItemSysBase:IsPropType( itemID ) then                 --道具
		flag = self:getBagProp( itemID, itemNum )
	end
	
	return falg
end

--获取背包当前容量
function ItemBagCtrl:getBagCapacity()
	local bagCapacity = 0
	if isEmpty(self.bagItemList) then
		return bagCapacity
	end
	
	for itemID, dbID in pairs(self.bagItemList) do
		local itemBagNum = self.itemPropList[dbID].itemBagNum
		local weight = ItemSysBase:getItemWeight(itemID)
		bagCapacity = bagCapacity + weight*itemBagNum
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
	for itemID, dbID in pairs(self.bagItemList) do
		local itemCfg = ItemSysBase:readPropCfg(itemID)
		if itemCfg["ISPROP"] ~= TaskCard.TASK then
			--self.itemPropList[dbID].itemBagNum = 0
			local prop = self.itemPropList[dbID]
			prop.itemBagNum = 0
			self:SendFlushBagNumber(prop.databaseID,prop.itemBagNum)   --一条一条发送
			self.bagItemList[itemID] = nil
		end
	end
--通知客户端刷新
	--self:SendFlushBagNumbers()  --打包发送
end

--背包物品放入仓库,清空背包所有物品 
function ItemBagCtrl:RemoveAllBagItem()
	local falg = false
	for itemID, dbID in pairs(self.bagItemList) do
		local itemCfg = ItemSysBase:readPropCfg(itemID)
		if itemCfg["ISPROP"] ~= TaskCard.TASK then
			local maxNum = itemCfg["MAXNUM"]
			local propObj = self.itemPropList[dbID]
    		local itemNum = propObj.itemNumber + propObj.itemBagNum
    		if itemNum >= maxNum then
				propObj.itemNumber = maxNum
			else
				propObj.itemNumber = itemNum
			end
			propObj.itemBagNum = 0
			self:FlushItemNum(dbID, propObj.itemNumber, propObj.itemBagNum)  --一条一条发送
			self.bagItemList[itemID] = nil
			--falg = true
		end
	end
--通知客户端
--	if flag == true then
--		self:FlushItemNumOutBag()    --打包发送
--	end
end

--根据物品ID清空背包里的数据放入仓库中
function ItemBagCtrl:recoveBagItem(itemID)
	local propDBID = self.bagItemList[itemID]
	local propObj = self.itemPropList[propDBID]
	if isEmpty(propObj) then
		return
	end
	propObj.itemNumber = propObj.itemNumber + propObj.itemBagNum
	propObj.itemBagNum = 0
	self.bagItemList[itemID] = nil
end

--扣除背包物品
function ItemBagCtrl:deductBagItem(itemID,itemNum)
	if ItemSysBase:IsPropType(itemID) then
		local flag = self:deductBagProp( itemID, itemNum )
		return flag
	end

	if specialItemTB.specialItemConsume[itemID](self, itemNum) == true then
		return true
	end
	
	return false
end

--扣除背包物品(加上类型)
function ItemBagCtrl:deductBagStandard(item)
	if isEmpty(item) then
		return false
	end
	
	local flag = self:deductBagItem(item[2], item[3])
	
	return flag
end

--获取物品背包数量
function ItemBagCtrl:getBagSum(itemID)
	local itemDBID = self.bagItemList[itemID]
	if isEmpty(itemDBID) then
		return false
	end
	
	local itemObj = self.itemPropList[itemDBID]
	return itemObj.itemBagNum

end

--出售背包物品
function ItemBagCtrl:SaleBagItem(itemID,itemNum)
	local itemDBID = self.bagItemList[itemID]
	if isEmpty(itemDBID) then
		return false
	end
	
	local price = ItemSysBase:getItemPrice(itemID)
	if price == 0 then
		return false
	end
	
	local itemObj = self.itemPropList[itemDBID]
	if itemNum > itemObj.itemBagNum then
		return false
	end
	
	if self:deductBagItem(itemID,itemNum) == false then   --删除物品
		return false
	end
	
	if self:getItem(ResourceType.COPPER, itemNum*price) == false then  --获得金币
		return false
	end

	return true
end

--探险出征从仓库携带物品
function ItemBagCtrl:CarryBagItem(itemID,bagNum)
	local carryFlag = ItemSysBase:getItemCarry(itemID)
	if carryFlag ~= 1 then   --不能携带出城
		return false
	end
	
    local curCapacity = self:getBagCapacity()
    local maxCapacity = self:getTravelKitCapacity(1)
    local curNum = maxCapacity - curCapacity
    if curNum <= 0 then
        return false		--背包满
    end
    local weight = ItemSysBase:getItemWeight(itemID)
    local itemNum = 0
    if bagNum*weight > curNum then
    	itemNum = NumberToInt(curNum/weight)
    else
    	itemNum = bagNum
    end

	if ItemSysBase:IsPropType( itemID ) then
		local flag = self:CarryBagProp(itemID, itemNum)
		return flag
	end
	return true
end

--探险出征批量从仓库携带物品(加上类型)
function ItemBagCtrl:CarryBagListWithType(bagList)
	local flag = true
	for __, itemTB in pairs(bagList) do
		if ItemSysBase:IsPropType( itemTB[2] ) then				--物品类型
			self:recoveBagItem(itemTB[2])
			if self:CarryBagItem(itemTB[2], itemTB[3]) == false then
				flag = false
				break
			end
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

function ItemBagCtrl:testt()
	for k,v in pairs(self.bagItemList) do
		print(k,v)
	end
end

function ItemBagCtrl:test()
	for __, item in pairs(self.itemPropList) do
		if item.itemBagNum ~= 0 then
			print("背包数据：",item.itemID, item.itemBagNum)
		end
	end
end