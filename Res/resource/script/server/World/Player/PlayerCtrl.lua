--PlayerCtrl.lua
local PlayerMacro = require "resource.script.server.World.Player.PlayerMacro"
local exploreFun = require "resource.script.server.World.Explore.ExploreFun"
local pairs = pairs

PlayerCtrl = {}

function PlayerCtrl:New()
	local object = setmetatable(self, {})
	self.__index = self
	return object
end

--���߻�ȡ��Դ����
function PlayerCtrl:getAllPlayerInfo(state)
	if state == 0 then--ȫ����
		self:send_HeroBase_Info()
		self:send_BuildBase_Info()
		self:send_TaskBase_Info()
		self:send_ItemBase_Info()
		self:send_SevenRewardBase_Info()
		self:send_ForgeBase_Info()
		self:send_ExploreBase_Info()
		self:send_ShopBase_Info()
	elseif state == 1 then--ð��������
		self:send_HeroBase_Info()
	elseif state == 2 then--��������
		self:send_BuildBase_Info()
	elseif state == 3 then--����ɾ�����
		self:send_TaskBase_Info()
	elseif state == 4 then--��Ʒ����
		self:send_ItemBase_Info()
	elseif state == 5 then--���ս�������
		self:send_SevenRewardBase_Info()
	elseif state == 6 then--̽������
		self:send_ExploreBase_Info()
		self:send_ForgeBase_Info()
	elseif state == 7 then--�̳�����
		self:send_ShopBase_Info()
	end
	self:send_PlayerBase_Info()
end

--��һ�����Ϣ
function PlayerCtrl:send_PlayerBase_Info()
	local _betW = self.roleLastOnlineTime - self.roleOfflineTime
	if _betW <= 0 then
		_betW = 0
	end
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ON_GET_PLAYER_INFO)
	Au.addString(self.playerName)
	Au.addUint8(self.playerSex)
	Au.addUint32(self.playerDiamond)
	Au.addUint32(self.playerCopper)
	Au.addUint16(self.playerRenKouTotal)
	Au.addUint32(self.playerSystemState)	--���ܿ���
	Au.addUint8(self.playerStatus)			--״̬(0-����״̬��1-̽��״̬)
	Au.addUint32(_betW)						--�����߼��ʱ��
	Au.messageEnd()
end

--ð���߻�����Ϣ
function PlayerCtrl:send_HeroBase_Info()
	self:getHeroList()	--�����б�
	exploreFun.ExploreFun:send_formation_toClient( self.playerID, self.fightLineupList )
end

--����������Ϣ
function PlayerCtrl:send_BuildBase_Info()
	self:getBuildList()	--������Ϣ
	self:getCollectWoodOnLine()	--���߷�����ȡľ��CD
end

--���������Ϣ
function PlayerCtrl:send_TaskBase_Info()
	self:getTaskList()	--�����б�
end

--��Ʒ������Ϣ
function PlayerCtrl:send_ItemBase_Info()
	self:sendItemList()  --��Ʒ�б�
end

--���콱��������Ϣ
function PlayerCtrl:send_SevenRewardBase_Info()
	self:SendRewardTimesAndStatus()--7����ȡ������״̬
	self:requestOutPutData(true)--����˲Ź���
end

--̽�ջ�����Ϣ
function PlayerCtrl:send_ExploreBase_Info()
	self:getExploreOnline()	--̽������
	self:sendTalentToClient()--�츳��Ϣ
end

--�̳ǻ�����Ϣ
function PlayerCtrl:send_ShopBase_Info()
	self:sendBuyStatu()     --һ������Ʒ״̬λ
end

--���������Ϣ
function PlayerCtrl:send_ForgeBase_Info()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ITEM_FORGE_INFO)
	Au.addUint16(self.Backpack)       --���б���
	Au.addUint16(self.WaterBag)       --ˮ��
	Au.addUint16(self.Carriage)       --��
	Au.addUint16(self.Alchemy)        --����
	Au.addUint16(self.Bread)          --���
	Au.messageEnd()
