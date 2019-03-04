-- PlayerEmailCtrl.lua

require "resource.script.server.Config.Email.RANKINGREWARD"
require "resource.script.server.Config.Email.RANKINGTOPREWARD"
require "resource.script.server.World.EmailSys.PlayerEmail"

--宏定义
local EMAILTYPEMACRO = {}
EMAILTYPEMACRO.NOTICE = 901        --公告邮件
EMAILTYPEMACRO.UPDATE = 902        --更新补偿邮件
EMAILTYPEMACRO.RANKING = 101       --竞技场排名奖励邮件
EMAILTYPEMACRO.RANKINGTOP = 102    --竞技场最高排名奖励邮件

--全局函数
local table_insert = table.insert
local pairs = pairs


PlayerEmailCtrl = {}

function PlayerEmailCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	obj.emailList = {}      --邮件列表
	
	return obj
end

--读取数据库初始化玩家邮件列表
function PlayerEmailCtrl:InitPlayerEmail(sqlResult, tableName)
	if isEmpty(sqlResult) then
		return
	end
	
	for i = 1, sqlResult:GetRowCount() do
		local obj = PlayerEmail:CreatePlayerEmailNew()
		obj.emailKey = sqlResult:GetFieldFromCount(0):GetUInt32()
		obj.emailID = sqlResult:GetFieldFromCount(2):GetUInt32()
		obj.emailContent = sqlResult:GetFieldFromCount(3):GetString()
		obj.readFlag = sqlResult:GetFieldFromCount(4):GetInt8()
		obj.deleteFlag = sqlResult:GetFieldFromCount(5):GetInt8()
		obj.emailCreateTime = sqlResult:GetFieldFromCount(6):GetUInt32()
		obj.emailSaveTime = sqlResult:GetFieldFromCount(7):GetUInt32()
		obj.ranking = sqlResult:GetFieldFromCount(8):GetUInt32()
		
		self.emailList[obj.emailKey] = obj  --保存邮件到列表
		
		sqlResult:NextRow()
	end
	sqlResult:Delete()
end

--获取邮件列表
function PlayerEmailCtrl:ReturnEmailList()
	local ItemList = self:getPlayerEmail()  --玩家身上的邮件
	local emailNums = self:getMailCount()
	
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_EMAIL_EMAILLIST)
		Au.addUint16(emailNums)            --邮件数量
		if emailNums ~= 0 then
			for k, obj in pairs(ItemList) do
				Au.addUint32(obj.emailKey)         --邮件唯一id
				Au.addUint32(obj.emailID)   	   --邮件类型
				Au.addUint8(obj.readFlag)          --1-已读，0-未读
				Au.addUint32(obj.emailCreateTime)  --生成时间
				if obj.emailID == EMAILTYPEMACRO.RANKING then
					Au.addUint32(obj.ranking)
				end
				if obj.emailID == EMAILTYPEMACRO.NOTICE or obj.emailID == EMAILTYPEMACRO.UPDATE then
					local content = SysEmailList[obj.emailKey].emailContent
					local rewardItem = SysEmailList[obj.emailKey].emailRewardList
					Au.addString(content)          --内容
					Au.addString(rewardItem)       --奖励列表
				end
			end
		end
		Au.messageEnd()
		
end

--玩家当前身上的邮件
function PlayerEmailCtrl:getPlayerEmail()
	local emailItem = self:getEmailList()
	if isEmpty(emailItem) then
		print("---player emailList null")
		return
	end
	
	local playerEmailList = {}
	for k, obj in pairs(self.emailList) do
		if obj.deleteFlag ~= 1 then                            -- 过滤已删除的邮件
			playerEmailList[obj.emailKey] = obj
		end
	end
	
	return playerEmailList
end

--邮件列表整合
function PlayerEmailCtrl:getEmailList()
--删除到期邮件
	local nowTime = Au.nowTime()
	if isEmpty(SysEmailList) == false then
		for k, obj in pairs(SysEmailList) do
			if  nowTime >= obj.emailSaveTime then
				SysEmail:deleteSysEmail(obj.emailKey)    --删除邮件
			end
		end
	end
	
	if isEmpty(self.emailList) == false then
		for k, _Obj in pairs(self.emailList) do
			if  nowTime >= _Obj.emailSaveTime then
				self:DeleteEndTimeEmail(_Obj.emailKey)
			end
		end
	end

