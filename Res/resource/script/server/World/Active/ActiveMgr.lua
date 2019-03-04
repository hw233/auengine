--ActiveMgr.lua
require "resource.script.server.Game.Active.Active"

ActiveMgr = {}
ActiveMgr.Actives = {}--��б�

--�����
function ActiveMgr:openActive(actionArg)
	local activeID = actionArg[1]
	local _active = ActiveMgr.Actives[activeID]
	
	if not isEmpty(_active) then
		PrintError("��Ѿ�����"..activeID)
		return
	end
	
	_active = Active:createActive(activeID)
	_active:setState(ACTIVE_STATE.OPEN)
	self.Actives[activeID] = _active
	
	_active:checkOpenAcitveGetReward()
--	print("�����"..activeID)
end

--�������еĻ��ʱʹ��
function ActiveMgr:openAllActive()
	
end

--�����
function ActiveMgr:closeActive(actionArg)
	local activeID = actionArg[1]
	local _active = ActiveMgr.Actives[activeID]
	
	if isEmpty(_active) then
		PrintError(activeID)
	end
	
	_active:setState(ACTIVE_STATE.AWARD)
	_active:statisticsAcitve()
end

--��콱����
function ActiveMgr:endGetAward(actionArg)
	local activeID = actionArg[1]
	local _active = ActiveMgr.Actives[activeID]
	print("���������",actionArg[1], _active)
	if isEmpty(_active) then
		return
	end
	self:deleteActive(activeID)
end

--ɾ���
function ActiveMgr:deleteActive(activeID)
	ActiveMgr.Actives[activeID] = nil
end

--���״̬
function ActiveMgr:checkActiveState(activeID)
	local _active = ActiveMgr.Actives[activeID]
	
	if isEmpty(_active) then
		return false
	end
	
	if _active.activeState == ACTIVE_STATE.OPEN then
		return true
	end
	
	return false
end

--��齱��
function ActiveMgr:checkActiveData(activeID, playerDBID)
	local _active = ActiveMgr.Actives[activeID]
	
	if isEmpty(_active) then
		return false
	end
	if _active.activeState ~= ACTIVE_STATE.AWARD then
		return false
	end
	return _active:checkAward(playerDBID)
end