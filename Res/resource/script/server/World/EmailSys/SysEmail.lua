-- SysEmail.lua

require "resource.script.server.Config.Email.EMAIL"
require "resource.script.server.World.EmailSys.BaseEmail"

SysEmail = {}

SysEmailList = {}    --系统邮件列表

function SysEmail:New()
	local obj = setmetatable({}, self)
	self.emailRewardList = ""    --奖励物品列表 

	return obj
end

function SysEmail:CreateEamilObj()
	local obj = createClass(BaseEmail, SysEmail)
	
	return obj
end

--初始化系统邮件列表
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
		
		SysEmailList[obj.emailKey] = obj  --保存邮件列表
		
		sqlResult:NextRow()
	end
		sqlResult:Delete()
end

--创建系统公告，更新补偿邮件(GM调用接口)
function CreateSysEmail(emailID, Content, rewardList)
--读取邮件配置
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
	
	--保存到数据库
	Au.queryQueue("CALL update_tb_email("..obj.emailKey..","
										 ..obj.emailID..",'"
										 ..obj.emailContent.."',"   --如果发过来的是GB2312格式要转化为UTF8
										 ..obj.emailCreateTime..","
										 ..obj.emailSaveTime..","
										 ..obj.emailIsReward..",'"
										 ..obj.emailRewardList..
										 "');")
	
	SysEmail:SendNewEmailIfno()  -- 通知有新邮件生成
	
end

--凌晨创建竞技场排名邮件奖励
function SysEmail:CreatePVPEmail()
local eKey = Au.getDatateID("tb_email")

end

--读取系统邮件配置
function SysEmail:readSysEmailCfg(emailID)
	local emailItem = "EMAIL_"..emailID
	return SysEmailCfg[emailItem]
end

--删除系统邮件
function SysEmail:deleteSysEmail(emailID)
	SysEmailList[emailID] = nil
	Au.queryQueue("DELETE FROM tb_email WHERE tb_email.gid = "..emailID..";")
end

--通知客户端有新邮件生成
function SysEmail:SendNewEmailIfno()
	for _, _player in pairs(Players) do
		Au.messageToClientBegin(_player.playerID, MacroMsgID.MSG_ID_EMAIL_NEWEMAILINFO)
		Au.addUint8(0)
		Au.messageEnd()
	end
	
end

--临时测试接口(服务器启动初始化两封邮件)
function SysEmail:TestEmail()
	local sqlResult = Au.query("SELECT * FROM tb_email;")
	
	if isEmpty(sqlResult) then
	
--第一封邮件
		local emailCfg = SysEmail:readSysEmailCfg(901)
		local obj = SysEmail:CreateEamilObj()
		local createTime = Au.nowTime()
		local eKey = Au.getDatateID("tb_email")
		local content = "游戏将于18日凌晨2:00-4:00进行更新，请广大玩家准时下线，谢谢合作!"
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
		
--第二封邮件
		emailCfg = SysEmail:readSysEmailCfg(902)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "本次更新完毕，特给予您以下补偿，祝您游戏愉快！!"
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
--第三封邮件		
		emailCfg = SysEmail:readSysEmailCfg(902)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "本次更新完毕，特给予您以下补偿，祝您游戏愉快！!"
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

--第四封邮件		
		emailCfg = SysEmail:readSysEmailCfg(901)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "游戏将于18日凌晨2:00-4:00进行更新，请广大玩家准时下线，谢谢合作!"
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
--第五封邮件	
		emailCfg = SysEmail:readSysEmailCfg(902)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "本次更新完毕，特给予您以下补偿，祝您游戏愉快！!"
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

--第六封邮件											 
		emailCfg = SysEmail:readSysEmailCfg(901)
		obj = SysEmail:CreateEamilObj()
		createTime = Au.nowTime()
		eKey = Au.getDatateID("tb_email")
		content = "游戏将于18日凌晨2:00-4:00进行更新，请广大玩家准时下线，谢谢合作!"
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