end

function PlayerCtrl:set_playerDiamond(value)
	if self.playerDiamond == value then
		return
	end
	self.playerDiamond = value
	self:sendPropToClient( PLAYER_PROP_TYPE.PLAYERDIAMOND, self.playerDiamond, ENTITY_PROP_TYPE_UINT32)
end

function PlayerCtrl:set_playerCopper(value)
	if self.playerCopper == value then
		return
	end
	self.playerCopper = value
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERCOPPER, self.playerCopper, ENTITY_PROP_TYPE_UINT32)
end

function PlayerCtrl:set_playerRenKouTotal( value )
	-- body
	if self.playerRenKouTotal == value then
		return
	end
	self.playerRenKouTotal = value
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERRENKOUTOTAL, self.playerRenKouTotal, ENTITY_PROP_TYPE_UINT16)
end

function PlayerCtrl:set_playerTalentPoint( value )
	-- body
	if value <= 0 then
		value = 0
	end
	if self.achievementPoint == value then
		return
	end
	self.achievementPoint = value
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERTALENTPOINT, self.achievementPoint, ENTITY_PROP_TYPE_UINT8)
end

function PlayerCtrl:subPlayerCopper(value)
	if self.playerCopper < value then
		sendSystemMsg(self.playerID,"��Ҳ���")
		return false
	end
	self:set_playerCopper(self.playerCopper - value)
	return true
end

function PlayerCtrl:subPlayerDiamond(value)
	if self.playerDiamond < value then
		sendSystemMsg(self.playerID,"��ʯ����")
		return false
	end
	self:set_playerDiamond(self.playerDiamond - value)
	return true
end

function PlayerCtrl:initPlayerProp(sqlResult,tableName)
	if tableName == "tb_PlayerProp" and isEmpty(sqlResult) == false then
		self.playerLevel = sqlResult:GetFieldFromCount(1):GetUInt8()
		self.playerDiamond = sqlResult:GetFieldFromCount(2):GetUInt32()
		self.playerCopper = sqlResult:GetFieldFromCount(3):GetUInt32()
		self.playerRenKouTotal = sqlResult:GetFieldFromCount(4):GetUInt16()
		self.rewardTimes = sqlResult:GetFieldFromCount(5):GetUInt8()
		self.rewardFlag = sqlResult:GetFieldFromCount(6):GetUInt8()
		self.bFreeTimes = sqlResult:GetFieldFromCount(7):GetUInt8()
		self.sFreeTimes = sqlResult:GetFieldFromCount(8):GetUInt8()
		self.sTotalTimes = sqlResult:GetFieldFromCount(9):GetUInt32()
		self.buyStatu = sqlResult:GetFieldFromCount(10):GetUInt32()
		self.playerSystemState = sqlResult:GetFieldFromCount(11):GetUInt32()
		self.Backpack = sqlResult:GetFieldFromCount(12):GetUInt16()
		self.WaterBag = sqlResult:GetFieldFromCount(13):GetUInt16()
		self.Carriage = sqlResult:GetFieldFromCount(14):GetUInt16()
		self.Alchemy = sqlResult:GetFieldFromCount(15):GetUInt16()
		self.Bread = sqlResult:GetFieldFromCount(16):GetUInt16()
		self.talentState = sqlResult:GetFieldFromCount(17):GetUInt32()
		self.achievementPoint = sqlResult:GetFieldFromCount(18):GetUInt16()
	end
end

function PlayerCtrl:WritePlayerData()
	Au.queryQueue("CALL update_tb_PlayerProp("..self.databaseID..","
					..self.playerLevel..","
					..self.playerDiamond..","
					..self.playerCopper..","
					..self.playerRenKouTotal..","
					..self.rewardTimes..","
					..self.rewardFlag..","
					..self.bFreeTimes..","
					..self.sFreeTimes..","
					..self.sTotalTimes..","
					..self.buyStatu..","
					..self.playerSystemState..","
					..self.Backpack..","
					..self.WaterBag..","
					..self.Carriage..","
					..self.Alchemy..","
					..self.Bread..","
					..self.talentState..","
					..self.achievementPoint..
				  ");")
