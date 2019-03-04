--ItemData.lua

ItemData = {}

function ItemData:New()
	local object = setmetatable({},self)
	self.__index = self
    self.databaseID = 0
    self.playerDBID = 0
	self.itemID = 0
    self.itemQuality = 0
    self.itemNumber = 0         --物品的仓库数量
    self.itemBagNum = 0		--物品的背包数量
    self.itemPostion = 0		--默认仓库0,1背包，2玩家
	return object
end