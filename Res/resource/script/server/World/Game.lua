--Game.lua
require "resource.script.server.Macro.Macro"
require "resource.script.server.Base.Base"
require "resource.script.server.Base.RankList"
require "resource.script.server.Base.Queue"
require "resource.script.server.World.Player.Player"
require "resource.script.server.World.SaveDB.SaveDB"
require "resource.script.server.World.TimeAction.TimeAction"
require "resource.script.server.World.SysMsg.SysMsg"
require "resource.script.server.World.ReloadLua.ReloadLua"
require "resource.script.server.World.EmailSys.SysEmail"
require "resource.script.server.World.Robot.RobotBase"
local playerFun = require "resource.script.server.World.Player.PlayerFun"


WORLD_STATUS = {}
WORLD_STATUS.STARTING = 0
WORLD_STATUS.RUNING = 1
WORLD_STATUS.SHUT_DOWN = 2

Game = {}
Game.GAME_STATE_OK = WORLD_STATUS.STARTING		--��������������¼״̬
Game.ShutDownTime = 0
Game.ShutDownTimeID = -1
Game.LoginTimeID = -1
Game.s_playerOnlines = Queue:Create()
Game.regesterPlayerNum = 0
Game.totalPlayerNum = 0
Game.GAME_DEBUG = 0


--Game init
function Game:init()
	Game.GAME_STATE_OK = WORLD_STATUS.STARTING
	error(string.format("====World AgentID:%s,ServerID:%s, maxOnlinePlayer: %d, maxRegester:%d,IP:%s",GData.AgentID,GData.ServerID,GData.maxOnlinePlayer,GData.maxRegester,GData.ServerIP))
	Game:onDBForPlayer()	--���
	
	error("==============World init==============")
	Game:InitPlayerFromReadDB()
	Game:checkGameStartOver()
	--SysEmail:TestEmail()    --��ʱ��ʼ��6������ʼ�
	Game:InitPlayerShopOpenList()  --�̳�,���߿����б�

--	ArenaQueue:initArenaQueue()
--	RobotObjList:InitAllRobot()  --��ʼ��������
end

--check server
function Game:checkGameStartOver()
	if Game.totalPlayerNum ~= 0 then
		return
	end
	TimeAction:initTimeAction()
	Game.GAME_STATE_OK = WORLD_STATUS.RUNING
	error("============== Wait SubModule Start==========")
end

--�������
function Game:onDBForPlayer()
	local sqlResult = Au.query("SELECT * FROM tb_playerInfo;")
	if isEmpty(sqlResult) then
		return
	end
	Game.totalPlayerNum = sqlResult:GetRowCount()
	for j = 1, Game.totalPlayerNum do
		local dbid = sqlResult:GetFieldFromCount(0):GetUInt32()
		local usex = sqlResult:GetFieldFromCount(2):GetUInt16()
		local uname = sqlResult:GetFieldFromCount(3):GetString()
		local accountID = sqlResult:GetFieldFromCount(4):GetString()
		local onLineTime = sqlResult:GetFieldFromCount(5):GetUInt32()
		local offLineTime = sqlResult:GetFieldFromCount(6):GetUInt32()
		local lasttime = sqlResult:GetFieldFromCount(7):GetUInt32()
		-- ����ʵ��
		Player:createFromDB( dbid, uname, accountID, usex, onLineTime, offLineTime, lasttime)
		sqlResult:NextRow()
	end
	sqlResult:Delete()
	error("============== Player Init End PlayerNum:["..Game.totalPlayerNum.."]==========")
end

--��ʼ����Ҵ�db
function Game:InitPlayerFromReadDB()
	-- body
	for DBID,_player in pairs(Players_DBID) do
		Game:ReadPlayerAllProp(_player)
	end
end

--��ʼ�����¼�
function Game:InitPlayerShopOpenList()
	for DBID,_player in pairs(Players_DBID) do
		_player:initEventList()     --�����¼�
	end
end

