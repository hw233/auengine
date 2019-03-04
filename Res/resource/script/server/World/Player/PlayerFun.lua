--PlayerFun.lua

local PlayerFun = {}

--����
function PlayerFun:playerOnline(playerID, accountID, clientIP)
	if getTableLength(Players) >= GData.maxOnlinePlayer then
		self:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_MAX_ONLINE)
		return
	end
	local _player = Players_account[accountID]
	if isEmpty(_player) then
		self:playerFun_CreatePlayer_toClient( playerID, clientIP, accountID )
		return
	end
	if _player.playerID ~= 0 and _player.playerID ~= playerID then
		self:sendPlayerLogonToClient(_player.playerID, LOG_BACK_TYPE.LOG_PLAYER_OTHER)
		Players[_player.playerID] = nil
		Au.disconnectPlayer(_player.playerID)
	end
	_player.clientIP = clientIP
	_player:handlePlayerOnline(true)
	_player:doPlayerOnLine(playerID)
	self:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_SUCCESS)
end

--����
function PlayerFun:playerOffline(playerID, accountID)
	local _player = Players_account[accountID]
	if not isEmpty(_player) then
		SaveDB.OfflinePlayers[_player.databaseID] = _player
		if Players[playerID] == _player then
			Players[playerID] = nil
		end
		if _player.playerID == playerID then --��ȫ����
			error("Game:onPlayerDisconnect Normal:"..playerID.." "..accountID)
			_player:set_playerID(0)
			_player:handlePlayerOnline(false)
			_player:handlePlayerOffline()
		else
			error("Game:onPlayerDisconnect Error:"..playerID.." "..accountID)
		end
	end
end

--������ɫ to client
function PlayerFun:playerFun_CreatePlayer_toClient(playerID, clientIP, accountID)
	Players_IP[accountID] = clientIP
	self:sendPlayerLogonToClient(playerID, LOG_BACK_TYPE.LOG_CREATE_PLAYER)	
end

--to client and validate
--��ҵ�½��Ϣ���͸��ͻ���
function PlayerFun:sendPlayerLogonToClient(playerID, backType)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_PLAYER_LOGON_SUCCESS)
	Au.addUint8(backType)
	Au.messageEnd()
end

return {PlayerFun = PlayerFun}