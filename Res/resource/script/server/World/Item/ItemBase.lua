--ItemBase.lua


ItemBase = {} --��Ʒ��������

function ItemBase:New()
    local object = setmetatable({},self)
    self.__index = self
    return object
end

--��Ʒ�Ĵ���
function ItemBase:CreateItemBase(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
    self.databaseID = databaseID
    self.playerDBID = playerDBID
    self.itemID = itemID
    self.itemQuality = quality
    self.itemNumber = itemNum 
    self.itemBagNum = itemBagNum
    self.itemPosition = itemPosition
end

--������Ʒ�麯��
function ItemBase:WriteItemToDB()

end

--ɾ����Ʒ�麯��
function ItemBase:RemoveItemFromDB()
	
end


