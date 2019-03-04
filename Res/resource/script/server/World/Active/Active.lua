--Active.lua
ACTIVID = {}
ACTIVID.PLAYER_LEVEL = 103	--每天更新

local statisticsActiveCtl = {}	--统计玩家奖励控制
local checkJoinCtl = {}			--控制玩家是否能参加该活动操作

statisticsActiveCtl["activeID"..ACTIVID.PLAYER_LEVEL] = function (playerDBID)
	
	return true
end


ACTIVE_STATE = {}

ACTIVE_STATE.CLOSE = 0		--关闭
ACTIVE_STATE.OPEN = 1		--开启
ACTIVE_STATE.AWARD = 2		--奖励

Active = {}

function Active:New()
	local object = setmetatable({},self)
	self.__index = self
	self.activeID = 0							--活动ID
	self.activeState = ACTIVE_STATE.CLOSE		--活动激活状态
	self.activeGetReward = 0					--是否主动领奖操作(0:自动 1:主动)
	self.activeJoinLimit = 0					--参与活动限制(0:所有玩家1:部分玩家)
	object.activeJoinData = nil					--参与玩家数据(适用于acriveJoinLimit为1的情况)
	object.activeData = nil						--领奖玩家数据
	object.saveGetRewardActive = nil			--保存领取奖励的玩家
	return object
end

--改变活动
function Active:setState(state)
	self.activeState = state
end

--设置领奖状态
function Active:setGetReward(value)
	self.activeGetReward = value
end

--设置参与活动限制
function Active:setJoinLimit(value)
	self.activeJoinLimit = value
end

--创建活动
function Active:createActive(activeID)
	local _active = Active:New()
	_active.activeID = activeID
	_active.activeData = {}
	return _active
end

--检查玩家是否有奖励
function Active:checkAward(databaseID)
	if self.activeData[databaseID] == 1 then
		return true
	end
	return false
end

--参与玩家数据压入
function Active:pushActivePlayerData(playerDBID)
	if table_has_Key(self.activeJoinData, playerDBID) == true then
		return
	end
	table.insert(self.activeJoinData, playerDBID)
end

--统计所有玩家在活动中完成的活动
function Active:statisticsAcitve()
	if self.activeJoinLimit == 1 then--部分玩家
		if isEmpty(self.activeJoinData) then
			return
		end
		for i=1,#self.activeJoinData do
			local playerDBID = self.activeJoinData[i]
			if statisticsActiveCtl["activeID"..self.activeID](playerDBID) == true then
				self.activeData[playerDBID] = 1
			end
		end
	else
		
	end
end

--活动开启即可领取奖励的活动
function Active:checkOpenAcitveGetReward()
	self:setState(ACTIVE_STATE.AWARD)
end

function Active:getDataAward(_player)
	if self.activeData[_player.databaseID] ~= 1 then
		return
	end
	
	if not isEmpty(self.saveGetRewardActive[_player.databaseID]) then
		return
	end
	
	local rewardConfig = {}--活动奖励配置
		
	if not isEmpty(rewardConfig) then
		
	end
	
	self:handleGetDataAward(_player)--领取完奖励的后续操作
end

--活动领完奖励的后续操作
function Active:handleGetDataAward(_player)
	self.activeData[_player.databaseID] = nil
	self.saveGetRewardActive[_player.databaseID] = 0
	
	if getTableLength(self.activeData) == 0 then
		ActiveMgr:deleteActive(self.activeID)
	end	
end