--邮件列表
	if isEmpty(SysEmailList) then
		if isEmpty(self.emailList) then
			return
		else
			return self.emailList
		end
	else if isEmpty(self.emailList) then
		for k, emailObj in pairs(SysEmailList) do
			local oneItem = PlayerEmail:CreateEmail(emailObj)
			self.emailList[emailObj.emailKey] = oneItem  --保存邮件到玩家列表
			self:UpdateEmailInfo(oneItem)                                       --保存到玩家邮件数据库
		end
			return self.emailList
	else
		for i, SysEmailObj in pairs(SysEmailList) do
			if self.emailList[SysEmailObj.emailKey] == nil then
				local Item = PlayerEmail:CreateEmail(SysEmailObj)
				self.emailList[SysEmailObj.emailKey] = Item  --保存邮件到玩家列表
				self:UpdateEmailInfo(Item)                                       --保存到玩家邮件数据库
			end
		end
		
		return self.emailList
	end
 end	
	
end

--回写邮件
function PlayerEmailCtrl:WriteEmailData()
	for _, obj in pairs(self.emailList) do
		if obj.flag then
			self:UpdateEmailInfo(obj)
		end
	end
end

--更新邮件
function PlayerEmailCtrl:UpdateEmailInfo(emailObj)
	Au.queryQueue("CALL update_tb_UserEmail("..emailObj.emailKey..","
											 ..self.databaseID..","
											 ..emailObj.emailID..",'"
											 ..emailObj.emailContent.."',"
											 ..emailObj.readFlag..","
											 ..emailObj.deleteFlag..","
											 ..emailObj.emailCreateTime..","
											 ..emailObj.emailSaveTime..","
											 ..emailObj.ranking..
											 ");")
end

--邮件操作
function PlayerEmailCtrl:ReadOrDeleletEmail(emailKey, emailID)
	local Cfg = SysEmail:readSysEmailCfg(emailID)
	if isEmpty(Cfg) then
		return
	end
	
	if Cfg["isDelete"] == 0 then       --阅读后不删除 
		self.emailList[emailKey].readFlag = 1             -- 1-已读，0-未读
	elseif Cfg["isDelete"] == 1 then   --阅读后删除
		self.emailList[emailKey].readFlag = 1
		self.emailList[emailKey].deleteFlag = 1           -- 1-邮件已删除
	else
		return
	end
	
	self.emailList[emailKey].flag = true                 
end

--删除到期邮件
function PlayerEmailCtrl:DeleteEndTimeEmail(emailKey)
	self.emailList[emailKey] = nil
	Au.queryQueue("DELETE FROM tb_useremail WHERE gid = "..emailKey.." AND playerDBID = "..self.databaseID..";")
end

--统计玩家邮件数量
function PlayerEmailCtrl:getMailCount()
	local num = 0
	for k, emailItem in pairs(self.emailList) do
		if emailItem.deleteFlag == 0 then
			num = num + 1
		end
	end
	return num
end

--凌晨生成排名奖励邮件
function PlayerEmailCtrl:CreateEmailMidnight(emailKey, emailID)
	local emailCfg = SysEmail:readSysEmailCfg(emailID)  -- 101类型邮件
	if isEmpty(emailCfg) then
		print("error!!!")
		return
	end
	
	local createTime = Au.nowTime()
	local obj = PlayerEmail:CreatePlayerEmailNew()
	obj.emailKey = eKey
	obj.emailID = emailID
	obj.emailCreateTime = createTime 
	obj.emailSaveTime = createTime + emailCfg["saveTime"]
	obj.emailIsReward = emailCfg["isReward"]
	obj.ranking = self.ArenaObject.arenaRank      -- 排名
	
	self.emailList[obj.emailKey] = obj
	self:UpdateEmailInfo(obj)
	
	SysEmail:SendNewEmailIfno()  -- 通知有新邮件生成

