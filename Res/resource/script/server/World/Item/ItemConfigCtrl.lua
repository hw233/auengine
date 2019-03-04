--ItemConfigCtrl.lua
require "resource.script.server.Config.Item.ItemConfig"
require "resource.script.server.Config.Item.EquitStrengthen"
require "resource.script.server.Config.Item.EquitAdvance"
require "resource.script.server.Config.Item.ItemDefaultConfig"
require "resource.script.server.Config.Item.TradeConfig"
require "resource.script.server.Config.Item.PROPCOMPOUND"

ItemConfigCtrl = {}

ResourceType = 					--资源类
{
	DIAMOND = 3010003,			--钻石(特殊资源）
	COPPER = 3010004,			--金币（特殊资源）
	BREAD = 1010064,			--面包
	WOOD = 1010063,				--木材
}
ItemType =	                       --物品类型
{
    Item_Prop = 10,                --道具类型
    Item_Equip = 20,               --装备类型
}
KindType = 								--总类型分类
{
	Item = 1,			--物品类型
	Pet = 2, 			--宠物类型
}

ItemPosition = 					--装备位置
{
	Position_StoreRoom = 0,			--仓库
	Position_Package = 1,			--背包
	Position_Player = 2,			--玩家
}

ItemEquipType =                	 --装备位置
{
    Equip_Weapon = 10,				--武器
    Equip_Cloth = 20,				--衣服
    Equip_Helmet = 30,				--头盔
    Equip_Shoes = 40,				--鞋子 
    Equip_Ring = 50,				--戒指
    Equip_Wrist = 60,				--护腕
}

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

TaskCard = 							--是否任务道具
{
	TASK = 1,				--任务道具
	NOTTASK = 2,			--非任务道具
}

OutCity = 					--是否携带出城
{
	OUTCITY = 1,			--可携带出城
	NOTOUTCITY = 2,		--不可携带出城
}

--==================================================
--是否道具
function ItemConfigCtrl:IsProp(itemID)
    local _itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    if _itemCfg.itemType == ItemType.Item_Prop then
        return true
    end
    return false
end

--是否装备
function ItemConfigCtrl:IsEquip(itemID)
	local _itemCfg = ItemConfigCtrl:getItemCfg(itemID)
    if _itemCfg.itemType == ItemType.Item_Equip then
        return true
    end
    return false
end

--特殊资源
function ItemConfigCtrl:IsResource(itemID)
	if itemID == ResourceType.COPPER or itemID == ResourceType.DIAMOND then
		return true
	end
	return false
end

--==================================================
--获取配置
function ItemConfigCtrl:getItemCfg(itemID)		--物品配置
    return ItemConfig["Item_"..itemID]
end

--基础配置属性
function ItemConfigCtrl:getItemName(itemID)		--名字
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemName"]
end

function ItemConfigCtrl:getItemType(itemID)		--类型
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemType"]
end

function ItemConfigCtrl:getItemQuality(itemID)	--品质
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemQuality"]
end

function ItemConfigCtrl:getItemWeight(itemID)	--重量
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemWeight"]
end

function ItemConfigCtrl:getItemMaxNumber(itemID)	--叠加上限
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemMaxNumber"]
end

function ItemConfigCtrl:getItemUseLevel(itemID)		--使用等级
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemUseLevel"]
end

function ItemConfigCtrl:getItemSell(itemID)			--售价
	local _item = ItemConfig["Item_"..itemID]
	return _item["itemSale"]
end

function ItemConfigCtrl:getItemOutCity(itemID)		--是否可以携带出城
	local _item = ItemConfig["Item_"..itemID]
	return _item["itemOutCity"]
end

function ItemConfigCtrl:getItemTaskCard(itemID)		--是否任务道具
	local _item = ItemConfig["Item_"..itemID]
	return _item["itemTaskCard"]
end

function ItemConfigCtrl:getItemViewKind(itemID)		--显示种类
	local _item = ItemConfig["Item_"..itemID]
	return _item["itemViewKind"]
end

--==================================================
--道具合成配置
function ItemConfigCtrl:getPropCompoundCfg()
	return PROPCOMPOUND
end

function ItemConfigCtrl:getPropCfg(propID)
	local propID = "ID_"..propID
	return PROPCOMPOUND[propID]
end
--==================================================
--装备专有
function ItemConfigCtrl:getItemProperty(itemID)				--装备属性列表
	local _item = ItemConfig["Item_"..itemID]
	return _item["itemProperty"]
end

function ItemConfigCtrl:getItemMaxStrengthenLevel(itemID)	--强化等级上限
    local _item = ItemConfig["Item_"..itemID]
    return _item["itemStrengthenLimit"]
end

--==================================================

--获取经验丹
function ItemConfigCtrl:getItemExp(itemID)
	local _item = ItemConfigCtrl:getItemSkillAdditional(itemID)
	return _item[2]
end

--获取强化消耗
function ItemConfigCtrl:getStrengthenUse( qualityID, level )
    -- body
    local strengthCfg = EquitStrengthen[qualityID]
    return strengthCfg["LEVEL_"..level]["USE"]
end

--获取进阶配置
function ItemConfigCtrl:getAdvanceCfg( itemID )
    -- body
    local _equitCfg = EquitAdvance["Equit_"..itemID]
    return _equitCfg
end

--贸易行配置
function ItemConfigCtrl:getTradeCfg(itemID)
	local _tradeCfg = TradeConfig["Trade_"..itemID]
	return _tradeCfg
end