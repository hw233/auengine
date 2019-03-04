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

Players = {}			--playerID-角色
Players_name = {}		--角色名-角色
Players_account = {}	--账号-角色
Players_DBID = {}		--dbID-角色
Players_IP = {}

function Player:New()
	local object = setmetatable({},self)
	self.__index = self
	self.roleBirthTime = 0		--角色生成日期
	self.roleOfflineTime = 0	--角色下线日期
	self.roleLastOnlineTime=0	--角色最新一次登录日期
	self.roleNameUtf8 = ""		--角色的utf8名字
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
	Game.regesterPlayerNum = Game.regesterPlayerNum + 1 --已注册人数
	--print("Create Player From DB", _player.accountID, _player.databaseID,_player.playerName)
	return _player
end

function Player:create(roleName, accountID, roleSex)
	local dbID = Au.getDatateID("tb_playerInfo")
	local nowtime = Au.nowTime()
	local _player = Player:createFromDB(dbID, roleName, accountID, roleSex, nowtime, nowtime, nowtime)
	
	--第一次创建初始化
	_player:onFirstCreate()
	
	Au.queryQueue("CALL update_tb_playerInfo("..dbID..",1,"..roleSex..",'"
		.._player.roleNameUtf8.."','"..accountID.."',".._player.roleBirthTime..","
		.._player.roleOfflineTime..",".._player.roleLastOnlineTime..");")
	
	return _player
end

-- 处理下线
function Player:handlePlayerOffline()
	--处理下线的操作
	self:setEventFlag(0)   --重置主城事件状态
end

--处理玩家上线
function Player:handlePlayerOnline(isBool)
	local nowtime = Au.nowTime()
	local isOnline = 0
	if isBool == true then
		isOnline = 1
		self.roleLastOnlineTime = nowtime	--上线时间
		SaveDB.OfflinePlayers[self.databaseID] = nil
	else
		self.roleOfflineTime = nowtime		--下线时间
	end
	Au.queryQueue("CALL update_tb_playerInfo("..self.databaseID..","..isOnline..","..self.playerSex..",'"..self.roleNameUtf8.."','"..self.accountID.."',"..self.roleBirthTime..","..self.roleOfflineTime..","..self.roleLastOnlineTime..");")
end

--玩家上线要做的操作在这里添加
function Player:doPlayerOnLine(playerID)
	self:setAllPlayerID(playerID)
	Players[playerID] = self
end

--玩家上线时，为武将等赋值playerID
function Player:setAllPlayerID(playerID)
	self:set_playerID(playerID)
	for __, heroObj in pairs(self.heroList) do
		if not isEmpty(heroObj) then
			heroObj:set_playerID(playerID)
		end
	end
end

--玩家第一次被创建各模块的初始化
function Player:onFirstCreate()
	self:setDefaultBuild()
	self:InitNewPlayerItemList()
	self:setDefaultTask()--默认开放成就
	self:initEventList()
end

--定时保存玩家数据
function Player:WriteDataToDatabase()
	--error("fixed cycle operation")
	self:WritePlayerData()
	self:WriteTaskData()
	self:WriteHeroData()
	self:WriteItemData()
	self:WriteExploreData()
	self:WriteBuildData()       --建筑
	self:WriteEmailData()       --邮件
	self:WritePeopleManageData()
end

--更新每一天的数据 --日常任务接口
function Player:UpdateEveryDayData()
	self:UpdateRewardFlag()         --更新7天奖励领取状态
	self:onDayUpdateArenaAward()	--更新竞技场奖励
	self:CreateRankingEmail()       --更新每天凌晨排名邮件
	self:UpdateBoxTimes()           --更新宝箱免费领取次数
end

--服务器启动后玩家的一些默认操作
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