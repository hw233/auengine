--ExploreCtrl.lua
local exploreCfg = require "resource.script.server.World.Explore.ExploreCfg"
local exploreOBJ = require "resource.script.server.World.Explore.ExploreOBJ"
local exploreFun = require "resource.script.server.World.Explore.ExploreFun"
local rewardMgr  = require "resource.script.server.World.Reward.RewardMgr"
local table_concat = table.concat
local table_insert = table.insert
local table_getn = table.getn
local pairs = pairs

ExploreCtrl = {}

function ExploreCtrl:New()
	local object = setmetatable({}, self)
	self.__index = self
	object.fightLineupList = nil		--����
	object.exploreOBJ = exploreOBJ.ExploreOBJ:createExploreOBJ()
	return object
end

function ExploreCtrl:initExploreList(sqlResult,tableName)
	if isEmpty(sqlResult) then
		return
	end
	self.exploreOBJ.nowBigMap = sqlResult:GetFieldFromCount(0):GetUInt8()
	local bigMapTB = SplitStringToNumberTable(sqlResult:GetFieldFromCount(1):GetString(), ",")
	local ficthStateTB = SplitStringToNumberTable(sqlResult:GetFieldFromCount(2):GetString(), ",")
	self.exploreOBJ.bigMapIndex = sqlResult:GetFieldFromCount(3):GetUInt8()
	for i=1,#bigMapTB do
		local j = 2*i - 1
		self.exploreOBJ:setSecondStateFromDB(bigMapTB[i], ficthStateTB[j], ficthStateTB[j+1])
--		print("from db state:", bigMapTB[i], ficthStateTB[j], ficthStateTB[j+1])
	end
	sqlResult:Delete()
end

function ExploreCtrl:WriteExploreData()
	-- body
	local bigMapTB = {}
	local ficthStarTB = {}
	for bigMapID, _ficthStart in pairs(self.exploreOBJ.saveExploreState) do
		table_insert(bigMapTB, bigMapID)
		table_insert(ficthStarTB, _ficthStart.exploreState1)
		table_insert(ficthStarTB, _ficthStart.exploreState2)
	end
	
	local bigMapStr = ""
	if not isEmpty(bigMapTB) then
		bigMapStr = table_concat(bigMapTB, ",")
--		print("from db bigMapStr", bigMapStr)
	end
	local ficthStateStr = ""
	if not isEmpty(ficthStarTB) then
		ficthStateStr = table_concat(ficthStarTB, ",")
--		print("from db ficthStateStr", ficthStateStr)
	end
	
	Au.queryQueue("CALL update_tb_Explore("..self.databaseID..
		","..self.exploreOBJ.nowBigMap..
		",'"..bigMapStr..
		"','"..ficthStateStr..
		"',"..self.exploreOBJ.bigMapIndex..")"
		)
end

--�����������
function ExploreCtrl:saveFormation(heroTB)
	if isEmpty(heroTB) then
		return false
	end
	local pet = {}
	local isBool = false
	for i=1,#heroTB do
		local hero = self.heroList[heroTB[i]]
		if isEmpty(hero) then
			isBool = true
			break
		end
		table_insert(pet, heroTB[i])
	end
	if isBool then
		return false
	end
	self.fightLineupList = pet
	exploreFun.ExploreFun:send_formation_toClient( self.playerID, self.fightLineupList )
	return true
end

--��ʼ̽��
function ExploreCtrl:startExplore( bigMapID, heroNum, _repeat, ... )
	local preCfg = exploreCfg.ExploreCfg:getBigMapCfg(self.exploreOBJ.nowBigMap)["OPENTERM"]
	if self:checkPrecondition( preCfg ) == false then
		print("big map is not open")
		return
	end
	if heroNum <= 0 or _repeat <= 0 then
		print("heroNum is error")
		return
	end
	local itemTB = {}
	local heroTB = {}
	local itemNum = _repeat - heroNum
	for i=1,itemNum,2 do
		table_insert(itemTB, {arg[i],arg[i+1]})
	end
	for i=1,heroNum do
		local j = i + itemNum
		table_insert( heroTB, arg[j])
	end
	--�ж�Я����Ʒ����
	if self:CarryBagList(itemTB) == false then
		print("createBagListWithType is error")
		return
	end
	if self:saveFormation( heroTB ) == false then
		print(" heroTB is error")
		return
	end
	
	self:recoverExploreWater()
	self:set_playerStatus(PLAYERSTATUS.EXPLORE)
	self:sendStarExploreToClient()
	TaskBase:completeServerOpenSys(self, SEVER_TYPE_TRIGGER_NO.TYPE_BIGMAP, self.exploreOBJ.nowBigMap)
end

--�����������
function ExploreCtrl:startSecondSpace( second_space_id )
	local preCfg = exploreCfg.ExploreCfg:getSmallMapCfg(second_space_id)["PERM"]
	--���ĵ���
	if preCfg[1] ~= 0 and self:deductBagStandard(preCfg) == false then
		print("deductBagStandard is error")
		return
	end
	exploreFun.ExploreFun:send_enterSpace_toClient( self.playerID, second_space_id, MacroMsgID.MSG_ID_EXPLORE_ENTERSPACE )
