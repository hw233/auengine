--BoxCtrl.lua
require "resource.script.server.Config.BoxReward.BOXSPECIAL"
require "resource.script.server.Config.BoxReward.BOXTYPE"
require "resource.script.server.Config.BoxReward.BOXREWARD"

--�궨��
local BOXMACRO = {}
BOXMACRO.BRONZE = 1    					-- ��ͭ����
BOXMACRO.SILVER = 2    					-- �������� 
BOXMACRO.GOLD = 3      					-- �ƽ���
BOXMACRO.BRONZECONSUME = 10000			-- ��ͭ�������Ľ������
BOXMACRO.SILVERCONSUME = 200			-- ��������������ʯ����200
BOXMACRO.GOLDCONSUME = 1800				-- �ƽ���������ʯ����1800
BOXMACRO.PETLIMIT = 3                   -- ���λƽ����ȡ��õĳ���������޲�����3��
BOXMACRO.TIMES = 10                     -- ��������ÿ��10�αصó���
BOXMACRO.PETTYPE = 2                    -- ������(��Ʒ����Ϊ2�����ڳ���)
BOXMACRO.PETID = 1008                   -- ���������һ�λ�õĳ���id

BoxCtrl = {}

function BoxCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.bFreeTimes = 5     --��ͭ���������ȡ����
	self.sFreeTimes = 1     --�������������ȡ����
	self.sTotalTimes = 0    --���������ۻ���ȡ����(�����ȡ�Ĵ�������)
	self.firstTime = 0      --��һ��ʹ�ð�������س�����
	
	return obj
end

--�賿���������ȡ����
function BoxCtrl:UpdateBoxTimes()
	self.bFreeTimes = 5
	self.sFreeTimes = 1
	self:SendBoxFreeTimes()
end

--���������ȡ����
function BoxCtrl:SendBoxFreeTimes()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_BOX_BOXFREETIMES)
	Au.addUint8(self.firstTime)
	Au.addUint8(self.bFreeTimes)
	Au.addUint8(self.sFreeTimes)
	Au.addUint32(self.sTotalTimes)
	Au.messageEnd()
end

--��ȡ���ó�ȡ��Ʒ
function BoxCtrl:ReadCfgFile(boxID)
	local boxType = "BOX_"..boxID
	local ItemCfg = BOXTYPE[boxType]
	if isEmpty(ItemCfg) then
		return
	end
	
	local randomNum = 0
	local TB = ItemCfg["QZ"]
	local index = BoxCtrl:getIndex(TB)
	local typeID = ItemCfg["TYPE"][index]
	local itemList = self:getRewardItem(typeID)  --�齱
	
	return itemList
	
end

--��ȡ����±����Ʒ�±�
function BoxCtrl:getIndex(TB)
	local itemIndex = 0
	while itemIndex == 0 do
		local tempValue = 0
		randomNum = AuRandom(1, 100)
		for key, value in pairs(TB) do
			tempValue = tempValue + value
			if randomNum <= tempValue then
				itemIndex = key
				break
			end
		end
	end
	
	return itemIndex
end

--��ȡ��Ʒ
function BoxCtrl:getRewardItem(typeID)
	local  rewardType = "REWARD_"..typeID
	local cfg = BOX_REWARD[rewardType]
	local rewardTB = cfg["INDEX"]
	local itemIndex = 0
	itemIndex = BoxCtrl:getIndex(rewardTB)
	
	local itemList = cfg["ITEM_"..itemIndex]
	if isEmpty(itemList) then
		return
	end

	return itemList
end

--���������ص���Ʒ
function BoxCtrl:getSilverPet(boxID)
	local index = 0
	local typeID = 0
	local TB = 0
	local boxTpye = "BOX_"..boxID
	local cfg = BOXSPECIAL[boxTpye]
	if boxID == BOXMACRO.SILVER then    --��������(�ۼƳ齱10�ȵ�һ������)
		TB = cfg["PETQZ"]
		index = BoxCtrl:getIndex(TB)
		typeID = cfg["PET"][index]
	elseif boxID == BOXMACRO.GOLD then   --�ƽ���(�ۼƳ���3�������ֻ�ܻ�ȡ��Ʒ)
		TB = cfg["ITMEQZ"]
		index = BoxCtrl:getIndex(TB)
		typeID = cfg["ITEM"][index]
	end
	
	local itemList = BoxCtrl:getRewardItem(typeID)
	return itemList

end

