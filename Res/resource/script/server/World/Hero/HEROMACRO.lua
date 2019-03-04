--HEROMACRO.lua
require "resource.script.server.Config.Hero.HERO_CONFIG"
require "resource.script.server.World.Hero.HeroData"

local HEROMACRO = {}
HEROMACRO.HEROEXP_1 = 1010019
HEROMACRO.HEROEXP_2 = 1010020
HEROMACRO.HEROEXP_3 = 1010021

--∂¡»°ªÔ∞È≈‰÷√
function HEROMACRO:getHeroCfg( heroID )
	return HERO_CONFIG["HERO_"..heroID]
end

--–¬ªÔ∞È
function HEROMACRO:sendHeroToClient( playerID, databaseID, heroID, msgID )
	Au.messageToClientBegin(playerID, msgID)
	Au.addUint32(databaseID)
	Au.addUint16(heroID)
	Au.messageEnd()
end

return {HEROMACRO=HEROMACRO}