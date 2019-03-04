-- TechnologyCtrl.lua
local techBase = require "resource.script.server.World.Technology.TechnologyBase"


TechnologyCtrl = {}

function TechnologyCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.Backpack = 101           --出行背包
	self.WaterBag = 201           --水袋
	self.Carriage = 301           --马车
	self.Alchemy = 401            --炼金术
	self.Bread = 501              --面包
	
	return obj
end

--获取出行装备容量(参数 Type：1-背包，2-水袋，3-马车，4-炼金，5-面包)
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

--出行装备升级
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
--科技升级
function World_TechnologyCtrl_UpTravelKitLevel(playerID, itemID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return 
	end
	_player:UpTravelKitLevel( itemID )
end
