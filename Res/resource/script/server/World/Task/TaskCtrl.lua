--TaskCtrl.lua
require "resource.script.server.World.Task.TaskBase"
local taskPre = require "resource.script.server.World.Task.TaskPre"
local taskFun = require "resource.script.server.World.Task.TaskFun"

TaskCtrl = {}

function TaskCtrl:New()
	local object = setmetatable({},self)
	self.__index = self
	return object
end

function TaskCtrl:initTaskList(sqlResult, tableName)
	if isEmpty(sqlResult) then
		return
	end
	local taskID = 0
	local taskType = 0
	local taskState = 0
	local taskEnd = 0
	local taskProgress = 0
	local _task = nil

	for i=1, sqlResult:GetRowCount() do
		taskID = sqlResult:GetFieldFromCount(0):GetUInt32()
		taskType = sqlResult:GetFieldFromCount(1):GetUInt8()
		taskState = sqlResult:GetFieldFromCount(2):GetUInt8()
		taskEnd = sqlResult:GetFieldFromCount(3):GetUInt8()
		taskProgress = sqlResult:GetFieldFromCount(4):GetUInt8()
		
		_task = TaskBase:createFromDB(self.databaseID, taskID, taskType, taskState, taskEnd, taskProgress, 0)
		self.taskList[taskID] = _task
		sqlResult:NextRow()
	end
	sqlResult:Delete()
end

function TaskCtrl:WriteTaskData()
	for taskID, taskObject in pairs(self.taskList) do
		taskObject:WriteDB()
	end
end

--��ȡ����
function TaskCtrl:receiveTask(taskID, taskWriteDB, taskProgress)
	if not isEmpty(self.taskList[taskID]) then
		return
	end
	local taskObject = TaskBase:create( self.databaseID, taskID, 0, 0, taskProgress, taskWriteDB )
	if isEmpty(taskObject) then
		PrintError("FunctionName receiveTask task config error,taskID = ",taskID)
		return
	end
	self.taskList[taskObject.taskID] = taskObject
	if taskObject.taskType ~= 4 then
		taskObject:checkCompleteTask(self)
		taskFun.TaskFun:send_newTask_client(self.playerID, taskObject.taskID, taskObject.taskState)
	end
end

--����Ĭ������
function TaskCtrl:setFirstTask( taskID )
	--print("����Ĭ������", taskID,self.databaseID)
	self:receiveTask(taskID, 0, 0)
end

--Ĭ�Ͽ��ųɾ�
function TaskCtrl:setDefaultTask()
	local tb = TaskBase:getDefaultAch()
	for i=1,#tb do
		self:receiveTask(tb[i], 0, 0)
	end
end

--�������
function TaskCtrl:completeTask(task)
	task:set_completeTask()
	task:followUpOnCompleteTask(self)
end

--��ȡ����
function TaskCtrl:acceptAwardFromTask(taskID)
	local taskObject = self.taskList[taskID]
	if isEmpty(taskObject) then
		return
	end
	if taskObject.taskState == 0 or taskObject.taskEnd == 1 then
		return
	end
	print("��ȡ�������ɹ�")
	TaskBase:receiveTaskOnSatisfy(self, taskObject.taskType, taskObject.taskID)
end

function TaskCtrl:sendTaskReward( taskAwardCfg )
	-- body
	self:createItemList(taskAwardCfg)
end

--��ȡ��������ID
function TaskCtrl:getZhuXiangTask()
	-- body
	local zhuXID = 0
	for taskID,taskOBJ in pairs(self.taskList) do
		if taskOBJ.taskType == 2 then
			zhuXID = taskID
		end
	end
	return zhuXID
end

--�ͻ���
--���͵�ǰ����
function TaskCtrl:getTaskList()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_NOW_TASK)
	Au.addUint8(self.achievementPoint)		--�ɾ͵�
	for __,taskObject in pairs(self.taskList) do
		Au.addUint32(taskObject.taskID)
		Au.addUint8(taskObject.taskState)
		Au.addUint32(taskObject.taskProgress)
		Au.addUint8(taskObject.taskEnd)
	end
	Au.messageEnd()
end

--����ɾ�����
function TaskCtrl:getAchiData()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_TASK_GETACHI)
	for __,taskObject in pairs(self.taskList) do
		Au.addUint32(taskObject.taskID)
		Au.addUint8(taskObject.taskState)
		Au.addUint32(taskObject.taskProgress)
		Au.addUint8(taskObject.taskEnd)
	end
	Au.messageEnd()
end

--API
--��ȡ����
function World_TaskCtrl_acceptAwardFromTask( playerID, taskID )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:acceptAwardFromTask(taskID)
end

--������ɿͻ�������
function World_TaskCtrl_completeClientTask( playerID, taskID, taskParam )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	TaskBase:completeTaskClientTrigger(_player, taskID, taskParam)
end

function World_TaskCtrl_getAchiData( playerID )
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:getAchiData( )
end