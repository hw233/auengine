--Player
require "resource.script.server.Base.BaseEntity"
require "resource.script.server.Macro.MacroMsgID"
require "resource.script.server.Base.Redis"
require "resource.script.server.World.Player.PlayerData"
require "resource.script.server.World.Player.PlayerCtrl"
require "resource.script.server.World.Task.TaskCtrl"
require "resource.script.server.World.Build.BuildCtrl"
require "resource.script.server.World.PeopleManage.PeopleManageCtrl"
require "resource.script.server.World.Hero.HeroCtrl"
--require "resource.script.server.World.Item.ItemMainCtrl"
require "resource.script.server.World.ItemSys.ItemSysCtrl"
require "resource.script.server.World.Talent.TalentCtrl"
require "resource.script.server.World.Explore.ExploreCtrl"
require "resource.script.server.World.SevenReward.SevenRewardCtrl"
require "resource.script.server.World.Arena.ArenaCtrl"
require "resource.script.server.World.EmailSys.PlayerEmailCtrl"
require "resource.script.server.World.BoxSys.BoxCtrl"
require "resource.script.server.World.Technology.TechnologyCtrl"
require "resource.script.server.World.MainEvent.MainEventCtrl"
require "resource.script.server.World.Shop.ShopBuyCtrl"

Player = {}

Players = {}			--playerID-��ɫ
Players_name = {}		--��ɫ��-��ɫ
Players_account = {}	--�˺�-��ɫ
Players_DBID = {}		--dbID-��ɫ
Players_IP = {}

function Player:New()
	local object = setmetatable({},self)
	self.__index = self
	self.roleBirthTime = 0		--��ɫ��������
	self.roleOfflineTime = 0	--��ɫ��������
	self.roleLastOnlineTime=0	--��ɫ����һ�ε�¼����
	self.roleNameUtf8 = ""		--��ɫ��utf8����
	return object
end

function Player:createFromDB(dbID, roleName, accountID, roleSex, birthTime, offlineTime, lastTime )
	local _player = createClass(BaseEntity, PlayerData, SevenRewardCtrl, ShopBuyCtrl, EventCtrl, PlayerEmailCtrl, BoxCtrl, TechnologyCtrl, BuildCtrl, PeopleManageCtrl, PlayerItemCtrl, TaskCtrl,HeroCtrl, TalentCtrl, ExploreCtrl, ArenaCtrl, PlayerCtrl, Player)
	_player:set_update_prop_msg_ID(MacroMsgID.MSG_ID_UPDATE_PLAYER_PROP)
	_player:set_databaseID(dbID)
	_player:set_playerName(roleName)
	_player.accountID = accountID
	_player.playerSex = roleSex
	_player.roleBirthTime = birthTime
	_player.roleOfflineTime = offlineTime
	_player.roleLastOnlineTime = lastTime
	_player.roleNameUtf8 = _player.playerName
	Players_name[roleName] = _player
	Players_account[accountID] = _player
	Players_DBID[dbID] = _player
	Game.regesterPlayerNum = Game.regesterPlayerNum + 1 --��ע������
	--print("Create Player From DB", _player.accountID, _player.databaseID,_player.playerName)
	return _player
end

function Player:create(roleName, accountID, roleSex)
	local dbID = Au.getDatateID("tb_playerInfo")
	local nowtime = Au.nowTime()
	local _player = Player:createFromDB(dbID, roleName, accountID, roleSex, nowtime, nowtime, nowtime)
	
	--��һ�δ�����ʼ��
	_player:onFirstCreate()
	
	Au.queryQueue("CALL update_tb_playerInfo("..dbID..",1,"..roleSex..",'"
		.._player.roleNameUtf8.."','"..accountID.."',".._player.roleBirthTime..","
		.._player.roleOfflineTime..",".._player.roleLastOnlineTime..");")
	
	return _player
end

-- ��������
function Player:handlePlayerOffline()
	--�������ߵĲ���
	self:setEventFlag(0)   --���������¼�״̬
end

--�����������
function Player:handlePlayerOnline(isBool)
	local nowtime = Au.nowTime()
	local isOnline = 0
	if isBool == true then
		isOnline = 1
		self.roleLastOnlineTime = nowtime	--����ʱ��
		SaveDB.OfflinePlayers[self.databaseID] = nil
	else
		self.roleOfflineTime = nowtime		--����ʱ��
	end
	Au.queryQueue("CALL update_tb_playerInfo("..self.databaseID..","..isOnline..","..self.playerSex..",'"..self.roleNameUtf8.."','"..self.accountID.."',"..self.roleBirthTime..","..self.roleOfflineTime..","..self.roleLastOnlineTime..");")
end

--�������Ҫ���Ĳ������������
function Player:doPlayerOnLine(playerID)
	self:setAllPlayerID(playerID)
	Players[playerID] = self
end

--�������ʱ��Ϊ�佫�ȸ�ֵplayerID
function Player:setAllPlayerID(playerID)
	self:set_playerID(playerID)
	for __, heroObj in pairs(self.heroList) do
		if not isEmpty(heroObj) then
			heroObj:set_playerID(playerID)
		end
	end
end

--��ҵ�һ�α�������ģ��ĳ�ʼ��
function Player:onFirstCreate()
	self:setDefaultBuild()
	self:InitNewPlayerItemList()
	self:setDefaultTask()--Ĭ�Ͽ��ųɾ�
	self:initEventList()
end

--��ʱ�����������
function Player:WriteDataToDatabase()
	--error("fixed cycle operation")
	self:WritePlayerData()
	self:WriteTaskData()
	self:WriteHeroData()
	self:WriteItemData()
	self:WriteExploreData()
	self:WriteBuildData()       --����
	self:WriteEmailData()       --�ʼ�
	self:WritePeopleManageData()
end

--����ÿһ������� --�ճ�����ӿ�
function Player:UpdateEveryDayData()
	self:UpdateRewardFlag()         --����7�콱����ȡ״̬
	self:onDayUpdateArenaAward()	--���¾���������
	self:CreateRankingEmail()       --����ÿ���賿�����ʼ�
	self:UpdateBoxTimes()           --���±��������ȡ����
end

--��������������ҵ�һЩĬ�ϲ���
function Player:managePlayerOnOpenServer()
	-- body
end

function Player:getPlayerFromID(playerID)
	return Players[playerID]
end

function Player:getPlayerFromDBID(databaseID)
	return Players_DBID[databaseID]
end

function Player:getPlayerFromName(playerName)
	return Players_name[playerName]
end