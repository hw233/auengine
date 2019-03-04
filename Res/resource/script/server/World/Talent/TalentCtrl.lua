--TalentCtrl.lua
require "resource.script.server.Config.Talent.TALENTCONFIG"
require "resource.script.server.Config.Talent.TALENT_ACHIEVEMENT"

TalentCtrl = {}

function TalentCtrl:New(  )
	-- body
	local object = setmetatable( {}, self)
	self.__index = self
	self.talentState = 0		--天赋状态
	return object
end

--成就点激活天赋
function TalentCtrl:achOpenPlayerTalent()
	local talentID = 0
	local talentIndex = 0
	if self.achievementPoint >= 80 then
		talentIndex = 80
	elseif self.achievementPoint >= 60 then
		talentIndex = 60
	elseif self.achievementPoint >= 40 then
		talentIndex = 40
	elseif self.achievementPoint >= 20 then
		talentIndex = 20
	end
	talentID = (talentIndex ~= 0) and TALENT_ACHIEVEMENT["ACHI_"..talentID] or 0
	if talentID ~= 0 then
		self:openPlayerTalent( talentID )
	end
end

--激活天赋(@param talentID 天赋ID @return 无)
function TalentCtrl:openPlayerTalent( talentID )
	local talentIndex = talentID%100
	self.talentState = Au.bitAddState(self.talentState, talentIndex)
	sendSystemMsg(self.playerID, "恭喜你获得了["..talentID.."]天赋")
	TaskBase:completeStudyTalent( self, talentID )
end

--发送给客户端
function TalentCtrl:sendTalentToClient()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_TALENT_INFO)
	Au.addUint32(self.talentState)
	Au.messageEnd()	
end

--检测天赋开放(@param talentID 天赋ID @return true false)
function TalentCtrl:checkPlayerTalent( talentID )
	local talentIndex = talentID%100
	if Au.bitCheckState(self.talentState, talentIndex) == 1 then
		return false
	end
	local cfg = TALENTCONFIG["TALENT_"..talentID]
	if isEmpty(cfg) then
		return false
	end
	if self:checkPrecondition(cfg["OPEN"]) == false then
		return false
	end
	self:addEvet(talentID)
	return true
end
