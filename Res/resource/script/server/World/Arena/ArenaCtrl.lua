--ArenaCtrl.lua
require "resource.script.server.Base.LinkList"
local arena = require "resource.script.server.World.Arena.Arena"


ArenaCtrl = {}

ArenaQueue = {}
ArenaQueue.LinkList = LinkList:Create()
ArenaQueue.rankNum = 100			--Ŀǰ��Ϸ���ѵ����������������

--��ʼ��������  ��ʱ����100���
function ArenaQueue:initArenaQueue()
	if not isEmpty(Players_DBID) then
		return
	end
	for i=1, 100 do
		local _player = Player:create("Robot_"..i, "Robot_Name_"..i, AuRandom(0,1))
		_player.ArenaObject.arenaRank = i
		ArenaQueue:InsertPlayer(_player)
		Au.queryQueue("CALL update_tb_Arena(".._player.databaseID..",".._player.ArenaObject.arenaRank..");")
	end
	SaveDB:SaveAllPlayerData()
end

--���ؾ���������
function ArenaQueue:getNewPlayerRank()
	self.rankNum = self.rankNum + 1
	return self.rankNum
end

--���������
function ArenaQueue:InsertPlayer(_player)
	_player.ArenaNode = self.LinkList:getNewNode()
	_player.ArenaNode.data = _player
	
	local tnode = self.LinkList.endNode.front
	
	if tnode:noData() then
		self.LinkList:push(_player.ArenaNode)
		return
	end
	
	local tPlayer = tnode.data
	
	while _player.ArenaObject.arenaRank < tPlayer.ArenaObject.arenaRank do
		tnode = tnode.front
		if tnode:noData() then
			self.LinkList:pushFront(_player.ArenaNode)
			return
		end
		tPlayer = tnode.data
	end
	
	if tPlayer.databaseID == 0 then --������
		self.LinkList:replaceNode(tnode,_player.ArenaNode)
	else
		self.LinkList:insertBackToNode(tnode,_player.ArenaNode)
	end
end

--���ҵ�ǰ����ھ���������������
function ArenaQueue:getNodePlayerList(node)
	local frontTB  = {}
	local returnTB = {}
	local nowRank = node.data.ArenaObject.arenaRank
	local tnode = node.front
	if nowRank >= 1 and nowRank <= 10 then
		if nowRank == 1 then
			tnode = tnode.back
		end
		for i=1,10 do
			if tnode:noData() then
				break
			end
			if nowRank ~= i then
				table.insert(frontTB,tnode.data)
			end
			if nowRank <= 3 then
				tnode = tnode.back
			else
				tnode = tnode.front
			end
		end
		print("--------------start-----------",nowRank, node.data.playerName)
		for i=1,3 do
			table.insert(returnTB,table.remove(frontTB,AuRandom(1,table.getn(frontTB))))
			print(returnTB[i].ArenaObject.arenaRank, returnTB[i].playerName)
		end
		print("---------------end-------------")
	else
		local lenth = 3
		local PiPeiExtentTB = arena.Arena:getPiPeiExtent(nowRank)
		local first = AuRandom(PiPeiExtentTB[1][1], PiPeiExtentTB[1][2])
		local second = AuRandom(PiPeiExtentTB[2][1], PiPeiExtentTB[2][2])
		local third = AuRandom(PiPeiExtentTB[3][1], PiPeiExtentTB[3][2])
		while true do
			if tnode:noData() then
				break
			end
			local nowNodeRank = tnode.data.ArenaObject.arenaRank
			if nowNodeRank == first or nowNodeRank == second or nowNodeRank == third then
				table.insert(returnTB, tnode.data)
			end
			if table.getn(returnTB) >= 3 then
				break
			end
			tnode = tnode.front
		end
	end
	return returnTB
end

--������Ϸ������ǰ��ʮ��
function ArenaQueue:getTopTenPlayer()
	local tb = {}
	local tnode = self.LinkList.firstNode.back
	if tnode:noData() then
		return tb
	end
	for i=1,20 do
		if tnode:noData() then
			break
		end
		table.insert(tb,tnode.data)
		tnode = tnode.back
	end
	return tb
end

function ArenaCtrl:New()
	local object = setmetatable({}, self)
	self.__index = self
	object.ArenaObject = arena.Arena:New()	--����������
	object.ArenaPlayerList = {}			--��ǰƥ��ľ��������
	object.ArenaNode = nil				--����Լ��Ľڵ�
	self.attackArenaTime = 5			--��ս����
	self.buyAttackArenaTime = 2			--������ս����
	return object
end

--��ȡ��Ҿ����б�
function ArenaCtrl:getArenaPlayerList()
	if self.ArenaObject.arenaRank == 0 then
		return
	end
	self.ArenaPlayerList = ArenaQueue:getNodePlayerList(self.ArenaNode)
	self:sendArenaPlistToClient()
	self:sendArenaDataToClient()
end

function ArenaCtrl:sendArenaPlistToClient()
	local _player = nil
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ARENA_GET_LIST)
	Au.addUint8(table.getn(self.ArenaPlayerList))
	for i=1,table.getn(self.ArenaPlayerList) do
		_player = self.ArenaPlayerList[i]
		Au.addString(_player.roleNameUtf8)
--		Au.addUint8(_player.leadObject.heroLevel)
--		Au.addUint16(_player:getCountFightPower())
		Au.addUint8(1)
		Au.addUint16(0)
		Au.addUint16(_player.ArenaObject.arenaRank)
	end
	Au.messageEnd()	
end

