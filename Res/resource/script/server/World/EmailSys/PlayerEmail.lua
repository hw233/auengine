-- PlayerEmail.lua

PlayerEmail = {}

function PlayerEmail:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.readFlag = 0       --邮件是否读取，0-未读, 1-已读
	self.deleteFlag = 0     --邮件是否已经删除 0-未删除，1-已删除
	self.ranking = 0        --排名
	self.flag = false   
	
	return obj
end

--继承BaseEmail
function PlayerEmail:CreatePlayerEmailNew()
	local obj = createClass(BaseEmail, PlayerEmail)
	return obj
end

--创建邮件
function PlayerEmail:CreateEmail(emailObj)
	local obj = PlayerEmail:CreatePlayerEmailNew()
		obj.emailKey = emailObj.emailKey
		obj.emailID = emailObj.emailID
		obj.emailCreateTime = emailObj.emailCreateTime
		obj.emailSaveTime = emailObj.emailSaveTime
		obj.emailContent = emailObj.emailContent
	
	return obj
end
