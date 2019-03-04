--ItemBase.lua


ItemBase = {} --物品基础属性

function ItemBase:New()
    local object = setmetatable({},self)
    self.__index = self
    return object
end

--物品的创建
function ItemBase:CreateItemBase(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
    self.databaseID = databaseID
    self.playerDBID = playerDBID
    self.itemID = itemID
    self.itemQuality = quality
    self.itemNumber = itemNum 
    self.itemBagNum = itemBagNum
    self.itemPosition = itemPosition
end

--创建物品虚函数
function ItemBase:WriteItemToDB()

end

--删除物品虚函数
function ItemBase:RemoveItemFromDB()
	
end


