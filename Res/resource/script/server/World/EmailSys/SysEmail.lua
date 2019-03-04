-- SysEmail.lua

require "resource.script.server.Config.Email.EMAIL"
require "resource.script.server.World.EmailSys.BaseEmail"

SysEmail = {}

SysEmailList = {}    --ϵͳ�ʼ��б�

function SysEmail:New()
	local obj = setmetatable({}, self)
	self.emailRewardList = ""    --������Ʒ�б� 

	return obj
end

function SysEmail:CreateEamilObj()
	local obj = createClass(BaseEmail, SysEmail)
	
	return obj
end

--��ʼ��ϵͳ�ʼ��б�
function SysEmail:InitSysEmail(sqlResult, tableName)
	if isEmpty(sqlResult) then
		return
	end
	
	for i = 1, sqlResult:GetRowCount() do
		local obj = SysEmail:CreateEamilObj()
		obj.emailKey = sqlResult:GetFieldFromCount(0):GetUInt32()
		obj.emailID = sqlResult:GetFieldFromCount(1):GetUInt32()
		obj.emailContent = sqlResult:GetFieldFromCount(2):GetString()
		obj.emailCreateTime = sqlResult:GetFieldFromCount(3):GetUInt32()
		obj.emailSaveTime = sqlResult:GetFieldFromCount(4):GetUInt32()
		obj.emailIsReward = sqlResult:GetFieldFromCount(5):GetInt8()
		obj.emailRewardList = sqlResult:GetFieldFromCount(6):GetString()
		
		SysEmailList[obj.emailKey] = obj  --�����ʼ��б�
		
		sqlResult:NextRow()
	end
		sqlResult:Delete()
end

--����ϵͳ���棬���²����ʼ�(GM���ýӿ�)
function CreateSysEmail(emailID, Content, rewardList)
--��ȡ�ʼ�����
	local emailCfg = SysEmail:readSysEmailCfg(emailID)
	if isEmpty(emailCfg) then
		print("error!!!")
		return
	end
	
	local createTime = Au.nowTime()
	local eKey = Au.getDatateID("tb_email")
	local obj = SysEmail:CreateEamilObj()
	obj.emailKey = eKey
	obj.emailID = emailID
	obj.emailContent = Content
	obj.emailCreateTime = createTime 
	obj.emailSaveTime = createTime + emailCfg["saveTime"]
	obj.emailIsReward = emailCfg["isReward"]
	
	if obj.emailIsReward == 1 then
		obj.emailRewardList = rewardList
	end
	
	SysEmailList[obj.emailKey] = obj
	
	--���浽���ݿ�
	Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
										 ..obj.emailID..",'"
										 ..obj.emailContent.."',"   --�������������GB2312��ʽҪת��ΪUTF8
										 ..obj.emailCreateTime..","
										 ..obj.emailSaveTime..","
										 ..obj.emailIsReward..",'"
										 ..obj.emailRewardList..
										 "');")
	
	SysEmail:SendNewEmailIfno()  -- ֪ͨ�����ʼ�����
	
end

--�賿���������������ʼ�����
function SysEmail:CreatePVPEmail()
local eKey = Au.getDatateID("tb_email")

end

--��ȡϵͳ�ʼ�����
function SysEmail:readSysEmailCfg(emailID)
	local emailItem = "EMAIL_"..emailID
	return SysEmailCfg[emailItem]
end

--ɾ��ϵͳ�ʼ�
function SysEmail:deleteSysEmail(emailID)
	SysEmailList[emailID] = nil
	Au.queryQueue("DELETE FROM tb_email WHERE tb_email.gid = "..emailID..";")
end

--֪ͨ�ͻ��������ʼ�����
function SysEmail:SendNewEmailIfno()
	for _, _player in pairs(Players) do
		Au.messageToClientBegin(_player.playerID, MacroMsgID.MSG_ID_EMAIL_NEWEMAILINFO)
		Au.addUint8(0)
		Au.messageEnd()
	end
	
end

--��ʱ���Խӿ�(������������ʼ�������ʼ�)
function SysEmail:TestEmail()
	local sqlResult = Au.query("SELECT * FROM tb_email;")
	
	if isEmpty(sqlResult) then
	
--��һ���ʼ�
		local emailCfg = SysEmail:readSysEmailCfg(901)
		local obj = SysEmail:CreateEamilObj()
		local createTime = Au.nowTime()
		local eKey = Au.getDatateID("tb_email")
		local content = "��Ϸ����18���賿2:00-4:00���и��£��������׼ʱ���ߣ�лл����!"
		obj.emailKey = eKey
		obj.emailID = 901
		obj.emailContent = Au.ToUTF8(content)
		obj.emailCreateTime = createTime 
		obj.emailSaveTime = createTime + emailCfg["saveTime"]
		obj.emailIsReward = emailCfg["isReward"]
		obj.emailRewardList = 0
		SysEmailList[obj.emailKey] = obj
		Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
											 ..obj.emailID..",'"
											 ..obj.emailContent.."',"   
											 ..obj.emailCreateTime..","
											 ..obj.emailSaveTime..","
											 ..obj.emailIsReward..",'"
											 ..obj.emailRewardList..
											 "');")
		
