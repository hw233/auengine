--HeroCtrl.lua
require "resource.script.server.World.Hero.Hero"
local heroMacro = require "resource.script.server.World.Hero.HEROMACRO"

HeroCtrl = {}

function HeroCtrl:New(  )
	-- body
	local  object = setmetatable({}, self)
	self.__index = self
	return object
end

--初始化宠物列表
function HeroCtrl:initHeroList(sqlResult,tableName)
	if isEmpty(sqlResult) then
		return
	end
	for i = 1,sqlResult:GetRowCount() do
		local dbID = sqlResult:GetFieldFromCount(0):GetUInt32()
		local playerDBID = sqlResult:GetFieldFromCount(1):GetUInt32()
		local heroID = sqlResult:GetFieldFromCount(2):GetUInt16()
		local _hero = Hero:createFromDB(dbID, playerDBID, heroID)
		self:insertHeroList(_hero)
		_hero:set_playerID(self.playerID)
		sqlResult:NextRow()
	end
	sqlResult:Delete()
end

function HeroCtrl:WriteHeroData( )  
	-- body
	for __, heroObj in pairs(self.heroList) do
		heroObj:WriteDB()
	end
end

function HeroCtrl:insertHeroList( heroObj )
	-- body
	self.heroList[heroObj.databaseID] = heroObj
end

function HeroCtrl:removeHeroList( heroDBID )
	-- body
	self.heroList[heroDBID] = nil
end

function HeroCtrl:getHeroNumFromID( heroID )
	-- body
	local num = 0
	for __, heroObj in pairs(self.heroList) do
		if heroObj.heroID == heroID then
			num = num + 1
		end
	end
	return num
end

function HeroCtrl:getHero( heroID )
	-- body
	local heroObj = Hero:create(self.databaseID, heroID)
	if isEmpty(heroObj) then
		return
	end
	heroObj:set_playerID(self.playerID)
	self:insertHeroList(heroObj)
	heroMacro.HEROMACRO:sendHeroToClient(self.playerID, heroObj.databaseID, heroObj.heroID, MacroMsgID.MSG_ID_SEND_SINGLE_HERO)
end

--客户端消息
function HeroCtrl:getHeroList(  )
	-- body
	if isEmpty(self.heroList) then
		return
	end
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_SEND_HERO_LIST)
	for __, heroObj in pairs(self.heroList) do
		Au.addUint32(heroObj.databaseID)
		Au.addUint16(heroObj.heroID)
	end
	Au.messageEnd() 
end

--升职
function HeroCtrl:promotionHero(heroDBID)
	local heroObj = self.heroList[heroDBID]
	if isEmpty(heroObj) then
		return
	end
	local heroCfg = heroMacro.HEROMACRO:getHeroCfg( heroObj.heroID )
	if isEmpty(heroCfg) then
		return
	end
	local nextHeroID = heroCfg["NEXTHERO"]
	if nextHeroID == 0 then
		return
	end
	heroCfg = heroMacro.HEROMACRO:getHeroCfg( nextHeroID )
	if isEmpty(heroCfg) then
		return
	end
	local preUse = heroCfg["PREUSE"]
	if self:checkOutAndTakeawaySource(preUse) == false then
		return
	end
	heroObj.heroID = nextHeroID
	heroMacro.HEROMACRO:sendHeroToClient(self.playerID, heroObj.databaseID, heroObj.heroID, MacroMsgID.MSG_ID_SEND_HERO_DEVELOP)
end

--招募
function HeroCtrl:recruitHero(heroID)
	local heroCfg = heroMacro.HEROMACRO:getHeroCfg( heroID )
	if isEmpty(heroCfg) then
		return
	end
	local openTerm = heroCfg["OPEN"]
	if self:checkPrecondition(openTerm) == false then
		return
	end
	if self:getHeroNumFromID(heroID) >= 1 then
		return
	end
	local preUse = heroCfg["PREUSE"]
	if self:checkOutAndTakeawaySource(preUse) == false then
		return
	end
	self:getHero(heroID)
	sendSystemMsg(self.playerID, "恭喜你获得了"..heroCfg["NAME"].."冒险者")
	TaskBase:completeHeroNumTask(self, heroID, 1)
end

--API
--招募
function World_HeroCtrl_recruitHero(playerID, heroID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:recruitHero( heroID )
end

--升职
function World_HeroCtrl_promotionHero(playerID, heroDBID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:promotionHero( heroDBID )
end