--Activity.lua

ACTIVITY_TYPE = {}

ACTIVITY_TYPE.FIX_TIME = 1		--固定时间隔执行的活动
ACTIVITY_TYPE.FIX_DATE = 2		--固定时间开启的活动
ACTIVITY_TYPE.FIX_DATE_HOUR = 3	--整点开始活动
ACTIVITY_TYPE.YEAR_DATA_HOUR = 4--按日期开放活动
ACTIVITY_TYPE.FIX_WEEKEND = 5	--按每周周六、周日开放活动


--单个活动
Activity = {}

function Activity:New()
	local object = setmetatable({},self)
	self.__index = self
	self.activityID = 0				--活动的ID
	self.activityType = 0			--活动类型
	self.startTime = 0				--开始时间
	self.intervalTime = 0			--间隔时间
	self.executeTime = 0			--执行的时间
	self.repeatTime = 0				--重复执行活动的次数
	self.shutDown = 0				--是否暂时关闭
	object.Cfg = {}					--配置
	return object
end

--初始化活动
function Activity:initFromCfg(activityCfg,nowTime)
	self.activityID = activityCfg.activityID
	self.activityType = activityCfg.activityType
	self.intervalTime = activityCfg.intervalTime
	self.repeatTime = activityCfg.repeatTime
	self.Cfg = activityCfg
	if self.activityType == ACTIVITY_TYPE.FIX_TIME then		--启动服务器立即开始活动
		self.executeTime = nowTime + self.intervalTime
	elseif self.activityType == ACTIVITY_TYPE.FIX_DATE then --固定时间开启
		self.executeTime = self:FormatHourTime(self.Cfg.startTime,nowTime)
	elseif self.activityType == ACTIVITY_TYPE.FIX_DATE_HOUR then
		local M2 = tonumber(os.date("%M", nowTime))
		local S2 = tonumber(os.date("%S", nowTime))
		self.executeTime = nowTime + 3600 - M2*60 - S2
	elseif self.activityType == ACTIVITY_TYPE.YEAR_DATA_HOUR then
		self.executeTime = self:FormatDateTime(self.Cfg.startTime)
	elseif self.activityType == ACTIVITY_TYPE.FIX_WEEKEND then
		self.executeTime = self:FormatWeekendTime(nowTime)
	end
	
	print("开启活动:",self.activityID,"下次执行时间:",os.date("%c",self.executeTime))
	
end

--按日期开放活动执行时间
function Activity:FormatDateTime(dayTimes)
	timesTb = Split(dayTimes,":")
	if table.getn(timesTb) ~= 5 then
		PrintError("Activity Config is Error: activityID "..self.activityID.." startTime "..dayTimes)
		return nowTime - 10000
	end
	
	return os.time({year=timesTb[1], month=timesTb[2], day=timesTb[3], hour=timesTb[4], min=timesTb[5]})
end

--按周末开放活动执行时间
function Activity:FormatWeekendTime(nowTime)
	local h = tonumber(os.date("%H",nowTime))--时
	local m = tonumber(os.date("%M",nowTime))--分
	local s = tonumber(os.date("%S",nowTime))--秒
	local nowWeek = tonumber(os.date("%w",nowTime))
	local betweenValue = 0
	local finalTime = 0--最近周六的时间戳
	
	if nowWeek == 6 then
		betweenValue = 172800
	else
		betweenValue = 86400 - ( 86400*nowWeek )
	end
	finalTime = nowTime + betweenValue + 432000 - h*3600 - m*60 - s
	self.intervalTime = 604800	--7天的间隔时间
	return finalTime
end

--整点开始活动执行时间
function Activity:FormatHourTime(dayTimes,nowTime)
	timesTb = Split(dayTimes,":")
	if table.getn(timesTb) ~= 3 then
		PrintError("Activity Config is Error: activityID "..self.activityID.." startTime "..dayTimes)
		return nowTime - 10000
	end
	
	local value = getNextTimeFromNow(nowTime,timesTb)
	
	self.intervalTime = 86400 --每一天的间隔时间
	
	return value
end

--检查活动是否执行   返回 1 表示正常执行 0 表示没有执行 2 表示执行完成 同时 需要删除的活动
function Activity:checkStart(nowTime)
	if self.shutDown ~= 0 then
		return 0
	end

	if nowTime < self.executeTime then
		return 0
	end
	
	if self.repeatTime == 0 then
		return 0
	end
	
	--执行后续活动
	if self.Cfg.nextActivities[1] ~= 0 then
		for i = 1, table.getn(self.Cfg.nextActivities) do
			TimeAction:addNewActivity(self.Cfg.nextActivities[i])
		end
	end
	if self.repeatTime ~= -1 then
		self.repeatTime = self.repeatTime - 1
	end
	if self.repeatTime == 0 then --执行结束 删除活动
		return 2
	end
	self.executeTime = self.executeTime + self.intervalTime
	print("继续活动:",self.activityID,"下次执行时间:",os.date("%c",self.executeTime))
	return 1
end