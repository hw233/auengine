--PlayerCtrl.lua
local PlayerMacro = require "resource.script.server.World.Player.PlayerMacro"
local exploreFun = require "resource.script.server.World.Explore.ExploreFun"
local pairs = pairs

PlayerCtrl = {}

function PlayerCtrl:New()
	local object = setmetatable(self, {})
	self.__index = self
	return object
end

--上线获取资源数据
function PlayerCtrl:getAllPlayerInfo(state)
	if state == 0 then--全数据
		self:send_HeroBase_Info()
		self:send_BuildBase_Info()
		self:send_TaskBase_Info()
		self:send_ItemBase_Info()
		self:send_SevenRewardBase_Info()
		self:send_ForgeBase_Info()
		self:send_ExploreBase_Info()
		self:send_ShopBase_Info()
	elseif state == 1 then--冒险者数据
		self:send_HeroBase_Info()
	elseif state == 2 then--建筑数据
		self:send_BuildBase_Info()
	elseif state == 3 then--任务成就数据
		self:send_TaskBase_Info()
	elseif state == 4 then--物品数据
		self:send_ItemBase_Info()
	elseif state == 5 then--七日奖励数据
		self:send_SevenRewardBase_Info()
	elseif state == 6 then--探险数据
		self:send_ExploreBase_Info()
		self:send_ForgeBase_Info()
	elseif state == 7 then--商城数据
		self:send_ShopBase_Info()
	end
	self:send_PlayerBase_Info()
end

--玩家基础信息
function PlayerCtrl:send_PlayerBase_Info()
	local _betW = self.roleLastOnlineTime - self.roleOfflineTime
	if _betW <= 0 then
		_betW = 0
	end
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ON_GET_PLAYER_INFO)
	Au.addString(self.playerName)
	Au.addUint8(self.playerSex)
	Au.addUint32(self.playerDiamond)
	Au.addUint32(self.playerCopper)
	Au.addUint16(self.playerRenKouTotal)
	Au.addUint32(self.playerSystemState)	--功能开放
	Au.addUint8(self.playerStatus)			--状态(0-空闲状态，1-探险状态)
	Au.addUint32(_betW)						--上下线间隔时间
	Au.messageEnd()
end

--冒险者基础信息
function PlayerCtrl:send_HeroBase_Info()
	self:getHeroList()	--宠物列表
	exploreFun.ExploreFun:send_formation_toClient( self.playerID, self.fightLineupList )
end

--建筑基础信息
function PlayerCtrl:send_BuildBase_Info()
	self:getBuildList()	--建筑信息
	self:getCollectWoodOnLine()	--上线发送收取木材CD
end

--任务基础信息
function PlayerCtrl:send_TaskBase_Info()
	self:getTaskList()	--任务列表
end

--物品基础信息
function PlayerCtrl:send_ItemBase_Info()
	self:sendItemList()  --物品列表
end

--七天奖励基础信息
function PlayerCtrl:send_SevenRewardBase_Info()
	self:SendRewardTimesAndStatus()--7天领取次数和状态
	self:requestOutPutData(true)--检测人才管理
end

--探险基础信息
function PlayerCtrl:send_ExploreBase_Info()
	self:getExploreOnline()	--探险数据
	self:sendTalentToClient()--天赋信息
end

--商城基础信息
function PlayerCtrl:send_ShopBase_Info()
	self:sendBuyStatu()     --一次性物品状态位
end

--打造基础信息
function PlayerCtrl:send_ForgeBase_Info()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FORGE_INFO)
	Au.addUint16(self.Backpack)       --出行背包
	Au.addUint16(self.WaterBag)       --水袋
	Au.addUint16(self.Carriage)       --马车
	Au.addUint16(self.Alchemy)        --炼金
	Au.addUint16(self.Bread)          --面包
	Au.messageEnd()
end

function PlayerCtrl:set_playerDiamond(value)
	if self.playerDiamond == value then
		return
	end
	self.playerDiamond = value
	self:sendPropToClient( PLAYER_PROP_TYPE.PLAYERDIAMOND, self.playerDiamond, ENTITY_PROP_TYPE_UINT32)
end

function PlayerCtrl:set_playerCopper(value)
	if self.playerCopper == value then
		return
	end
	self.playerCopper = value
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERCOPPER, self.playerCopper, ENTITY_PROP_TYPE_UINT32)
end

function PlayerCtrl:set_playerRenKouTotal( value )
	-- body
	if self.playerRenKouTotal == value then
		return
	end
	self.playerRenKouTotal = value
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERRENKOUTOTAL, self.playerRenKouTotal, ENTITY_PROP_TYPE_UINT16)
end

function PlayerCtrl:set_playerTalentPoint( value )
	-- body
	if value <= 0 then
		value = 0
	end
	if self.achievementPoint == value then
		return
	end
	self.achievementPoint = value
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERTALENTPOINT, self.achievementPoint, ENTITY_PROP_TYPE_UINT8)
end

function PlayerCtrl:subPlayerCopper(value)
	if self.playerCopper < value then
		sendSystemMsg(self.playerID,"金币不足")
		return false
	end
	self:set_playerCopper(self.playerCopper - value)
	return true
end

function PlayerCtrl:subPlayerDiamond(value)
	if self.playerDiamond < value then
		sendSystemMsg(self.playerID,"钻石不足")
		return false
	end
	self:set_playerDiamond(self.playerDiamond - value)
	return true
end

