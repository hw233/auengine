--ItemUseCtrl.lua

require "resource.script.server.World.Item.ItemConfigCtrl"

ItemUseCtrl = {}

function ItemUseCtrl:New()
    local object = setmetatable({},self)
    self.__index = self
    return object
end

--��ȡ����������ֵ������
function ItemUseCtrl:getItemMaxVaulue(tb)
	local _key,_value
	for key,value in pairs(tb) do
		if(_value == nil) then
			_key,_value = key,value
		end
		if value > _value then
			_key,_value = key,value
		end
	end
	return _key,_value
end

--��ȡ���������Сֵ������
function ItemUseCtrl:getItemMinValue(tb)
	local _key,_value
	for key,value in pairs(tb) do
		if(_value == nil) then
			_key,_value = key,value
		end
		if value < _value then
			_key,_value = key,value
		end
	end
	return _key,_value

end

--�ж���Ʒ���������ֵ��С
function ItemUseCtrl:IsItemEqualToValue(itemID,itemNum)
	local itemSum = self:getItemSum(itemID)
	if(itemSum >= itemNum) then
		return true
	end
	return false
end

--�ж���Ʒ�Ƿ����
function ItemUseCtrl:IsItemExist(itemID)
	if ItemConfigCtrl:IsResource(itemID) then
		return true;
	elseif ItemConfigCtrl:IsProp(itemID) then 
		for dbid, prop in pairs(self.itemPropList) do
			if prop.itemID == itemID then
				return true
			end
		end
	elseif ItemConfigCtrl:IsEquip(itemID) then
		for dbid, equip in pairs(self.itemEquipList) do
			if equip.itemID == itemID then
				return true
			end
		end
	end
	return false
end