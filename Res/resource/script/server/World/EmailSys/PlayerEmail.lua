-- PlayerEmail.lua

PlayerEmail = {}

function PlayerEmail:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.readFlag = 0       --�ʼ��Ƿ��ȡ��0-δ��, 1-�Ѷ�
	self.deleteFlag = 0     --�ʼ��Ƿ��Ѿ�ɾ�� 0-δɾ����1-��ɾ��
	self.ranking = 0        --����
	self.flag = false   
	
	return obj
end

--�̳�BaseEmail
function PlayerEmail:CreatePlayerEmailNew()
	local obj = createClass(BaseEmail, PlayerEmail)
	return obj
end

--�����ʼ�
function PlayerEmail:CreateEmail(emailObj)
	local obj = PlayerEmail:CreatePlayerEmailNew()
		obj.emailKey = emailObj.emailKey
		obj.emailID = emailObj.emailID
		obj.emailCreateTime = emailObj.emailCreateTime
		obj.emailSaveTime = emailObj.emailSaveTime
		obj.emailContent = emailObj.emailContent
	
	return obj
end
