--TaskBase.lua
require "resource.script.server.Config.Task.TaskConfig"
require "resource.script.server.Config.Task.TASK_ACHIEVEMENT"
require "resource.script.server.Config.Player.SYSTEMOPEN"

local taskPre = require "resource.script.server.World.Task.TaskPre"
local taskFun = require "resource.script.server.World.Task.TaskFun"

TaskBase = {}

function TaskBase:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.parentDBID = 0
	self.taskID = 0
	self.taskType = 0		--类型
	self.taskState = 0		--(0未完成1完成)
	self.taskEnd = 0		--(0未领取1领取)
	self.taskWriteDB = 0	--是否写入库
	self.taskProgress = 0	--进度
	return object
end

function TaskBase:createFromDB( playerDBID, taskID, taskType, taskState, taskEnd, taskProgress, taskWriteDB)
	local _task = TaskBase:New()
	_task.parentDBID = playerDBID
	_task.taskID = taskID
	_task.taskType = taskType
	_task.taskState = taskState
	_task.taskEnd = taskEnd
	_task.taskProgress = taskProgress
	_task.taskWriteDB = taskWriteDB
	return _task
end

function TaskBase:create( playerDBID, taskID, taskState, taskEnd, taskProgress, taskWriteDB )
	local taskConfig = TaskBase:get_taskConfig(taskID)
	if isEmpty(taskConfig) then
		return nil
	end
	local taskType = taskConfig["TaskType"]
	if taskWriteDB == taskPre.WRITEDBTYPE.UPDATEDB then
		print("update to DB")
		Au.queryQueue("UPDATE tb_Task SET taskID="..taskID..
			",taskState="..taskState..",taskEnd="..taskEnd..
			",taskProgress="..taskProgress..
			" WHERE playerDBID="..playerDBID.." AND taskType="..taskType..";")
	elseif taskWriteDB == taskPre.WRITEDBTYPE.SAVEDB then
		Au.queryQueue("CALL update_tb_Task("..playerDBID..","..taskID..","..taskType..","..taskState..
		","..taskEnd..","..taskProgress..");")
	else
		
	end
	return TaskBase:createFromDB( playerDBID, taskID, taskType, taskState, taskEnd, taskProgress, taskWriteDB )
end

function TaskBase:WriteDB()
	Au.queryQueue("CALL update_tb_Task("..self.parentDBID..","
					..self.taskID..","
					..self.taskType..","
					..self.taskState..","
					..self.taskEnd..","
					..self.taskProgress..
					");")
end

--默认开放的成就
function TaskBase:getDefaultAch()
	return TASK_ACHIEVEMENT
end

--判断任务是否直接完成
function TaskBase:checkCompleteTask(playerOBJ)
	local taskConfig = TaskBase:get_taskConfig(self.taskID)
	local completeType = taskConfig["TaskCompleteType"]
	local completeID = taskConfig["TaskCompleteID"]
	local completeParm = taskConfig["TaskCompleteParamList"]
	if completeType == nil or completeID == nil or completeParm == nil then
		PrintError("FunctionName checkCompleteTask task config error,taskID = ",self.taskID)
		return
	end
	if completeType == 1 or table_has_Key( SEVER_TYPE_TRIGGER_NO, completeID ) then--客户端和服务端无类型触发情况
		return
	end
	if taskPre.CompleteTermCtrl["TERM"..completeID] == nil or type(taskPre.CompleteTermCtrl["TERM"..completeID]) ~= "function" then
		PrintError("FunctionName checkCompleteTask task completeFunction error,taskID = ",self.taskID,"completeID = ",completeID)
		return
	end
	if taskPre.CompleteTermCtrl["TERM"..completeID]( playerOBJ, self, completeParm ) == true then
		self.taskState = 1
	end
end

--任务状态改变
function TaskBase:set_completeTask()
	self.taskState = 1
end

--任务完成后续操作
function TaskBase:followUpOnCompleteTask(playerOBJ)
	if taskPre.FollowUpCtrl["POST_"..self.taskType]( playerOBJ, self ) == true then
		print("任务完成后续操作", self.taskType, self.taskID)
	end
	taskFun.TaskFun:send_completeTask_Client( playerOBJ.playerID, self.taskID )
end

--领取奖励后续操作
function TaskBase:receiveTaskOnSatisfy(playerOBJ, satisfyType, param)
	if taskPre.RepayFollowUp["POST_"..satisfyType](playerOBJ, param) == true then
		print("任务领取奖励后续操作")
	end
	if satisfyType == taskPre.TASTTYPE.ACHIEVEMENT then
		taskFun.TaskFun:send_TaskGetReward_toClient( playerOBJ.playerID, param, 1 )
	else
		taskFun.TaskFun:send_DelTask_Client(playerOBJ.playerID, param)
	end
