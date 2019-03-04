--ExploreOBJ.lua
local ExploreState = require "resource.script.server.World.Explore.ExploreState"

local ExploreOBJ = {}

function ExploreOBJ:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.playerExploreWater = 0		--ˮ
	self.nowBigMap = 11				--��ǰ�󸱱�
	self.bigMapIndex = 11			--���½ڽ���
	object.saveExploreState = {}	--��������״̬
	object.dropItemTB = nil			--�������
	return object
end

--�����ݿ��ж�ȡ��������״̬
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

--���´��ͼ
function ExploreOBJ:updateBigMap( bigMapID )
	self.nowBigMap = bigMapID
end

--����̽��ˮ
function ExploreOBJ:supplyExploreWater( value )
	self.playerExploreWater = value
end

--�ƶ��۳�ˮ
function ExploreOBJ:takeOutExploreWater( value )
	if value <= 0 then
		return
	end
	local tmpValue = self.playerExploreWater - value
	self.playerExploreWater = (tmpValue <=0 ) and 0 or tmpValue
	return self.playerExploreWater
end

--�����������
function ExploreOBJ:enterSecondary(bigMapID)
	if not isEmpty(self.saveExploreState[bigMapID]) then
		return
	end
	self.saveExploreState[bigMapID] = ExploreState.ExploreState:New()
end

--ͨ�ض�������
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

--���������
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

--��ȡ�󸱱��ж���������״̬
function ExploreOBJ:getSecondFromBigMap( bigMapID )
	local tmpOBJ = self.saveExploreState[bigMapID]
	if isEmpty(tmpOBJ) then
		return 0,0,0,0
	end
	return tmpOBJ.exploreState1,tmpOBJ.exploreState2,tmpOBJ.exploreSupply, tmpOBJ.exploreSupply1
end

--���´󸱱�����
function ExploreOBJ:updateBigMapIndex(value)
	if self.bigMapIndex >= value then
		return
	end
	self.bigMapIndex = value
end

--���ò�����
function ExploreOBJ:reset_supplyPoint()
	local bigMapID = self.nowBigMap
	if isEmpty(self.saveExploreState[bigMapID]) then
		return
	end
	self.saveExploreState[bigMapID].exploreSupply = 0
	self.saveExploreState[bigMapID].exploreSupply1 = 0
end

return {ExploreOBJ=ExploreOBJ}