end

--ս������
function ExploreCtrl:fightingEnd(winState, fightType, npcID)
	if fightType == exploreCfg.ExploreCfg.NORMAILFIGHTTYP then--ʤ��(��ͨ)
		if winState == 1 then
			self:CombatWinNPC(npcID)
			TaskBase:GetCountingTask(self, SEVER_TYPE_TRIGGER_NO.TYPE_KILLKW)
		else
		--	self:CombatFailNPC()
			self:comeBackCity(exploreCfg.ExploreCfg.DEATHCOMEBACK)
		end
	elseif fightType == exploreCfg.ExploreCfg.DARKRAYLFIGHTTYP then
		if winState == 1 then
			self:darkRayCombatWinNPC(npcID)
			TaskBase:GetCountingTask(self, SEVER_TYPE_TRIGGER_NO.TYPE_KILLKW)
		else
		--	self:darkRayCombatFailNPC()
			self:comeBackCity(exploreCfg.ExploreCfg.DEATHCOMEBACK)
		end
	end
end

--ս��ʤ��
function ExploreCtrl:CombatWinNPC(npcID)
	local floorsCfg = exploreCfg.ExploreCfg:getMapEventCfg(npcID)
	local isPassID = floorsCfg["FINAL"]
	local rewardCfg = floorsCfg["DROPREWARD"]
	self.exploreOBJ.dropItemTB = self:sendReward(rewardCfg)
	local second_space_id = NumberToInt(npcID/100)
	local nextBigMap = 0
	if isPassID == 1 then--����ͨ��
		nextBigMap = exploreCfg.ExploreCfg:getSmallMapCfg(second_space_id)["OPENSTATE"] --�¼��󸱱�ID
		self.exploreOBJ:passSecondary(npcID, nextBigMap)
		TaskBase:completePassSpace(self, second_space_id)
	end
	exploreFun.ExploreFun:send_passSpace_toClient(self.playerID, second_space_id, isPassID, self.exploreOBJ.bigMapIndex)
	exploreFun.ExploreFun:send_supplyPoint_toClient(self.playerID, exploreCfg.ExploreCfg.NORMAILFIGHTTYP, npcID, self.exploreOBJ.dropItemTB)
end

--ս��ʤ��(����)
function ExploreCtrl:darkRayCombatWinNPC(nowDarkRayID)
	local _darkRayCfg = exploreCfg.ExploreCfg:getCloudMineCfg(nowDarkRayID)
	self.exploreOBJ.dropItemTB = self:sendReward(_darkRayCfg["DROPREWARD"])
	exploreFun.ExploreFun:send_supplyPoint_toClient(self.playerID, exploreCfg.ExploreCfg.DARKRAYLFIGHTTYP, nowDarkRayID, self.exploreOBJ.dropItemTB)
end

--ͬ��λ��
function ExploreCtrl:syncPosition(water, rice)
	self.exploreOBJ:takeOutExploreWater(water)
	self:deductBagItem(ResourceType.BREAD, rice)
	exploreFun.ExploreFun:send_syncPos_toClient(self.playerID, self.exploreOBJ.playerExploreWater)
	print("ͬ��λ��:", self.exploreOBJ.playerExploreWater)
end

--ˮ�ָ�
function ExploreCtrl:recoverExploreWater()
	local nowLimitWater = self:getTravelKitCapacity(2)--���ˮ��
	self.exploreOBJ:supplyExploreWater(nowLimitWater)
--	print("ˮ�ָ�:", nowLimitWater)
end

--ͨ�ط��ͽ�������(����ֱ�Ӹ�����Ʒ���Ϊ)
function ExploreCtrl:sendReward( awardCfg )
	-- body
	local dropLib = awardCfg["DROPLIB"]--�����
	local taskItem = awardCfg["TASKITEM"] --�������
	local dropTB = {}
	if not isEmpty(dropLib) and dropLib ~= 0 then
		dropTB = rewardMgr.RewardMgr:getRewardFromLib( dropLib )
	end
	if taskItem[1] ~= 0 then
		self:getBagItem(taskItem[2],taskItem[3])
	end
	return dropTB
end

--�سǲ���
function ExploreCtrl:comeBackCity(isBool, rice)
	if isBool == exploreCfg.ExploreCfg.DEATHCOMEBACK then--�����س�
		self:DeadRemoveAllBagItem()
	elseif isBool == exploreCfg.ExploreCfg.NORMALCOMEBACK then--����
		self:deductBagItem(ResourceType.BREAD, rice)
		self:RemoveAllBagItem()
	else
		
	end
	self:set_playerStatus(PLAYERSTATUS.INNERCITY)
	self.exploreOBJ:reset_supplyPoint()
	exploreFun.ExploreFun:send_comeBackCity_toClient( self.playerID, isBool )
	TaskBase:completeServerOpenSys(self, SEVER_TYPE_TRIGGER_NO.TYPE_BACKCITY)
