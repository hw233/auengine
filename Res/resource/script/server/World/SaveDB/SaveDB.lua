--SaveDB.lua

SaveDB = {}

SaveDB.OfflinePlayers = {}

--ֱ�ӱ���ȫ����Ϸ����
function SaveDB:saveToDB(isShutDown)
	local dbSaveSize = Au.queryGetSize(1)
	error("��ǰ�������:"..getTableLength(Players).." MYSQL World:"..dbSaveSize)
	if dbSaveSize > 10 and isShutDown == false then
		return
	end
	for playerID,_player in pairs(Players) do --�������
		_player:WriteDataToDatabase()
	end
	for databaseID,_player in pairs(SaveDB.OfflinePlayers) do --�����ߵ����
		_player:WriteDataToDatabase()
	end
	SaveDB.OfflinePlayers = {}
	self:saveGlobalDataToDB()
end

--����ҵ�ȫ������д����
function SaveDB:saveGlobalDataToDB()
	
end

--ֱ�ӱ���������ҵ�����
function SaveDB:SaveAllPlayerData()
	self:saveGlobalDataToDB()
	for DBID,_player in pairs(Players_DBID) do --�������
		_player:WriteDataToDatabase()
	end
end