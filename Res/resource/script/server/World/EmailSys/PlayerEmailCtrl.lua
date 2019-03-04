-- PlayerEmailCtrl.lua

require "resource.script.server.Config.Email.RANKINGREWARD"
require "resource.script.server.Config.Email.RANKINGTOPREWARD"
require "resource.script.server.World.EmailSys.PlayerEmail"

--�궨��
local EMAILTYPEMACRO = {}
EMAILTYPEMACRO.NOTICE = 901        --�����ʼ�
EMAILTYPEMACRO.UPDATE = 902        --���²����ʼ�
EMAILTYPEMACRO.RANKING = 101       --���������������ʼ�
EMAILTYPEMACRO.RANKINGTOP = 102    --������������������ʼ�

--ȫ�ֺ���
local table_insert = table.insert
local pairs = pairs


PlayerEmailCtrl = {}

function PlayerEmailCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	obj.emailList = {}      --�ʼ��б�
	
	return obj
end

--��ȡ���ݿ��ʼ������ʼ��б�
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
		
		self.emailList[obj.emailKey] = obj  --�����ʼ����б�
		
		sqlResult:NextRow()
	end
	sqlResult:Delete()
end

--��ȡ�ʼ��б�
function PlayerEmailCtrl:ReturnEmailList()
	local ItemList = self:getPlayerEmail()  --������ϵ��ʼ�
	local emailNums = self:getMailCount()
	
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_EMAIL_EMAILLIST)
		Au.addUint16(emailNums)            --�ʼ�����
		if emailNums ~= 0 then
			for k, obj in pairs(ItemList) do
				Au.addUint32(obj.emailKey)         --�ʼ�Ψһid
				Au.addUint32(obj.emailID)   	   --�ʼ�����
				Au.addUint8(obj.readFlag)          --1-�Ѷ���0-δ��
				Au.addUint32(obj.emailCreateTime)  --����ʱ��
				if obj.emailID == EMAILTYPEMACRO.RANKING then
					Au.addUint32(obj.ranking)
				end
				if obj.emailID == EMAILTYPEMACRO.NOTICE or obj.emailID == EMAILTYPEMACRO.UPDATE then
					local content = SysEmailList[obj.emailKey].emailContent
					local rewardItem = SysEmailList[obj.emailKey].emailRewardList
					Au.addString(content)          --����
					Au.addString(rewardItem)       --�����б�
				end
			end
		end
		Au.messageEnd()
		
end

--��ҵ�ǰ���ϵ��ʼ�
function PlayerEmailCtrl:getPlayerEmail()
	local emailItem = self:getEmailList()
	if isEmpty(emailItem) then
		print("---player emailList null")
		return
	end
	
	local playerEmailList = {}
	for k, obj in pairs(self.emailList) do
		if obj.deleteFlag ~= 1 then                            -- ������ɾ�����ʼ�
			playerEmailList[obj.emailKey] = obj
		end
	end
	
	return playerEmailList
end

--�ʼ��б�����
function PlayerEmailCtrl:getEmailList()
--ɾ�������ʼ�
	local nowTime = Au.nowTime()
	if isEmpty(SysEmailList) == false then
		for k, obj in pairs(SysEmailList) do
			if  nowTime >= obj.emailSaveTime then
				SysEmail:deleteSysEmail(obj.emailKey)    --ɾ���ʼ�
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

--�ʼ��б�
	if isEmpty(SysEmailList) then
		if isEmpty(self.emailList) then
			return
		else
			return self.emailList
		end
	else if isEmpty(self.emailList) then
		for k, emailObj in pairs(SysEmailList) do
			local oneItem = PlayerEmail:CreateEmail(emailObj)
			self.emailList[emailObj.emailKey] = oneItem  --�����ʼ�������б�
			self:UpdateEmailInfo(oneItem)                                       --���浽����ʼ����ݿ�
		end
			return self.emailList
	else
		for i, SysEmailObj in pairs(SysEmailList) do
			if self.emailList[SysEmailObj.emailKey] == nil then
				local Item = PlayerEmail:CreateEmail(SysEmailObj)
				self.emailList[SysEmailObj.emailKey] = Item  --�����ʼ�������б�
				self:UpdateEmailInfo(Item)                                       --���浽����ʼ����ݿ�
			end
		end
		
		return self.emailList
	end
 end	
	
end

--��д�ʼ�
function PlayerEmailCtrl:WriteEmailData()
	for _, obj in pairs(self.emailList) do
		if obj.flag then
			self:UpdateEmailInfo(obj)
		end
	end
end

--�����ʼ�
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

