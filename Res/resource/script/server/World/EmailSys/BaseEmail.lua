-- BaseEmail.lua

BaseEmail = {}

function BaseEmail:New()
local obj = setmetatable({}, self)
	self.__index = self
	self.emailKey = 0            --邮件唯一id
	self.emailID = 0			 --邮件类型
	self.emailCreateTime = 0     --邮件生成时间
	self.emailSaveTime = 0       --邮件保存时间
	self.emailContent = ""       --邮件内容
	self.emailIsReward = 0       --是否有奖励 0-没有奖励，1-有奖励

	return obj
end
