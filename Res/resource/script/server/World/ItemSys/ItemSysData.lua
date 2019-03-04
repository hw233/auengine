--ItemSysData.lua

ItemSysData = {}
function ItemSysData:New()
	local object = setmetatable({},self)
	self.__index = self
    self.databaseID = 0
    self.playerDBID = 0
	self.itemID = 0         --��Ʒid
    self.itemQuality = 0    --Ʒ��
    self.itemNumber = 0         --��Ʒ�Ĳֿ�����
    self.itemBagNum = 0		--��Ʒ�ı�������
    self.itemPosition = 0		--Ĭ�ϲֿ�0,1������2���
	return object
end

--�����ݿ�ɾ��(����)
function ItemSysData:RemoveItemFromDB()
    Au.queryQueue("DELETE FROM tb_ItemProp WHERE databaseID = "..self.databaseID..";")
end

--д�����ݿ�(����)
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