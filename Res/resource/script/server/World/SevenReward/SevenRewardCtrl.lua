-- SevenRewardCtrl.lua

require "resource.script.server.Config.SevenReward.SEVENREWARDCFG"

--宏定义
local REWARD_MACRO = {}
REWARD_MACRO.REWARD_FLAG = 0      -- 0-可以领取奖励
REWARD_MACRO.REWARD_PERIOD = 9    -- 领取周期,累积领取7次后重置
REWARD_MACRO.REWARD_STATUS = 1    -- 领取状态位,1-已经领取

SevenRewardCtrl = {}

function SevenRewardCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.rewardTimes = 1                --领取次数
	self.rewardFlag = 0                 --领取标识 0-没有领取，1-已经领取
	return obj
end

--领取奖励
function SevenRewardCtrl:GetReward()
--判断玩家是否已经领取过奖励
	if not self:isRewardFlag() then
		return
	end
--获取领取次数
	local rewardTime = self:getRewardTimes()              
--获取领取物品配置
	local rewardList = self:readCfg(rewardTime)
	if isEmpty(rewardList) then
		return
	end
--领取奖励 (调用物品接口)
	self:createItemList(rewardList)
--修改领取状态位
	self:setRewardFlag(REWARD_MACRO.REWARD_STATUS)   -- 修改领取状态位 0-没有领取， 1-已经领取
--回复客户端
	self:SendRewardTimesAndStatus()
	
end

--发送玩家领取的次数和状态
function SevenRewardCtrl:SendRewardTimesAndStatus()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_REWARD_TIMESANDTATUS)
	Au.addUint8(self.rewardTimes)        --领取次数
	Au.addUint8(self.rewardFlag)         --领取的状态
	Au.messageEnd()
end

--判断玩家是否领取了奖励
function SevenRewardCtrl:isRewardFlag()
	local isBOOl = false
	
	if REWARD_MACRO.REWARD_FLAG == self.rewardFlag then
		isBOOl = true
	end
	
	return isBOOl
end

--获取今天应该领取次数
function SevenRewardCtrl:getRewardNums(rewardTime)
	local res = 0
	if REWARD_MACRO.REWARD_PERIOD == rewardTime then
		res = 1
	else
		res = rewardTime + 1
	end
	
	return res  
end

--更新7天领取奖励状态
function SevenRewardCtrl:UpdateRewardFlag()
	if self.rewardFlag == 0 then
		return
	else
		self.rewardFlag = 0    --凌晨更新领取状态 0-可以领取，1-已经领取
		if REWARD_MACRO.REWARD_PERIOD == self.rewardTimes then
			self.rewardTimes = 1
		else
			self.rewardTimes = self.rewardTimes + 1
		end
	end
	
	if self.playerID == 0 then
		return
	end
	self:SendRewardTimesAndStatus()
end

-- 读取配置文件
function SevenRewardCtrl:readCfg(index)
	return SEVEN_REWARD[index]
end

--设置领取状态位
function SevenRewardCtrl:setRewardFlag(value)
	if value == nil or value < 0 or value > 1 then
		return
	end
	self.rewardFlag = value
end

--设置领取次数
function SevenRewardCtrl:setRewardTimes(value)
	if value == nil or value <= 0 or value > 9 then
		print("error",value)
		return
	end
	self.rewardTimes = value
end

--获取领取次数
function SevenRewardCtrl:getRewardTimes()
	return self.rewardTimes
end

--获取领取状态
function SevenRewardCtrl:getRewardFlag()
	return self.rewardFlag
end

--客户端API
--领取奖励
function World_EveryDayReward_GetReward(playerID, bool)
	local playerObj = Player:getPlayerFromID(playerID)
	if isEmpty(playerObj) then
		return
	end
	playerObj:GetReward()
end