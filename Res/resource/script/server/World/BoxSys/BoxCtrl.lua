--BoxCtrl.lua
require "resource.script.server.Config.BoxReward.BOXSPECIAL"
require "resource.script.server.Config.BoxReward.BOXTYPE"
require "resource.script.server.Config.BoxReward.BOXREWARD"

--宏定义
local BOXMACRO = {}
BOXMACRO.BRONZE = 1    					-- 青铜宝箱
BOXMACRO.SILVER = 2    					-- 白银宝箱 
BOXMACRO.GOLD = 3      					-- 黄金宝箱
BOXMACRO.BRONZECONSUME = 10000			-- 青铜宝箱消耗金币数量
BOXMACRO.SILVERCONSUME = 200			-- 白银宝箱消耗钻石数量200
BOXMACRO.GOLDCONSUME = 1800				-- 黄金宝箱消耗钻石数量1800
BOXMACRO.PETLIMIT = 3                   -- 单次黄金宝箱抽取获得的宠物个数上限不超过3个
BOXMACRO.TIMES = 10                     -- 白银宝箱每够10次必得宠物
BOXMACRO.PETTYPE = 2                    -- 宠物类(物品类型为2的属于宠物)
BOXMACRO.PETID = 1008                   -- 白银宝箱第一次获得的宠物id

BoxCtrl = {}

function BoxCtrl:New()
	local obj = setmetatable({}, self)
	self.__index = self
	self.bFreeTimes = 5     --青铜宝箱免费领取次数
	self.sFreeTimes = 1     --白银宝箱免费领取次数
	self.sTotalTimes = 0    --白银宝箱累积领取次数(免费领取的次数除外)
	self.firstTime = 0      --第一次使用白银宝箱必出宠物
	
	return obj
end

--凌晨更新免费领取次数
function BoxCtrl:UpdateBoxTimes()
	self.bFreeTimes = 5
	self.sFreeTimes = 1
	self:SendBoxFreeTimes()
end

--发送免费领取次数
function BoxCtrl:SendBoxFreeTimes()
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_BOX_BOXFREETIMES)
	Au.addUint8(self.firstTime)
	Au.addUint8(self.bFreeTimes)
	Au.addUint8(self.sFreeTimes)
	Au.addUint32(self.sTotalTimes)
	Au.messageEnd()
end

--读取配置抽取物品
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
	local itemList = self:getRewardItem(typeID)  --抽奖
	
	return itemList
	
end

--获取类别下标或物品下标
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

--抽取物品
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

--满足条件必得物品
function BoxCtrl:getSilverPet(boxID)
	local index = 0
	local typeID = 0
	local TB = 0
	local boxTpye = "BOX_"..boxID
	local cfg = BOXSPECIAL[boxTpye]
	if boxID == BOXMACRO.SILVER then    --白银宝箱(累计抽奖10比得一个宠物)
		TB = cfg["PETQZ"]
		index = BoxCtrl:getIndex(TB)
		typeID = cfg["PET"][index]
	elseif boxID == BOXMACRO.GOLD then   --黄金宝箱(累计出现3个宠物后，只能获取物品)
		TB = cfg["ITMEQZ"]
		index = BoxCtrl:getIndex(TB)
		typeID = cfg["ITEM"][index]
	end
	
	local itemList = BoxCtrl:getRewardItem(typeID)
	return itemList

end

--黄金宝箱必得一个宠物
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

--青铜宝箱抽奖操作
function BoxCtrl:BronzeOperator(boxID)
	if self.bFreeTimes <= 0 then    
		if not self:subPlayerCopper(BOXMACRO.BRONZECONSUME) then	--消耗金币
			return
		end
		self.bFreeTimes = 0
	else
		self.bFreeTimes = self.bFreeTimes - 1
	end
	
	local Item = BoxCtrl:ReadCfgFile(boxID)   -- 读取配置抽取一个奖励物品
	self:createItemList(Item)                 -- 生成物品
	
	self:SendBoxReward(Item)                   --回复客户端 
	
end

--白银宝箱抽奖操作
function BoxCtrl:SilverOperator(boxID)
	local Item = 0
	if self.firstTime == 0 then     
		local Item = {{BOXMACRO.PETTYPE, BOXMACRO.PETID},}
		self.sFreeTimes = self.sFreeTimes - 1
		self.firstTime = 1                     -- 第一次已经使用
		self:createItemList(Item)              -- 生成物品 
		self:SendBoxReward(Item)               -- 回复客户端
		return
	end
	
	if self.sFreeTimes <= 0 then  
		if not self:subPlayerDiamond(BOXMACRO.SILVERCONSUME) then    --消耗宝石
			return
		end
		self.sTotalTimes = self.sTotalTimes + 1
		if self.sTotalTimes % BOXMACRO.TIMES == 0 then
			Item = self:getSilverPet(boxID)         --第十次必得宠物
			self.sTotalTimes = 0
		else
			Item = BoxCtrl:ReadCfgFile(boxID)
		end
	else
		self.sFreeTimes = self.sFreeTimes - 1
		Item = BoxCtrl:ReadCfgFile(boxID)
	end
	self:createItemList(Item)              --生成物品 
	self:SendBoxReward(Item)               --回复客户端 
	
end

--黄金宝箱抽奖操作
function BoxCtrl:GOLDOperator(boxID)
	if not self:subPlayerDiamond(BOXMACRO.GOLDCONSUME) then
		return
	end
	
	local ItemList = {}
	local Item = self:getGoldPet(boxID)  --必得一个宠物
	local petNum = 1
	table.insert(ItemList, Item)
	for i = 1, 9 do
		if petNum >= BOXMACRO.PETLIMIT then
			Item = self:getSilverPet(boxID)
		else
			Item = BoxCtrl:ReadCfgFile(boxID)
			for _, item in pairs(Item) do
				if item[1] == BOXMACRO.PETTYPE then   -- 宠物
					petNum = petNum + 1
				end
			end
		end
		table.insert(ItemList, Item)
	end
	
	for _, obj in pairs(ItemList) do
		self:createItemList(obj)      --生成物品
	end
	
	self:SendGoldBoxReward(ItemList)  --回复客户端 
	
end

--回复客户端抽到的物品
function BoxCtrl:SendBoxReward(item)
	Au.messageToClientBegin(self.playerID, MacroMsgID.MSG_ID_BOX_BOXREWARD)
	for k, value in pairs(item) do
		Au.addUint8(value[1])
		Au.addUint32(value[2])
		Au.addUint8(value[3] or 0)
	end
	Au.messageEnd()
end

--发送黄金宝箱物品
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

--抽奖
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


--客户端API
--抽宝箱
function World_BoxCtrl_getBoxReward(playerID, boxID)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	_player:getBoxReward(boxID)
	
end

--请求免费抽奖次数
function World_BoxCtrl_SendBoxFreeTimes(playerID, bool)
	local _player = Player:getPlayerFromID(playerID)
	if isEmpty(_player) then
		return
	end
	
	_player:SendBoxFreeTimes()
	
end



