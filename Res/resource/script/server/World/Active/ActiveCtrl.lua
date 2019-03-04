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
	--获取奖励操作
	local _active = ActiveMgr.Actives[activeID]
	_active:getDataAward(self)
end

--玩家上线时，需要判断的活动能否领取奖励的操作
function ActiveCtrl:checkActiveStateOnLine()
	if ActiveMgr:checkActiveState(ACTIVID.DAILY_LOG) == true then
		local _active = ActiveMgr.Actives[ACTIVID.DAILY_LOG]
		if isEmpty(_active.saveGetRewardActive[self.databaseID]) then
			_active.activeData[self.databaseID] = 1
		end
	end
end

--参加某个活动
function ActiveCtrl:joinActive(activeID)
	local _active = ActiveMgr.Actives[activeID]
	if isEmpty(_active) then
		return
	end
	if _active.activeState ~= ACTIVE_STATE.OPEN then
		return
	end
	if _active.activeJoinLimit == 1 then
		--判断参加该活动的条件
	end
	_active:pushActivePlayerData(self.databaseID)
end