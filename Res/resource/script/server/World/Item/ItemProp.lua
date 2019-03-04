--ItemProp.lua
require "resource.script.server.World.Item.ItemBase"
require "resource.script.server.World.Item.ItemData"

ItemProp = {}   --道具

function ItemProp:New()
	local object = setmetatable({},self)
	self.__index = self
	return object
end

--构造函数
function ItemProp:CreateItemFromDB(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
    local _prop = createClass(ItemData,ItemProp,ItemBase)
    _prop:CreateItemBase(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
    return _prop
end

--创建一个资源
function ItemProp:CreateItem(playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
    local databaseID = Au.getDatateID("tb_ItemProp")
    return ItemProp:CreateItemFromDB(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
end

--从数据库删除
function ItemProp:RemoveItemFromDB()
    Au.queryQueue("DELETE FROM tb_ItemProp WHERE databaseID = "..self.databaseID..";")
end

--写入数据库
function ItemProp:WriteItemToDB()
    Au.queryQueue("call update_tb_ItemProp("..self.databaseID..
		","..self.playerDBID..
		","..self.itemID..
		","..self.itemQuality..
		","..self.itemNumber..
        ","..self.itemBagNum..
        ","..self.itemPosition..");")
end

