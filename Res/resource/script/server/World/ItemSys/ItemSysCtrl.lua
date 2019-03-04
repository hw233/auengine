--ItemSysCtrl.lua
local specialItemTB = require "resource.script.server.World.ItemSys.ItemSysBase"
require "resource.script.server.World.ItemSys.PropCtrl"
require "resource.script.server.World.ItemSys.ItemBagCtrl"
require "resource.script.server.Config.ItemSys.ItemDefaultConfig"

--全局宏
local pairs = pairs
local table_insert = table.insert

ItemSysCtrl = {}
PlayerItemCtrl = {}

function ItemSysCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	--createClass( PropCtrl,ItemBagCtrl,ItemSysCtrl )
	return obj
end

function PlayerItemCtrl:New()
    return  createClass(PropCtrl,ItemBagCtrl,ItemSysCtrl)
end

--初始化所有物品列表
function ItemSysCtrl:initItemList(sqlResult,tablename)
    if(tablename == "tb_ItemProp") and isEmpty(sqlResult) == false then 
       	self:initPropList(sqlResult)
    end
end

--初始化新玩家物品列表
function ItemSysCtrl:InitNewPlayerItemList()
	self:createItemList(ItemDefaultConfig)	
end

--初始化物品(道具)列表
function ItemSysCtrl:initPropList(sqlResult)
	 for i = 1, sqlResult:GetRowCount() do
		local databaseID = sqlResult:GetFieldFromCount(0):GetUInt32()
		local playerDBID = sqlResult:GetFieldFromCount(1):GetUInt32()
		local itemID = sqlResult:GetFieldFromCount(2):GetUInt32()
		local itemQuality = sqlResult:GetFieldFromCount(3):GetUInt8()
		local itemNumber =	sqlResult:GetFieldFromCount(4):GetUInt32()
		local itemBagNum = sqlResult:GetFieldFromCount(5):GetUInt32()
		local itemPosition = sqlResult:GetFieldFromCount(6):GetUInt8()
		local _prop = ItemSysBase:createItem(databaseID,playerDBID,itemID,itemQuality,itemNumber,itemBagNum,itemPosition)
		self.itemPropList[_prop.databaseID] = _prop
		self.propDBIDList[_prop.itemID] = _prop.databaseID
		if _prop.itemBagNum > 0 then
			self.bagItemList[_prop.itemID] = _prop.databaseID    --背包物品
		end
		sqlResult:NextRow()
		
	end
	sqlResult:Delete()
end

--物品定期存储
function ItemSysCtrl:WriteItemData()
   	for __, prop in pairs(self.itemPropList) do
	print("------------------------", prop.databaseID,prop.playerDBID)
		prop:WriteItemToDB()
	end
end

--发送玩家物品信息
function ItemSysCtrl:sendItemList()
	local MAX_SEND_NUM = 30 
    self:SendItemropListToClient(MAX_SEND_NUM)	
end

--发送道具列表信息
function ItemSysCtrl:SendItemropListToClient(maxSendNum)
    if not isEmpty(self.itemPropList) then                                  
		local propList = {}
		for dbid,item in pairs(self.itemPropList) do
			table_insert(propList,item)
		end
		local length = table.getn(propList)
		local sendTimes = NumberToInt(length/maxSendNum)
		if length % maxSendNum ~= 0 then
			sendTimes = sendTimes + 1
		end
		for i = 1, sendTimes do
			local endPoint = (i == sendTimes) and length or (i*maxSendNum)
			Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_PROP_SEND_LIST)
			for j = (i-1)*maxSendNum+1,endPoint do
				Au.addUint32(propList[j].databaseID)
				Au.addUint32(propList[j].itemID)
				Au.addUint8(propList[j].itemQuality)
				Au.addUint32(propList[j].itemNumber)
				Au.addUint32(propList[j].itemBagNum)
				Au.addUint8(propList[j].itemPosition)
			end
			Au.messageEnd()
		end
	end
end

--刷新物品仓库数量
function ItemSysCtrl:SendFlushItemNumber(itemDBID,num)
    Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FLUSH_NUMBER)
	Au.addUint32(itemDBID)
	Au.addUint32(num)
	Au.messageEnd()
end

--同时刷新仓库和背包数量
function ItemSysCtrl:FlushItemNum(itemDBID,num,bagNum)
	 Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FLUSH_ITEM_NUM)
	Au.addUint32(itemDBID)
	Au.addUint32(num)
	Au.addUint32(bagNum)
	Au.messageEnd()
end


--生成物品( 单个物品生成 )
function ItemSysCtrl:getItem(itemID, itemNum)
	local flag = false
	if ItemSysBase:IsResource( itemID ) then
		flag = specialItemTB.specialItem[itemID](self, itemNum) --特殊资源(金币，宝石)
	elseif ItemSysBase:IsPropType( itemID ) then           --道具
		flag = self:getItemProp( itemID, itemNum )
	end
	
	return flag
end

--批量生成物品
function ItemSysCtrl:createItemList( itemList )
	local tempList = {}
	tempList = ItemSysBase:itemCount(itemList)
	
 	for itemID,itemNum in pairs(tempList) do
		if self:getItem(itemID, itemNum) == false then
			return false
		end
    end
	
	return true
end

--消耗物品
function ItemSysCtrl:deductItem(itemID, itemNum)
	local flag = false
	if ItemSysBase:IsResource( itemID ) then
		flag = specialItemTB.specialItemConsume[itemID](self, itemNum)
	elseif ItemSysBase:IsPropType( itemID ) then
		flag = self:deductItemProp( itemID, itemNum )
	end

	return flag
end

--批量消耗物品
function ItemSysCtrl:consumeItemList( itemList )
	local flag = true
	local tempList = {}
	tempList = ItemSysBase:itemCount(itemList)
	
	for itemID,itemNum in pairs(tempList) do
		if self:deductItem(itemID, itemNum) == false then
			flag = false
			break
		end
	end
	
	return flag
end

--出售仓库物品
function ItemSysCtrl:saleItem(itemID, itemNum)
	local flag = false
	if ItemSysBase:IsPropType( itemID ) then
		flag = self:saleProp( itemID, itemNum )
		return flag
	end
	
	return flag
end

--批量出售仓库物品
function ItemSysCtrl:saleItemList( itemList )
	local flag = true
	local tempList = {}
	tempList = ItemSysBase:itemCount(itemList)
	
	for itemID,itemNum in pairs(tempList) do
		if self:saleItem(itemID,itemNum) == false then
			flag = false
			break
		end
	end
	
	return flag
end

--获取物品仓库总数量
function ItemSysCtrl:getItemSum(itemID)
	local itemDBID = self.propDBIDList[itemID]
	local itemObj = self.itemPropList[itemDBID]
	if isEmpty(itemObj) then
		if itemID == ResourceType.COPPER then
			itemSum = self.playerCopper
		elseif itemID == ResourceType.DIAMOND then
			itemSum = self.playerDiamond
		else
			return 0
		end
		return itemSum									
	end
    local itemSum = 0
	if ItemSysBase:IsPropType( itemID ) then
		itemSum = itemObj.itemNumber
	end
	
	return itemSum
end




--API
--出售仓库物品
function World_ItemSysCtrl_OnDeductItem( playerID, itemID, itemNum )
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:saleItem(itemID,itemNum)
end

--出售背包物品
function World_BagItemCtrl_OnDeductBagItem(playerID, itemID, itemNum)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:SaleBagItem(itemID,itemNum)
end

--道具合成
function World_PropCtrl_PropCompound(playerID, propID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return 
	end
	_player:PropCompound(propID)
end





