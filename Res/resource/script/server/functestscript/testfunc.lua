
function TestFunc_MsgID_2020(playerid, A, B)

	--print("***Receive A:"..A.." B:"..B.." From".." playerid:"..playerid)
	local res_sockfd=Au.GetSockfdByServerName("CalcServer")
	Au.messageBegin(res_sockfd, 2021)
	Au.addUint32(playerid)
	Au.addInt32(A)
	Au.addInt32(B)
	Au.messageEnd()
end

function CalcOFAandB_MsgID_2021(sendersockid,playerid, calres)
	--print("Received the msg from CalcServer")
	--Here, The MsgID must be 2020, because the player send A and B through msg id 2020 , so The Server send The MSGID:2020 too.
	Au.messageBegin(playerid, 2020)
	Au.addInt32(calres)
	Au.messageEnd()
end

function SavePlayerInfoToMemcached(key, data)
	Au.MemcachedSet(key, data, string.len(data))
end 

function TestLuaStringStringFunction(sockfd,STR,STR2,STR3,num)
	--print("sockfd:"..sockfd)
--	print("STR:"..STR)
--	print("STR2:"..STR2)
--	print("STR3:"..STR3)
	--print("str1: "..string(str1))
--	print("num:"..num)
	--print("str2: "..str2)
end 

function TimerFunc()
	print("TimerFunc")
end 


function TestVariableParaBool(boolvalue)
	if boolvalue then 
		print("+++++++++++++++boolvalue true")
	else
		print("---------------boolvalue false")
	end 
	
end 

function TestVariParaChar(charvalue)
	print("charvalue:"..charvalue)
end 

function TestVariParaBoolIntChar(boolvalue, intvalue, charvalue)
	print("boolvalue:"..boolvalue.." intvalue:"..intvalue.." charvalue:"..charvalue)
end 