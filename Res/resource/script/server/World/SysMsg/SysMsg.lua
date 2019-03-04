--SysMsg.lua

SysMsg = {}

SysMsg.MSG_BROADCAST = 1  --广播
SysMsg.MSG_SYSTEM = 2	  --系统
SysMsg.MSG_WORLd = 3      --世界频道
SysMsg.MSG_UNION = 4	  --工会频道
SysMsg.MSG_PERSON = 5     --私聊频道

function SysMsg:BroadcastMessageToPlayer(playerID, pname, channelID, msg)
	if msg == nil then
		return
	end
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_SYSMSG_PRIVATEMSG)
	Au.addUint8(channelID)
	Au.addString(pname)
	Au.addString(msg)
	Au.messageEnd()
end

function SysMsg:BroadcastMessageToAll(channel, msg)
	
end

function SysMsg:HandleSysMsg(playerID, pname, channelID, sysMsg)
	if channelID > SysMsg.MSG_SYSTEM or channelID < SysMsg.MSG_BROADCAST then
		return
	end
	if channelID == SysMsg.MSG_BROADCAST then
		for pid,_player in pairs(Players) do 
			if _player.playerID ~= 0 then
				SysMsg:BroadcastMessageToPlayer(_player.playerID, pname, channelID, sysMsg)
			end
		end
	elseif channelID == SysMsg.MSG_SYSTEM then
		SysMsg:BroadcastMessageToPlayer(playerID, pname, channelID, sysMsg)
	else
		
	end
end

--系统提示消息(无参数控制)
function sendSystemMsg(playerID, sysMsg)
	if playerID == 0 or type(sysMsg) ~= "string" or playerID == nil then 
		return
	end
	SysMsg:HandleSysMsg( playerID, "1", SysMsg.MSG_SYSTEM, Au.ToUTF8(sysMsg) )
end

function sendGongGaoMsgToAll(chatMsg)
	for pid,_player in pairs(Players) do
		if _player.playerID ~= 0 then
			SysMsg:HandleSysMsg(_player.playerID, Au.ToUTF8("公告"), SysMsg.MSG_BROADCAST, Au.ToUTF8(chatMsg))
		end
	end
end


function SysMsg:SendInfoToClient(playerID, playerName, MemberList, ChannelID, MsgInfo)
	for _, _player in pairs(MemberList) do
		if _player.playerID ~= 0 then
			Au.messageToClientBegin(_player.playerID, MacroMsgID.MSG_ID_MSGSYS_WORLD)
			Au.addUint8(ChannelID)      --频道ID
			Au.addString(playerName)    --发送该信息的玩家名称
			Au.addString(MsgInfo)       --消息
			Au.messageEnd()
		end
	end
end

--发送世界信息接口
function SysMsg:SendWordMsg(playerID, ChannelID, MsgInfo)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	SysMsg:SendInfoToClient(playerID, _player.playerName, Players, ChannelID, MsgInfo)
end


--发送工会信息接口
function SysMsg:SendUnionMsg(playerID, ChannelID, MsgInfo)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	local unionList = _player:getUnionList()   --获取工会成员列表TODO
	if isEmpty(unionList) then
		return
	end
	
	SysMsg:SendInfoToClient(playerID, _player.playerName, unionList, ChannelID, MsgInfo)
	
end


--发送私聊信息接口 注:OtherName为对方的名称
function SysMsg:SendPersonMsg(playerID, OtherName, ChannelID, MsgInfo)
	local playerInfo = Player:getPlayerFromID(playerID)
	local _player = Player:getPlayerFromName(OtherName)
	
	if isEmpty(playerInfo) or isEmpty(_player) then
		sendSystemMsg(playerInfo.playerID, "玩家不存在")
		return
	end
	
	if _player.playerID == 0 then   --对方不在线
		sendSystemMsg(playerInfo.playerID, "玩家不在线")
		return
	end
	
	--发送给自己A
	Au.messageToClientBegin(playerInfo.playerID, MacroMsgID.MSG_ID_MSGSYS_PERSON)
		Au.addUint8(ChannelID)                      --频道ID
		Au.addUint8(0)                      		--发送
		Au.addString(_player.playerName)        	--接收方姓名
		Au.addString(MsgInfo)  
	Au.messageEnd()
	
	--发送给对方B
	Au.messageToClientBegin(_player.playerID, MacroMsgID.MSG_ID_MSGSYS_PERSON)
		Au.addUint8(ChannelID)                      --频道ID
		Au.addUint8(1)                      		--接收
		Au.addString(playerInfo.playerName)        	--发送方姓名
		Au.addString(MsgInfo)            			--消息
	Au.messageEnd()
end

--获取聊天玩家信息
function SysMsg:getPlayerInfo(playerID, playerName)
	local playerInfo = Player:getPlayerFromName(playerName)
	if isEmpty(playerInfo) then
		return
	end
	
--	local level = playerInfo.leadObject.heroLevel
--	local fightPower = playerInfo.leadObject.fightPower
	local level = 1
	local fightPower = 1
	
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_MSGSYS_PLAYERINFO)
	Au.addUint8(level)                      --等级
	Au.addString(playerInfo.playerName)     --玩家姓名
	Au.addUint32(fightPower)            	--战斗力
	Au.messageEnd()
end



--客户端API
--世界, 工会
function World_MsgSys_Send_WOrldOrUnion_MsgInfo(playerID, ChannelID, MsgInfo)
	if playerID == nil or playerID == 0 or type(MsgInfo) ~= "string" or ChannelID == nil then
		return
	end

	if ChannelID == SysMsg.MSG_WORLd then
		SysMsg:SendWordMsg(playerID, ChannelID, MsgInfo)    --世界
	elseif ChannelID == SysMsg.MSG_UNION then
		SysMsg:SendUnionMsg(playerID, ChannelID, MsgInfo)   --工会
	else
		return
	end

end

--私聊
function World_MsgSys_SendPersonMsg(playerID, ChannelID, OtherName, MsgInfo)
	if playerID == nil or playerID == 0 or OtherName == nil or ChannelID ~= SysMsg.MSG_PERSON or type(MsgInfo) ~= "string" then
		return
	end
	
	SysMsg:SendPersonMsg(playerID, OtherName, ChannelID, MsgInfo)
end

--请求聊天玩家信息
function World_MsgSys_Playerinfo(playerID, playerName)
	if playerID == nil or playerID == 0 then
		return
	end
	
	SysMsg:getPlayerInfo(playerID, playerName)
end