function Game:ReadPlayerAllProp( playerObj )
	-- body
	Au.StartSqlQueue()
	Au.AddSqlQueue("SELECT databaseID FROM tb_playerInfo WHERE databaseID = "..playerObj.databaseID)
	Au.AddSqlQueue("SELECT * FROM tb_PlayerProp WHERE playerDBID="..playerObj.databaseID)
	Au.AddSqlQueue("SELECT buildKey,buildID,PosX,PosY,startTime,updateTime,buildLevel FROM tb_Build WHERE playerDBID = "..playerObj.databaseID)
	Au.AddSqlQueue("SELECT taskID,taskType,taskState,taskEnd,taskProgress FROM tb_Task WHERE playerDBID = "..playerObj.databaseID..";")
	Au.AddSqlQueue("SELECT * FROM tb_Hero WHERE playerDBID = "..playerObj.databaseID..";")
	Au.AddSqlQueue("SELECT * FROM tb_ItemProp WHERE playerDBID = "..playerObj.databaseID..";")
	Au.AddSqlQueue("SELECT databaseID,playerDBID,itemID,itemQuality,itemNumber,itemPosition,itemStrengthenLevel FROM tb_ItemEquip WHERE playerDBID = "..playerObj.databaseID..";")
	Au.AddSqlQueue("SELECT nowBigMap,ficthBigID,ficthState,bigMapIndex FROM tb_Explore WHERE playerDBID="..playerObj.databaseID)
	Au.AddSqlQueue("SELECT arenaRank FROM tb_Arena WHERE playerDBID="..playerObj.databaseID)
	Au.AddSqlQueue("SELECT * FROM tb_email;") --ϵͳ�ʼ�
	Au.AddSqlQueue("SELECT * FROM tb_useremail WHERE playerDBID = "..playerObj.databaseID..";")  --����ʼ�
	Au.AddSqlQueue("SELECT allotType,allotNum FROM tb_PeopleManage WHERE playerDBID = "..playerObj.databaseID..";")
	Au.EndSqlQueue()
	
end

function Game:ReadPlayerAllPropBack()
	-- body
	Game.totalPlayerNum = Game.totalPlayerNum - 1
	local sqlResult = nil
	local _player = nil
	sqlResult = Au.GetWorldQueueResult()
	local databaseID = sqlResult:GetFieldFromCount(0):GetUInt32()
	_player = Players_DBID[databaseID]
	sqlResult:Delete()
	_player:initPlayerProp(Au.GetWorldQueueResult(),"tb_PlayerProp")
	_player:initBuildList(Au.GetWorldQueueResult(), "tb_Build")
	_player:initTaskList(Au.GetWorldQueueResult(), "tb_Task")
	_player:initHeroList(Au.GetWorldQueueResult(),"tb_Hero")
	_player:initItemList(Au.GetWorldQueueResult(),"tb_ItemProp")
	_player:initItemList(Au.GetWorldQueueResult(),"tb_ItemEquip")
	_player:initExploreList(Au.GetWorldQueueResult(),"tb_Explore")
	_player:OnReadArenaDataFromDB(Au.GetWorldQueueResult(),"tb_Arena")
	SysEmail:InitSysEmail(Au.GetWorldQueueResult(), "tb_email") --ϵͳ�ʼ�
	_player:InitPlayerEmail(Au.GetWorldQueueResult(), "tb_useremail")
	_player:InitAllotData(Au.GetWorldQueueResult(), "tb_PeopleManage")
	Game:checkGameStartOver()
	_player:managePlayerOnOpenServer()--��ʼ����ҵ�һЩĬ�ϲ���
end

--�������
function handSqlQuery()
	if Game.GAME_STATE_OK == WORLD_STATUS.STARTING then
		Game:ReadPlayerAllPropBack()
	end
end

function Game:playerOnline()
	if Game.GAME_STATE_OK ~= WORLD_STATUS.RUNING then
		return
	end
	
	if Game.s_playerOnlines:size() == 0 then
		if not(Game.LoginTimeID == -1) then
			Au.stopTimer(Game.LoginTimeID)
			Game.LoginTimeID = -1
		end
		return
	end
	
	for i = 1, 50 do
		local on = Game.s_playerOnlines:pop()
		if not isEmpty(on) then
			local playerID = on[1]
			local accountID = on[2]
			local clientIP = on[3]
			local ValidateKey = on[4]
			if ValidateKey == MacroValedate.VATEDATE_SUCCESS then
				playerFun.PlayerFun:playerOnline(playerID,accountID,clientIP)
			else
				Au.disconnectPlayer(playerID)
			end
		else
			if not(Game.LoginTimeID == -1) then
				Au.stopTimer(Game.LoginTimeID)
				Game.LoginTimeID = -1
				break
			end
		end
	end
end

