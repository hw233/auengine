--TaskPre.lua
local WRITEDBTYPE = {}
WRITEDBTYPE.SAVEDB = 0		--保存数据库
WRITEDBTYPE.UPDATEDB = 1	--更新数据库
WRITEDBTYPE.NOSAVE = 3		--不保存数据

local PostConTypeCtl = {}	--后置条件控制
local CompleteTermCtrl = {} --完成条件控制
local FollowUpCtrl = {}		--任务完成后续
local RepayFollowUp = {}	--领取奖励后续

POSTCONTYPE = {}
POSTCONTYPE.STARTTASK = 0	--起始任务
POSTCONTYPE.PLAYERLEVEL = 1	--玩家升级
POSTCONTYPE.POSTTAST = 2	--后置任务
POSTCONTYPE.OPENSYS = 3		--系统功能开放
POSTCONTYPE.PLAYESTROY = 4	--剧情对话

local TASTTYPE = {}
TASTTYPE.DEFAULTTAST = 0--默认任务
TASTTYPE.DAYTAST = 1	--日常
TASTTYPE.ZHUXIAN = 2	--主线
TASTTYPE.LEVELAWARD = 3	--等级
TASTTYPE.ACHIEVEMENT = 4--成就

PostConTypeCtl["PRE"..POSTCONTYPE.STARTTASK] = function(player)
	return true
end

PostConTypeCtl["PRE"..POSTCONTYPE.PLAYERLEVEL] = function(player, level)
--	return player.leadObject.heroLevel >= level
	return 1 >= level
end

PostConTypeCtl["PRE"..POSTCONTYPE.POSTTAST] = function(player, taskID)
	local taskObject = player.taskList[taskID]
	if taskObject ~= nil and taskObject.taskEnd == 1 then
		return false
	end
	return true
end

PostConTypeCtl["PRE"..POSTCONTYPE.OPENSYS] = function(player, sysID)
	--判断系统是否开放
	return true
end

PostConTypeCtl["PRE"..POSTCONTYPE.PLAYESTROY] = function(player, storyID)
	--判断剧情完成情况
	return true
end

--任务完成后续操作
--默认任务
FollowUpCtrl["POST_"..TASTTYPE.DEFAULTTAST] = function(player, taskObject)
	return true
end
--主线
FollowUpCtrl["POST_"..TASTTYPE.ZHUXIAN] = function(player, taskObject)
	return true
end
--日常
FollowUpCtrl["POST_"..TASTTYPE.DAYTAST] = function(player, taskObject)
	return true
end
--等级
FollowUpCtrl["POST_"..TASTTYPE.LEVELAWARD] = function(player, taskObject)
	return true
end
--成就
FollowUpCtrl["POST_"..TASTTYPE.ACHIEVEMENT] = function(player, taskObject)
	local taskCfg = TaskBase:get_taskConfig(taskObject.taskID)
	local achievementPoint = taskCfg["TaskPoint"]
	player:set_playerTalentPoint(player.achievementPoint + achievementPoint)
	player:achOpenPlayerTalent()
	return true
end

--领取奖励后续操作
--主线
RepayFollowUp["POST_"..TASTTYPE.ZHUXIAN] = function(player, param)
	local taskCfg = TaskBase:get_taskConfig(param)
	local taskAwardCfg = taskCfg["TaskPayValue"]
	local postTask = taskCfg["TaskPostCondition"]
	local nextTaskID = 0
	for __,tb in pairs(postTask) do
		if tb[1] ~= 0 and tb[1] == POSTCONTYPE.POSTTAST then
			nextTaskID = tb[2]
		end
	end
	player.taskList[param].taskEnd = 1
	if nextTaskID ~= 0 then
		player:receiveTask(nextTaskID, WRITEDBTYPE.UPDATEDB, 0)
		player.taskList[param] = nil
	end
	--发送奖励
	print("主线任务奖励领取成功",nextTaskID)
	player:sendTaskReward(taskAwardCfg)
	return true
end
--日常
RepayFollowUp["POST_"..TASTTYPE.DAYTAST] = function(player, param)
	local taskCfg = TaskBase:get_taskConfig(param)
	local taskAwardCfg = taskCfg["TaskPayValue"]
	local postTask = taskCfg["TaskPostCondition"]
	local nextTaskID = 0
	for __,tb in pairs(postTask) do
		if tb[1] ~= 0 and tb[1] == POSTCONTYPE.POSTTAST then
			nextTaskID = tb[2]
		end
	end
	
end
--等级
RepayFollowUp["POST_"..TASTTYPE.LEVELAWARD] = function(player, param)
	local taskCfg = TaskBase:get_taskConfig(param)
	local taskAwardCfg = taskCfg["TaskPayValue"]
	local postTask = taskCfg["TaskPostCondition"]
	local nextTaskID = 0
	for __,tb in pairs(postTask) do
		if tb[1] ~= 0 and tb[1] == POSTCONTYPE.POSTTAST then
			nextTaskID = tb[2]
		end
	end
	player.taskList[param].taskEnd = 1
	if nextTaskID ~= 0 then
		player:receiveTask(nextTaskID, WRITEDBTYPE.UPDATEDB, 0)
		player.taskList[param] = nil
	end
	--发送奖励
	print("发送等级奖励成功")
	--player:sendTaskReward(taskAwardCfg)
	return true
end
--成就
RepayFollowUp["POST_"..TASTTYPE.ACHIEVEMENT] = function(player, param)
	local taskCfg = TaskBase:get_taskConfig(param)
	local taskAwardCfg = taskCfg["TaskPayValue"]
	player.taskList[param].taskEnd = 1
	player:sendTaskReward(taskAwardCfg)
	return false
