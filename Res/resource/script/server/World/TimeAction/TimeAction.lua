--TimeAction.lua
require "resource.script.server.Config.TimeAction.TimeConfig"
require "resource.script.server.World.TimeAction.Activity"

--��Ϸ�����Ա

TimeAction = {}

TimeAction.activities = {}		--��������������Ϸ�

--��ʼ���Ա
function TimeAction:initTimeAction()
	local activityOBJ = nil
	local nowTime = Au.nowTime()
	for key,activityCfg in pairs(TimeConfig) do
		if activityCfg.startTime ~= "0" then	--��0�Ļֱ������
			activityOBJ = Activity:New()
			activityOBJ:initFromCfg(activityCfg,nowTime)
			self.activities[activityOBJ.activityID] = activityOBJ
		end
	end
	Au.addTimer( 5000, 5000, "TimeAction:onTimer")
end


--���һ���µĻ
function TimeAction:addNewActivity(activityID)
	if activityID == 0 then
		return
	end
	
	if not isEmpty(self.activities[activityID]) then
		return
	end
	local activityCfg = TimeConfig["Activity_"..activityID]
	
	if isEmpty(activityCfg) then
		return
	end
	
	local activityOBJ = Activity:New()
	activityOBJ:initFromCfg(activityCfg,Au.nowTime())
	self.activities[activityOBJ.activityID] = activityOBJ
end

--ɾ���
function TimeAction:removeActivity(activityID)
	self.activities[activityID] = nil
end

--ɾ��� ͨ��actionID
function TimeAction:removeActivityFromActionID(actionID)
	for activityID,activityOBJ in pairs(self.activities) do
		if activityOBJ.Cfg.actionID == actionID then
			self:removeActivity(activityOBJ.activityID)
		end
	end
end


--�ص�
function TimeAction:onTimer()
	local nowTime = Au.nowTime()
	local activityBack = 0
	local activeTB = {}
	for activityID,activityOBJ in pairs(self.activities) do
		activityBack = activityOBJ:checkStart(nowTime)
		if activityBack ~= 0 then
			if activityBack == 1 then
				table.insert(activeTB,activityOBJ.Cfg)
			elseif activityBack == 2 then
				self:removeActivity(activityOBJ.activityID)
			end
		end
	end
	
	for i = 1 , table.getn(activeTB) do
		self:doActivity(activeTB[i])
	end
end


--ִ�л�¼�
function TimeAction:doActivity(Cfg)
	print("ִ�л:",Cfg.activityID,Cfg.actionID)
	Game:doTimeActivity(Cfg.actionID,Cfg.actionArg)
end