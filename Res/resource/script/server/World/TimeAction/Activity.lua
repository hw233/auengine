--Activity.lua

ACTIVITY_TYPE = {}

ACTIVITY_TYPE.FIX_TIME = 1		--�̶�ʱ���ִ�еĻ
ACTIVITY_TYPE.FIX_DATE = 2		--�̶�ʱ�俪���Ļ
ACTIVITY_TYPE.FIX_DATE_HOUR = 3	--���㿪ʼ�
ACTIVITY_TYPE.YEAR_DATA_HOUR = 4--�����ڿ��Ż
ACTIVITY_TYPE.FIX_WEEKEND = 5	--��ÿ�����������տ��Ż


--�����
Activity = {}

function Activity:New()
	local object = setmetatable({},self)
	self.__index = self
	self.activityID = 0				--���ID
	self.activityType = 0			--�����
	self.startTime = 0				--��ʼʱ��
	self.intervalTime = 0			--���ʱ��
	self.executeTime = 0			--ִ�е�ʱ��
	self.repeatTime = 0				--�ظ�ִ�л�Ĵ���
	self.shutDown = 0				--�Ƿ���ʱ�ر�
	object.Cfg = {}					--����
	return object
end

--��ʼ���
function Activity:initFromCfg(activityCfg,nowTime)
	self.activityID = activityCfg.activityID
	self.activityType = activityCfg.activityType
	self.intervalTime = activityCfg.intervalTime
	self.repeatTime = activityCfg.repeatTime
	self.Cfg = activityCfg
	if self.activityType == ACTIVITY_TYPE.FIX_TIME then		--����������������ʼ�
		self.executeTime = nowTime + self.intervalTime
	elseif self.activityType == ACTIVITY_TYPE.FIX_DATE then --�̶�ʱ�俪��
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
	
	print("�����:",self.activityID,"�´�ִ��ʱ��:",os.date("%c",self.executeTime))
	
end

--�����ڿ��Żִ��ʱ��
function Activity:FormatDateTime(dayTimes)
	timesTb = Split(dayTimes,":")
	if table.getn(timesTb) ~= 5 then
		PrintError("Activity Config is Error: activityID "..self.activityID.." startTime "..dayTimes)
		return nowTime - 10000
	end
	
	return os.time({year=timesTb[1], month=timesTb[2], day=timesTb[3], hour=timesTb[4], min=timesTb[5]})
end

--����ĩ���Żִ��ʱ��
function Activity:FormatWeekendTime(nowTime)
	local h = tonumber(os.date("%H",nowTime))--ʱ
	local m = tonumber(os.date("%M",nowTime))--��
	local s = tonumber(os.date("%S",nowTime))--��
	local nowWeek = tonumber(os.date("%w",nowTime))
	local betweenValue = 0
	local finalTime = 0--���������ʱ���
	
	if nowWeek == 6 then
		betweenValue = 172800
	else
		betweenValue = 86400 - ( 86400*nowWeek )
	end
	finalTime = nowTime + betweenValue + 432000 - h*3600 - m*60 - s
	self.intervalTime = 604800	--7��ļ��ʱ��
	return finalTime
end

--���㿪ʼ�ִ��ʱ��
function Activity:FormatHourTime(dayTimes,nowTime)
	timesTb = Split(dayTimes,":")
	if table.getn(timesTb) ~= 3 then
		PrintError("Activity Config is Error: activityID "..self.activityID.." startTime "..dayTimes)
		return nowTime - 10000
	end
	
	local value = getNextTimeFromNow(nowTime,timesTb)
	
	self.intervalTime = 86400 --ÿһ��ļ��ʱ��
	
	return value
end

--����Ƿ�ִ��   ���� 1 ��ʾ����ִ�� 0 ��ʾû��ִ�� 2 ��ʾִ����� ͬʱ ��Ҫɾ���Ļ
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
	
	--ִ�к����
	if self.Cfg.nextActivities[1] ~= 0 then
		for i = 1, table.getn(self.Cfg.nextActivities) do
			TimeAction:addNewActivity(self.Cfg.nextActivities[i])
		end
	end
	if self.repeatTime ~= -1 then
		self.repeatTime = self.repeatTime - 1
	end
	if self.repeatTime == 0 then --ִ�н��� ɾ���
		return 2
	end
	self.executeTime = self.executeTime + self.intervalTime
	print("�����:",self.activityID,"�´�ִ��ʱ��:",os.date("%c",self.executeTime))
	return 1
end