--�ʼ�����
function PlayerEmailCtrl:ReadOrDeleletEmail(emailKey, emailID)
	local Cfg = SysEmail:readSysEmailCfg(emailID)
	if isEmpty(Cfg) then
		return
	end
	
	if Cfg["isDelete"] == 0 then       --�Ķ���ɾ�� 
		self.emailList[emailKey].readFlag = 1             -- 1-�Ѷ���0-δ��
	elseif Cfg["isDelete"] == 1 then   --�Ķ���ɾ��
		self.emailList[emailKey].readFlag = 1
		self.emailList[emailKey].deleteFlag = 1           -- 1-�ʼ���ɾ��
	else
		return
	end
	
	self.emailList[emailKey].flag = true                 
end

--ɾ�������ʼ�
function PlayerEmailCtrl:DeleteEndTimeEmail(emailKey)
	self.emailList[emailKey] = nil
	Au.queryQueue("DELETE FROM tb_useremail WHERE gid = "..emailKey.." AND playerDBID = "..self.databaseID..";")
end

--ͳ������ʼ�����
function PlayerEmailCtrl:getMailCount()
	local num = 0
	for k, emailItem in pairs(self.emailList) do
		if emailItem.deleteFlag == 0 then
			num = num + 1
		end
	end
	return num
end

--�賿�������������ʼ�
function PlayerEmailCtrl:CreateEmailMidnight(emailKey, emailID)
	local emailCfg = SysEmail:readSysEmailCfg(emailID)  -- 101�����ʼ�
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
	obj.ranking = self.ArenaObject.arenaRank      -- ����
	
	self.emailList[obj.emailKey] = obj
	self:UpdateEmailInfo(obj)
	
	SysEmail:SendNewEmailIfno()  -- ֪ͨ�����ʼ�����

end

--�賿ϵͳ��ÿ���������һ�������ʼ�
function PlayerEmailCtrl:CreateRankingEmail()
	local emailKey = Au.getDatateID("tb_email")
	local emailID = EMAILTYPEMACRO.RANKING
	self:CreateEmailMidnight(emailKey, emailID)
end


--���꾺�����󴴽����������ʼ� Ԥ���ӿ�TODO
function PlayerEmailCtrl:CreateRankingEmail()
	local gid = Au.getDatateID("tb_email")
	
end

--��ȡ��������
function PlayerEmailCtrl:getEmailReward(emailKey, emailID)
	if isEmpty(self.emailList[emailKey]) then
		return
	end
	
	if self.emailList[emailKey].readFlag == 1 then  --���ʼ��Ѿ��Ķ���ȡ
		return
	end
	
	if emailID == EMAILTYPEMACRO.NOTICE then          --�����ʼ�
		return
	elseif emailID == EMAILTYPEMACRO.UPDATE then      --���²����ʼ�
		if isEmpty(SysEmailList[emailKey]) then
			return
		elseif SysEmailList[emailKey].emailIsReward == 0 then  -- 0-û�н�����1-�н���
			return
		else
			local item = SysEmailList[emailKey].emailRewardList
			local itemList = PlayerEmailCtrl:SplitRewardList(item)  --��ָ����б�
			self:createItemList(itemList)
		end
	elseif emailID == EMAILTYPEMACRO.RANKING then      --���������������ʼ�
		local ranking = self.ArenaObject.arenaRank     --��ȡ����
		local item = PlayerEmailCtrl:readRankingCfg(ranking)  
		self:createItemList(item)
	elseif emailID == EMAILTYPEMACRO.RANKINGTOP then   --������������������ʼ�
	--Ԥ���ӿ�TODO
		local ranking = getRanking()   --��ȡ����
		local item = PlayerEmailCtrl:readRankingTopCfg(ranking)  
		self:createItemList(item)
	else
		print("error!!")
		return
	end
end

--��ȡ�����ļ�
function PlayerEmailCtrl:readRankingCfg(ranking)
	local index = 0
	local TB = RANKING_REWARD["RANKING_INTERVAL"]
		if ranking <= 3 then         --ǰ3��
			index = ranking
		elseif ranking >= 501 then   --501��֮��
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

--�����������
function PlayerEmailCtrl:readRankingTopCfg(ranking)
	return SEVEN_TOP_REWARD[ranking]
end

--��ָ��������б�
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


--�ͻ���API
--�����ʼ��б�
function World_EmailSys_ReturnEmialList(playerID, bool)
	local playerObj = Player:getPlayerFromID(playerID)
	if isEmpty(playerObj) then
		return
	end
	
	playerObj:ReturnEmailList()
end

--�ʼ�����(�Ķ��� ɾ���� ��ȡ����)
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
		playerObj:getEmailReward(gid, emailID) --��ȡ��������
	end
	
	playerObj:ReadOrDeleletEmail(gid, emailID)
end

