--Arena.lua

local Arena = {}

local LOCALMACRO = {}
LOCALMACRO.INTERVAL = 300	--战斗间隔时间
LOCALMACRO.MIANFEITIME = 5	--免费次数
LOCALMACRO.BUYATTACKTIME = 2--购买次数
LOCALMACRO.BUYUSE = 50		--购买消耗
LOCALMACRO.CLEARCD = 10		--清除CD消耗


function Arena:New()
	local object = setmetatable({},self)
	self.__index = self
	self.arenaOk = 0			--是否可以挑战
	self.arenaTime = 0			--战斗冷却时间
	self.arenaRank = 0			--竞技排名
	self.databaseID = 0			--玩家的DBID
	return object
end

--初始化
function Arena:initArena(databaseID)
	self.arenaOk = 1
	self.arenaRank = 0
	self.databaseID = databaseID
end

function Arena:cancelCD()
	self.arenaTime = 0
	self.arenaOk = 1
end

function Arena:onSetArenaTime()
	local nowTime = Au.nowTime()
	if self.arenaTime == 0 then
		self.arenaTime = nowTime
	end
	self.arenaTime = self.arenaTime + LOCALMACRO.INTERVAL
	self.arenaOk = 0
end

function Arena:getLeaveTime()
	if self.arenaTime == 0 then
		self.arenaOk = 1
		return 0
	end
	local ltime = self.arenaTime - Au.nowTime()
	if ltime <= 0 then
		self.arenaTime = 0
		self.arenaOk = 1
		ltime = 0
	end
	return ltime
end

function Arena:getArenaReward()
	
end


function Arena:getPaiMing()
	
end

function Arena:saveToDB()
	Au.queryQueue("CALL update_tb_Arena("..self.databaseID..","..self.arenaRank..");")
end

function Arena:exchangeRank(Arena1,Arena2)
	local t = Arena1.arenaRank
	Arena1.arenaRank = Arena2.arenaRank
	Arena2.arenaRank = t
	Arena1:saveToDB()
	Arena2:saveToDB()
end

function Arena:getPiPeiExtent(nowRank)
	local tmpTB = {}
	local lowRate1 = 0
	local hight1 = 0
	local lowRate2 = 0
	local hight2 = 0
	local lowRate3 = 0
	local hight3 = 0
	if nowRank > 10 and nowRank <= 50 then
		lowRate1 = NumberToInt(nowRank*0.7)
		hight1 = NumberToInt(nowRank*0.99)
		lowRate2 = NumberToInt(nowRank*0.4)
		hight2 = NumberToInt(nowRank*0.69)
		lowRate3 = NumberToInt(nowRank*0.1)
		hight3 = NumberToInt(nowRank*0.39)
	elseif nowRank <= 100 then
		lowRate1 = NumberToInt(nowRank*0.8)
		hight1 = NumberToInt(nowRank*0.99)
		lowRate2 = NumberToInt(nowRank*0.6)
		hight2 = NumberToInt(nowRank*0.79)
		lowRate3 = NumberToInt(nowRank*0.4)
		hight3 = NumberToInt(nowRank*0.59)
	elseif nowRank <= 500 then
		lowRate1 = NumberToInt(nowRank*0.9)
		hight1 = NumberToInt(nowRank*0.99)
		lowRate2 = NumberToInt(nowRank*0.8)
		hight2 = NumberToInt(nowRank*0.89)
		lowRate3 = NumberToInt(nowRank*0.7)
		hight3 = NumberToInt(nowRank*0.79)
	else
		lowRate1 = NumberToInt(nowRank*0.95)
		hight1 = NumberToInt(nowRank*0.99)
		lowRate2 = NumberToInt(nowRank*0.9)
		hight2 = NumberToInt(nowRank*0.94)
		lowRate3 = NumberToInt(nowRank*0.85)
		hight3 = NumberToInt(nowRank*0.89)
	end
	return {{lowRate1,hight1},{lowRate2,hight2},{lowRate3,hight3}}
end

return {Arena=Arena, LOCALMACRO=LOCALMACRO}