end


--服务端按类型
local SEVER_TYPE_TRIGGER = {}
SEVER_TYPE_TRIGGER.TYPE_PLAYERLV	= 101			--主人公等级
SEVER_TYPE_TRIGGER.TYPE_BUILDNUM	= 102			--完成建筑
SEVER_TYPE_TRIGGER.TYPE_ITEMNUM		= 103			--获得物品
SEVER_TYPE_TRIGGER.TYPE_HERONUM		= 104			--获得宠物
SEVER_TYPE_TRIGGER.TYPE_STRENGTHEN	= 105			--强化装备
SEVER_TYPE_TRIGGER.TYPE_HEROLEVEL	= 106			--宠物等级
SEVER_TYPE_TRIGGER.TYPE_ALLOTNUM	= 107			--分配人口
SEVER_TYPE_TRIGGER.TYPE_PASSSPACE	= 108			--通关二级副本
SEVER_TYPE_TRIGGER.TYPE_OPENSURFACE	= 109			--扩建地表
SEVER_TYPE_TRIGGER.TYPE_PETSPLAY	= 110			--宠物上阵
SEVER_TYPE_TRIGGER.TYPE_KJLEVELUP	= 111			--科技升级
SEVER_TYPE_TRIGGER.TYPE_STUDYTALENT	= 305			--学习天赋
SEVER_TYPE_TRIGGER.TYPE_HIRERK 		= 113			--招募人口


--服务端按无类型
SEVER_TYPE_TRIGGER_NO = {}
SEVER_TYPE_TRIGGER_NO.TYPE_NPC			= 201			--npc对话
SEVER_TYPE_TRIGGER_NO.TYPE_BACKCITY		= 202			--回城
SEVER_TYPE_TRIGGER_NO.TYPE_LIANJIN		= 301			--炼金
SEVER_TYPE_TRIGGER_NO.TYPE_DUBO			= 302			--赌博
SEVER_TYPE_TRIGGER_NO.TYPE_BREAD		= 303			--吃面包
SEVER_TYPE_TRIGGER_NO.TYPE_KILLKW		= 304			--杀死怪物
SEVER_TYPE_TRIGGER_NO.TYPE_BIGMAP		= 112			--进入大副本

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_PLAYERLV] = function(player, nowTaskObj, param)
	if #param ~= 1 or type(param[1]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_PLAYERLV paramList error")
		return false
	end
--	return player.leadObject.heroLevel >= param[1]
	return 1 >= param[1]
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_BUILDNUM] = function(player, nowTaskObj, param)
	if #param ~= 2 or type(param[1])  ~= "number" or type(param[2]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_BUILDNUM paramList error")
		return false
	end
	return player:getBuildNumSame(param[1]) >= param[2]
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_ITEMNUM] = function ( player, nowTaskObj, param )
	-- body
	if #param ~= 2 or type(param[1])  ~= "number" or type(param[2]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_ITEMNUM paramList error")
		return false
	end
	return player:IsItemEqualToValue( param[1], param[2] )
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_HERONUM] = function ( player, nowTaskObj, param )
	-- body
	if #param ~= 2 or type(param[1])  ~= "number" or type(param[2]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_HERONUM paramList error")
		return false
	end
	return player:getHeroNumFromID(param[1]) >= param[2]
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_HEROLEVEL] = function ( player, nowTaskObj, param )
	if #param ~= 2 or type(param[1])  ~= "number" or type(param[2]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_HEROLEVEL paramList error")
		return false
	end
	return player:checkHeroLevel(param[1], param[2])
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_STRENGTHEN] = function ( player, nowTaskObj, param )
	if #param ~= 2 or type(param[1])  ~= "number" or type(param[2]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_STRENGTHEN paramList error")
		return false
	end
	return player:IsEquipRight(param[1],param[2])
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_ALLOTNUM] = function ( player, nowTaskObj, param )
	if #param ~= 1 or type(param[1]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_ALLOTNUM paramList error")
		return false
	end
	return true--player:checkAllotNum( param[1] )
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_PASSSPACE] = function ( player, nowTaskObj, param )
	if #param ~= 1 or type(param[1]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_PASSSPACE paramList error")
		return false
	end
	return player:checkBigMapPass( param[1] )
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_OPENSURFACE] = function ( player, nowTaskObj, param)
	if #param ~= 1 or type(param[1]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_OPENSURFACE paramList error")
		return false
	end
	return true
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_PETSPLAY] = function ( player, nowTaskObj, param)
	if #param < 1 or type(param) ~= "table" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_PETSPLAY paramList error")
		return false
	end
	return player:checkPetsPlay()
end

CompleteTermCtrl["TERM"..SEVER_TYPE_TRIGGER.TYPE_KJLEVELUP] = function ( player, nowTaskObj, param )
	if #param ~= 2 or type(param[1])  ~= "number" or type(param[2]) ~= "number" then
		PrintError("CompleteTermCtrl SEVER_TYPE_TRIGGER.TYPE_KJLEVELUP paramList error")
		return false
	end
	return player:checkTeckLevelUp(param[1], param[2])
end

return { PostConTypeCtl = PostConTypeCtl, TASTTYPE = TASTTYPE, SEVER_TYPE_TRIGGER = SEVER_TYPE_TRIGGER, CompleteTermCtrl = CompleteTermCtrl,WRITEDBTYPE = WRITEDBTYPE,FollowUpCtrl = FollowUpCtrl,RepayFollowUp = RepayFollowUp }