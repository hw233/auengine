-- TechnologyCtrl.lua
local techBase = require "resource.script.server.World.Technology.TechnologyBase"


TechnologyCtrl = {}

function TechnologyCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.Backpack = 101           --���б���
	self.WaterBag = 201           --ˮ��
	self.Carriage = 301           --��
	self.Alchemy = 401            --������
	self.Bread = 501              --���
	
	return obj
end

--��ȡ����װ������(���� Type��1-������2-ˮ����3-����4-����5-���)
function TechnologyCtrl:getTravelKitCapacity(Type)
	local ID = 0
	if Type == 1 then
		ID = self.Backpack
	elseif Type == 2 then
		ID = self.WaterBag
	elseif Type == 3 then
		ID = self.Carriage
	elseif Type == 4 then
		ID = self.Alchemy
	elseif Type == 5 then
		ID = self.Bread
	else
		return 0
	end
		
	local Cfg = techBase.TechnologyBase:getTravelKitCfg( ID )
	if isEmpty(Cfg) then
		return 0
	end

	return Cfg["CAPACITY"]
end

--����װ������
function TechnologyCtrl:UpTravelKitLevel( itemID )
	local itemCfg = techBase.TechnologyBase:getTravelKitCfg(itemID)
	if isEmpty(itemCfg) then
		return
	end
	
	local nextID = itemCfg["NEXTID"]
	if nextID == 0 then
		return
	end
	
	local useItem = itemCfg["USE"]
	if not self:checkOutAndTakeawaySource(useItem) then
		return
	end

	if itemID == self.Backpack then
		self.Backpack = nextID
	elseif itemID == self.WaterBag then
		self.WaterBag = nextID
	elseif itemID == self.Carriage then
		self.Carriage = nextID
	elseif itemID == self.Alchemy then
		self.Alchemy = nextID
	elseif itemID == self.Bread then
		self.Bread = nextID
	else
		return
	end
	
	Au.messageToClientBegin(self.playerID, MacroMsgID.Msg_ID_UPLEVE_TRAVELKIT)
	Au.addUint16(nextID)
	Au.messageEnd()
end



--API
--�Ƽ�����
function World_TechnologyCtrl_UpTravelKitLevel(playerID, itemID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return 
	end
	_player:UpTravelKitLevel( itemID )
end
