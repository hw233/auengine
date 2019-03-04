--BaseEntity.lua
require "resource.script.server.Macro.MacroMsgID"


ENTITY_PROP_TYPE_STRING = 1
ENTITY_PROP_TYPE_UINT8 = 2
ENTITY_PROP_TYPE_UINT16 = 3
ENTITY_PROP_TYPE_UINT32 = 4
ENTITY_PROP_TYPE_INT8 = 5
ENTITY_PROP_TYPE_INT16 = 6
ENTITY_PROP_TYPE_INT32 = 7

BaseEntity = {}

function BaseEntity:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.entityType = 0			--Entity类型
	self.playerName = ""		--Entity的名字
	self.playerID = 0			--玩家的客户端ID 也就是SocketID
	self.databaseID = 0			--数据库的ID		--只有保存数据库的Entity才有值
	self.playerDBID = 0			--实体的玩家DBID	--只有属于某玩家的实体才有值
	self.update_prop_msg_ID = 0 --同步客服端属性ID
	return object
end

function BaseEntity:set_playerID(pid)
	self.playerID = pid
end

function BaseEntity:set_playerName(name)
	self.playerName = name
end

function BaseEntity:set_playerDBID(playerDBID)
	self.playerDBID = playerDBID
end

function BaseEntity:set_databaseID(dbid)
	self.databaseID = dbid
end

function BaseEntity:set_entityType(_type)
	self.entityType = _type
end

function BaseEntity:set_update_prop_msg_ID(msgID)
	self.update_prop_msg_ID = msgID
end

function BaseEntity:sendPropToClient(prop_type,prop_value,prop_bit)
	if self.playerID == 0 or self.databaseID == 0 then
		return
	end
	Au.messageToClientBegin(self.playerID, self.update_prop_msg_ID)
	Au.addUint32(self.databaseID)
	Au.addUint8(prop_type)
	if prop_bit == ENTITY_PROP_TYPE_STRING then
		Au.addString(prop_value)
	elseif prop_bit == ENTITY_PROP_TYPE_INT8 then
		Au.addInt8(prop_value)
	elseif prop_bit == ENTITY_PROP_TYPE_UINT8 then
		Au.addUint8(prop_value)
	elseif prop_bit == ENTITY_PROP_TYPE_INT16 then
		Au.addInt16(prop_value)
	elseif prop_bit == ENTITY_PROP_TYPE_UINT16 then
		Au.addUint16(prop_value)
	elseif prop_bit == ENTITY_PROP_TYPE_INT32 then
		Au.addInt32(prop_value)
	elseif prop_bit == ENTITY_PROP_TYPE_UINT32 then
		Au.addUint32(prop_value)
	else --错误数据
		Au.addInt8(0)
		Au.messageEnd()
		PrintError(prop_type,prop_value,prop_bit)
		return
	end
	Au.messageEnd()
end