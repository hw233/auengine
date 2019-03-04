--ExploreFun.lua

local ExploreFun = {}

--�����������to client
function ExploreFun:send_enterSpace_toClient( playerID, second_space_id, msgID )
	Au.messageToClientBegin(playerID, msgID)
	Au.addUint16(second_space_id)
	Au.messageEnd()
	print("enter second_space_id", second_space_id)
end

--������Ʒ�ķ���(@fromID 0:���� 1:���� 2:������ @eventID ����ID,����ID,0)
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
	print("������Ʒ:", fromID, eventID, dropTBLen)
end

--ʰȡto client
function ExploreFun:send_pickItem_toClient(playerID)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_PICKUPITEM)
	Au.addUint8(1)
	Au.messageEnd()
end

--ͨ��to client
function ExploreFun:send_passSpace_toClient( playerID, second_space_id, isPassID, nextBigMapID )
	-- body
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_PASSSPACE)
	Au.addUint16(second_space_id)
	Au.addUint8(isPassID)
	Au.addUint8(nextBigMapID)
	Au.messageEnd()
	print("ͨ��:", isPassID)
end

--ͬ��to client
function ExploreFun:send_syncPos_toClient( playerID, water )
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_SYNCPOS)
	Au.addUint8(water)
	Au.messageEnd()	
end

--�س�to client
function ExploreFun:send_comeBackCity_toClient( playerID, comeBackType )
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_EXPLORE_BACKCITY)
	Au.addUint8( comeBackType )
	Au.messageEnd()
end

--����to client
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