-- SevenRewardCtrl.lua

require "resource.script.server.Config.SevenReward.SEVENREWARDCFG"

--�궨��
local REWARD_MACRO = {}
REWARD_MACRO.REWARD_FLAG = 0      -- 0-������ȡ����
REWARD_MACRO.REWARD_PERIOD = 9    -- ��ȡ����,�ۻ���ȡ7�κ�����
REWARD_MACRO.REWARD_STATUS = 1    -- ��ȡ״̬λ,1-�Ѿ���ȡ

SevenRewardCtrl = {}

function SevenRewardCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.rewardTimes = 1                --��ȡ����
	self.rewardFlag = 0                 --��ȡ��ʶ 0-û����ȡ��1-�Ѿ���ȡ
	return obj
end

--��ȡ����
function SevenRewardCtrl:GetReward()
--�ж�����Ƿ��Ѿ���ȡ������
	if not self:isRewardFlag() then
		return
	end
--��ȡ��ȡ����
	local rewardTime = self:getRewardTimes()              
--��ȡ��ȡ��Ʒ����
	local rewardList = self:readCfg(rewardTime)
	if isEmpty(rewardList) then
		return
	end
--��ȡ���� (������Ʒ�ӿ�)
	self:createItemList(rewardList)
--�޸���ȡ״̬λ
	self:setRewardFlag(REWARD_MACRO.REWARD_STATUS)   -- �޸���ȡ״̬λ 0-û����ȡ�� 1-�Ѿ���ȡ
--�ظ��ͻ���
	self:SendRewardTimesAndStatus()
	
end

--���������ȡ�Ĵ�����״̬
function SevenRewardCtrl:SendRewardTimesAndStatus()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_REWARD_TIMESANDTATUS)
	Au.addUint8(self.rewardTimes)        --��ȡ����
	Au.addUint8(self.rewardFlag)         --��ȡ��״̬
	Au.messageEnd()
end

--�ж�����Ƿ���ȡ�˽���
function SevenRewardCtrl:isRewardFlag()
	local isBOOl = false
	
	if REWARD_MACRO.REWARD_FLAG == self.rewardFlag then
		isBOOl = true
	end
	
	return isBOOl
end

--��ȡ����Ӧ����ȡ����
function SevenRewardCtrl:getRewardNums(rewardTime)
	local res = 0
	if REWARD_MACRO.REWARD_PERIOD == rewardTime then
		res = 1
	else
		res = rewardTime + 1
	end
	
	return res  
end

--����7����ȡ����״̬
function SevenRewardCtrl:UpdateRewardFlag()
	if self.rewardFlag == 0 then
		return
	else
		self.rewardFlag = 0    --�賿������ȡ״̬ 0-������ȡ��1-�Ѿ���ȡ
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

-- ��ȡ�����ļ�
function SevenRewardCtrl:readCfg(index)
	return SEVEN_REWARD[index]
end

--������ȡ״̬λ
function SevenRewardCtrl:setRewardFlag(value)
	if value == nil or value < 0 or value > 1 then
		return
	end
	self.rewardFlag = value
end

--������ȡ����
function SevenRewardCtrl:setRewardTimes(value)
	if value == nil or value <= 0 or value > 9 then
		print("error",value)
		return
	end
	self.rewardTimes = value
end

--��ȡ��ȡ����
function SevenRewardCtrl:getRewardTimes()
	return self.rewardTimes
end

--��ȡ��ȡ״̬
function SevenRewardCtrl:getRewardFlag()
	return self.rewardFlag
end

--�ͻ���API
--��ȡ����
function World_EveryDayReward_GetReward(playerID, bool)
	local playerObj = Player:getPlayerFromID(playerID)
	if isEmpty(playerObj) then
		return
	end
	playerObj:GetReward()
end