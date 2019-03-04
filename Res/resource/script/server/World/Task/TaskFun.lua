--TaskFun.lua

local TaskFun = {}

function TaskFun:send_newTask_client( playerID, taskID, taskState )
	-- body
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_NEW_TASK)
	Au.addUint32(taskID)
	Au.addUint8(taskState)
	Au.messageEnd()
end

function TaskFun:send_completeTask_Client( playerID, taskID )
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_COMPLETE_TASK)
	Au.addUint32(taskID)
	Au.messageEnd()
end

function TaskFun:send_DelTask_Client( playerID, taskID)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_DEL_TASK)
	Au.addUint32(taskID)
	Au.messageEnd()
end

function TaskFun:send_TaskProgress_Client( playerID, taskID, taskProgress)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_TASK_PROGRESS)
	Au.addUint32(taskID)
	Au.addUint32(taskProgress)
	Au.messageEnd()
end

function TaskFun:send_TaskGetReward_toClient( playerID, taskID, taskEnd)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_TASK_GETREWARD)
	Au.addUint32(taskID)
	Au.addUint8(taskEnd)
	Au.messageEnd()
end


return {TaskFun = TaskFun}