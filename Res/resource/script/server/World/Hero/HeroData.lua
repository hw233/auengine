--HeroData.lua

HeroData = {}

function HeroData:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.heroID = 0			--ʵ��ID
	self.currentHp = 0		--��ǰѪ��
	self.heroName = ""		--����
	
	self.hp = 0				--���Ѫ��
	self.att = 0			--������
	self.attSpeed = 0		--�����ٶ�
	self.hitNum = 0			--������
	self.dodgeNum = 0		--����
	self.strikeNum = 0		--������
	self.strikeHurt = 0		--�����˺�
	self.skillID = 0		--����ID
	
	return object
end