end

--凌晨系统给每个玩家生成一封排名邮件
function PlayerEmailCtrl:CreateRankingEmail()
	local emailKey = Au.getDatateID("tb_email")
	local emailID = EMAILTYPEMACRO.RANKING
	self:CreateEmailMidnight(emailKey, emailID)
end


--打完竞技场后创建排名奖励邮件 预留接口TODO
function PlayerEmailCtrl:CreateRankingEmail()
	local gid = Au.getDatateID("tb_email")
	
end

--领取附件奖励
function PlayerEmailCtrl:getEmailReward(emailKey, emailID)
	if isEmpty(self.emailList[emailKey]) then
		return
	end
	
	if self.emailList[emailKey].readFlag == 1 then  --该邮件已经阅读领取
		return
	end
	
	if emailID == EMAILTYPEMACRO.NOTICE then          --公告邮件
		return
	elseif emailID == EMAILTYPEMACRO.UPDATE then      --更新补偿邮件
		if isEmpty(SysEmailList[emailKey]) then
			return
		elseif SysEmailList[emailKey].emailIsReward == 0 then  -- 0-没有奖励，1-有奖励
			return
		else
			local item = SysEmailList[emailKey].emailRewardList
			local itemList = PlayerEmailCtrl:SplitRewardList(item)  --拆分附件列表
			self:createItemList(itemList)
		end
	elseif emailID == EMAILTYPEMACRO.RANKING then      --竞技场排名奖励邮件
		local ranking = self.ArenaObject.arenaRank     --获取排名
		local item = PlayerEmailCtrl:readRankingCfg(ranking)  
		self:createItemList(item)
	elseif emailID == EMAILTYPEMACRO.RANKINGTOP then   --竞技场最高排名奖励邮件
	--预留接口TODO
		local ranking = getRanking()   --获取排名
		local item = PlayerEmailCtrl:readRankingTopCfg(ranking)  
		self:createItemList(item)
	else
		print("error!!")
		return
	end
end

--读取配置文件
function PlayerEmailCtrl:readRankingCfg(ranking)
	local index = 0
	local TB = RANKING_REWARD["RANKING_INTERVAL"]
		if ranking <= 3 then         --前3名
			index = ranking
		elseif ranking >= 501 then   --501名之后
			index = #TB
		else
			for k, value in pairs(TB) do
				if ranking <= value[2] then
					index = k
					break	
				end
			end
		end
	local rewardIndex = "REWARD_"..index
	return RANKING_REWARD[rewardIndex]
end

--最高排名配置
function PlayerEmailCtrl:readRankingTopCfg(ranking)
	return SEVEN_TOP_REWARD[ranking]
end

--拆分附件奖励列表
function PlayerEmailCtrl:SplitRewardList(list)
	local itemList = {}
	local tab = Split(list, ';')
	for k,oneTB in pairs(tab) do
		local tempList = {}
		local oneItem = Split(oneTB,'%$')
		for _, value in pairs(oneItem) do
			table_insert(tempList,tonumber(value))
		end
		table_insert(itemList,tempList)
	end
	return itemList
end


--客户端API
--请求邮件列表
function World_EmailSys_ReturnEmialList(playerID, bool)
	local playerObj = Player:getPlayerFromID(playerID)
	if isEmpty(playerObj) then
		return
	end
	
	playerObj:ReturnEmailList()
end

--邮件操作(阅读， 删除， 领取附件)
function World_EmailSys_getEmailReward(playerID, gid, emailID)
	local playerObj = Player:getPlayerFromID(playerID)
	if isEmpty(playerObj) then
		return
	end
	
	local cfg = SysEmail:readSysEmailCfg(emailID)
	if isEmpty(cfg) then
		return
	end
	
	if cfg["isReward"] == 1 then    
		playerObj:getEmailReward(gid, emailID) --领取附件奖励
	end
	
	playerObj:ReadOrDeleletEmail(gid, emailID)
end