end

--�����㲹������
function ExploreCtrl:supplyPointFeed(second_space_id)
	local bigMapID = NumberToInt(second_space_id/100)
	local stateIndex = second_space_id%100
	local bigMapCfg = exploreCfg.ExploreCfg:getBigMapCfg(bigMapID)["CANUP"]
	if table_has_Key(bigMapCfg, second_space_id) == true then
		return
	end
	if self.exploreOBJ:checkExploreSupply(bigMapID, stateIndex) == false then
		print("����������������")
		return
	end
	local dropTB = {}
	local supplyPointID = exploreCfg.ExploreCfg:getSmallMapCfg(second_space_id)["SUPPLYPOINT"]
	local boxCfg = exploreCfg.ExploreCfg:getSourcePointCfg( supplyPointID )
	table_insert(dropTB, {1, boxCfg["SOURCEID"], AuRandom(boxCfg["LIMIT"][1],boxCfg["LIMIT"][2])})
	self.exploreOBJ.dropItemTB = dropTB
	self:recoverExploreWater()
	exploreFun.ExploreFun:send_enterSpace_toClient( self.playerID, second_space_id, MacroMsgID.MSG_ID_EXPLORE_POINTUP )
	exploreFun.ExploreFun:send_supplyPoint_toClient(self.playerID, 2, 0, self.exploreOBJ.dropItemTB )
end

--ʰȡ����
function ExploreCtrl:playerPickUpItem(_repeat, ...)
	local itemTB = {}
	local itemID = 0
	local itemNum = 0
	for i=1,_repeat*3,3 do
		itemID = arg[i]
		itemNum = arg[i+1]
		if arg[i+2] == 1 then
			self:getBagItem(itemID, itemNum)
		else
			self:deductBagItem(itemID, itemNum)
		end
	end
	self.exploreOBJ.dropItemTB = nil
	exploreFun.ExploreFun:send_pickItem_toClient(self.playerID)
end

--��⸱����ͨ�����
function ExploreCtrl:checkBigMapPass( second_space_id )
	if isEmpty(self.exploreOBJ) then
		return false
	end
	local bigMapID = NumberToInt(second_space_id/100)
	local stateIndex = second_space_id%100
	if isEmpty(self.exploreOBJ.saveExploreState[bigMapID]) then
		return false
	end
	if self.exploreOBJ.saveExploreState[bigMapID]:checkExploreState( stateIndex ) == false then
		return false
	end
	return true
end

--������
function ExploreCtrl:enterGateway( bigMapID )
	if bigMapID <= 0 or bigMapID > self.exploreOBJ.bigMapIndex then
		return
	end
	self.exploreOBJ:updateBigMap(bigMapID)
	self:sendStarExploreToClient()
end

function ExploreCtrl:sendStarExploreToClient()
	local state1,state2,point,point1 = self.exploreOBJ:getSecondFromBigMap(self.exploreOBJ.nowBigMap)
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_EXPLORE_STARTEXPLORE)
	Au.addUint8(self.exploreOBJ.nowBigMap)
	Au.addUint32(state1)
	Au.addUint32(state2)
	Au.addUint32(point)
	Au.addUint32(point1)
	Au.addUint8(self.exploreOBJ.playerExploreWater)
	Au.messageEnd()
	print("start Explore:", self.exploreOBJ.nowBigMap, state1, state2, point, point1, self.exploreOBJ.playerExploreWater)
end

--����̽����Ϣto client
function ExploreCtrl:getExploreOnline()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_EXPLORE_ONLINEEXPLORE)
	Au.addUint8(self.exploreOBJ.nowBigMap)
	Au.addUint8(self.exploreOBJ.bigMapIndex)
	Au.messageEnd()
	print("����̽����Ϣ:", self.exploreOBJ.nowBigMap, self.exploreOBJ.bigMapIndex)
end

--API
function World_ExploreCtrl_startExplore( playerID, bigMapID, heroNum, _repeat, ... )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:startExplore(bigMapID, heroNum, _repeat, ...)
end

function World_ExploreCtrl_startSecondSpace(playerID, second_space_id)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:startSecondSpace(second_space_id)
end

function World_ExploreCtrl_fightingEnd( playerID, winState, fightType, npcID )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:fightingEnd(winState, fightType, npcID)
end

function World_ExploreCtrl_syncPosition(playerID, water, rice)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:syncPosition( water, rice)
end

function World_ExploreCtrl_comeBackCity(playerID, isBool, rice)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:comeBackCity(isBool, rice)
end

function World_ExploreCtrl_supplyPointFeed(playerID, second_space_id)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:supplyPointFeed(second_space_id)
end

function World_ExploreCtrl_playerPickUpItem(playerID, _repeat, ...)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:playerPickUpItem(_repeat, ...)
end

function World_ExploreCtrl_enterGateway(playerID, bigMapID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:enterGateway( bigMapID )
end