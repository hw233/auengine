--MainEventCtrl.lua
require "resource.script.server.World.MainEvent.MainEventBase"

--全局函数
local pairs = pairs
local table_insert = table.insert

--宏定义
local EVENTTYPE = {}
EVENTTYPE.NULL = 1     --无事件
EVENTTYPE.SALE = 2     --出售事件
EVENTTYPE.CUT = 3      --索取事件
EVENTTYPE.GAMBLE = 4   --赌徒事件
EVENTTYPE.GIVE = 5     --赠送事件
EVENTTYPE.TALENT = 6   --天赋事件

EventCtrl = {}

function EventCtrl:New()
	local obj = setmetatable({},self)
	self.__index = self
	self.eventID = 0         --触发的事件Id
	self.itemIndex = 0       --物品编号
	self.itemID = 0          --事件触发产生的物品ID
	self.itemNum = 0         --事件触发产生的数量(出售物品，或索取物品，或赠送物品，或赌博)
	self.saleTB = 0          --出售事件的消耗
	self.eventFlag = 0       --事件的状态(0-事件已处理，1-事件还没处理)
	obj.eventList = {}       --事件列表
	
	return obj
end

--3分钟执行主城事件
function EventCtrl:eventPerform()
	if self:CheckFunctionID(FUNCTION_ID_TYPE.EVENT) == false then
		return
	end
	if self.playerStatus == 1 then
		return
	end
	if self.eventFlag == 1 then
		return
	end
	self:triggerEvent()
end

--初始化事件列表
function EventCtrl:initEventList()
	local eventCfg = EventBase:readEventsCfg()
	if isEmpty(eventCfg) then
		return
	end
	
	for eventID, eventObj in pairs(eventCfg) do
		if eventObj.TYPE < EVENTTYPE.TALENT then
			self.eventList[eventObj.ID] = eventObj
		elseif eventObj.TYPE == EVENTTYPE.TALENT then
			if self:checkPlayerTalent(eventObj.TALENT) then
				self.eventList[eventObj.ID] = eventObj
			end
		else
			
		end
	end
end

--触发一个事件
function EventCtrl:triggerEvent()
	local probabilitySum = self:countProbabilitySum()
	if probabilitySum == 0 then
		return
	end
	
	local value = AuRandom(1, probabilitySum)
	local tempValue = 0
	local eventID = 0
	local eventType = 0
	for id, obj in pairs(self.eventList) do
		tempValue = tempValue + obj.PROBABILITY
		if value <= tempValue then
			eventID = obj.ID
			eventType = obj.TYPE
			break
		end
	end
	
	if eventType == EVENTTYPE.NULL then  --无事件类型
		return
	end
	
	if eventType == EVENTTYPE.GAMBLE then  --赌徒事件 金币小于100不触发
		if self.playerCopper < 100 then
			return
		end
	end
	
	self:triggerNum(eventID)   --保存事件的属性
	self:setEventFlag(1)
	
	--回复客户端
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_MAINEVENT_TRIGGEREVENT)
	Au.addUint32(self.eventID)
	Au.addUint8(self.itemIndex)
	Au.addUint32(self.itemNum)
	Au.messageEnd()
	
end

--处理触发事件(参数：事件id，flag；0-不接受，1-接受)
function EventCtrl:disposeEvent(eventID, flag)
	local ret 
	local eventObj = self.eventList[eventID]
	if eventObj == nil then
		return 
	end
	
	if eventObj.TYPE == EVENTTYPE.SALE then
		ret = self:doSaleEvent(flag)
	elseif eventObj.TYPE == EVENTTYPE.CUT then
		ret = self:doCutEvent(flag)
	elseif eventObj.TYPE == EVENTTYPE.GAMBLE then
		ret = self:doGambleEvent(flag)
	elseif eventObj.TYPE == EVENTTYPE.GIVE then
		ret = self:doGiveEvent(flag)
	elseif eventObj.TYPE == EVENTTYPE.TALENT then
		ret = self:doTalentEvent(eventID, flag)
	else
		return 
	end
	
	self:setEventFlag(0)
	--回复客户端
	local status = 1
	if ret == false then
		status = 0
	end
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_MAINEVENT_DOEVENT)
	Au.addUint8(status)
	Au.messageEnd()
end

--设置事件状态
function EventCtrl:setEventFlag(status)
	self.eventFlag = status
end

--增加事件
function EventCtrl:addEvet(talentID)
	local eventCfg = EventBase:readEventsCfg()
	if isEmpty(eventCfg) then
		return
	end
	
	for eventID, eventObj in pairs(eventCfg) do
		if eventObj.TALENT == talentID then
			if self.eventList[eventObj.ID] == nil then
				self.eventList[eventObj.ID] = eventObj
			end
			break
		end
	end
end

--删除事件(激活天赋后从事件列表移除)
function EventCtrl:deleteEvent(talentID)
	for eventID, obj in pairs(self.eventList) do
		if obj.TALENT == talentID then
			self.eventList[obj.ID] = nil
		end
	end
end

--清空事件属性
function EventCtrl:cleanEventData()
	self.eventID = 0 
	self.itemIndex = 0
	self.itemID = 0          
	self.itemNum = 0
	self.eventFlag = 0
	self.saleTB = {}          
end

--统计事件列表的概率总和
function EventCtrl:countProbabilitySum()
	local sum = 0
	for ID, obj in pairs(self.eventList) do
		sum = sum + obj.PROBABILITY
	end
	return sum
end