end

function TaskBase:get_taskConfig(taskID)
	return Task_Config["task_"..taskID]
end

function TaskBase:get_taskCompleteCfg()
	local taskConfig = self:get_taskConfig(self.taskID)
	local completeID = taskConfig["TaskCompleteID"]
	local completeParm = taskConfig["TaskCompleteParamList"]
	if completeID == nil or completeParm == nil then
			PrintError("FunctionName get_taskCompleteCfg task config error,taskID = ",task.taskID)
		return
	end
	return completeID, completeParm
end

--各类任务触发完成
--玩家等级类任务触发完成
function TaskBase:completePlayerLvTask(playerOBJ, level)
	for __, taskObj in pairs(playerOBJ.taskList) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_PLAYERLV) and (assert(completeParam[1]) <= level)
					and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
end

--建筑类任务触发完成
function TaskBase:completeBuildTask(playerOBJ, buildType, buildNum)
--	for __, taskObj in pairs(playerOBJ.taskList) do
--		local completeID, completeParam = taskObj:get_taskCompleteCfg()
--		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_BUILDNUM) and (assert(completeParam[1]) == buildType)
--						and (assert(completeParam[2]) <= buildNum) and taskObj.taskState ~= 1
--		if check then
--			playerOBJ:completeTask(taskObj)
--		end
--	end
	--建筑触发进程开放
	for __, sysCfg in pairs(SYSTEMOPEN) do
		local check = (assert(sysCfg["CLOSECOND"]) == taskPre.SEVER_TYPE_TRIGGER.TYPE_BUILDNUM) and (assert(sysCfg["PARAM"]) == buildType)
		if check then
			playerOBJ:openSystemState(sysCfg["SYSID"], sysCfg["OPENBUILD"])
		end
	end
end

--招募人口触发完成
function TaskBase:completeHireRK( playerOBJ )
	for __, sysCfg in pairs(SYSTEMOPEN) do
		local check = (assert(sysCfg["CLOSECOND"]) == taskPre.SEVER_TYPE_TRIGGER.TYPE_HIRERK) and ((assert(sysCfg["PARAM"]) >= playerOBJ.playerRenKouTotal))

		if check then
			playerOBJ:openSystemState(sysCfg["SYSID"], sysCfg["OPENBUILD"])
		end
	end	
end

--物品类任务触发完成
function TaskBase:completeItemTask(playerOBJ, itemType, itemNum)
	for __, taskObj in pairs(playerOBJ.taskList) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = ( completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_USESOURCE ) and (assert(completeParam[1]) == itemType)
					and (assert(completeParam[2]) == itemNum) and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
end

--宠物数量任务触发完成
function TaskBase:completeHeroNumTask(playerOBJ, heroID, heroNum)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_HERONUM) and (assert(completeParam[1]) == heroID) and (assert(completeParam[2]) >= heroNum)
					and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
	for __, sysCfg in pairs(SYSTEMOPEN) do
		local check = (assert(sysCfg["CLOSECOND"]) == taskPre.SEVER_TYPE_TRIGGER.TYPE_HERONUM)
		if check then
			playerOBJ:openSystemState(sysCfg["SYSID"], sysCfg["OPENBUILD"])
		end
	end
end

--强化装备任务触发完成
function TaskBase:completeOnEquitLevelUp(playerOBJ, itemID, lv)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_STRENGTHEN) and (assert(completeParam[1]) == itemID) and (assert(completeParam[2]) <= lv)
					and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
end

--宠物升级等级任务触发完成
function TaskBase:completeHeroLevelTask(playerOBJ, heroID, heroLv)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_HEROLEVEL) and (assert(completeParam[1]) == heroID) and (assert(completeParam[2])) <= heroLv
					and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end	
end

--分配人口任务触发完成
function TaskBase:completeAllotPeople(playerOBJ, allotType)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_ALLOTNUM) and (assert(completeParam[1]) == allotType) and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
	for __, sysCfg in pairs(SYSTEMOPEN) do
		local check = (assert(sysCfg["CLOSECOND"]) == taskPre.SEVER_TYPE_TRIGGER.TYPE_ALLOTNUM) and (assert(sysCfg["PARAM"]) == allotType)
		if check then
			playerOBJ:openSystemState(sysCfg["SYSID"], sysCfg["OPENBUILD"])
		end
	end
end

