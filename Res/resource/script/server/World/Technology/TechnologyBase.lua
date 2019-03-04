--TechnologyBase.lua
require "resource.script.server.Config.Technology.TRAVELKITCFG"

local TechnologyBase = {}

--∂¡»°≈‰÷√
function TechnologyBase:getTravelKitCfg(itemID)
	return TRAVELKIT["ID_"..itemID]
end


return {TechnologyBase=TechnologyBase}