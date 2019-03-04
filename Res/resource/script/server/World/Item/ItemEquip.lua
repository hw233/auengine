--ItemEquip.lua
require "resource.script.server.World.Item.ItemBase"
require "resource.script.server.World.Item.ItemData"

ItemEquip = {} -- 装备

function ItemEquip:New()
	local object = setmetatable({}, self)
	self.__index = self
    self.itemStrengthenLevel = 0    --当前强化等级
	return object
end

--构造
function ItemEquip:CreateItemFromDB(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition,itemLevel)
	local _equip = createClass(ItemData,ItemEquip,ItemBase)
    _equip:CreateItemBase(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
	_equip.itemStrengthenLevel = itemLevel
	
	return _equip
end

--创建一个装备
function ItemEquip:CreateItem(playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition,itemLevel)
	local databaseID = Au.getDatateID("tb_ItemEquip")
	return ItemEquip:CreateItemFromDB(databaseID,playerDBID,itemID,quality,itemNum,itemPackNum,itemPosition,itemLevel)
end

--从数据库删除
function ItemEquip:RemoveItemFromDB()
	Au.queryQueue("DELETE FROM tb_ItemEquip WHERE databaseID = "..self.databaseID..";")
end

--写入数据库
function ItemEquip:WriteItemToDB()
	Au.queryQueue("CALL update_tb_ItemEquip("..self.databaseID..
        ","..self.playerDBID..
        ","..self.itemID..
		","..self.itemQuality..
		","..self.itemNumber..
		","..self.itemBagNum..
		","..self.itemPosition..
		","..self.itemStrengthenLevel..");")
end

