--PeopleManageCtrl.lua
local peopleManage = require "resource.script.server.World.PeopleManage.PeopleManage"
local peopleManageFun = require "resource.script.server.World.PeopleManage.PeopleManageFun"
local buildFun = require "resource.script.server.World.Build.BuildFun"

PeopleManageCtrl = {}

function PeopleManageCtrl:New()
	-- body
	local object = setmetatable({}, self)
	self.__index = self
	self.startAllotTime = 0		--开始分配时间
	self.getAllotDataTime = 0--请求数据时间
	object.allotList = {}		--分配列表
	object.priorityLV = {0,0,0,0,0,0,0,0,0}--优先级
	return object
end

--from db to allotData
function PeopleManageCtrl:InitAllotData(sqlResult, tableName)
	local canAllotNum = 0
	if isEmpty(sqlResult) == false then
		local row = sqlResult:GetRowCount()
		for i = 1, row do
			local pMange = peopleManage.PeopleManage:New()
			pMange.allotType = sqlResult:GetFieldFromCount(0):GetUInt32()
			pMange.allotRenKouNum = sqlResult:GetFieldFromCount(1):GetUInt8()
			self.allotList[pMange.allotType] = pMange
			local preCfg = buildFun.BuildFun:get_ProUsePre(pMange.allotType)
			self.priorityLV[preCfg["PRIORITY"]] = pMange.allotType

			if pMange.allotType == ResourceType.WOOD then
				canAllotNum = pMange.allotRenKouNum
			end
			sqlResult:NextRow()
		end
		sqlResult:Delete()
	else
		canAllotNum = self.playerRenKouTotal
	end
	self.playerAllotRenKou = canAllotNum
	self.startAllotTime = self.startAllotTime > 0 and self.startAllotTime or Au.nowTime()
--	print("InitAllotData:", self.playerAllotRenKou, self.playerRenKouTotal, canAllotNum)
end

function PeopleManageCtrl:WritePeopleManageData()
	if isEmpty(self.allotList) then
		return
	end
	for __, pMange in pairs(self.allotList) do
		pMange:WritePeopleManage(self.databaseID)
	end
end

--分配人口函数
function PeopleManageCtrl:allotRenkouFun(renKouNum, allotType, priority)
	local pMange = self.allotList[allotType]
	if isEmpty(pMange) then
		pMange = peopleManage.PeopleManage:New()
		self.allotList[allotType] = pMange
		self.priorityLV[priority] = allotType
	end
	if allotType ~= ResourceType.WOOD then
		self.playerAllotRenKou = self.playerAllotRenKou - renKouNum
		local _pMange = self.allotList[ResourceType.WOOD]
		if not isEmpty(_pMange) then
			_pMange:set_RenKouNumNull()
			_pMange:allotRenkou(self.playerAllotRenKou, ResourceType.WOOD)
		end
	else
		pMange:set_RenKouNumNull()
	end
	pMange:allotRenkou(renKouNum, allotType)
	print("分配人口成功:类型:"..allotType.."人口:"..renKouNum.."当前人口:"..pMange.allotRenKouNum)
	return pMange.allotRenKouNum
end

--人口分配操作(人口增量)
function PeopleManageCtrl:allotRenkou(renKouNum, allotType)
	if renKouNum <= 0 or self.playerAllotRenKou < renKouNum then
		print("PeopleManageCtrl:allotRenkou():playerAllotRenKou")
		return
	end
	local preCfg = buildFun.BuildFun:get_ProUsePre(allotType)
	if self:checkPrecondition(preCfg["PRE"]) == false then
		print("PeopleManageCtrl:allotRenkou():PRE NOT")
		return
	end
	self.startAllotTime = self.startAllotTime > 0 and self.startAllotTime or Au.nowTime()

	local nowAllotRK = self:allotRenkouFun(renKouNum, allotType, preCfg["PRIORITY"])
	peopleManageFun.PeopleManageFun.sendAllotRenKouToClient( self.playerID, allotType, nowAllotRK, self.playerAllotRenKou )
	
	TaskBase:completeAllotPeople(self, allotType)
