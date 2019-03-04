--ItemEquip.lua
require "resource.script.server.World.Item.ItemBase"
require "resource.script.server.World.Item.ItemData"

ItemEquip = {} -- װ��

function ItemEquip:New()
	local object = setmetatable({}, self)
	self.__index = self
    self.itemStrengthenLevel = 0    --��ǰǿ���ȼ�
	return object
end

--����
function ItemEquip:CreateItemFromDB(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition,itemLevel)
	local _equip = createClass(ItemData,ItemEquip,ItemBase)
    _equip:CreateItemBase(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
	_equip.itemStrengthenLevel = itemLevel
	
	return _equip
end

--����һ��װ��
function ItemEquip:CreateItem(playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition,itemLevel)
	local databaseID = Au.getDatateID("tb_ItemEquip")
	return ItemEquip:CreateItemFromDB(databaseID,playerDBID,itemID,quality,itemNum,itemPackNum,itemPosition,itemLevel)
end

--�����ݿ�ɾ��
function ItemEquip:RemoveItemFromDB()
	Au.queryQueue("DELETE FROM tb_ItemEquip WHERE databaseID = "..self.databaseID..";")
end

--д�����ݿ�
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

