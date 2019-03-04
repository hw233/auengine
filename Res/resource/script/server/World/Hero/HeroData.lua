--HeroData.lua

HeroData = {}

function HeroData:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.heroID = 0			--实体ID
	self.currentHp = 0		--当前血量
	self.heroName = ""		--名字
	
	self.hp = 0				--最大血量
	self.att = 0			--攻击力
	self.attSpeed = 0		--攻击速度
	self.hitNum = 0			--命中率
	self.dodgeNum = 0		--闪避
	self.strikeNum = 0		--暴击率
	self.strikeHurt = 0		--暴击伤害
	self.skillID = 0		--技能ID
	
	return object
end