end

--取消人口分配操作(人口减量)
function PeopleManageCtrl:quitAllotRenKou( renKouNum, allotType )
	if renKouNum < 0 then
		return
	end
	if isEmpty(self.allotList[allotType]) then
		return
	end
	local pMange = self.allotList[allotType]
	if pMange.allotRenKouNum <= 0 then
		return
	end
	local finalRenKouNum = pMange.allotRenKouNum - renKouNum
	if finalRenKouNum < 0 then
		print("finalRenKouNum:", finalRenKouNum)
		return
	end
	pMange.allotRenKouNum = finalRenKouNum
	local tmpNum = isEmpty(self.allotList[allotType]) and 0 or self.allotList[allotType].allotRenKouNum
	self.playerAllotRenKou = self.playerAllotRenKou + renKouNum
	self:allotRenkouFun(self.playerAllotRenKou, ResourceType["WOOD"], 1)
	peopleManageFun.PeopleManageFun.sendAllotRenKouToClient( self.playerID, allotType, tmpNum, self.playerAllotRenKou )
	print("取消分配人口：", allotType, renKouNum, tmpNum, self.playerAllotRenKou)
end

--请求数据操作
function PeopleManageCtrl:requestOutPutData( isBool )
	if self.startAllotTime <= 0 or isEmpty(self.allotList) then
		return
	end
	local nowTime = Au.nowTime()
	local defultTime = buildFun.BuildFun:readDeafultValue()["DEFAULTTIME"]
	local runningtime = defultTime - (nowTime - self.startAllotTime)
	local check = (isBool == false and self.getAllotDataTime ~= 0 and runningtime > 0)
	if check then
		peopleManageFun.PeopleManageFun.onStepRequestTime(self.playerID, runningtime)
		return
	end
	local goTime = NumberToInt((nowTime - self.startAllotTime)/defultTime + 0.5)
	self.startAllotTime = nowTime
	self.getAllotDataTime = 1
	
	local tb = {}	--保存产量
	for i=1,#self.priorityLV do
		local pMange = self.allotList[self.priorityLV[i]]
		if not isEmpty(pMange) then
			tb[pMange.allotType] = pMange:countOtherSourceOutPut(self, goTime) or 0
		end
	end
	
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_PEOPLEMANAGE_INFO)
	Au.addUint8(defultTime)
	Au.addUint16(self.playerAllotRenKou)
	for allotType, pMange in pairs(self.allotList) do
		Au.addUint32(allotType)
		Au.addUint16(pMange.allotRenKouNum)
		Au.addUint32(tb[allotType] or 0)
		print("请求数据:分配类型:["..allotType.."]分配人口:["..pMange.allotRenKouNum.."]总量:["..(tb[allotType] or 0))
	end
	Au.messageEnd()
end

function PeopleManageCtrl:checkAllotNum(allotType)
	if isEmpty(self.allotList) then
		return false
	end
	local pMange = self.allotList[allotType]
	if isEmpty(pMange) then
		return false
	end
	if pMange.allotRenKouNum <= 0 then
		return false
	end
	return true
end

--默认分配给木材操作
function PeopleManageCtrl:defaultAllotWood()
	if self.playerAllotRenKou < 1 then
		return
	end
	local preCfg = buildFun.BuildFun:get_ProUsePre(ResourceType["WOOD"])
	if self:checkPrecondition(preCfg["PRE"]) == false then
		return
	end
	self.startAllotTime = self.startAllotTime > 0 and self.startAllotTime or Au.nowTime()
	self:allotRenkouFun(self.playerAllotRenKou, ResourceType["WOOD"], 1)
end

--api
function World_PeopleManageCtrl_requestOutPutData( playerID )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	_player:requestOutPutData(false)
end

function World_PeopleManageCtrl_allotRenkou( playerID, renKouNum, allotType, isBool )
	-- body
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	if isBool == 1 then
		_player:allotRenkou( renKouNum, allotType )
	else
		_player:quitAllotRenKou( renKouNum, allotType )
	end
end