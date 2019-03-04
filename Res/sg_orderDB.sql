/*创建数据库可以修改 */
DROP DATABASE IF EXISTS mg_order_db;
create database if not exists mg_order_db default character set utf8;
set character_set_server=utf8;
set character_set_database=utf8;
set character_set_connection = utf8;
set names utf8;
use mg_order_db;

CREATE TABLE account(
`accountID` INT AUTO_INCREMENT PRIMARY KEY,
`accountName` VARCHAR(100) NOT NULL COMMENT '帐号ID',
`VerifyKey` INT UNSIGNED NOT NULL COMMENT '帐号验证码',
`login` TINYINT UNSIGNED NOT NULL COMMENT '登录状态 0:刚进,2:开始创建角色,1:成功',
`server_id` VARCHAR(100) NOT NULL DEFAULT "" COMMENT '服务器ID',
`union_id` VARCHAR(100) NOT NULL DEFAULT "" COMMENT '运营商ID',
`coil` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '总共充值数',
`activeTime` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '有效时间',
`firstTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_GameState(
`ID` INT AUTO_INCREMENT PRIMARY KEY,
`server_id` VARCHAR(100) NOT NULL DEFAULT "",
`union_id` VARCHAR(100) NOT NULL DEFAULT "",
`GameState` TINYINT UNSIGNED NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;




delimiter //

/*保存服务器状态*/
DROP PROCEDURE IF EXISTS saveServerState //
CREATE PROCEDURE saveServerState(
	in serverID VARCHAR(100),in unionID VARCHAR(100),in gameState TINYINT
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tb_GameState WHERE tb_GameState.server_id=serverID AND tb_GameState.union_id=unionID) THEN
		INSERT tb_GameState(tb_GameState.server_id,tb_GameState.union_id,tb_GameState.GameState) VALUES(serverID,unionID,gameState);
	ELSE
		UPDATE tb_GameState SET tb_GameState.GameState=gameState WHERE tb_GameState.server_id=serverID AND tb_GameState.union_id=unionID;
	END IF;
END//

delimiter ;