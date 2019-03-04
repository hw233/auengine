 function Addsqlquery()
	Au.StartSqlQueue();
	Au.AddSqlQueue("SELECT * FROM tb_playerInfo")
	Au.EndSqlQueue();
 end


function Handsqlquery()
	local sqlResult = nil
	sqlResult = Au.GetWorldQueueResult();
	if sqlResult==nil then 
		print("sql_result is empty")
		return  
	end
	local totalPlayerNum = sqlResult:GetRowCount()
	for j = 1, totalPlayerNum do
		local dbid = sqlResult:GetFieldFromCount(0):GetUInt32()
		local usex = sqlResult:GetFieldFromCount(2):GetUInt16()
		local uname = sqlResult:GetFieldFromCount(3):GetString()
		local accountID = sqlResult:GetFieldFromCount(4):GetString()
		local onLineTime = sqlResult:GetFieldFromCount(5):GetUInt32()
		local offLineTime = sqlResult:GetFieldFromCount(6):GetUInt32()
		local lasttime = sqlResult:GetFieldFromCount(7):GetUInt32()
		-- 创建实体
		print("ddd", dbid, usex, uname, accountID)
	--	Player:createFromDB( dbid, uname, accountID, usex, onLineTime, offLineTime, lasttime)
		sqlResult:NextRow()
	end
	sqlResult:Delete()
end  