--�ڶ����ʼ�
		emailCfg = SysEmail:readSysEmailCfg(902)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "���θ�����ϣ��ظ��������²�����ף����Ϸ��죡!"
		obj.emailKey = eKey
		obj.emailID = 902
		obj.emailContent = Au.ToUTF8(content)
		obj.emailCreateTime = createTime 
		obj.emailSaveTime = createTime + emailCfg["saveTime"]
		obj.emailIsReward = emailCfg["isReward"]
		obj.emailRewardList = "1$3010001$1000;1$3010004$1000"
		SysEmailList[obj.emailKey] = obj
		Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
											 ..obj.emailID..",'"
											 ..obj.emailContent.."',"   
											 ..obj.emailCreateTime..","
											 ..obj.emailSaveTime..","
											 ..obj.emailIsReward..",'"
											 ..obj.emailRewardList..
											 "');")
--�������ʼ�		
		emailCfg = SysEmail:readSysEmailCfg(902)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "���θ�����ϣ��ظ��������²�����ף����Ϸ��죡!"
		obj.emailKey = eKey
		obj.emailID = 902
		obj.emailContent = Au.ToUTF8(content)
		obj.emailCreateTime = createTime - 86400
		obj.emailSaveTime = createTime + emailCfg["saveTime"]
		obj.emailIsReward = emailCfg["isReward"]
		obj.emailRewardList = "1$3010001$1000;1$3010004$1000"
		SysEmailList[obj.emailKey] = obj
		Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
											 ..obj.emailID..",'"
											 ..obj.emailContent.."',"   
											 ..obj.emailCreateTime..","
											 ..obj.emailSaveTime..","
											 ..obj.emailIsReward..",'"
											 ..obj.emailRewardList..
											 "');")

--���ķ��ʼ�		
		emailCfg = SysEmail:readSysEmailCfg(901)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "��Ϸ����18���賿2:00-4:00���и��£��������׼ʱ���ߣ�лл����!"
		obj.emailKey = eKey
		obj.emailID = 901
		obj.emailContent = Au.ToUTF8(content)
		obj.emailCreateTime = createTime - 86400
		obj.emailSaveTime = createTime + emailCfg["saveTime"]
		obj.emailIsReward = emailCfg["isReward"]
		obj.emailRewardList = 0
		SysEmailList[obj.emailKey] = obj
		Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
											 ..obj.emailID..",'"
											 ..obj.emailContent.."',"   
											 ..obj.emailCreateTime..","
											 ..obj.emailSaveTime..","
											 ..obj.emailIsReward..",'"
											 ..obj.emailRewardList..
											 "');")
--������ʼ�	
		emailCfg = SysEmail:readSysEmailCfg(902)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "���θ�����ϣ��ظ��������²�����ף����Ϸ��죡!"
		obj.emailKey = eKey
		obj.emailID = 902
		obj.emailContent = Au.ToUTF8(content)
		obj.emailCreateTime = createTime - 172800
		obj.emailSaveTime = createTime + emailCfg["saveTime"]
		obj.emailIsReward = emailCfg["isReward"]
		obj.emailRewardList = "1$3010001$1000;1$3010004$1000"
		SysEmailList[obj.emailKey] = obj
		Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
											 ..obj.emailID..",'"
											 ..obj.emailContent.."',"   
											 ..obj.emailCreateTime..","
											 ..obj.emailSaveTime..","
											 ..obj.emailIsReward..",'"
											 ..obj.emailRewardList..
											 "');")

--�������ʼ�											 
		emailCfg = SysEmail:readSysEmailCfg(901)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "��Ϸ����18���賿2:00-4:00���и��£��������׼ʱ���ߣ�лл����!"
		obj.emailKey = eKey
		obj.emailID = 901
		obj.emailContent = Au.ToUTF8(content)
		obj.emailCreateTime = createTime - 172800
		obj.emailSaveTime = createTime + emailCfg["saveTime"]
		obj.emailIsReward = emailCfg["isReward"]
		obj.emailRewardList = 0
		SysEmailList[obj.emailKey] = obj
		Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
											 ..obj.emailID..",'"
											 ..obj.emailContent.."',"   
											 ..obj.emailCreateTime..","
											 ..obj.emailSaveTime..","
											 ..obj.emailIsReward..",'"
											 ..obj.emailRewardList..
											 "');")
	
		
	end
end