end

--��ȡ��ս��
function PlayerCtrl:getCountFightPower()
	local countFightPower = 0
	if isEmpty(self.fightLineupList) then
		return countFightPower
	end
	for i = 1, #self.fightLineupList do
		local heroDBID = self.fightLineupList[i]
		if heroDBID ~= 0 then
			countFightPower = countFightPower + self.heroList[heroDBID].fightPower
		end
	end
	return countFightPower
end

--����ĳһ���¹���,��ϵͳ
function PlayerCtrl:set_playerSystemState(systemState)
	if Au.bitCheckState(self.playerSystemState, systemState) == 1 then
		return false
	end
	self.playerSystemState = Au.bitAddState(self.playerSystemState,systemState)
	self:sendPropToClient(PLAYER_PROP_TYPE.PLAYERSYSTEMSTATE,self.playerSystemState,ENTITY_PROP_TYPE_UINT32)
	return true
end

--���Ž���
function PlayerCtrl:openSystemState(systemState, buildTB)
	if self:set_playerSystemState( systemState ) == false then
		return
	end
	for __, _buildID in pairs( buildTB ) do
		if _buildID ~= 0 then
			local buildType = _buildID%100
			self:createBuild(buildType)
		end
	end
end

--���ܿ��ż��
function PlayerCtrl:CheckFunctionID(functionID)
	local processID = PlayerMacro.PlayerMacro:readFunctionCfg(functionID)
	if isEmpty(processID) then
		return false
	end
	
	if Au.bitCheckState(self.playerSystemState, processID) ~= 1 then
		return false
	end
	
	return true
end

--��������ģ��
function PlayerCtrl:set_playerStatus( value )
	self.playerStatus = value
end

--��ҵ�һЩ�����ӿڶ���Begin

--�ж���Դ�Ƿ���� ��������Դ�����ӿ�
--function:checkOutAndTakeawaySource
--arg useCfg ��Դ��������
--return false true
function PlayerCtrl:checkOutAndTakeawaySource( useCfg )
	if isEmpty(useCfg) then
		return false
	end
	local pairs = pairs
	for __, scTB in pairs(useCfg) do
		--��Դ�Ƿ����
		if scTB[1] == KindType.Item and self:IsItemEqualToValue(scTB[2], scTB[3]) == false then
			return false
		end
	end
	for __, scTB in pairs(useCfg) do
		if scTB[1] ~= 0 then
			self:deductItem(scTB[2], scTB[3])
		end
	end
	return true
end

--ǰ���������ж�
--function:checkPrecondition
--arg preCfg
--return false true
function PlayerCtrl:checkPrecondition( preCfg )
	if isEmpty( preCfg ) then
		return false
	end
	if preCfg[1] == 0 then
		return true
	end
	if preCfg[1] == PlayerMacro.PlayerMacro.PLAYERLEVEL and (self.playerLevel < preCfg[2]) then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.TASKID and self:getZhuXiangTask() < preCfg[2] then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.BUILD and self:checkBuildExists(preCfg[2]) == false  then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.SPACE and self:checkBigMapPass( preCfg[2] ) == false then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.GETITEM and self:IsItemEqualToValue(preCfg[2], preCfg[3]) == false then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.BIGMAP and self.exploreOBJ.bigMapIndex <= preCfg[2] then
		return false
	elseif preCfg[1] == PlayerMacro.PlayerMacro.OPENSYS and Au.bitCheckState(self.playerSystemState, preCfg[2]) == 0 then
		return false
	else
	
	end
	return true
end

--��ҵ�һЩ�����ӿڶ���End

function World_PlayerCtrl_getAllPlayerInfo( playerID, state )
	local _player = Player:getPlayerFromID( playerID )
	if isEmpty(_player) then
		return
	end
	_player:getAllPlayerInfo( state )

end