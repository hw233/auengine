--RobotBase.lua

--ȫ�ֺ���
local table_insert = table.insert
local pairs = pairs

RobotObjList = {}    --ȫ��������ʵ��

--����ȫ��������
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


--�̳��������
function RobotBase:CreateNew()
	local robotObj = createClass(Player,PlayerData,ExploreCtrl,HeroNPC,BaseEntity,HeroData,HeroPlayer, RobotBase)
	return robotObj
end

--������ҵȼ���ȡһ��������
function RobotBase:getOneRobot(playerLevel)
	local levelIdx = NumberToInt(playerLevel/3) + 1      --��ҵȼ���Ӧ�����˵ĵȼ�����
	local robotCfg = HeroNPC:readRobotCfg(levelIdx)
	if isEmpty(robotCfg) then
		return
	end
	
	local _robot = RobotObjList["ROBOT_"..levelIdx]      --�õȼ���������л�����
	if isEmpty(_robot) then
		return
	end
	
	--�����һ�����������
	local idx = AuRandom(1, #_robot)
	local robotItem = _robot[idx]
	
	return robotItem 
end

--��ȡĳ���ȼ���������л�����
function RobotBase:getAllRobotByLevel(level)
	local levelIdx = NumberToInt(level/3) + 1
	local _robot = RobotObjList["ROBOT_"..levelIdx]      --�õȼ���������л�����
	if isEmpty(_robot) then
		return
	end
	
	return _robot
end

--��ȡĳ���ȼ����� num ��������
function RobotBase:getSomeRobotByLevel(level, num)
	local levelIdx = NumberToInt(level/3) + 1
	local _robot = RobotObjList["ROBOT_"..levelIdx]      --�õȼ���������л�����
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


--����һ���ȼ�����Ķ��������
function RobotBase:CreateRobot(config)                
	local RobotNameList = {}
	local HostID = config["HOSTID"]          --����ID
	local level = config["LEVEL"]            --�ȼ�
	local nameList = config["ROBOTNAME"]     --����������
	local petNum = config["PETNUM"]          --��������
	local petTB = config["PETID"]            --����ID
	
	for id = 1, #nameList do
	--�������������
		local _robot = RobotBase:CreateNew()
		_robot.playerName = nameList[id]
		_robot.playerLevel = level
		
	--��������
		local RobotHeroList = {}
		local petDatabaseID = {}
		local obj = 0
		obj = HeroNPC:Create(HostID, level)
		table_insert(RobotHeroList, obj)
		_robot.heroList[obj.databaseID] = obj
		table_insert(petDatabaseID, obj.databaseID)
	--��������(���ﲻ���ظ�)
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
		_robot:changeFormation(petDatabaseID)    --���������б�
		
	end
	
	return RobotNameList
end

--�������Ƿ��Ѿ�����
function RobotBase:checkPet(petID, RobotHeroList)
	local isBool = false
	for k, obj in pairs(RobotHeroList) do
		if RobotHeroList[k].heroID == petID then
			isBool = true
		end
	end
	
	return isBool
end


