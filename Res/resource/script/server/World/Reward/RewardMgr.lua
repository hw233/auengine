--RewardMgr.lua
require "resource.script.server.Config.Reward.REWARDCOFIG"
require "resource.script.server.Config.Reward.LIBID"

local table_insert = table.insert

RewardMgr = {}

--获取总概率
function RewardMgr:getTotalRandFromLib( libCfg )
	-- body
	local randTotal = 0
	for _, rewardCfg in pairs(libCfg) do
		randTotal = randTotal + rewardCfg[2]
	end
	return randTotal
end

--获取掉落库ID
function RewardMgr:getLibIDTB( libID )
	local libCfg = LIBID["ID_"..libID]
	if isEmpty(libCfg) then
		return
	end
	
	local libNum = libCfg["LIBNUM"]
	if libNum <= 0 then
		return
	end
	
	local libList = libCfg["LIBID"]
	local tempTB = {}
	for i = 1, #libList do
		table_insert(tempTB, libList[i])
	end
	
	local libTB = selectNumber(libNum,tempTB)
	return libTB
end

function RewardMgr:getRewardFromLib( libID )
	-- body
	local libTB = self:getLibIDTB( libID )
	if isEmpty(libTB) then
		return
	end
	
	local awardTB = {}
	for i = 1, #libTB do
		local libID = libTB[i]
		local rewardCfg = REWARDCOFIG["LIB_"..libID]
		if isEmpty(rewardCfg) then
			PrintError("RewardMgr reward Config is error"..libID)
			return
		end
		local randTotal = self:getTotalRandFromLib(rewardCfg)
		local randNum = AuRandom(1, randTotal)
		local nowRand = 0
		for __,tb in pairs(rewardCfg) do
			nowRand = nowRand + tb[2]
			if randNum <= nowRand then
				table_insert(awardTB, tb[1])
				break
			end
		end
	end
	return awardTB
end

return {RewardMgr=RewardMgr}