--����
function Game:onPlayerConnect( playerID, accountID, clientIP, ValidateKey)
	if Game.GAME_STATE_OK ~= WORLD_STATUS.RUNING then
		playerFun.PlayerFun:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_GAME_SHUT)
		return
	end
	
	if Au.validatePlayer( playerID, accountID ) == 1 then
		Game.s_playerOnlines:push({playerID,accountID,clientIP,ValidateKey})
		error("Game:onPlayerConnect ["..playerID.." "..accountID.." "..ValidateKey.." "..clientIP.."]")
		if Game.LoginTimeID == -1 then
			Game.LoginTimeID = Au.addTimer(200,200,"Game:playerOnline")
		end
	end
end

--����
function Game:onPlayerDisconnect( playerID, accountID )
	if Game.GAME_STATE_OK ~= WORLD_STATUS.RUNING then
		return
	end
	local on = nil
	for i=1,Game.s_playerOnlines:size() do
		on = Game.s_playerOnlines:getData(i)
		if on[1] == playerID and on[2] == accountID then
			Game.s_playerOnlines:removeData(i)
			break
		end
	end
	playerFun.PlayerFun:playerOffline(playerID,accountID)
end

--׼���رշ�����
function Game:ShutDownGame()
	if Game.ShutDownTimeID == -1 then
		Game.GAME_STATE_OK = WORLD_STATUS.SHUT_DOWN
		Game.ShutDownTime = 6
		Game.ShutDownTimeID = Au.addTimer(60000,60000,"Game:ShutDownGame")
	end
	
	Game.ShutDownTime = Game.ShutDownTime - 1
	
	if Game.ShutDownTime < 1 then
		if Game.ShutDownTime == 0 then
			--SaveDB:SaveAllPlayerData() --���������������
			SaveDB:saveToDB(true) --�����������
			Game:DisconnectAllPlayer()
		end
		if Au.queryGetSize(3) < 10 then
			error("Save all database ������������ѱ���,��������������")
		end
	else
		sendGongGaoMsgToAll("����������["..Game.ShutDownTime.."]���Ӻ�ά��,Ϊ�������ݶ�ʧ,����ǰ����")
	end
end

function Game:DisconnectAllPlayer()
	for id,_player in pairs(Players) do
		if _player.playerID ~= 0 then
			playerFun.PlayerFun:sendPlayerLogonToClient(_player.playerID, LOG_BACK_TYPE.LOG_GAME_SHUT)
			playerFun.PlayerFun:playerOffline(_player.playerID)
		end
	end
	Players = {}
end

--����ÿһ�������
function Game:UpdateEveryDayData()
	for DBID,_player in pairs(Players_DBID) do
		_player:UpdateEveryDayData()
	end
	Players_IP = {}
end

--��ʱˢ���̳���Ʒ�б�()
function Game:UpdateShopListData()
	ShopCtrl:UpdateShopList()
	for DBID,_player in pairs(Players_DBID) do
		_player:UpdateBuyShopState()
	end
end

--��ʱ���������¼�
function Game:executeMainEvent()
	for DBID,_player in pairs(Players) do
		_player:eventPerform()
	end
end

--������� ִ�л
function Game:doTimeActivity(actionID,actionArg)
	if Game.GAME_STATE_OK == WORLD_STATUS.SHUT_DOWN then
		return
	end
	error("Do action ID = "..actionID)
	if actionID == 10 then
		SaveDB:saveToDB(false)
		error((string.format("Lua memory used: %.3fK", collectgarbage("count"))))
	elseif actionID == 11 then
		Game:UpdateEveryDayData()
	elseif actionID == 12 then
		ReloadLua:World_Reload_Files()
	elseif actionID == 13 then
		Game:executeMainEvent()
	end
end

--����GM����  1001 �ػ�
function Game_HandleGM_Order( id, gmOrderID, gmArg )
	-- body

end

--�ͻ��˴������
function onCreatePlayerFromClient(playerID, playerSex, accountID, playerName)
	if playerName == "" or accountID == "" or string.len(playerName) < 2 or string.len(playerName) > 14 or string.find(playerName," ") ~= nil then
		return
	end
	if Game.regesterPlayerNum >= GData.maxRegester then 
		playerFun.PlayerFun:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_GAME_FULL)
		return
	end
	local _player = Players_name[playerName]
	if not isEmpty(_player) then 
		playerFun.PlayerFun:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_PLAYER_EXIEST)
		return
	end
	_player = Players_account[accountID]
	if not isEmpty(_player) then
		return
	end
	_player = Player:create(playerName, accountID, playerSex)
	_player.clientIP = Players_IP[accountID]
	if _player.clientIP == nil then
		_player.clientIP = "127.0.0.1"
	end
	_player:doPlayerOnLine(playerID)
	Players_IP[accountID] = nil
	playerFun.PlayerFun:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_SUCCESS)
end