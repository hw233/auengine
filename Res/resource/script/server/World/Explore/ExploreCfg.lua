--Explore.lua
require "resource.script.server.Config.Explore.EXPLOREBIGMAP"
require "resource.script.server.Config.Explore.EXPLORECONFIG"
require "resource.script.server.Config.Explore.CLOUDMINE"
require "resource.script.server.Config.Explore.SOURCEPOINT"
require "resource.script.server.Config.Explore.MAPEVENT"

local ExploreCfg = {}

ExploreCfg.NORMAILFIGHTTYP = 0
ExploreCfg.DARKRAYLFIGHTTYP = 1
ExploreCfg.DEATHCOMEBACK = 2
ExploreCfg.NORMALCOMEBACK = 1

function ExploreCfg:getBigMapCfg(bigMapID)
	return EXPLOREBIGMAP["BIGMAP_"..bigMapID]
end

function ExploreCfg:getSmallMapCfg(smallMapID)
	return EXPLORECONFIG["EXPLORE_"..smallMapID]
end

function ExploreCfg:getCloudMineCfg( cloudMineID )
	return CLOUDMINE["CLOUD_"..cloudMineID]
end

function ExploreCfg:getSourcePointCfg( pointID )
	return SOURCEPOINT["SOURCEPOINT_"..pointID]
end

function ExploreCfg:getMapEventCfg(npcID)
	return MAPEVENT["MAPEVENT_"..npcID]
end

return {ExploreCfg = ExploreCfg}