--�ƽ���ص�һ������
function BoxCtrl:getGoldPet(boxID)
	local index = 0
	local typeID = 0
	local TB = 0
	local boxTpye = "BOX_"..boxID
	local cfg = BOXSPECIAL[boxTpye]
	TB = cfg["PETQZ"]
	index = BoxCtrl:getIndex(TB)
	typeID = cfg["PET"][index]
	local itemList = BoxCtrl:getRewardItem(typeID)
	
	return itemList
	
end

--��ͭ����齱����
function BoxCtrl:BronzeOperator(boxID)
	if self.bFreeTimes <= 0 then    
		if not self:subPlayerCopper(BOXMACRO.BRONZECONSUME) then	--���Ľ��
			return
		end
		self.bFreeTimes = 0
	else
		self.bFreeTimes = self.bFreeTimes - 1
	end
	
	local Item = BoxCtrl:ReadCfgFile(boxID)   -- ��ȡ���ó�ȡһ��������Ʒ
	self:createItemList(Item)                 -- ������Ʒ
	
	self:SendBoxReward(Item)                   --�ظ��ͻ��� 
	
end

--��������齱����
function BoxCtrl:SilverOperator(boxID)
	local Item = 0
	if self.firstTime == 0 then     
		local Item = {{BOXMACRO.PETTYPE, BOXMACRO.PETID},}
		self.sFreeTimes = self.sFreeTimes - 1
		self.firstTime = 1                     -- ��һ���Ѿ�ʹ��
		self:createItemList(Item)              -- ������Ʒ 
		self:SendBoxReward(Item)               -- �ظ��ͻ���
		return
	end
	
	if self.sFreeTimes <= 0 then  
		if not self:subPlayerDiamond(BOXMACRO.SILVERCONSUME) then    --���ı�ʯ
			return
		end
		self.sTotalTimes = self.sTotalTimes + 1
		if self.sTotalTimes % BOXMACRO.TIMES == 0 then
			Item = self:getSilverPet(boxID)         --��ʮ�αصó���
			self.sTotalTimes = 0
		else
			Item = BoxCtrl:ReadCfgFile(boxID)
		end
	else
		self.sFreeTimes = self.sFreeTimes - 1
		Item = BoxCtrl:ReadCfgFile(boxID)
	end
	self:createItemList(Item)              --������Ʒ 
	self:SendBoxReward(Item)               --�ظ��ͻ��� 
	
end

--�ƽ���齱����
function BoxCtrl:GOLDOperator(boxID)
	if not self:subPlayerDiamond(BOXMACRO.GOLDCONSUME) then
		return
	end
	
	local ItemList = {}
	local Item = self:getGoldPet(boxID)  --�ص�һ������
	local petNum = 1
	table.insert(ItemList, Item)
	for i = 1, 9 do
		if petNum >= BOXMACRO.PETLIMIT then
			Item = self:getSilverPet(boxID)
		else
			Item = BoxCtrl:ReadCfgFile(boxID)
			for _, item in pairs(Item) do
				if item[1] == BOXMACRO.PETTYPE then   -- ����
					petNum = petNum + 1
				end
			end
		end
		table.insert(ItemList, Item)
	end
	
	for _, obj in pairs(ItemList) do
		self:createItemList(obj)      --������Ʒ
	end
	
	self:SendGoldBoxReward(ItemList)  --�ظ��ͻ��� 
	
end

--�ظ��ͻ��˳鵽����Ʒ
function BoxCtrl:SendBoxReward(item)
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_BOX_BOXREWARD)
	for k, value in pairs(item) do
		Au.addUint8(value[1])
		Au.addUint32(value[2])
		Au.addUint8(value[3] or 0)
	end
	Au.messageEnd()
end

--���ͻƽ�����Ʒ
function BoxCtrl:SendGoldBoxReward(itemList)
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_BOX_BOXREWARD)
	for _, item in pairs(itemList) do
		for k, value in pairs(item) do
			Au.addUint8(value[1])
			Au.addUint32(value[2])
			Au.addUint8(value[3] or 0)
		end
	end
	Au.messageEnd()
end

--�齱
function BoxCtrl:getBoxReward(boxID)
	if boxID == BOXMACRO.BRONZE then
		self:BronzeOperator(boxID)
		
	elseif boxID == BOXMACRO.SILVER then
		self:SilverOperator(boxID)
		
	elseif boxID == BOXMACRO.GOLD then
		self:GOLDOperator(boxID)
	
	else
		print("error!!")
		return
	end

end


--�ͻ���API
--�鱦��
function World_BoxCtrl_getBoxReward(playerID, boxID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	_player:getBoxReward(boxID)
	
end

--������ѳ齱����
function World_BoxCtrl_SendBoxFreeTimes(playerID, bool)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	_player:SendBoxFreeTimes()
	
end



