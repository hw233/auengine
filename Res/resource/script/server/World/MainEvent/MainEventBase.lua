--MainEventBase.lua
require "resource.script.server.Config.MainEvent.CUTITEM"
require "resource.script.server.Config.MainEvent.EVENTS"
require "resource.script.server.Config.MainEvent.GIVEITEM"
require "resource.script.server.Config.MainEvent.SALEITEM"
require "resource.script.server.Config.MainEvent.EVENTMACRO"

local pairs = pairs
local table_insert = table.insert

EventBase = {}

function EventBase:New()
	local obj = setmetatable({}, self)
	self.__index = self
	
	return obj
end

--获取赌金比例
function EventBase:getGoldPercent()
	local cfg = EventBase:readEventMacro()
	local value = AuRandom(cfg["MIN_MAX"][1], cfg["MIN_MAX"][2])/100
	return value
end

--读取配置
--主城事件
function EventBase:readEventsCfg()
	return EVENTS
end

function EventBase:readEventById(eventID)
	local ID = "ID_"..eventID
	return EVENTS[ID]
end

--出售库
function EventBase:readSaleItemCfg(FBID)
	local itemTB = {}
	for _, obj in pairs(SALEITEM) do
		if obj.FBID == FBID then
			table_insert(itemTB, obj)
		end
	end
	return itemTB
end

--索取库
function EventBase:readCutItemCfg(FBID)
	local itemTB = {}
	for _, obj in pairs(CUTITEM) do
		if obj.FBID == FBID then
			table_insert(itemTB, obj)
		end
	end
	return itemTB
end

--赠送库
function EventBase:readGiveItemCfg(FBID)
	local itemTB = {}
	for _, obj in pairs(GIVEITEM) do
		if obj.FBID == FBID then
			table_insert(itemTB, obj)
		end
	end
	return itemTB
end

--其他宏配置
function EventBase:readEventMacro()
	return EVENTMACRO
end