--The file Lua Engine load first.
print("in robot main.lua");
ROBOT_MOUDLE = 4
function scriptInit()
	print("Here, Robot initialize all script file.")
end

function initEngine()
	print("In  initEngine")
	Au.RegisterModule(ROBOT_MOUDLE);--4代表机器人模块,可根据需要改成字符串(引擎代码做修改)
	Au.CreateRobots(1);--Create One Robots.
	--Au.RobotStart();
	Au.StartModule(ROBOT_MOUDLE)
end

function ResOfAandB_Robot_2020(playerid, res)
	print("%%%%%%%%%The result is: "..res)
end

function RobotThreadCallFunc(sockfd)
	print("sockfd:"..sockfd)
	Au.messageBegin(sockfd, 11112) --交给主服务器去处理11112这个消息。
	--Au.addString("hello ")
	Au.addString("world  ")
	Au.addString("world1 ")
	Au.addString("world2 ")
	Au.addInt32(10101)
	Au.messageEnd()
end 



