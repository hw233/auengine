--ItemSysData.lua

ItemSysData = {}
function ItemSysData:New()
	local object = setmetatable({},self)
	self.__index = self
    self.databaseID = 0
    self.playerDBID = 0
	self.itemID = 0         --物品id
    self.itemQuality = 0    --品质
    self.itemNumber = 0         --物品的仓库数量
    self.itemBagNum = 0		--物品的背包数量
    self.itemPosition = 0		--默认仓库0,1背包，2玩家
	return object
end

--从数据库删除(道具)
function ItemSysData:RemoveItemFromDB()
    Au.queryQueue("DELETE FROM tb_ItemProp WHERE databaseID = "..self.databaseID..";")
end

--写入数据库(道具)
function ItemSysData:WriteItemToDB()
--print("test..",self.databaseID,self.playerDBID,self.itemID)
    Au.queryQueue("call update_tb_ItemProp("..self.databaseID..
		","..self.playerDBID..
		","..self.itemID..
		","..self.itemQuality..
		","..self.itemNumber..
        ","..self.itemBagNum..
        ","..self.itemPosition..");")
end