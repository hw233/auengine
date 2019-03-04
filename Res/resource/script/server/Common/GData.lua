--GData.lua

GData = {}

GData.AgentID = ""			--代理商标识
GData.ServerID = ""			--代理商的服务器
GData.maxOnlinePlayer = 1 	--最大在线人数
GData.maxRegester = 1 		--最大注册人数
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