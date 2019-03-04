--ExploreOBJ.lua
local ExploreState = require "resource.script.server.World.Explore.ExploreState"

local ExploreOBJ = {}

function ExploreOBJ:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.playerExploreWater = 0		--水
	self.nowBigMap = 11				--当前大副本
	self.bigMapIndex = 11			--大章节进度
	object.saveExploreState = {}	--二级副本状态
	object.dropItemTB = nil			--掉落操作
	return object
end

--从数据库中读取二级副本状态
function ExploreOBJ:setSecondStateFromDB(bigMapID, state1, state2)
	local tmpOBJ = ExploreState.ExploreState:New()
	tmpOBJ.exploreState1 = state1
	tmpOBJ.exploreState2 = state2
	self.saveExploreState[bigMapID] = tmpOBJ
end

function ExploreOBJ:createExploreOBJ()
	local object = createClass(ExploreOBJ)
	return object
end

--更新大地图
function ExploreOBJ:updateBigMap( bigMapID )
	self.nowBigMap = bigMapID
end

--补给探险水
function ExploreOBJ:supplyExploreWater( value )
	self.playerExploreWater = value
end

--移动扣除水
function ExploreOBJ:takeOutExploreWater( value )
	if value <= 0 then
		return
	end
	local tmpValue = self.playerExploreWater - value
	self.playerExploreWater = (tmpValue <=0 ) and 0 or tmpValue
	return self.playerExploreWater
end

--进入二级副本
function ExploreOBJ:enterSecondary(bigMapID)
	if not isEmpty(self.saveExploreState[bigMapID]) then
		return
	end
	self.saveExploreState[bigMapID] = ExploreState.ExploreState:New()
end

--通关二级副本
function ExploreOBJ:passSecondary(floors_id, bigMapIndex)
	local second_space_id = NumberToInt(floors_id/100)
	local bigMapID = NumberToInt(second_space_id/100)
	local stateIndex = second_space_id%100
	self:enterSecondary(bigMapID)
	self.saveExploreState[bigMapID]:addExploreState(stateIndex)
	if bigMapIndex ~= 0 then
		self:updateBigMapIndex( bigMapIndex )
	end
end

--补给点操作
function ExploreOBJ:checkExploreSupply(bigMapID, stateIndex)
	if isEmpty( self.saveExploreState[bigMapID] ) then
		return false
	end
	if self.saveExploreState[bigMapID]:checkExploreState( stateIndex ) == false then
		return false
	end
	if self.saveExploreState[bigMapID]:checkExplorePointState( stateIndex ) == false then
		return false
	end
	self.saveExploreState[bigMapID]:updateExploreSupply(stateIndex)
	return true
end

--获取大副本中二级副本的状态
function ExploreOBJ:getSecondFromBigMap( bigMapID )
	local tmpOBJ = self.saveExploreState[bigMapID]
	if isEmpty(tmpOBJ) then
		return 0,0,0,0
	end
	return tmpOBJ.exploreState1,tmpOBJ.exploreState2,tmpOBJ.exploreSupply, tmpOBJ.exploreSupply1
end

--更新大副本进度
function ExploreOBJ:updateBigMapIndex(value)
	if self.bigMapIndex >= value then
		return
	end
	self.bigMapIndex = value
end

--重置补给点
function ExploreOBJ:reset_supplyPoint()
	local bigMapID = self.nowBigMap
	if isEmpty(self.saveExploreState[bigMapID]) then
		return
	end
	self.saveExploreState[bigMapID].exploreSupply = 0
	self.saveExploreState[bigMapID].exploreSupply1 = 0
end

return {ExploreOBJ=ExploreOBJ}
