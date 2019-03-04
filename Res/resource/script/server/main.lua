--The file Lua Engine load first.
require "resource.script.server.World.Game"
require "resource.script.server.Common.GData"
require "resource.script.server.functestscript.testfunc"
--先初始化引擎，再初始化脚本
print("in main.lua");
function initEngine()
	print("In  initEngine")
	--Revoke the C interface.
	Au.Listen()--
	
	if Au.RegisterModule(6) then --Memcached Module
		print("Register Memcached Successed.")
	else 
		print("Register Memcached Failured")
		return 
	end 
	if Au.StartModule(6) then 
		print("Memcched Module Start Successed.")
	else
		print("Memcached module Start Failured.")
	end 
	
	if Au.RegisterModule(8) then --GameConsole Module
		print("Register GameConsoleModule Successed")
	else 
		print("Register GameConsoleModule Failured")
		return 
	end
	if Au.StartModule(8) then 
		print("GameConsole Module Start Successed.")
	else
		print("GameConsole module Start Failured.")
	end 
	
	if Au.RegisterModule(5) then --Mysql Module
		print("Register MySqlModule Successed")
	else 
		print("Register MySqlModule Failured")
		return 
	end
	if Au.StartModule(5) then 
		print("MySqlModule Module Start Successed.")
	else
		print("MySqlModule module Start Failured.")
	end 
	
	--MemcachedTest()
end

function scriptInit()
	print("Here, initialize all script file.")
	
	init()
end

function init()		--游戏入口
	Game:init()
end

function onPlayerConnect( ID,playerID,accountID,clientIP,ValidateKey) -- 玩家上线
	print("id:"..ID.."playerID:"..playerID.."accountID:"..accountID.."clientIP:"..clientIP.."ValidateKey:"..ValidateKey)
	Game:onPlayerConnect( playerID, accountID,clientIP,ValidateKey)
end

function onPlayerDisconnect(ID,playerID,accountID) -- 玩家下线
	Game:onPlayerDisconnect( playerID,accountID)
end

function onTimer(timerFunc,timerparam1,timerparam2) -- 计时器回调
	loadstring(string.format("%s(%s,%s)",timerFunc,timerparam1,timerparam2))()
end

