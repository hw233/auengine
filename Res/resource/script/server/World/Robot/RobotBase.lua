--RobotBase.lua

--全局函数
local table_insert = table.insert
local pairs = pairs

RobotObjList = {}    --全部机器人实例

--创建全部机器人
function RobotObjList:InitAllRobot()
	for levelIdx, robotCfg in pairs(ROBOT) do
		local _robot = RobotBase:CreateRobot(robotCfg)
		RobotObjList[levelIdx] = _robot	
	end
end


RobotBase = {}

function RobotBase:New()
	local obj = setmetatable({}, self)
	self.__index = self
	
	return obj
end


--继承玩家属性
function RobotBase:CreateNew()
	local robotObj = createClass(Player,PlayerData,ExploreCtrl,HeroNPC,BaseEntity,HeroData,HeroPlayer, RobotBase)
	return robotObj
end

--根据玩家等级获取一个机器人
function RobotBase:getOneRobot(playerLevel)
	local levelIdx = NumberToInt(playerLevel/3) + 1      --玩家等级对应机器人的等级区间
	local robotCfg = HeroNPC:readRobotCfg(levelIdx)
	if isEmpty(robotCfg) then
		return
	end
	
	local _robot = RobotObjList["ROBOT_"..levelIdx]      --该等级区间的所有机器人
	if isEmpty(_robot) then
		return
	end
	
	--随机出一个机器人玩家
	local idx = AuRandom(1, #_robot)
	local robotItem = _robot[idx]
	
	return robotItem 
end

--获取某个等级区间的所有机器人
function RobotBase:getAllRobotByLevel(level)
	local levelIdx = NumberToInt(level/3) + 1
	local _robot = RobotObjList["ROBOT_"..levelIdx]      --该等级区间的所有机器人
	if isEmpty(_robot) then
		return
	end
	
	return _robot
end

--获取某个等级区间 num 个机器人
function RobotBase:getSomeRobotByLevel(level, num)
	local levelIdx = NumberToInt(level/3) + 1
	local _robot = RobotObjList["ROBOT_"..levelIdx]      --该等级区间的所有机器人
	if isEmpty(_robot) then
		return
	end
	
	if	getTableLength(_robot) <= num then
		return _robot
	end
	
	local robot = {}
	for i = 1, num do
		table_insert(robot, _robot[i])
	end
	
	return robot
end


--生成一个等级区间的多个机器人
function RobotBase:CreateRobot(config)                
	local RobotNameList = {}
	local HostID = config["HOSTID"]          --主角ID
	local level = config["LEVEL"]            --等级
	local nameList = config["ROBOTNAME"]     --机器人名称
	local petNum = config["PETNUM"]          --宠物数量
	local petTB = config["PETID"]            --宠物ID
	
	for id = 1, #nameList do
	--创建机器人玩家
		local _robot = RobotBase:CreateNew()
		_robot.playerName = nameList[id]
		_robot.playerLevel = level
		
	--创建主角
		local RobotHeroList = {}
		local petDatabaseID = {}
		local obj = 0
		obj = HeroNPC:Create(HostID, level)
		table_insert(RobotHeroList, obj)
		_robot.heroList[obj.databaseID] = obj
		table_insert(petDatabaseID, obj.databaseID)
	--创建宠物(宠物不能重复)
		local i = 1
		while (i <= petNum) do
			local idx = AuRandom(1, #petTB)
			local petID = petTB[idx]
			local ret = RobotBase:checkPet(petID, RobotHeroList)
			if not ret then
				obj = HeroNPC:Create(petID, level)
				table_insert(RobotHeroList, obj)
				_robot.heroList[obj.databaseID] = obj
				table_insert(petDatabaseID, obj.databaseID)
				i = i + 1
			end
		end
		
		table_insert(RobotNameList, _robot)
		Players_name[_robot.playerName] = _robot
		_robot:changeFormation(petDatabaseID)    --宠物上阵列表
		
	end
	
	return RobotNameList
end

--检测宠物是否已经存在
function RobotBase:checkPet(petID, RobotHeroList)
	local isBool = false
	for k, obj in pairs(RobotHeroList) do
		if RobotHeroList[k].heroID == petID then
			isBool = true
		end
	end
	
	return isBool
end


