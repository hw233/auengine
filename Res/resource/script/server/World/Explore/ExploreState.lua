--ExploreState.lua


local ExploreState = {}	--副本状态对象

function ExploreState:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.exploreState1 = 0		--二级副本状态1
	self.exploreState2 = 0		--二级副本状态2
	self.exploreSupply = 0		--补给点次数状态1
	self.exploreSupply1 = 0		--补给点次数状态2
	return object
end

--更新副本状态
function ExploreState:addExploreState( stateIndex )
	if stateIndex > 0 and stateIndex <= 32 then
		self.exploreState1 = Au.bitAddState(self.exploreState1,stateIndex)
	elseif stateIndex >= 33 and stateIndex <= 64 then
		self.exploreState2 = Au.bitAddState(self.exploreState2,stateIndex - 32)
	end
end

--判断副本状态
function ExploreState:checkExploreState( stateIndex )
	if stateIndex > 0 and stateIndex <= 32 then
		if Au.bitCheckState(self.exploreState1, stateIndex) ~= 1 then
			return false
		end
	elseif stateIndex >= 33 and stateIndex <= 64 then
		if Au.bitCheckState(self.exploreState2, stateIndex - 32) ~= 1 then
			return false
		end
	end
	return true
end

--更新补给点状态
function ExploreState:updateExploreSupply(stateIndex)
	if stateIndex > 0 and stateIndex <= 32 then
		self.exploreSupply = Au.bitAddState(self.exploreSupply,stateIndex)
	elseif stateIndex >= 33 and stateIndex <= 64 then
		self.exploreSupply1 = Au.bitAddState(self.exploreSupply1,stateIndex - 32)
	end
end

--判断补给点状态
function ExploreState:checkExplorePointState( stateIndex )
	if stateIndex > 0 and stateIndex <= 32 then
		if Au.bitCheckState(self.exploreSupply, stateIndex) ~= 1 then
			return true
		end
	elseif stateIndex >= 33 and stateIndex <= 64 then
		if Au.bitCheckState(self.exploreSupply1, stateIndex - 32) ~= 1 then
			return true
		end
	end
	return false
end

return {ExploreState=ExploreState}