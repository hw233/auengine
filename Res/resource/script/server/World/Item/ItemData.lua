--ItemData.lua

ItemData = {}

function ItemData:New()
	local object = setmetatable({},self)
	self.__index = self
    self.databaseID = 0
    self.playerDBID = 0
	self.itemID = 0
    self.itemQuality = 0
    self.itemNumber = 0         --��Ʒ�Ĳֿ�����
    self.itemBagNum = 0		--��Ʒ�ı�������
    self.itemPostion = 0		--Ĭ�ϲֿ�0,1������2���
	return object
end