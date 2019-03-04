--ItemUseCtrl.lua

require "resource.script.server.World.Item.ItemConfigCtrl"

ItemUseCtrl = {}

function ItemUseCtrl:New()
    local object = setmetatable({},self)
    self.__index = self
    return object
end

--获取索引表的最大值和索引
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

--获取索引表的最小值和索引
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

--判断物品总数与给定值大小
function ItemUseCtrl:IsItemEqualToValue(itemID,itemNum)
	local itemSum = self:getItemSum(itemID)
	if(itemSum >= itemNum) then
		return true
	end
	return false
end

--判断物品是否存在
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