--通关二级副本任务触发完成
function TaskBase:completePassSpace(playerOBJ, second_space_id)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_PASSSPACE) and (assert(completeParam[1]) == second_space_id) and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
	for __, sysCfg in pairs(SYSTEMOPEN) do
		local check = (assert(sysCfg["CLOSECOND"]) == taskPre.SEVER_TYPE_TRIGGER.TYPE_PASSSPACE) and (assert(sysCfg["PARAM"]) == second_space_id)
		if check then
			playerOBJ:openSystemState(sysCfg["SYSID"], sysCfg["OPENBUILD"])
		end
	end
end

--扩建地表任务触发完成
function TaskBase:completeOpensurface(playerOBJ)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_OPENSURFACE) and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end	
end

--宠物上阵任务触发完成
function TaskBase:completePetsPlay(playerOBJ)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_PETSPLAY) and taskObj.taskState ~= 1
		if check then
			if (playerOBJ:checkPetsPlay()) then
				playerOBJ:completeTask(taskObj)
			end
		end
	end
end

--科技升级任务触发完成
function TaskBase:completeTeckLevelUp(playerOBJ, teckID, teckLevel)
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_KJLEVELUP) and (assert(completeParam[1]) == teckID) and (assert(completeParam[2]) >= teckLevel) and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end
end

--激活天赋
function TaskBase:completeStudyTalent( playerOBJ, talentID )
	for __, taskObj in pairs( playerOBJ.taskList ) do
		local completeID, completeParam = taskObj:get_taskCompleteCfg()
		local check = (completeID == taskPre.SEVER_TYPE_TRIGGER.TYPE_STUDYTALENT) and (assert(completeParam[1]) == talentID) and taskObj.taskState ~= 1
		if check then
			playerOBJ:completeTask(taskObj)
		end
	end	
end

--吃面包操作
function TaskBase:completeEatBread( playerOBJ, taskParam )
	for __,taskObject in pairs(playerOBJ.taskList) do
		local completeID ,completeConfig = taskObject:get_taskCompleteCfg()
		if completeID == SEVER_TYPE_TRIGGER_NO.TYPE_BREAD and taskObject.taskState ~= 1 and taskObject.taskEnd~=1 then
			taskObject.taskProgress = taskObject.taskProgress + taskParam
			if taskObject.taskProgress >= completeConfig[1] then
				taskObject.taskProgress = completeConfig[1]
				playerOBJ:completeTask(taskObject)
			end
		end
	end	
end

--触发完成服务端(无类型)
function TaskBase:completeTaskServerTrigger(playerOBJ, taskCompleteID, param)
	for __, taskObject in pairs(playerOBJ.taskList) do
		local completeID,completeCfg = taskObject:get_taskCompleteCfg()
		local check = (taskCompleteID == completeID) and (taskObject.taskState ~= 1) and (taskObject.taskEnd ~= 1)
		if check then
			playerOBJ:completeTask(taskObject)
		end
	end
end

--系统开放无类型触发
function TaskBase:completeServerOpenSys(playerOBJ, taskCompleteID, param)
	for __, sysCfg in pairs(SYSTEMOPEN) do
		local check = (assert(sysCfg["CLOSECOND"]) == taskCompleteID)
		if not isEmpty(param) then
			check = (assert(sysCfg["PARAM"]) == param) and check
		end
		if check then
			playerOBJ:openSystemState(sysCfg["SYSID"], sysCfg["OPENBUILD"])
		end
	end
end

--触发接取任务
function TaskBase:receiveTaskFromTrigger(playerOBJ, condition, conParam)
	--根据类型获取接取任务的配置
	if PostConTypeCtl["PRE"..condition](playerOBJ, conParam) == true then
		
	end
end

--完成客户端任务
function TaskBase:completeTaskClientTrigger( playerOBJ, taskID, taskParam )
	local taskObject = playerOBJ.taskList[taskID]
	if isEmpty(taskObject) then
		return
	end
	local taskConfig = TaskBase:get_taskConfig(taskID)
	local check = (taskObject.taskState ~= 0) or (taskConfig["TaskCompleteType"] ~= 1) 
	if check then
		return
	end
	if taskConfig["TaskType"] == taskPre.TASTTYPE.ACHIEVEMENT then
		TaskBase:completeEatBread( playerOBJ, taskParam )
	else
		playerOBJ:completeTask(taskObject)
	end
end

--计数任务操作
function TaskBase:GetCountingTask(playerOBJ, taskCompleteID)
	for __,taskObject in pairs(playerOBJ.taskList) do
		local completeID ,completeConfig = taskObject:get_taskCompleteCfg()
		if completeID == taskCompleteID and taskObject.taskState ~= 1 and taskObject.taskEnd~=1 then
			taskObject.taskProgress = taskObject.taskProgress + 1
			if taskObject.taskProgress >= completeConfig[1] then
				playerOBJ:completeTask(taskObject)
			end
		end
	end
end