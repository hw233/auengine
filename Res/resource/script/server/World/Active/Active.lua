--Active.lua
ACTIVID = {}
ACTIVID.PLAYER_LEVEL = 103	--ÿ�����

local statisticsActiveCtl = {}	--ͳ����ҽ�������
local checkJoinCtl = {}			--��������Ƿ��ܲμӸû����

statisticsActiveCtl["activeID"..ACTIVID.PLAYER_LEVEL] = function (playerDBID)
	
	return true
end


ACTIVE_STATE = {}

ACTIVE_STATE.CLOSE = 0		--�ر�
ACTIVE_STATE.OPEN = 1		--����
ACTIVE_STATE.AWARD = 2		--����

Active = {}

function Active:New()
	local object = setmetatable({},self)
	self.__index = self
	self.activeID = 0							--�ID
	self.activeState = ACTIVE_STATE.CLOSE		--�����״̬
	self.activeGetReward = 0					--�Ƿ������콱����(0:�Զ� 1:����)
	self.activeJoinLimit = 0					--��������(0:�������1:�������)
	object.activeJoinData = nil					--�����������(������acriveJoinLimitΪ1�����)
	object.activeData = nil						--�콱�������
	object.saveGetRewardActive = nil			--������ȡ���������
	return object
end

--�ı�
function Active:setState(state)
	self.activeState = state
end

--�����콱״̬
function Active:setGetReward(value)
	self.activeGetReward = value
end

--���ò�������
function Active:setJoinLimit(value)
	self.activeJoinLimit = value
end

--�����
function Active:createActive(activeID)
	local _active = Active:New()
	_active.activeID = activeID
	_active.activeData = {}
	return _active
end

--�������Ƿ��н���
function Active:checkAward(databaseID)
	if self.activeData[databaseID] == 1 then
		return true
	end
	return false
end

--�����������ѹ��
function Active:pushActivePlayerData(playerDBID)
	if table_has_Key(self.activeJoinData, playerDBID) == true then
		return
	end
	table.insert(self.activeJoinData, playerDBID)
end

--ͳ����������ڻ����ɵĻ
function Active:statisticsAcitve()
	if self.activeJoinLimit == 1 then--�������
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

--�����������ȡ�����Ļ
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
	
	local rewardConfig = {}--���������
		
	if not isEmpty(rewardConfig) then
		
	end
	
	self:handleGetDataAward(_player)--��ȡ�꽱���ĺ�������
end

--����꽱���ĺ�������
function Active:handleGetDataAward(_player)
	self.activeData[_player.databaseID] = nil
	self.saveGetRewardActive[_player.databaseID] = 0
	
	if getTableLength(self.activeData) == 0 then
		ActiveMgr:deleteActive(self.activeID)
	end	
end