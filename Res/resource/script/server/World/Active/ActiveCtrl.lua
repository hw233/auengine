--ActiveCtrl.lua

ActiveCtrl = {}

function ActiveCtrl:New()
	local object = setmetatable({}, self)
	self.__index = self
	
	return object
end

function ActiveCtrl:getDataAward(activeID)
	if ActiveMgr:checkActiveData(activeID, self.databaseID) == false then
		return
	end
	--��ȡ��������
	local _active = ActiveMgr.Actives[activeID]
	_active:getDataAward(self)
end

--�������ʱ����Ҫ�жϵĻ�ܷ���ȡ�����Ĳ���
function ActiveCtrl:checkActiveStateOnLine()
	if ActiveMgr:checkActiveState(ACTIVID.DAILY_LOG) == true then
		local _active = ActiveMgr.Actives[ACTIVID.DAILY_LOG]
		if isEmpty(_active.saveGetRewardActive[self.databaseID]) then
			_active.activeData[self.databaseID] = 1
		end
	end
end

--�μ�ĳ���
function ActiveCtrl:joinActive(activeID)
	local _active = ActiveMgr.Actives[activeID]
	if isEmpty(_active) then
		return
	end
	if _active.activeState ~= ACTIVE_STATE.OPEN then
		return
	end
	if _active.activeJoinLimit == 1 then
		--�жϲμӸû������
	end
	_active:pushActivePlayerData(self.databaseID)
end