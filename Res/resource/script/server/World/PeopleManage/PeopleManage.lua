--PeopleManage.lua
local buildFun = require "resource.script.server.World.Build.BuildFun"

PeopleManage = {}

function PeopleManage:New()
	-- body
	local object = setmetatable({}, self)
	self.__index = self
	self.allotType = 0		--分配类型
	self.allotRenKouNum = 0	--分配人口
	return object
end

function PeopleManage:WritePeopleManage(playerDBID)
		Au.queryQueue("CALL update_tb_PeopleManage("..playerDBID..","
			..self.allotType..","
			..self.allotRenKouNum..");")
end

function PeopleManage:allotRenkou( allotRenkou, allotType )
	-- body
	self.allotType = allotType
	self.allotRenKouNum = self.allotRenKouNum + allotRenkou
end

--置空分配人口
function PeopleManage:set_RenKouNumNull()
	self.allotRenKouNum = 0
end

--资源计算
function PeopleManage:countOtherSourceOutPut( playerOBJ, _min)
	-- body
	local useCfg = buildFun.BuildFun:get_ProUsePre(self.allotType)
	local rate = useCfg["BASERATE"]
	local produreNum = _min*self.allotRenKouNum*rate--正常产出的量
	local factProdureNum = produreNum				--实际产出的量
	local factUseNum = 0							--实际消耗的量

	for __,tb in pairs(useCfg["USE"]) do
		if tb[1] ~= 0 then
			local itemID = tb[2]
			local itemNum = tb[3]
			local itemCount = playerOBJ:getItemSum(itemID)	--总的资源量
			local totalUse = itemNum*produreNum				--总的消耗量(每个)
			if itemCount >= totalUse then
				factProdureNum = produreNum
				factUseNum = totalUse
			else
				local tmp = NumberToInt(itemCount/itemNum)--最少获取量
				if factUseNum == 0 then
					factUseNum = tmp
				else
					if factUseNum > tmp then
						factUseNum = tmp
					end
				end
				factProdureNum = factUseNum
			end
		end
	end
	--消耗材料获取资源
	for __, tb in pairs(useCfg["USE"]) do
		if tb[1] ~= 0 then
			if playerOBJ:deductItem(tb[2], factUseNum) == 0 then
				return
			end
		end
	end
	playerOBJ:getItem(self.allotType, factProdureNum)
--	print("jjjjj:", self.allotType, rate, _min, self.allotRenKouNum, factProdureNum)
	return factProdureNum
end
return {PeopleManage=PeopleManage}
