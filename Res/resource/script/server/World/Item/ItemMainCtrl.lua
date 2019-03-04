--ItemMainCtrl.lua
require "resource.script.server.World.Item.ItemCtrl"
require "resource.script.server.World.Item.ItemBagCtrl"
require "resource.script.server.Config.Item.ItemDefaultConfig"

local pairs = pairs
local table_insert = table.insert

ItemMainCtrl = {}
PlayerItemCtrl = {}

function ItemMainCtrl:New()
	local object = setmetatable({}, self)
	self.__index = self
	return object
end

function PlayerItemCtrl:New()
    return  createClass(ItemBagCtrl,ItemCtrl,ItemUseCtrl,ItemEquipCtrl,ItemPropCtrl,ItemSourceCtrl,ItemMainCtrl)
end

--初始化所有物品列表
function ItemMainCtrl:initItemList(sqlResult,tablename)
    if(tablename == "tb_ItemProp") and isEmpty(sqlResult) == false then 
       	self:InitItemPropList(sqlResult)
    end
    if(tablename == "tb_ItemEquip") and isEmpty(sqlResult) == false then 
        self:InitItemEquipList(sqlResult)
    end
end
   
--发送玩家物品信息
function ItemMainCtrl:sendItemList()
	local MAX_SEND_NUM = 30 
    self:SendItemropListToClient(MAX_SEND_NUM)
    self:SendItemEquipListToClient(MAX_SEND_NUM)	
end

--初始化新玩家物品列表
function ItemMainCtrl:InitNewPlayerItemList()
	self:createItemList(ItemDefaultConfig)	
end

--物品定期存储
function ItemMainCtrl:WriteItemData()
   	for __,prop in pairs(self.itemPropList) do
		prop:WriteItemToDB()
	end
	for __,equip in pairs(self.itemEquipList) do
		equip:WriteItemToDB()
	end
end

--批量生成物品
function ItemMainCtrl:createItemList(itemList)
	local tempList = {}
	for __, itemOBJ in pairs(itemList) do
		if itemOBJ[1] == KindType.Item then							--物品类型
			if isEmpty(tempList[itemOBJ[2]]) then
				tempList[itemOBJ[2]] = itemOBJ[3]
			else
				tempList[itemOBJ[2]] = tempList[itemOBJ[2]] + itemOBJ[3]
			end
		elseif itemOBJ[1] == KindType.Pet then						--宠物类型
			self:getHero(itemOBJ[2])
		end
	end
 	for itemID,itemNum in pairs(tempList) do
        self:getItem(itemID, itemNum)
    end
end

--批量删除物品  
function ItemMainCtrl:deleteItemList(itemList)
	local tempList = {}
		for __, itemOBJ in pairs(itemList) do
		if itemOBJ[1] == KindType.Item then							--物品类型
			if isEmpty(tempList[itemOBJ[2]]) then
				tempList[itemOBJ[2]] = itemOBJ[3]
			else
				tempList[itemOBJ[2]] = tempList[itemOBJ[2]] + itemOBJ[3]
			end
		elseif itemOBJ[1] == KindType.Pet then						--宠物类型
			self:getHero(itemOBJ[2])
		end
	end
    for key,item in pairs(tempList) do
        self:deductItem(key,item)
    end
end

--初始化道具列表
function ItemMainCtrl:InitItemPropList(sqlResult)
    for i = 1, sqlResult:GetRowCount() do
    	local databaseID = sqlResult:GetFieldFromCount(0):GetUInt32()
		local playerDBID = sqlResult:GetFieldFromCount(1):GetUInt32()
		local itemID = sqlResult:GetFieldFromCount(2):GetUInt32()
		local itemQuality =	sqlResult:GetFieldFromCount(3):GetUInt8()
		local itemNumber =	sqlResult:GetFieldFromCount(4):GetUInt32()
		local itemBagNum = sqlResult:GetFieldFromCount(5):GetUInt32()
		local itemPosition = sqlResult:GetFieldFromCount(6):GetUInt8()
		local _prop = ItemProp:CreateItemFromDB(databaseID,playerDBID,itemID,itemQuality,itemNumber,itemBagNum,itemPosition)
		self.itemPropList[_prop.databaseID] = _prop
		sqlResult:NextRow()
	end
	sqlResult:Delete()
end

--初始化装备列表
function ItemMainCtrl:InitItemEquipList(sqlResult)
    for i = 1, sqlResult:GetRowCount() do
		local databaseID = sqlResult:GetFieldFromCount(0):GetUInt32()
		local playerDBID = sqlResult:GetFieldFromCount(1):GetUInt32()
		local itemID = sqlResult:GetFieldFromCount(2):GetUInt32()
		local itemQuality =	sqlResult:GetFieldFromCount(3):GetUInt8()
		local itemNumber =	sqlResult:GetFieldFromCount(4):GetUInt32()
		local itemBagNum = sqlResult:GetFieldFromCount(5):GetUInt32()
		local itemPosition = sqlResult:GetFieldFromCount(6):GetUInt8()
		local itemStrengthenLevel =	sqlResult:GetFieldFromCount(7):GetUInt16()
	    local _equip = ItemEquip:CreateItemFromDB(databaseID,playerDBID,itemID,itemQuality,itemNumber,itemBagNum,itemPosition,itemStrengthenLevel)
	    self.itemEquipList[_equip.databaseID] = _equip
		sqlResult:NextRow()
	end
	sqlResult:Delete()

	self:GetEquitValue()--保存装备属性
end

--发送道具列表信息
function ItemMainCtrl:SendItemropListToClient(maxSendNum)
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

--发送装备列表信息
function ItemMainCtrl:SendItemEquipListToClient(maxSendNum)
    if not isEmpty(self.itemEquipList) then 
		local equipList = {}
		for dbid,item in pairs(self.itemEquipList) do
			table_insert(equipList,item)
		end
		local length = table.getn(equipList)
		local sendTimes = NumberToInt(length/maxSendNum)
		if length % maxSendNum ~= 0 then
			sendTimes = sendTimes + 1
		end
		for i = 1, sendTimes do
			local endPoint = (i == sendTimes) and length or (i*maxSendNum)
			Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_EQUIP_SEND_LIST)
			for j = (i-1)*maxSendNum+1,endPoint do
				Au.addUint32(equipList[j].databaseID)
				Au.addUint32(equipList[j].itemID)
				Au.addUint8(equipList[j].itemQuality)
				Au.addUint32(equipList[j].itemNumber)
				Au.addUint32(equipList[j].itemBagNum)
				Au.addUint8(equipList[j].itemPosition)
				Au.addUint16(equipList[j].itemStrengthenLevel)
			end
			Au.messageEnd()
		end
	end
end

--装备强化
function World_ItemCtrl_OnEquitLevelUp( playerID, itemDBID )
	--body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:OnEquitLevelUp(itemDBID)
end

--装备进阶
function World_ItemCtrl_OnEquitMoveForward( playerID, itemDBID )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:OnEquitMoveForward(itemDBID)
end

--出售物品
function World_ItemCtrl_OnDeductItem( playerID, itemID, itemNum )
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:SaleItem(itemID,itemNum)
end

--出售背包物品
function World_BagItemCtrl_OnDeductBagItem(playerID, itemID, itemNum)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:SaleBagItem(itemID,itemNum)
end

--贸易行
function World_ItemCtrl_OnTradeItem(playerID,itemID,itemNum)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return 
	end
	_player:buyItem(itemID,itemNum)
end

--道具合成
function World_ItemCtrl_PropCompound(playerID, propID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return 
	end
	_player:PropCompound(propID)
end