function ArenaCtrl:sendArenaDataToClient()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ARENA_GET_DATE)
	Au.addUint16(self.ArenaObject:getLeaveTime())
	Au.addUint8(self.ArenaObject.arenaOk)
	Au.addUint16(self.ArenaObject.arenaRank)
	Au.addUint8(self.attackArenaTime)
	Au.addUint8(self.buyAttackArenaTime)
	Au.messageEnd()
end

--ÿ����ȡ��������
function ArenaCtrl:onDayUpdateArenaAward()
	self.attackArenaTime = arena.LOCALMACRO.MIANFEITIME
	self.buyAttackArenaTime = arena.LOCALMACRO.BUYATTACKTIME
end

--��ս���������
function ArenaCtrl:fightArenaPlayer(index)
	if self.ArenaObject.arenaOk == 0 then
		return
	end
	local _player = self.ArenaPlayerList[index]
	if isEmpty(_player) then
		return
	end
	if self.attackArenaTime <= 0 then
		print("��ս��������")
		return
	end
	--ս��
	local _fightData = AuRandom(0, 1)
	self.ArenaObject:onSetArenaTime()
	self.attackArenaTime = self.attackArenaTime - 1
	
	if _fightData == 0 then--ʤ��
		sendSystemMsg(self.playerID, "��սʤ��")
		if self.ArenaObject.arenaRank <= _player.ArenaObject.arenaRank then
			self.ArenaPlayerList = ArenaQueue:getNodePlayerList(self.ArenaNode)
			self:sendArenaPlistToClient()
			self:sendArenaDataToClient()
		else
			ArenaQueue.LinkList:exChange(self.ArenaNode,_player.ArenaNode) --�����ڵ�
			arena.Arena:exchangeRank(self.ArenaObject,_player.ArenaObject)	--��������
			self.ArenaPlayerList = ArenaQueue:getNodePlayerList(self.ArenaNode)
			self:sendArenaPlistToClient()
			self:sendArenaDataToClient()
		end
	else
		sendSystemMsg(self.playerID, "��սʧ��")
		self:sendArenaDataToClient()
	end
end

--����������
function ArenaCtrl:playOnArenaSystem(boolDB)
	if self.ArenaObject.arenaRank ~= 0 then
		return
	end
	self.ArenaObject:initArena(self.databaseID)
	self.ArenaObject.arenaRank = ArenaQueue:getNewPlayerRank()
	ArenaQueue:InsertPlayer(self)
	Au.queryQueue("CALL update_tb_Arena("..self.databaseID..","..self.ArenaObject.arenaRank..");")
	if boolDB == true then
		self.ArenaPlayerList = ArenaQueue:getNodePlayerList(self.ArenaNode)
	end
end

function ArenaCtrl:OnReadArenaDataFromDB(sqlResult,tableName)
	if isEmpty(sqlResult) then
		return
	end
	self.ArenaObject:initArena(self.databaseID)
	self.ArenaObject.arenaRank = sqlResult:GetFieldFromCount(0):GetUInt16()
	ArenaQueue:InsertPlayer(self)
	if self.ArenaObject.arenaRank > ArenaQueue.rankNum then
		ArenaQueue.rankNum = self.ArenaObject.arenaRank
	end
	sqlResult:Delete()
end

--���CDʱ��
function ArenaCtrl:CancelArenaTimeCD()
	if self:subPlayerDiamond(arena.LOCALMACRO.CLEARCD) == false then
		return
	end
	self.ArenaObject:cancelCD()
	self:sendArenaDataToClient()
end

--ˢ�¾�����
function ArenaCtrl:refreshArenaData()
	self.ArenaPlayerList = ArenaQueue:getNodePlayerList(self.ArenaNode)
	self:sendArenaPlistToClient()
end

--������ǰ20���������
function ArenaCtrl:getBeforeTwoTen()
	local tb = ArenaQueue:getTopTenPlayer()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ARENA_GET_QUEUE)
	Au.addUint16(self.ArenaObject.arenaRank)
	for i=1,table.getn(tb) do
		Au.addUint16(tb[i].ArenaObject.arenaRank)
		Au.addString(tb[i].roleNameUtf8)
--		Au.addUint8(tb[i].leadObject.heroLevel)
--		Au.addUint16(tb[i]:getCountFightPower())
		Au.addUint8(1)
		Au.addUint16(0)
	end
	Au.messageEnd()	
end

function ArenaCtrl:buyAttackArenaTimeFun()
	if self.buyAttackArenaTime <= 0 then
		return
	end
	if self:subPlayerDiamond(arena.LOCALMACRO.BUYUSE) == false then
		print("��ʯ����")
		return
	end
	self.attackArenaTime = self.attackArenaTime + 5
	self.buyAttackArenaTime = self.buyAttackArenaTime - 1
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_ARENA_BUY_TIME)
	Au.addUint8(self.attackArenaTime)
	Au.addUint8(self.buyAttackArenaTime)
	Au.messageEnd()
end

--��ȡ����������
function World_ArenaCtrl_getArenaPlayerList(playerID,state)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	if state == 4 then --ˢ�¾�����
		_player:refreshArenaData()
	elseif state == 2 then	--��鵹��ʱ�Ƿ�����
		_player:sendArenaDataToClient()
	elseif state == 3 then
		_player:CancelArenaTimeCD()
	elseif state == 1 then
		_player:getArenaPlayerList()
	end
end

function World_ArenaCtrl_fightArenaPlayer( playerID, index )
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:fightArenaPlayer(index)
end

function World_ArenaCtrl_getListData( playerID, index )
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	if index == 1 then--���������а�����
		_player:getBeforeTwoTen()
	elseif index == 2 then
		
	end
end

function World_ArenaCtrl_buyAttackArenaTimeFun(playerID, index)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end	
	_player:buyAttackArenaTimeFun()
end