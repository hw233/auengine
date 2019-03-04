--SysMsg.lua

SysMsg = {}

SysMsg.MSG_BROADCAST = 1  --�㲥
SysMsg.MSG_SYSTEM = 2	  --ϵͳ
SysMsg.MSG_WORLd = 3      --����Ƶ��
SysMsg.MSG_UNION = 4	  --����Ƶ��
SysMsg.MSG_PERSON = 5     --˽��Ƶ��

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

--ϵͳ��ʾ��Ϣ(�޲�������)
function sendSystemMsg(playerID, sysMsg)
	if playerID == 0 or type(sysMsg) ~= "string" or playerID == nil then 
		return
	end
	SysMsg:HandleSysMsg( playerID, "1", SysMsg.MSG_SYSTEM, Au.ToUTF8(sysMsg) )
end

function sendGongGaoMsgToAll(chatMsg)
	for pid,_player in pairs(Players) do
		if _player.playerID ~= 0 then
			SysMsg:HandleSysMsg(_player.playerID, Au.ToUTF8("����"), SysMsg.MSG_BROADCAST, Au.ToUTF8(chatMsg))
		end
	end
end


function SysMsg:SendInfoToClient(playerID, playerName, MemberList, ChannelID, MsgInfo)
	for _, _player in pairs(MemberList) do
		if _player.playerID ~= 0 then
			Au.messageToClientBegin(_player.playerID, MacroMsgID.MSG_ID_MSGSYS_WORLD)
			Au.addUint8(ChannelID)      --Ƶ��ID
			Au.addString(playerName)    --���͸���Ϣ���������
			Au.addString(MsgInfo)       --��Ϣ
			Au.messageEnd()
		end
	end
end

--����������Ϣ�ӿ�
function SysMsg:SendWordMsg(playerID, ChannelID, MsgInfo)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	SysMsg:SendInfoToClient(playerID, _player.playerName, Players, ChannelID, MsgInfo)
end


--���͹�����Ϣ�ӿ�
function SysMsg:SendUnionMsg(playerID, ChannelID, MsgInfo)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	local unionList = _player:getUnionList()   --��ȡ�����Ա�б�TODO
	if isEmpty(unionList) then
		return
	end
	
	SysMsg:SendInfoToClient(playerID, _player.playerName, unionList, ChannelID, MsgInfo)
	
end


--����˽����Ϣ�ӿ� ע:OtherNameΪ�Է�������
function SysMsg:SendPersonMsg(playerID, OtherName, ChannelID, MsgInfo)
	local playerInfo = Player:getPlayerFromID(playerID)
	local _player = Player:getPlayerFromName(OtherName)
	
	if isEmpty(playerInfo) or isEmpty(_player) then
		sendSystemMsg(playerInfo.playerID, "��Ҳ�����")
		return
	end
	
	if _player.playerID == 0 then   --�Է�������
		sendSystemMsg(playerInfo.playerID, "��Ҳ�����")
		return
	end
	
	--���͸��Լ�A
	Au.messageToClientBegin(playerInfo.playerID, MacroMsgID.MSG_ID_MSGSYS_PERSON)
		Au.addUint8(ChannelID)                      --Ƶ��ID
		Au.addUint8(0)                      		--����
		Au.addString(_player.playerName)        	--���շ�����
		Au.addString(MsgInfo)  
	Au.messageEnd()
	
	--���͸��Է�B
	Au.messageToClientBegin(_player.playerID, MacroMsgID.MSG_ID_MSGSYS_PERSON)
		Au.addUint8(ChannelID)                      --Ƶ��ID
		Au.addUint8(1)                      		--����
		Au.addString(playerInfo.playerName)        	--���ͷ�����
		Au.addString(MsgInfo)            			--��Ϣ
	Au.messageEnd()
end

--��ȡ���������Ϣ
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
	Au.addUint8(level)                      --�ȼ�
	Au.addString(playerInfo.playerName)     --�������
	Au.addUint32(fightPower)            	--ս����
	Au.messageEnd()
end



--�ͻ���API
--����, ����
function World_MsgSys_Send_WOrldOrUnion_MsgInfo(playerID, ChannelID, MsgInfo)
	if playerID == nil or playerID == 0 or type(MsgInfo) ~= "string" or ChannelID == nil then
		return
	end

	if ChannelID == SysMsg.MSG_WORLd then
		SysMsg:SendWordMsg(playerID, ChannelID, MsgInfo)    --����
	elseif ChannelID == SysMsg.MSG_UNION then
		SysMsg:SendUnionMsg(playerID, ChannelID, MsgInfo)   --����
	else
		return
	end

end

--˽��
function World_MsgSys_SendPersonMsg(playerID, ChannelID, OtherName, MsgInfo)
	if playerID == nil or playerID == 0 or OtherName == nil or ChannelID ~= SysMsg.MSG_PERSON or type(MsgInfo) ~= "string" then
		return
	end
	
	SysMsg:SendPersonMsg(playerID, OtherName, ChannelID, MsgInfo)
end

--�������������Ϣ
function World_MsgSys_Playerinfo(playerID, playerName)
	if playerID == nil or playerID == 0 then
		return
	end
	
	SysMsg:getPlayerInfo(playerID, playerName)
end
