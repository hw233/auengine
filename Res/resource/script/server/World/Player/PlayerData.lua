--PlayerData.lua
PlayerData = {}

function PlayerData:New()
	local object = setmetatable({},self)
	self.__index = self
	self.accountID = ""					--账号ID
	self.playerLevel = 1				--等级
	self.playerSex = 0					--性别
	self.playerDiamond = 10000			--钻石
	self.playerCopper = 10000			--金币
	self.playerRenKouTotal = 0			--人口总量
	self.playerAllotRenKou = 0			--可分配人口
	self.playerStatus = 0               --玩家状态(0-空闲状态，1-探险状态)
    
    self.playerSystemState = 1			--玩家开放功能
    self.playerPrimaryKey = 0			--玩家key(用于玩家建筑key)
    self.achievementPoint = 0 			--玩家成就点
    
    object.itemPropList = {}          	--道具列表
    object.itemEquipList = {}         	--装备列表
    self.itemMaxNum = 100             	--仓库的格子数量
    
    object.buildList = {}				--建筑列表
    object.taskList = {}				--任务列表
    object.heroList = {}				--伙伴列表

    object.equitPropList = {}			--装备属性加成
    for __,propID in pairs(ItemEquipPropertyType) do
		object.equitPropList[propID] = 0
	end

	return object
end

--获取玩家key
function PlayerData:getPrimaryKey()
	local primaryKey = self.playerPrimaryKey + 1
	self.playerPrimaryKey = primaryKey
	return primaryKey
end

--设置玩家key
function PlayerData:setPrimaryKey(value)
	if self.playerPrimaryKey >= value then
		return
	end
	self.playerPrimaryKey = value
end