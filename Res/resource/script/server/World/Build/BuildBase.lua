--BuildBase.lua

local BuildBase = {}

function BuildBase:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.buildID = 0	--建筑ID
	self.buildKey = 0
	self.buildLevel = 0
	self.startTime = 0	--开始时间
	self.updateTime = 0 --升级时间
	object.Pos = {0,0}
	return object
end

function BuildBase:createBuild(playerDBID, key, x, y, buildType)
	local object = BuildBase:New()
	object.buildKey = key
	object.buildID = buildType
	object.Pos[1] = x
	object.Pos[2] = y
	return object
end

function BuildBase:LevelUp(upTime)
	self.startTime = Au.nowTime()
	self.updateTime = upTime
end

function BuildBase:getLeaveTime(playerOBJ)
	if self.startTime == 0 then
		return 0
	end
	local leavetime = self.startTime + self.updateTime - Au.nowTime()
	if leavetime <= 1 then
		self:setLevelUp(playerOBJ)
		return 0
	end
	return leavetime
end

function BuildBase:setLevelUp(playerOBJ)
	self.buildLevel = self.buildLevel + 1
	self:clearUpTime()
	playerOBJ:onFinalBuildLevelUp(self)
end

function BuildBase:clearUpTime()
	self.startTime = 0
	self.updateTime = 0
end

function BuildBase:updateBuildData(databaseID)
	Au.queryQueue("CALL update_tb_Build("..databaseID..","
				..self.buildKey..","
				..self.buildID..","
				..self.Pos[1]..","
				..self.Pos[2]..","
				..self.startTime..","
				..self.updateTime..","
				..self.buildLevel..");")
end

return {BuildBase=BuildBase}