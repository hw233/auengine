--ActiveMgr.lua
require "resource.script.server.Game.Active.Active"

ActiveMgr = {}
ActiveMgr.Actives = {}--活动列表

--开启活动
function ActiveMgr:openActive(actionArg)
	local activeID = actionArg[1]
	local _active = ActiveMgr.Actives[activeID]
	
	if not isEmpty(_active) then
		PrintError("活动已经开启"..activeID)
		return
	end
	
	_active = Active:createActive(activeID)
	_active:setState(ACTIVE_STATE.OPEN)
	self.Actives[activeID] = _active
	
	_active:checkOpenAcitveGetReward()
--	print("开启活动"..activeID)
end

--开启所有的活动临时使用
function ActiveMgr:openAllActive()
	
end

--活动结束
function ActiveMgr:closeActive(actionArg)
	local activeID = actionArg[1]
	local _active = ActiveMgr.Actives[activeID]
	
	if isEmpty(_active) then
		PrintError(activeID)
	end
	
	_active:setState(ACTIVE_STATE.AWARD)
	_active:statisticsAcitve()
end

--活动领奖结束
function ActiveMgr:endGetAward(actionArg)
	local activeID = actionArg[1]
	local _active = ActiveMgr.Actives[activeID]
	print("活动结束操作",actionArg[1], _active)
	if isEmpty(_active) then
		return
	end
	self:deleteActive(activeID)
end

--删除活动
function ActiveMgr:deleteActive(activeID)
	ActiveMgr.Actives[activeID] = nil
end

--检测活动状态
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

--检查奖励
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