function PlayerCtrl:initPlayerProp(sqlResult,tableName)
	if tableName == "tb_PlayerProp" and isEmpty(sqlResult) == false then
		self.playerLevel = sqlResult:GetFieldFromCount(1):GetUInt8()
		self.playerDiamond = sqlResult:GetFieldFromCount(2):GetUInt32()
		self.playerCopper = sqlResult:GetFieldFromCount(3):GetUInt32()
		self.playerRenKouTotal = sqlResult:GetFieldFromCount(4):GetUInt16()
		self.rewardTimes = sqlResult:GetFieldFromCount(5):GetUInt8()
		self.rewardFlag = sqlResult:GetFieldFromCount(6):GetUInt8()
		self.bFreeTimes = sqlResult:GetFieldFromCount(7):GetUInt8()
		self.sFreeTimes = sqlResult:GetFieldFromCount(8):GetUInt8()
		self.sTotalTimes = sqlResult:GetFieldFromCount(9):GetUInt32()
		self.buyStatu = sqlResult:GetFieldFromCount(10):GetUInt32()
		self.playerSystemState = sqlResult:GetFieldFromCount(11):GetUInt32()
		self.Backpack = sqlResult:GetFieldFromCount(12):GetUInt16()
		self.WaterBag = sqlResult:GetFieldFromCount(13):GetUInt16()
		self.Carriage = sqlResult:GetFieldFromCount(14):GetUInt16()
		self.Alchemy = sqlResult:GetFieldFromCount(15):GetUInt16()
		self.Bread = sqlResult:GetFieldFromCount(16):GetUInt16()
		self.talentState = sqlResult:GetFieldFromCount(17):GetUInt32()
		self.achievementPoint = sqlResult:GetFieldFromCount(18):GetUInt16()
	end
end

function PlayerCtrl:WritePlayerData()
	Au.queryQueue("CALL update_tb_PlayerProp("..self.databaseID..","
					..self.playerLevel..","
					..self.playerDiamond..","
					..self.playerCopper..","
					..self.playerRenKouTotal..","
					..self.rewardTimes..","
					..self.rewardFlag..","
					..self.bFreeTimes..","
					..self.sFreeTimes..","
					..self.sTotalTimes..","
					..self.buyStatu..","
					..self.playerSystemState..","
					..self.Backpack..","
					..self.WaterBag..","
					..self.Carriage..","
					..self.Alchemy..","
					..self.Bread..","
					..self.talentState..","
					..self.achievementPoint..
				  ");")
end

--获取总战力
function PlayerCtrl:getCountFightPower()
	local countFightPower = 0
	if isEmpty(self.fightLineupList) then
		return countFightPower
	end
	for i = 1, #self.fightLineupList do
		local heroDBID = self.fightLineupList[i]
		if heroDBID ~= 0 then
			countFightPower = countFightPower + self.heroList[heroDBID].fightPower
		end
	end
	return countFightPower
end

--开启某一个新功能,新系统
function PlayerCtrl:set_playerSystemState(systemState)
	if Au.bitCheckState(self.playerSystemState, systemState) == 1 then
		return false
	end
	self.playerSystemState = Au.bitAddState(self.playerSystemState,systemState)
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERSYSTEMSTATE,self.playerSystemState,ENTITY_PROP_TYPE_UINT32)
	return true
end

--开放进程
function PlayerCtrl:openSystemState(systemState, buildTB)
	if self:set_playerSystemState( systemState ) == false then
		return
	end
	for __, _buildID in pairs( buildTB ) do
		if _buildID ~= 0 then
			local buildType = _buildID%100
			self:createBuild(buildType)
		end
	end
end

--功能开放检测
function PlayerCtrl:CheckFunctionID(functionID)
	local processID = PlayerMacro.PlayerMacro:readFunctionCfg(functionID)
	if isEmpty(processID) then
		return false
	end
	
	if Au.bitCheckState(self.playerSystemState, processID) ~= 1 then
		return false
	end
	
	return true
end

--设置所在模块
function PlayerCtrl:set_playerStatus( value )
	self.playerStatus = value
end

--玩家的一些公共接口定义Begin

--判断资源是否存在 并消耗资源公共接口
--function:checkOutAndTakeawaySource
--arg useCfg 资源消耗配置
--return false true
function PlayerCtrl:checkOutAndTakeawaySource( useCfg )
	if isEmpty(useCfg) then
		return false
	end
	local pairs = pairs
	for __, scTB in pairs(useCfg) do
		--资源是否存在
		if scTB[1] == KindType.Item and self:IsItemEqualToValue(scTB[2], scTB[3]) == false then
			return false
		end
	end
	for __, scTB in pairs(useCfg) do
		if scTB[1] ~= 0 then
			self:deductItem(scTB[2], scTB[3])
		end
	end
	return true
end

--前置条件的判断
--function:checkPrecondition
--arg preCfg
--return false true
function PlayerCtrl:checkPrecondition( preCfg )
	if isEmpty( preCfg ) then
		return false
	end
	if preCfg[1] == 0 then
		return true
	end
	if preCfg[1] == PlayerMacro.PlayerMacro.PLAYERLEVEL and (self.playerLevel < preCfg[2]) then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.TASKID and self:getZhuXiangTask() < preCfg[2] then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.BUILD and self:checkBuildExists(preCfg[2]) == false  then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.SPACE and self:checkBigMapPass( preCfg[2] ) == false then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.GETITEM and self:IsItemEqualToValue(preCfg[2], preCfg[3]) == false then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.BIGMAP and self.exploreOBJ.bigMapIndex <= preCfg[2] then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.OPENSYS and Au.bitCheckState(self.playerSystemState, preCfg[2]) == 0 then
		return false
	else
	
	end
	return true
end

--玩家的一些公共接口定义End

function World_PlayerCtrl_getAllPlayerInfo( playerID, state )
	local _player = Player:getPlayerFromID( playerID )
	if isEmpty(_player) then
		return
	end
	_player:getAllPlayerInfo( state )

end