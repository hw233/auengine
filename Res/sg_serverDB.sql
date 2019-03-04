/*创建数据库 game 可以修改 */
DROP DATABASE IF EXISTS mg_server_db;
CREATE DATABASE IF NOT EXISTS mg_server_db DEFAULT CHARACTER SET utf8;
SET character_set_server = utf8;
SET character_set_database = utf8;
SET character_set_connection = utf8;
SET names utf8;
USE mg_server_db;

/*创建游戏用到的数据表*/
CREATE TABLE tb_databaseID(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`gdatabaseid` INT UNSIGNED NOT NULL,
`dbkey` VARCHAR(50) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_playerInfo(
`databaseID` INT UNSIGNED PRIMARY KEY,
`isOnline` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1:在线0:未在线',
`playerSex` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '1:男0:女',
`playerName` VARCHAR(50) NOT NULL COMMENT '角色名',
`playerAccountID` VARCHAR(50) NOT NULL COMMENT '账号ID',
`playerBirthTime` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '出生日期',
`playerOfflineTime` INT UNSIGNED DEFAULT 0 COMMENT '下线日期',
`playerLastOnlineTime` INT UNSIGNED DEFAULT 0 COMMENT '最新一次登入日期'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*道具*/
CREATE TABLE tb_ItemProp(
`databaseID` INT UNSIGNED PRIMARY KEY COMMENT '物品databaseID',
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`itemID` INT UNSIGNED NOT NULL COMMENT '物品ID',
`itemQuality` TINYINT UNSIGNED NOT NULL COMMENT '品质',
`itemNumber` INT UNSIGNED NOT NULL COMMENT '物品仓库数量',
`itemBagNum` INT UNSIGNED NOT NULL COMMENT '物品背包数量',
`itemposition` TINYINT UNSIGNED NOT NULL COMMENT '位置'
)ENGINE=InnoDB DEFAULT CHARSET = utf8;

/*装备*/
CREATE TABLE tb_ItemEquip(
`databaseID` INT UNSIGNED PRIMARY KEY COMMENT '物品databaseID',
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`itemID` INT UNSIGNED NOT NULL COMMENT '物品ID',
`itemQuality` TINYINT UNSIGNED NOT NULL COMMENT '品质',
`itemNumber` INT UNSIGNED NOT NULL COMMENT '物品仓库数量',
`itemBagNum` INT UNSIGNED NOT NULL COMMENT '物品背包数量',
`itemposition` TINYINT UNSIGNED NOT NULL COMMENT '位置',
`itemStrengthenLevel` SMALLINT UNSIGNED NOT NULL COMMENT '当前强化等级'
)ENGINE=InnoDB DEFAULT CHARSET = utf8;

/*玩家属性*/
CREATE TABLE tb_PlayerProp(
`playerDBID` INT UNSIGNED PRIMARY KEY COMMENT '玩家databaseID',
`playerLevel` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '等级',
`playerDiamond` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '钻石',
`playerCopper` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '铜币',
`playerRenKouTotal` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '人口总量',
`rewardTimes` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '7天奖励领取次数',
`rewardFlag` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '领取标识 0-没有领取，1-已经领取',
`bFreeTimes` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT '青铜宝箱免费领取次数',
`sFreeTimes` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT '白银宝箱免费领取次数',
`sTotalTimes` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '白银宝箱累积领取次数(不包含免费领取次数)',
`playerBuyStatu` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已购买一次性物品状态位',
`playerSystemState` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '系统开放',
`playerBackpack` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '出行背包',
`playerWaterBag` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '水袋',
`playerCarriage` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '马车',
`playerAlchemy` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '炼金',
`playerBread` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '面包',
`playerTalentState` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '天赋状态',
`achievementPoint` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成就点'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*任务*/
CREATE TABLE tb_Task(
`ID` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`taskID` INT UNSIGNED NOT NULL COMMENT '任务ID',
`taskType` TINYINT UNSIGNED NOT NULL COMMENT '任务类型1:主线2:日常',
`taskState` TINYINT UNSIGNED NOT NULL COMMENT '任务状态1:完成0:未完成',
`taskEnd` TINYINT UNSIGNED NOT NULL COMMENT '领奖状态1:领取0:未领取',
`taskProgress` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '任务进度'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*建筑*/
CREATE TABLE tb_Build(
`ID` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`buildKey` SMALLINT UNSIGNED NOT NULL COMMENT '建筑KEY唯一',
`buildID` TINYINT UNSIGNED NOT NULL COMMENT '建筑类型',
`PosX` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'X坐标',
`PosY` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Y坐标',
`startTime` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '开始升级时间',
`updateTime` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '升级时间',
`buildLevel` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '建筑等级'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*人才分配*/
CREATE TABLE tb_PeopleManage(
`ID` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`allotType` INT UNSIGNED NOT NULL COMMENT '分配类型',
`allotNum` TINYINT UNSIGNED NOT NULL COMMENT '分配人口'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*伙伴*/
CREATE TABLE tb_Hero(
`databaseID` INT UNSIGNED PRIMARY KEY COMMENT '伙伴databaseID',
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`heroID` SMALLINT UNSIGNED NOT NULL COMMENT '伙伴ID'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*探险*/
CREATE TABLE tb_Explore(
`ID` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`playerDBID` INT UNSIGNED NOT NULL COMMENT '玩家databaseID',
`nowBigMap` TINYINT UNSIGNED NOT NULL COMMENT '当前大副本ID',
`bigMapIndex` TINYINT UNSIGNED NOT NULL COMMENT '大副本进度',
`ficthBigID` VARCHAR(64) NOT NULL DEFAULT "" COMMENT '大副本ID',
`ficthState` VARCHAR(64) NOT NULL DEFAULT "" COMMENT '大副本中二级副本状态'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*竞技场*/
CREATE TABLE tb_Arena(
`playerDBID` INT UNSIGNED PRIMARY KEY COMMENT '玩家databaseID',
`arenaRank` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '竞技场排名'
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


/*系统邮件*/
DROP TABLE IF EXISTS `tb_email`;
CREATE TABLE `tb_email` (
  `gid` INT(10) unsigned NOT NULL COMMENT '表id',
  `emailID` INT(10) unsigned NOT NULL COMMENT '邮件ID',
  `content` VARCHAR(200) NOT NULL COMMENT '邮件内容',
  `createtime` INT(10) unsigned NOT NULL COMMENT '邮件生成时间',
  `savetime` INT(10) unsigned NOT NULL COMMENT '邮件到期时间',
  `isreward` TINYINT(3) NOT NULL COMMENT '是否有奖励0-没有，1-有奖励',
  `rewardlist` VARCHAR(50) DEFAULT NULL COMMENT '奖励物品列表',
  PRIMARY KEY (`gid`,`emailID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*玩家邮件*/
DROP TABLE IF EXISTS `tb_useremail`;
CREATE TABLE `tb_useremail` (
  `gid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '邮件唯一id',
  `playerDBID` int(10) unsigned NOT NULL COMMENT '玩家id',
  `emailID` int(10) unsigned NOT NULL COMMENT '邮件类型',
  `content` varchar(200) NOT NULL COMMENT '邮件内容',
  `readflag` tinyint(3) NOT NULL COMMENT '阅读标记0-已读，1-未读',
  `emailstatus` tinyint(3) NOT NULL COMMENT '邮件状态0-未删除，1-删除',
  `sendtime` int(10) unsigned NOT NULL COMMENT '邮件发送时间，单位秒',
  `endtime` int(10) unsigned NOT NULL COMMENT '邮件到期时间',
  `ranking` int(10) unsigned NOT NULL COMMENT '竞技场排名',
  PRIMARY KEY (`gid`,`playerDBID`,`emailID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



/*创建游戏用到的储存过程*/
delimiter //

/*更新系统邮件*/

DROP PROCEDURE IF EXISTS update_tb_email //

CREATE PROCEDURE update_tb_email(
	in gid INT UNSIGNED, in emailID INT UNSIGNED, in content VARCHAR(200), in createtime INT unsigned, in savetime INT unsigned, in isreward TINYINT, in rewardlist varchar(50)
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_email WHERE tb_email.gid = gid AND tb_email.emailID = emailID LIMIT 1) THEN
		INSERT tb_email(tb_email.gid, tb_email.emailID, tb_email.content, tb_email.createtime, tb_email.savetime, tb_email.isreward, tb_email.rewardlist) VALUES(gid,emailID,content,createtime,savetime,isreward,rewardlist);
		
	ELSE	
		UPDATE tb_email SET tb_email.content = content,tb_email.createtime = createtime,tb_email.savetime = savetime,tb_email.isreward = isreward, tb_email.rewardlist = rewardlist WHERE tb_email.emailID = emailID AND tb_email.gid = gid;
	END IF;
END//

/*更新玩家邮件*/

DROP PROCEDURE IF EXISTS update_tb_UserEmail //

	CREATE PROCEDURE update_tb_UserEmail(
		in gid INT UNSIGNED, in playerDBID INT UNSIGNED, in emailID INT UNSIGNED, in content VARCHAR(200), in readflag TINYINT, in emailstatus TINYINT, in sendtime INT unsigned, in endtime INT unsigned, in ranking INT unsigned
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_useremail WHERE tb_useremail.gid = gid AND tb_useremail.playerDBID = playerDBID AND tb_useremail.emailID = emailID LIMIT 1) THEN
		INSERT tb_useremail(tb_useremail.gid, tb_useremail.playerDBID, tb_useremail.emailID, tb_useremail.content, tb_useremail.readflag, tb_useremail.emailstatus, tb_useremail.sendtime, tb_useremail.endtime, tb_useremail.ranking) VALUES(gid,playerDBID,emailID,content,readflag,emailstatus,sendtime,endtime,ranking);

	ELSE
		UPDATE tb_useremail SET tb_useremail.readflag = readflag, tb_useremail.emailstatus = emailstatus WHERE tb_useremail.gid = gid AND tb_useremail.playerDBID = playerDBID AND tb_useremail.emailID = emailID;
	END IF;
END//

DROP PROCEDURE IF EXISTS update_tb_databaseID //

CREATE PROCEDURE update_tb_databaseID(
	in gdatabaseid INT UNSIGNED,in dbkey VARCHAR(50)
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_databaseID WHERE tb_databaseID.dbkey=dbkey LIMIT 1) THEN
		INSERT tb_databaseID(tb_databaseID.gdatabaseid, tb_databaseID.dbkey) VALUES(gdatabaseid,dbkey);
	ELSE
		UPDATE tb_databaseID SET tb_databaseID.gdatabaseid = gdatabaseid WHERE tb_databaseID.dbkey=dbkey;
	END IF;
END//

/*更新玩家信息表*/
DROP PROCEDURE IF EXISTS update_tb_playerInfo //

CREATE PROCEDURE update_tb_playerInfo(
	in databaseID INT UNSIGNED,in isOnline TINYINT UNSIGNED,in playerSex TINYINT UNSIGNED,in playerName VARCHAR(50),in playerAccountID VARCHAR(50),in playerBirthTime INT UNSIGNED,in playerOfflineTime INT UNSIGNED,in playerLastOnlineTime INT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_playerInfo WHERE tb_playerInfo.databaseID=databaseID LIMIT 1) THEN
		INSERT tb_playerInfo VALUES(databaseID,isOnline,playerSex,playerName,playerAccountID,playerBirthTime,playerOfflineTime,playerLastOnlineTime);
	ELSE
		UPDATE tb_playerInfo SET tb_playerInfo.isOnline=isOnline,tb_playerInfo.playerLastOnlineTime=playerLastOnlineTime,tb_playerInfo.playerOfflineTime=playerOfflineTime WHERE tb_playerInfo.databaseID=databaseID;
	END IF;
END//

/*更新道具表*/
DROP PROCEDURE IF EXISTS update_tb_ItemProp//

CREATE PROCEDURE update_tb_ItemProp(
	in databaseID INT UNSIGNED, in playerDBID INT UNSIGNED,in itemID INT UNSIGNED,in itemQuality TINYINT UNSIGNED,in itemNumber INT UNSIGNED,in itemBagNum INT UNSIGNED,in itemposition TINYINT UNSIGNED
)
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM tb_ItemProp WHERE tb_ItemProp.databaseID=databaseID LIMIT 1) THEN
		INSERT tb_ItemProp VALUES(databaseID,playerDBID,itemID,itemQuality,itemNumber,itemBagNum,itemposition);
	ELSE
		UPDATE tb_ItemProp SET tb_ItemProp.itemQuality=itemQuality,tb_ItemProp.itemNumber=itemNumber,tb_ItemProp.itemBagNum=itemBagNum,tb_ItemProp.itemposition = itemposition WHERE tb_ItemProp.databaseID=databaseID;
	END IF;
END//

/*更新装备表*/
DROP PROCEDURE IF EXISTS update_tb_ItemEquip//

CREATE PROCEDURE update_tb_ItemEquip(
	in databaseID INT UNSIGNED, in playerDBID INT UNSIGNED,in itemID INT UNSIGNED,in itemQuality TINYINT UNSIGNED,in itemNumber INT UNSIGNED,in itemBagNum INT UNSIGNED,in itemposition TINYINT UNSIGNED,in itemStrengthenLevel SMALLINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_ItemEquip WHERE tb_ItemEquip.databaseID=databaseID LIMIT 1) THEN
		INSERT tb_ItemEquip VALUES(databaseID,playerDBID,itemID,itemQuality,itemNumber,itemBagNum,itemposition,itemStrengthenLevel);
	ELSE
		UPDATE tb_ItemEquip SET tb_ItemEquip.itemQuality=itemQuality,tb_ItemEquip.itemNumber=itemNumber,tb_ItemEquip.itemBagNum=itemBagNum,tb_ItemEquip.itemposition = itemposition,tb_ItemEquip.itemStrengthenLevel=itemStrengthenLevel WHERE tb_ItemEquip.databaseID=databaseID;
	END IF;
END//

/*更新建筑信息表*/
DROP PROCEDURE IF EXISTS update_tb_Build //

CREATE PROCEDURE update_tb_Build(
	in playerDBID INT UNSIGNED, in buildKey SMALLINT UNSIGNED, in buildID TINYINT UNSIGNED, in posX SMALLINT UNSIGNED, in posY SMALLINT UNSIGNED, in startTime INT UNSIGNED, in updateTime INT UNSIGNED, in buildLevel TINYINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_Build WHERE tb_Build.playerDBID=playerDBID AND tb_Build.buildKey=buildKey  LIMIT 1) THEN
		INSERT tb_Build(tb_Build.playerDBID,tb_Build.buildKey,tb_Build.buildID,tb_Build.PosX,tb_Build.PosY) VALUES(playerDBID, buildKey, buildID, posX, posY);
	ELSE
		UPDATE tb_Build SET tb_Build.PosX = posX, tb_Build.PosY = posY,tb_Build.buildLevel=buildLevel,tb_Build.startTime=startTime,tb_Build.updateTime=updateTime WHERE tb_Build.playerDBID = playerDBID AND tb_Build.buildKey = buildKey;
	END IF;
END//

/*更新人才分配信息表*/
DROP PROCEDURE IF EXISTS update_tb_PeopleManage //

CREATE PROCEDURE update_tb_PeopleManage(
	in playerDBID INT UNSIGNED, in allotType INT UNSIGNED, in allotNum TINYINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_PeopleManage WHERE tb_PeopleManage.playerDBID=playerDBID AND tb_PeopleManage.allotType=allotType  LIMIT 1) THEN
		INSERT tb_PeopleManage(tb_PeopleManage.playerDBID,tb_PeopleManage.allotType,tb_PeopleManage.allotNum) VALUES(playerDBID, allotType,allotNum);
	ELSE
		UPDATE tb_PeopleManage SET tb_PeopleManage.allotNum = allotNum WHERE tb_PeopleManage.playerDBID = playerDBID AND tb_PeopleManage.allotType=allotType;
	END IF;
END//

/*更新任务信息表*/
DROP PROCEDURE IF EXISTS update_tb_Task //

CREATE PROCEDURE update_tb_Task(
	in playerDBID INT UNSIGNED, in taskID INT UNSIGNED,in taskType TINYINT UNSIGNED, in taskState TINYINT UNSIGNED, in taskEnd TINYINT UNSIGNED,in taskProgress INT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_Task WHERE tb_Task.playerDBID=playerDBID AND tb_Task.taskID=taskID LIMIT 1) THEN
		INSERT tb_Task(tb_Task.playerDBID,tb_Task.taskID,tb_Task.taskType,tb_Task.taskState,tb_Task.taskEnd,tb_Task.taskProgress) VALUES(playerDBID,taskID,taskType,taskState,taskEnd,taskProgress);
	ELSE
		UPDATE tb_Task SET tb_Task.taskState=taskState,tb_Task.taskEnd=taskEnd,tb_Task.taskProgress=taskProgress WHERE tb_Task.playerDBID=playerDBID AND tb_Task.taskID=taskID;
	END IF;
END//

/*更新玩家属性表*/
DROP PROCEDURE IF EXISTS update_tb_PlayerProp //

CREATE PROCEDURE update_tb_PlayerProp(
	in playerDBID INT UNSIGNED, in playerLevel TINYINT UNSIGNED,in playerDiamond INT UNSIGNED,in playerCopper INT UNSIGNED, in playerRenKouTotal SMALLINT UNSIGNED
	, in rewardTimes TINYINT UNSIGNED, in rewardFlag TINYINT UNSIGNED, in bFreeTimes TINYINT UNSIGNED, in sFreeTimes TINYINT UNSIGNED, in sTotalTimes INT UNSIGNED, in playerBuyStatu INT UNSIGNED, in playerSystemState INT UNSIGNED
	, in playerBackpack SMALLINT UNSIGNED, in playerWaterBag SMALLINT UNSIGNED, in playerCarriage SMALLINT UNSIGNED, in playerAlchemy SMALLINT UNSIGNED, in playerBread SMALLINT UNSIGNED, in playerTalentState INT UNSIGNED, in achievementPoint SMALLINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_PlayerProp WHERE tb_PlayerProp.playerDBID=playerDBID LIMIT 1) THEN
		INSERT tb_PlayerProp VALUES(playerDBID,playerLevel,playerDiamond,playerCopper,playerRenKouTotal,rewardTimes,rewardFlag,bFreeTimes,sFreeTimes,sTotalTimes,playerBuyStatu,playerSystemState,playerBackpack,playerWaterBag,playerCarriage,playerAlchemy,playerBread,playerTalentState,achievementPoint);
	ELSE
		UPDATE tb_PlayerProp SET tb_PlayerProp.playerLevel=playerLevel,tb_PlayerProp.playerDiamond=playerDiamond,
		tb_PlayerProp.playerCopper=playerCopper,tb_PlayerProp.playerRenKouTotal=playerRenKouTotal,
		tb_PlayerProp.rewardTimes=rewardTimes,tb_PlayerProp.rewardFlag=rewardFlag,tb_PlayerProp.bFreeTimes=bFreeTimes,
		tb_PlayerProp.sFreeTimes=sFreeTimes,tb_PlayerProp.sTotalTimes=sTotalTimes,
		tb_PlayerProp.playerBuyStatu=playerBuyStatu,tb_PlayerProp.playerSystemState=playerSystemState,tb_PlayerProp.playerBackpack=playerBackpack,tb_PlayerProp.playerWaterBag=playerWaterBag,
		tb_PlayerProp.playerCarriage=playerCarriage,tb_PlayerProp.playerAlchemy=playerAlchemy,tb_PlayerProp.playerBread=playerBread,tb_PlayerProp.playerTalentState=playerTalentState,tb_PlayerProp.achievementPoint=achievementPoint
		 WHERE tb_PlayerProp.playerDBID=playerDBID;
	END IF;
END//

/*更新伙伴属性表*/
DROP PROCEDURE IF EXISTS update_tb_Hero //

CREATE PROCEDURE update_tb_Hero(
	in databaseID INT UNSIGNED, in playerDBID INT UNSIGNED, in heroID SMALLINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_Hero WHERE tb_Hero.databaseID=databaseID LIMIT 1) THEN
		INSERT tb_Hero VALUES(databaseID, playerDBID, heroID);
	ELSE
		UPDATE tb_Hero SET tb_Hero.heroID=heroID WHERE tb_Hero.databaseID=databaseID;
	END IF;
END//

/*更新探险表*/
DROP PROCEDURE IF EXISTS update_tb_Explore //

CREATE PROCEDURE update_tb_Explore(
	in playerDBID INT UNSIGNED,in nowBigMap TINYINT UNSIGNED,in ficthBigID VARCHAR(64), in ficthState VARCHAR(64), in bigMapIndex TINYINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_Explore WHERE tb_Explore.playerDBID=playerDBID LIMIT 1) THEN
		INSERT tb_Explore(tb_Explore.playerDBID,tb_Explore.nowBigMap,tb_Explore.ficthBigID,tb_Explore.ficthState, tb_Explore.bigMapIndex) VALUES(playerDBID, nowBigMap, ficthBigID, ficthState, bigMapIndex);
	ELSE
		UPDATE tb_Explore SET tb_Explore.nowBigMap=nowBigMap,tb_Explore.ficthBigID=ficthBigID,tb_Explore.ficthState=ficthState,tb_Explore.bigMapIndex=bigMapIndex WHERE tb_Explore.playerDBID=playerDBID;
	END IF;
END//

/*更新竞技场*/
DROP PROCEDURE IF EXISTS update_tb_Arena //

CREATE PROCEDURE update_tb_Arena(
	in playerDBID INT UNSIGNED,in arenaRank SMALLINT UNSIGNED
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_Arena WHERE tb_Arena.playerDBID=playerDBID LIMIT 1) THEN
		INSERT tb_Arena(tb_Arena.playerDBID,tb_Arena.arenaRank) VALUES(playerDBID, arenaRank);
	ELSE
		UPDATE tb_Arena SET tb_Arena.arenaRank=arenaRank WHERE tb_Arena.playerDBID=playerDBID;
	END IF;
END//


delimiter ;