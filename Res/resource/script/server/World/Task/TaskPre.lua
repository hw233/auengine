--TaskPre.lua
local WRITEDBTYPE = {}
WRITEDBTYPE.SAVEDB = 0		--�������ݿ�
WRITEDBTYPE.UPDATEDB = 1	--�������ݿ�
WRITEDBTYPE.NOSAVE = 3		--����������

local PostConTypeCtl = {}	--������������
local CompleteTermCtrl = {} --�����������
local FollowUpCtrl = {}		--������ɺ���
local RepayFollowUp = {}	--��ȡ��������

POSTCONTYPE = {}
POSTCONTYPE.STARTTASK = 0	--��ʼ����
POSTCONTYPE.PLAYERLEVEL = 1	--�������
POSTCONTYPE.POSTTAST = 2	--��������
POSTCONTYPE.OPENSYS = 3		--ϵͳ���ܿ���
POSTCONTYPE.PLAYESTROY = 4	--����Ի�

local TASTTYPE = {}
TASTTYPE.DEFAULTTAST = 0--Ĭ������
TASTTYPE.DAYTAST = 1	--�ճ�
TASTTYPE.ZHUXIAN = 2	--����
TASTTYPE.LEVELAWARD = 3	--�ȼ�
TASTTYPE.ACHIEVEMENT = 4--�ɾ�

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
	--�ж�ϵͳ�Ƿ񿪷�
	return true
end

PostConTypeCtl["PRE"..POSTCONTYPE.PLAYESTROY] = function(player, storyID)
	--�жϾ���������
	return true
end

--������ɺ�������
--Ĭ������
FollowUpCtrl["POST_"..TASTTYPE.DEFAULTTAST] = function(player, taskObject)
	return true
end
--����
FollowUpCtrl["POST_"..TASTTYPE.ZHUXIAN] = function(player, taskObject)
	return true
end
--�ճ�
FollowUpCtrl["POST_"..TASTTYPE.DAYTAST] = function(player, taskObject)
	return true
end
--�ȼ�
FollowUpCtrl["POST_"..TASTTYPE.LEVELAWARD] = function(player, taskObject)
	return true
end
--�ɾ�
FollowUpCtrl["POST_"..TASTTYPE.ACHIEVEMENT] = function(player, taskObject)
	local taskCfg = TaskBase:get_taskConfig(taskObject.taskID)
	local achievementPoint = taskCfg["TaskPoint"]
	player:set_playerTalentPoint(player.achievementPoint + achievementPoint)
	player:achOpenPlayerTalent()
	return true
end

--��ȡ������������
--����
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
	--���ͽ���
	print("������������ȡ�ɹ�",nextTaskID)
	player:sendTaskReward(taskAwardCfg)
	return true
end
--�ճ�
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
--�ȼ�
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
	--���ͽ���
	print("���͵ȼ������ɹ�")
	--player:sendTaskReward(taskAwardCfg)
	return true
end
--�ɾ�
RepayFollowUp["POST_"..TASTTYPE.ACHIEVEMENT] = function(player, param)
	local taskCfg = TaskBase:get_taskConfig(param)
	local taskAwardCfg = taskCfg["TaskPayValue"]
	player.taskList[param].taskEnd = 1
	player:sendTaskReward(taskAwardCfg)
	return false
end


--����˰�����
local SEVER_TYPE_TRIGGER = {}
SEVER_TYPE_TRIGGER.TYPE_PLAYERLV	= 101			--���˹��ȼ�
SEVER_TYPE_TRIGGER.TYPE_BUILDNUM	= 102			--��ɽ���
SEVER_TYPE_TRIGGER.TYPE_ITEMNUM		= 103			--�����Ʒ
SEVER_TYPE_TRIGGER.TYPE_HERONUM		= 104			--��ó���
SEVER_TYPE_TRIGGER.TYPE_STRENGTHEN	= 105			--ǿ��װ��
SEVER_TYPE_TRIGGER.TYPE_HEROLEVEL	= 106			--����ȼ�
SEVER_TYPE_TRIGGER.TYPE_ALLOTNUM	= 107			--�����˿�
SEVER_TYPE_TRIGGER.TYPE_PASSSPACE	= 108			--ͨ�ض�������
SEVER_TYPE_TRIGGER.TYPE_OPENSURFACE	= 109			--�����ر�
SEVER_TYPE_TRIGGER.TYPE_PETSPLAY	= 110			--��������
SEVER_TYPE_TRIGGER.TYPE_KJLEVELUP	= 111			--�Ƽ�����
SEVER_TYPE_TRIGGER.TYPE_STUDYTALENT	= 305			--ѧϰ�츳
SEVER_TYPE_TRIGGER.TYPE_HIRERK 		= 113			--��ļ�˿�


--����˰�������
SEVER_TYPE_TRIGGER_NO = {}
SEVER_TYPE_TRIGGER_NO.TYPE_NPC			= 201			--npc�Ի�
SEVER_TYPE_TRIGGER_NO.TYPE_BACKCITY		= 202			--�س�
SEVER_TYPE_TRIGGER_NO.TYPE_LIANJIN		= 301			--����
SEVER_TYPE_TRIGGER_NO.TYPE_DUBO			= 302			--�Ĳ�
SEVER_TYPE_TRIGGER_NO.TYPE_BREAD		= 303			--�����
SEVER_TYPE_TRIGGER_NO.TYPE_KILLKW		= 304			--ɱ������
SEVER_TYPE_TRIGGER_NO.TYPE_BIGMAP		= 112			--����󸱱�

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