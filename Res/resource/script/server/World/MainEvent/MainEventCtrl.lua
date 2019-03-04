--MainEventCtrl.lua
require "resource.script.server.World.MainEvent.MainEventBase"

--ȫ�ֺ���
local pairs = pairs
local table_insert = table.insert

--�궨��
local EVENTTYPE = {}
EVENTTYPE.NULL = 1     --���¼�
EVENTTYPE.SALE = 2     --�����¼�
EVENTTYPE.CUT = 3      --��ȡ�¼�
EVENTTYPE.GAMBLE = 4   --��ͽ�¼�
EVENTTYPE.GIVE = 5     --�����¼�
EVENTTYPE.TALENT = 6   --�츳�¼�

EventCtrl = {}

function EventCtrl:New()
	local obj = setmetatable({},self)
	self.__index = self
	self.eventID = 0         --�������¼�Id
	self.itemIndex = 0       --��Ʒ���
	self.itemID = 0          --�¼�������������ƷID
	self.itemNum = 0         --�¼���������������(������Ʒ������ȡ��Ʒ����������Ʒ����Ĳ�)
	self.saleTB = 0          --�����¼�������
	self.eventFlag = 0       --�¼���״̬(0-�¼��Ѵ���1-�¼���û����)
	obj.eventList = {}       --�¼��б�
	
	return obj
end

--3����ִ�������¼�
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

--��ʼ���¼��б�
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

--����һ���¼�
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
	
	if eventType == EVENTTYPE.NULL then  --���¼�����
		return
	end
	
	if eventType == EVENTTYPE.GAMBLE then  --��ͽ�¼� ���С��100������
		if self.playerCopper < 100 then
			return
		end
	end
	
	self:triggerNum(eventID)   --�����¼�������
	self:setEventFlag(1)
	
	--�ظ��ͻ���
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_MAINEVENT_TRIGGEREVENT)
	Au.addUint32(self.eventID)
	Au.addUint8(self.itemIndex)
	Au.addUint32(self.itemNum)
	Au.messageEnd()
	
end

--�������¼�(�������¼�id��flag��0-�����ܣ�1-����)
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
	--�ظ��ͻ���
	local status = 1
	if ret == false then
		status = 0
	end
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_MAINEVENT_DOEVENT)
	Au.addUint8(status)
	Au.messageEnd()
end

--�����¼�״̬
function EventCtrl:setEventFlag(status)
	self.eventFlag = status
end

--�����¼�
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

--ɾ���¼�(�����츳����¼��б��Ƴ�)
function EventCtrl:deleteEvent(talentID)
	for eventID, obj in pairs(self.eventList) do
		if obj.TALENT == talentID then
			self.eventList[obj.ID] = nil
		end
	end
end

--����¼�����
function EventCtrl:cleanEventData()
	self.eventID = 0 
	self.itemIndex = 0
	self.itemID = 0          
	self.itemNum = 0
	self.eventFlag = 0
	self.saleTB = {}          
end

--ͳ���¼��б�ĸ����ܺ�
function EventCtrl:countProbabilitySum()
	local sum = 0
	for ID, obj in pairs(self.eventList) do
		sum = sum + obj.PROBABILITY
	end
	return sum
end

--�¼�������������Ʒ������
function EventCtrl:triggerNum(eventID)
	local eventCfg = EventBase:readEventById(eventID)
	if isEmpty(eventCfg) then
		return
	end
	
	self.eventID = eventID       --�¼�ID
	local ItemID = 0 ItemNum = 0 ItemIndex = 0
	local eventType = eventCfg["TYPE"]
	if eventType == EVENTTYPE.SALE or eventType == EVENTTYPE.CUT or eventType == EVENTTYPE.GIVE then
		ItemID, ItemNum, ItemIndex = self:getItemValueAndNum(self.exploreOBJ.nowBigMap, eventType)
		self.itemIndex = ItemIndex   --��Ʒ���
		self.itemID = ItemID         --��Ʒid
		self.itemNum = ItemNum       --��Ʒ����
		if eventType == EVENTTYPE.SALE then   
			self.saleTB = self:getSalecounsum(self.exploreOBJ.nowBigMap, ItemIndex)  --��������
		end
	else
		if eventType == EVENTTYPE.GAMBLE then
			self.itemNum = self:getGoldNum()   --�Ĳ��������
		end
	end
end

--�����ȡ��ƷID������
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
--ͳ��Ȩ�غ�	
	local QzSum = 0
	for i = 1, #ItemTB do
		QzSum = QzSum + ItemTB[i]["QZ"]
	end
--��ȡ��Ʒ�±�
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

--�����¼�������
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

--��ȡ�Ľ�����
function EventCtrl:getGoldNum()
	local percent = EventBase:getGoldPercent()
	local goldNum = NumberToInt(percent * self.playerCopper)
	return goldNum
end

--�����¼�����
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

--��ȡ�¼�����
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
		--�Ƿ��ܻ�ȡ˫����Ʒ
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

--��ͽ�¼�����
function EventCtrl:doGambleEvent(flag)
	local isBool = false
	if flag == 1 then
		TaskBase:GetCountingTask(self, SEVER_TYPE_TRIGGER_NO.TYPE_DUBO)
		
		if self:subPlayerCopper(self.itemNum) == false then
			self:cleanEventData()
			return isBool
		end
		
		--��Ӯ�ж�
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

--�����¼�����
function EventCtrl:doGiveEvent(flag)
	local isBool = false
	if flag == 1 then
		self:getItem(self.itemID, self.itemNum)
		isBool = true
	end
	self:cleanEventData()
	return isBool
end

--�츳�¼�����
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
		self:openPlayerTalent(talentID)  --�����츳
		self:deleteEvent(talentID)       --ɾ���¼�
		isBool = true
	end
	self:cleanEventData()
	return isBool
end


--API
--�¼�����
function World_EventCtrl_disposeEvent(playerID, eventID, flag)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:disposeEvent(eventID, flag)
end

