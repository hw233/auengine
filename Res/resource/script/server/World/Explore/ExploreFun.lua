--ExploreFun.lua

local ExploreFun = {}

--进入二级副本to client
function ExploreFun:send_enterSpace_toClient( playerID, second_space_id, msgID )
	Au.messageToClientBegin(playerID, msgID)
	Au.addUint16(second_space_id)
	Au.messageEnd()
	print("enter second_space_id", second_space_id)
end

--掉落物品的发送(@fromID 0:副本 1:暗雷 2:补给点 @eventID 层数ID,暗雷ID,0)
function ExploreFun:send_supplyPoint_toClient( playerID, fromID, eventID, dropItemTB )
	local dropTBLen = 0
	if not isEmpty(dropItemTB) then
		dropTBLen = table.getn(dropItemTB)
	end
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_DROPITEM)
	Au.addUint8( fromID )
	Au.addUint32( eventID )
	Au.addUint8(dropTBLen)
	for i=1,dropTBLen do
		Au.addUint8(dropItemTB[i][1])
		Au.addUint32(dropItemTB[i][2])
		Au.addUint16(dropItemTB[i][3] or 0)
	end
	Au.messageEnd()
	print("掉落物品:", fromID, eventID, dropTBLen)
end

--拾取to client
function ExploreFun:send_pickItem_toClient(playerID)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_PICKUPITEM)
	Au.addUint8(1)
	Au.messageEnd()
end

--通关to client
function ExploreFun:send_passSpace_toClient( playerID, second_space_id, isPassID, nextBigMapID )
	-- body
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_PASSSPACE)
	Au.addUint16(second_space_id)
	Au.addUint8(isPassID)
	Au.addUint8(nextBigMapID)
	Au.messageEnd()
	print("通关:", isPassID)
end

--同步to client
function ExploreFun:send_syncPos_toClient( playerID, water )
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_SYNCPOS)
	Au.addUint8(water)
	Au.messageEnd()	
end

--回城to client
function ExploreFun:send_comeBackCity_toClient( playerID, comeBackType )
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_BACKCITY)
	Au.addUint8( comeBackType )
	Au.messageEnd()
end

--阵型to client
function ExploreFun:send_formation_toClient( playerID, formation )
	if isEmpty(formation) then
		return
	end
	
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_SENDPETFORMATION)
	for i = 1, #formation do
		Au.addUint32(formation[i])
	end
	Au.messageEnd()
end

return {ExploreFun = ExploreFun}