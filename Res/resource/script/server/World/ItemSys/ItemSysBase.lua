--ItemSysBase.lua
require "resource.script.server.Config.ItemSys.PROPITEM"
require "resource.script.server.Config.ItemSys.PROPCOMPOUND"
require "resource.script.server.World.ItemSys.ItemSysData"

ResourceType = 					--资源类
{
	PROP = 10,                  --道具类型
	DIAMOND = 3010003,			--钻石(特殊资源）
	COPPER = 3010004,			--金币（特殊资源）
	BREAD = 1010064,			--面包
	WOOD = 1010063,				--木材
}

KindType = 								--总类型分类
{
	Item = 1,			--物品类型
	Pet = 2, 			--宠物类型
}


TaskCard = 						
{
	TASK = 1,				--任务道具
	NOTTASK = 2,			--非任务道具
}

--------预留装备----------------
ItemEquipPropertyType =                   --装备属性类型
{
    Attack = 1,                 --攻击力
    Blood = 2,                  --生命值
    Phy_Defense = 3,      		--物理防御
    Mag_Defense = 4,			--法术防御
    Attack_Speed = 5,			--攻击速度
    MingZhongRate = 6,			--命中率
    BaoJiRate = 7,				--暴击率
    ShanBiRate = 8,				--闪避率
    BaoJiDamage = 9,			--暴击伤害
    PhyDamagePlus = 12,			--物理伤害减少
    MagDamagePlus = 11,			--法术伤害减少
    AllDamagePlus = 12,			--所有伤害减少
}


--------------------------------


ItemSysBase = {}

function ItemSysBase:New()
	local obj = setmetatable({}, self)
	self.__index = self
	return obj
end

--创建物品
function ItemSysBase:createItem(databaseID,playerDBID,itemID,quality,itemNum,itemBagNum,itemPosition)
	local obj = ItemSysData:New()
		obj.databaseID = databaseID
		obj.playerDBID = playerDBID
		obj.itemID = itemID
		obj.quality = itemQuality
		obj.itemNumber = itemNum
		obj.itemBagNum = itemBagNum
		obj.itemPostion = itemPosition
		
		return obj
end

--读取物品配置
function ItemSysBase:readPropCfg(itemID)
	local ID = "PROP_"..itemID
	return PROPITEM[ID]
end
--读取物品最大数量
function ItemSysBase:readItemMaxNum(itemID)
	local ID = "PROP_"..itemID
	local item = PROPITEM[ID]
	return item["MAXNUM"]
end
--读取物品重量
function ItemSysBase:getItemWeight(itemID)
	local ID = "PROP_"..itemID
	local item = PROPITEM[ID]
	return item["WEIGHT"]
end
--读取物品价格
function ItemSysBase:getItemPrice(itemID)
	local ID = "PROP_"..itemID
	local item =  PROPITEM[ID]
	return item["PRICE"]
end
--读取物品是否可以携带出城
function ItemSysBase:getItemCarry(itemID)
	local ID = "PROP_"..itemID
	local item =  PROPITEM[ID]
	return item["CARRY"]
end

--道具合成配置
function ItemSysBase:getPropCompoundCfg()
	return PROPCOMPOUND
end

function ItemSysBase:getPropCfg(propID)
	local propID = "ID_"..propID
	return PROPCOMPOUND[propID]
end


--统计物品列表
function ItemSysBase:itemCount( itemList )
	local tempList = {}
	for __, itemOBJ in pairs(itemList) do
		if isEmpty(tempList[itemOBJ[2]]) then
			tempList[itemOBJ[2]] = itemOBJ[3]
		else
			tempList[itemOBJ[2]] = tempList[itemOBJ[2]] + itemOBJ[3]
		end
	end
	
	return tempList
end

--检测是否道具
function ItemSysBase:IsPropType( itemID )
	local propCfg = ItemSysBase:readPropCfg(itemID)
	if isEmpty(propCfg) then
		return false
	end
	if propCfg["TYPE"] ~= ResourceType.PROP then
		return false
	end
	return true
end

--检测是否特殊资源
function ItemSysBase:IsResource( itemID )
	if itemID == ResourceType.COPPER or itemID == ResourceType.DIAMOND then
		return true
	end
	
	return false
end


--特殊资源获得处理(金币，宝石)
local specialItem = {}
local specialItemConsume = {}
specialItem[ResourceType.COPPER] = function( playerObj, itemNum )     --金币
	local value = playerObj.playerCopper + itemNum
	playerObj:set_playerCopper(value)
	
	return true
end

specialItem[ResourceType.DIAMOND] = function( playerObj, itemNum )   --宝石
	local value = playerObj.playerDiamond + itemNum
	playerObj:set_playerDiamond(value)
	
	return true
end

specialItemConsume[ResourceType.COPPER] = function( playerObj, itemNum )     --金币消耗
	local ret = playerObj:subPlayerCopper(itemNum)
	return ret
end

specialItemConsume[ResourceType.DIAMOND] = function( playerObj, itemNum )   --宝石消耗
	local ret = playerObj:subPlayerDiamond(itemNum)
	return ret
end


return {ItemSysBase=ItemSysBase, specialItem=specialItem, specialItemConsume=specialItemConsume }