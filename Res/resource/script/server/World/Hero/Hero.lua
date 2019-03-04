--Hero.lua

Hero = {}
Heros = createWeekTable()

function Hero:New()
	-- body
	local object = setmetatable({}, self)
	self.__index = self
	return object
end

function Hero:createNew()
	-- body
	local object = createClass(BaseEntity, HeroData, Hero)
	object:set_update_prop_msg_ID(MacroMsgID.MSG_ID_UPDATE_HERO_PROP)
	return object
end

function Hero:createFromDB(databaseID, playerDBID, heroID)
	local  heroObject = Hero:createNew()
	heroObject:set_databaseID(databaseID)
	heroObject:set_playerDBID(playerDBID)
	heroObject.heroID = heroID
	Heros[heroObject.databaseID] = heroObject
--	print("Create Hero", heroObject.databaseID, heroObject.heroID)
	return heroObject
end

function Hero:create( playerDBID, heroID)
	-- body
	local dbID = Au.getDatateID("tb_Hero")
	local heroObject = Hero:createFromDB(dbID, playerDBID, heroID)
	return heroObject
end

function Hero:WriteDB(  )
	Au.queryQueue("CALL update_tb_Hero("..self.databaseID..","
			..self.playerDBID..","
			..self.heroID..")")
end