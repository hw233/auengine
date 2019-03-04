
print("in calcserver main.lua");

function scriptInit()
	print("Here, CalcServer initialize all script file.")
end

function initEngine()
	Au.ConnectToServer("Server");
end

function CalcAandB_2021(sendersockfd, clientsockfd, A, B)
	print("Received A:"..A.." B:"..B.." from: "..clientsockfd)
	Au.messageBegin(sendersockfd, 2021)
	Au.addUint32(clientsockfd)
	Au.addInt32(A+B)
	Au.messageEnd()
end

