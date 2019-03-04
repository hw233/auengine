--BuildFun.lua
require "resource.script.server.Config.Build.PRODUCTIONUSE"
require "resource.script.server.Config.Build.BUILDUSE"
require "resource.script.server.Config.Build.DEFAULTVALUE"
require "resource.script.server.Config.Build.BUYPEOPLE"

local BuildFun = {}

BUILD_TYPE = {}
BUILD_TYPE.TYPE_MINGFANG = 1         --��
BUILD_TYPE.TYPE_HUAMUCHANG = 2       --����
BUILD_TYPE.TYPE_CHUFANG = 3			 --�̵�
BUILD_TYPE.TYPE_BULIEWU = 4			 --������
BUILD_TYPE.TYPE_YINGXIONGDIAN = 5	 --Ӣ�۵�
BUILD_TYPE.TYPE_LIANJINLU = 6		 --����¯
BUILD_TYPE.TYPE_CANGKU = 7			 --�ֿ�

function BuildFun:get_BuildUseCfg(buildID, buildNum)
	return BUILDUSE["BUILD_"..buildID][buildNum]
end

--��ȡ����
function BuildFun:get_ProUsePre(sourceID)
	return PRODUCTIONUSE["SOURCE_"..sourceID]
end

--��Ӷ����
function BuildFun:get_HireUse(_times)
	return BUYPEOPLE["BUYPEOPLE_".._times]
end

--�ж�ǰ�ú���Դ����
function BuildFun:checkPrePostion(buildID, playerOBJ, buildNum)
	local buildCfg = BuildFun:get_BuildCfg(buildID)
	if isEmpty(buildCfg) then
		return false
	end
	local buildMax = buildCfg["MAXLIMIT"]
	if buildNum >= buildMax then
		return false
	end
	local preCfg = buildCfg["PRE"]--ǰ������
	if playerOBJ:checkPrecondition( preCfg ) == false then
		return false
	end
	local sourceCfg = BuildFun:get_BuildUseCfg(buildID, buildNum+1)--��Դ����
	if playerOBJ:checkOutAndTakeawaySource( sourceCfg ) == false then
		return false
	end
	return true
end

--��ȡĬ������
function BuildFun:readDeafultValue()
	return DEFAULTVALUE
end

--��������to client
function BuildFun:sendBuildToClient(playerID, index, x, y, buildType, leaveTime, buildLevel)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_CREATE_BUILD)
	Au.addUint16(index)
	Au.addUint8(buildType)
	Au.addUint16(x)
	Au.addUint16(y)
	Au.addUint8(buildLevel)
	Au.addUint16(leaveTime)
	Au.messageEnd()
end

--�����˿�to client
function BuildFun:send_update_renkou(playerID, totalRK, allotRK)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_UPDATE_RENKOU)
	Au.addUint16(totalRK)
	Au.addUint16(allotRK)
	Au.messageEnd()
end

--����ʣ��ʱ��to client
function BuildFun:sendCollectWoodToClient(playerID, leaveTime)
	Au.messageToClientBegin(playerID, MacroMsgID.MSG_ID_COLLECT_WOOD)
	Au.addUint8(leaveTime)
	Au.messageEnd()
end

return {BuildFun = BuildFun}
