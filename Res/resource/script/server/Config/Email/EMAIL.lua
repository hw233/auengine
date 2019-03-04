SysEmailCfg=
{
--Start--

	EMAIL_901  =  
	{
		recv = 1,             --接收人(1-所有玩家)
		Item = "更新公告",    --主题
		sendBy = "运营团队",    --发送人
		isReward = 0,         --是否奖励
		isDelete = 0,         --是否阅读删除
		saveTime = 600,    --保存时间
	},


	EMAIL_902  =  
	{
		recv = 1,
		Item = "更新补偿",
		sendBy = "运营团队",
		isReward = 1,
		isDelete = 1,
		saveTime = 604800,
	},
	
	EMAIL_101  =  
	{
		recv = 0,
		Item = "竞技场排名奖励",
		sendBy = "系统",
		isReward = 1,
		isDelete = 1,
		saveTime = 604800,
	},
	
	EMAIL_102  =  
	{
		recv = 0,
		Item = "竞技场最高排名奖励",
		sendBy = "系统",
		isReward = 1,
		isDelete = 1,
		saveTime = 604800,
	},

}--End