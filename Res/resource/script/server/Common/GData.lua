--GData.lua

GData = {}

GData.AgentID = ""			--�����̱�ʶ
GData.ServerID = ""			--�����̵ķ�����
GData.maxOnlinePlayer = 1 	--�����������
GData.maxRegester = 1 		--���ע������
GData.ServerIP = ""

function Game_SetAgentID(idStr)
	GData.AgentID = idStr
end

function Game_SetServerID(idStr)
	GData.ServerID = idStr
end

function Game_SetMaxOnline(num)
	GData.maxOnlinePlayer = num
end

function Game_SetMaxRegester(num)
	GData.maxRegester = num
end

function Game_SetServerIP(ipStr)
	GData.ServerIP = ipStr
end