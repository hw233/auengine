-- BaseEmail.lua

BaseEmail = {}

function BaseEmail:New()
local obj = setmetatable({}, self)
	self.__index = self
	self.emailKey = 0            --�ʼ�Ψһid
	self.emailID = 0			 --�ʼ�����
	self.emailCreateTime = 0     --�ʼ�����ʱ��
	self.emailSaveTime = 0       --�ʼ�����ʱ��
	self.emailContent = ""       --�ʼ�����
	self.emailIsReward = 0       --�Ƿ��н��� 0-û�н�����1-�н���

	return obj
end
