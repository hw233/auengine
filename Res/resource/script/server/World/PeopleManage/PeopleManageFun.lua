--PeopleManageFun.lua
--人才分配的接口
local PeopleManageFun = {}

function PeopleManageFun.onStepRequestTime( playerID, leaveTime )
	-- body
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_PEOPLEMANAGE_ONSTEP)
	Au.addUint8(leaveTime)
	Au.messageEnd()
end

function PeopleManageFun.sendAllotRenKouToClient( playerID, allotType, renKouNum, AllotRenKou )
	-- body
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_PEOPLEMANAGE_ALLOTRENKOU)
	Au.addUint32(allotType)
	Au.addUint16(renKouNum)
	Au.addUint32(AllotRenKou)
	Au.messageEnd()
end

return {PeopleManageFun = PeopleManageFun}