--事件触发产生的物品和数量
function EventCtrl:triggerNum(eventID)
	local eventCfg = EventBase:readEventById(eventID)
	if isEmpty(eventCfg) then
		return
	end
	
	self.eventID = eventID       --事件ID
	local ItemID = 0 ItemNum = 0 ItemIndex = 0
	local eventType = eventCfg["TYPE"]
	if eventType == EVENTTYPE.SALE or eventType == EVENTTYPE.CUT or eventType == EVENTTYPE.GIVE then
		ItemID, ItemNum, ItemIndex = self:getItemValueAndNum(self.exploreOBJ.nowBigMap, eventType)
		self.itemIndex = ItemIndex   --物品编号
		self.itemID = ItemID         --物品id
		self.itemNum = ItemNum       --物品数量
		if eventType == EVENTTYPE.SALE then   
			self.saleTB = self:getSalecounsum(self.exploreOBJ.nowBigMap, ItemIndex)  --出售消耗
		end
	else
		if eventType == EVENTTYPE.GAMBLE then
			self.itemNum = self:getGoldNum()   --赌博金币数量
		end
	end
end

--随机获取物品ID和数量
function EventCtrl:getItemValueAndNum(FBID, eventType)
	local ItemTB
	if eventType == EVENTTYPE.SALE then
		ItemTB = EventBase:readSaleItemCfg(FBID)
	elseif eventType == EVENTTYPE.CUT then
		ItemTB = EventBase:readCutItemCfg(FBID)
	elseif eventType == EVENTTYPE.GIVE then
		ItemTB = EventBase:readGiveItemCfg(FBID)
	else
	
	end
	if isEmpty(ItemTB) then
		return 
	end
--统计权重和	
	local QzSum = 0
	for i = 1, #ItemTB do
		QzSum = QzSum + ItemTB[i]["QZ"]
	end
--获取物品下标
	local value = AuRandom(1, QzSum)
	local tempValue = 0
	local index = 0
	local ItemID = 0
	local ItemNum = 0
	for j = 1, #ItemTB do
		tempValue = tempValue + ItemTB[j]["QZ"]
		if value <= tempValue then
			index = ItemTB[j]["INDEX"]
			ItemID = ItemTB[j]["ITEMID"]
			ItemNum = AuRandom(ItemTB[j]["RANGE"][1], ItemTB[j]["RANGE"][2])
			break
		end
	end
	return ItemID, ItemNum, index
end

--出售事件的消耗
function EventCtrl:getSalecounsum(FBID, index)
	local ItemTB = EventBase:readSaleItemCfg(FBID)
	if isEmpty(ItemTB) then
		return 
	end
	
	local ItemUse = 0
	for _, obj in pairs(ItemTB) do
		if obj.INDEX == index then
			ItemUse = obj.USE
			break
		end
	end
	return ItemUse
end

--获取赌金数量
function EventCtrl:getGoldNum()
	local percent = EventBase:getGoldPercent()
	local goldNum = NumberToInt(percent * self.playerCopper)
	return goldNum
end

--出售事件处理
function EventCtrl:doSaleEvent(flag)
	local isBool = false
	if flag == 1 then
		if self:checkOutAndTakeawaySource(self.saleTB) == false then
			self:cleanEventData()
			return isBool
		end
		self:getItem(self.itemID, self.itemNum )
		isBool = true
	end
	self:cleanEventData()
	return isBool
end

--索取事件处理
function EventCtrl:doCutEvent(flag)
	local tempTB = {}
	local useTB = {}
	table_insert(tempTB, 1)
	table_insert(tempTB, self.itemID)
	table_insert(tempTB, self.itemNum)
	table_insert(useTB, tempTB)
	local isBool = false
	
	if flag == 1 then
		if self:checkOutAndTakeawaySource(useTB) == false then
			self:cleanEventData()
			return isBool
		end
		--是否能获取双倍物品
		local randomNum = AuRandom(1, 100)
		local cfg = EventBase:readEventMacro()
		if randomNum <= cfg["CUTBACK"] then
			self:getItem(self.itemID, self.itemNum * 2 )
			isBool = true
		end
	end
	self:cleanEventData()
	return isBool
end

--赌徒事件处理
function EventCtrl:doGambleEvent(flag)
	local isBool = false
	if flag == 1 then
		TaskBase:GetCountingTask(self, SEVER_TYPE_TRIGGER_NO.TYPE_DUBO)
		
		if self:subPlayerCopper(self.itemNum) == false then
			self:cleanEventData()
			return isBool
		end
		
		--输赢判定
		local cfg = EventBase:readEventMacro()
		local randomNum = AuRandom(1, 100)
		if randomNum <= cfg["WIN"] then
			local goldValue = self.playerCopper + self.itemNum * 2 
			self:set_playerCopper(goldValue)
			isBool = true
		end
	end
	self:cleanEventData()
	return isBool
end

--赠送事件处理
function EventCtrl:doGiveEvent(flag)
	local isBool = false
	if flag == 1 then
		self:getItem(self.itemID, self.itemNum)
		isBool = true
	end
	self:cleanEventData()
	return isBool
end

--天赋事件处理
function EventCtrl:doTalentEvent(eventID, flag)
	local isBool = false
	local eventCfg = EventBase:readEventById(eventID)
	if isEmpty(eventCfg) then
		return isBool
	end
	
	local useCfg = eventCfg["USE"]
	local talentID = eventCfg["TALENT"]
	if flag == 1 then
		if self:checkOutAndTakeawaySource(useCfg) == false then
			self:cleanEventData()
			return isBool
		end
		self:openPlayerTalent(talentID)  --激活天赋
		self:deleteEvent(talentID)       --删除事件
		isBool = true
	end
	self:cleanEventData()
	return isBool
end


--API
--事件处理
function World_EventCtrl_disposeEvent(playerID, eventID, flag)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:disposeEvent(eventID, flag)
end

