--SaveDB.lua

SaveDB = {}

SaveDB.OfflinePlayers = {}

--直接保存全部游戏数据
function SaveDB:saveToDB(isShutDown)
	local dbSaveSize = Au.queryGetSize(1)
	error("当前在线玩家:"..getTableLength(Players).." MYSQL World:"..dbSaveSize)
	if dbSaveSize > 10 and isShutDown == false then
		return
	end
	for playerID,_player in pairs(Players) do --在线玩家
		_player:WriteDataToDatabase()
	end
	for databaseID,_player in pairs(SaveDB.OfflinePlayers) do --刚下线的玩家
		_player:WriteDataToDatabase()
	end
	SaveDB.OfflinePlayers = {}
	self:saveGlobalDataToDB()
end

--非玩家的全局数据写这里
function SaveDB:saveGlobalDataToDB()
	
end

--直接保存所有玩家的数据
function SaveDB:SaveAllPlayerData()
	self:saveGlobalDataToDB()
	for DBID,_player in pairs(Players_DBID) do --在线玩家
		_player:WriteDataToDatabase()
	end
end