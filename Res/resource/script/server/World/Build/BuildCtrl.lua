--BuildCtrl.lua
local buildBase =  require "resource.script.server.World.Build.BuildBase"
local buildFun = require "resource.script.server.World.Build.BuildFun"
local peopleManageFun = require "resource.script.server.World.PeopleManage.PeopleManageFun"

BuildCtrl = {}

function BuildCtrl:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.goldStartTime = nil	--����ʼʱ��
	return object
end

--��ȡ���ݿ�
function BuildCtrl:initBuildList(sqlResult, tableName)
	if isEmpty(sqlResult) == false then
		local row = sqlResult:GetRowCount()
		for i = 1, row do
			local _build = buildBase.BuildBase:New()
			_build.buildKey = sqlResult:GetFieldFromCount(0):GetUInt16()
			_build.buildID = sqlResult:GetFieldFromCount(1):GetUInt8()
			_build.Pos = {sqlResult:GetFieldFromCount(2):GetUInt16(),sqlResult:GetFieldFromCount(3):GetUInt16()}
			_build.startTime = sqlResult:GetFieldFromCount(4):GetUInt32()
			_build.updateTime = sqlResult:GetFieldFromCount(5):GetUInt32()
			_build.buildLevel = sqlResult:GetFieldFromCount(6):GetUInt8()
			self.buildList[_build.buildKey] = _build

			sqlResult:NextRow()
		end
		sqlResult:Delete()
	end
end

--���½���
function BuildCtrl:WriteBuildData()
	for buildKey, buildObj in pairs(self.buildList) do
		buildObj:updateBuildData(self.databaseID)
	end
end

--����Ĭ�ϵĽ���
function BuildCtrl:setDefaultBuild(  )
	-- body
	local buildTB = buildFun.BuildFun:readDeafultValue()["DEFAULTBUILD"]
	for __, buildID in pairs(buildTB) do
		local buildObj = buildBase.BuildBase:createBuild(self.databaseID, buildID, 0, 0, buildID )
		buildObj.buildLevel = 1
		self.buildList[buildObj.buildKey] = buildObj
	end
end

--��ȡ������Ϣ
function BuildCtrl:getBuildList()
	local leaveTime = 0
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_GET_BUILDLIST)
	for index,build in pairs(self.buildList) do
		Au.addUint16(index)
		Au.addUint8(build.buildID)
		Au.addUint16(build.Pos[1])
		Au.addUint16(build.Pos[2])
		if build.startTime ~= 0 then
			leaveTime = build:getLeaveTime(self)
		end
		Au.addUint16(leaveTime)
		Au.addUint8(build.buildLevel)
	end
	Au.messageEnd()
end

--��ȡͬ���ͽ�������
function BuildCtrl:getBuildNumSame(buildType)
	local num = 0
	for buildKey, build in pairs(self.buildList) do
		if (build.buildID == buildType) then
			num = num + 1
		end
	end
	return num
end

--���ݽ������ͻ�ȡ�Ƿ����
function BuildCtrl:checkBuildExists( buildType )
	-- body
	local isBool = false
	for __,build in pairs(self.buildList) do
		if (build.buildID == buildType) then
			isBool = true
			break
		end 
	end
	return isBool
end

--���콨��
function BuildCtrl:createBuild(buildType)
	local buildObj = buildBase.BuildBase:createBuild(self.databaseID, buildType, 0, 0, buildType )
	local LvUptime = 0
	self.buildList[buildObj.buildKey] = buildObj
	buildObj:LevelUp(LvUptime)
	buildFun.BuildFun:sendBuildToClient(self.playerID, buildObj.buildKey, buildObj.Pos[1], buildObj.Pos[2], buildObj.buildID, buildObj:getLeaveTime(self), buildObj.buildLevel)
end

--����������ɲ���
function BuildCtrl:onFinalBuildLevelUp(buildObj)
	
end

--�����˿ڲ���
function BuildCtrl:updateMingFangRK()
	local renKouNum = buildFun.BuildFun:readDeafultValue()["MINGFANG_RK"]
	self.playerRenKouTotal = self.playerRenKouTotal + renKouNum
	self.playerAllotRenKou = self.playerAllotRenKou + renKouNum
	self:defaultAllotWood()
	buildFun.BuildFun:send_update_renkou(self.playerID, self.playerRenKouTotal, self.playerAllotRenKou)
end

--��Ӷ�˿ڲ���
function BuildCtrl:hireRK()
	local nowHireTimes = (self.playerRenKouTotal/5) + 1
	local hireUse = buildFun.BuildFun:get_HireUse(nowHireTimes)
	if isEmpty(hireUse) then
		return
	end
	if self:checkOutAndTakeawaySource( hireUse ) == false then
		return
	end
	self:updateMingFangRK()
	TaskBase:completeHireRK( self )
end

--��ȡ���
function BuildCtrl:collectWood()
	local nowTime = Au.nowTime()
	local woodFarm = buildFun.BuildFun:readDeafultValue()
	if not isEmpty(self.goldStartTime) then
		local leaveTime = self.goldStartTime + woodFarm["CD"] - nowTime
		if leaveTime > 0 then
			buildFun.BuildFun:sendCollectWoodToClient(self.playerID, leaveTime)
			return
		end
	end
	local num = self:getTravelKitCapacity(4)
	self:getItem(ResourceType.COPPER, num)
	self.goldStartTime = nowTime
	buildFun.BuildFun:sendCollectWoodToClient(self.playerID, woodFarm["CD"])
	
	TaskBase:GetCountingTask(self, SEVER_TYPE_TRIGGER_NO.TYPE_LIANJIN)
	TaskBase:completeServerOpenSys(self, SEVER_TYPE_TRIGGER_NO.TYPE_LIANJIN)
end

--���߷�����ȡ���CD
function BuildCtrl:getCollectWoodOnLine()
	if isEmpty(self.goldStartTime) then
		buildFun.BuildFun:sendCollectWoodToClient(self.playerID, 0)
		return
	end
	local woodFarm = buildFun.BuildFun:readDeafultValue()
	local leaveTime = self.goldStartTime + woodFarm["CD"] - Au.nowTime()
	if leaveTime < 0 then
		leaveTime = 0
	end
	buildFun.BuildFun:sendCollectWoodToClient(self.playerID, leaveTime)
end

--API
function World_BuildCtrl_collectWood(playerID)
	local  _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:collectWood()
end

function World_BuildCtrl_hireRK(playerID)
	local  _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:hireRK()
end
