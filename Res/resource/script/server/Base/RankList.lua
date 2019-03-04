--RankList.lua
RankList = {} --固定长度,不重复的有序列表

RankList.SORT_KEY = ""

function RankList:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.sortKey = ""		--排序键
	self.primaryKey = ""	--主键 不重复
	self.maxLenth = 0		--最大长度
	object.list = nil
	return object
end

function RankList:Create(sKey,pKey,lenth)
	local _rankList = createClass(RankList)
	_rankList.list = {}
	_rankList.sortKey = sKey
	_rankList.primaryKey = pKey
	_rankList.maxLenth = lenth
	return _rankList
end

--插入一个数据
function RankList:push(node)
	local lenth = table.getn(self.list)
	if lenth >= self.maxLenth then
		if node[self.sortKey] < self.list[lenth][self.sortKey] then
			return
		end
	end
	
	local obj = nil
	for i=1,lenth do
		obj = self.list[i]
		if obj[self.primaryKey] == node[self.primaryKey] then	--节点已在列表中存在
			RankList.SORT_KEY = self.sortKey
			table.sort(self.list,RankList.sortFun)
			return
		end
	end
	table.insert(self.list,node)
	RankList.SORT_KEY = self.sortKey
	table.sort(self.list,RankList.sortFun)
	while table.getn(self.list) > self.maxLenth do
		table.remove(self.list,table.getn(self.list))
	end
end

--比较算法
function RankList.sortFun(nodeA,nodeB)
	return nodeA[RankList.SORT_KEY] > nodeB[RankList.SORT_KEY]
end


--慎用,一般用与服务器启动,从一个列表中初始化,会把旧的数据清掉
function RankList:initFromList(_list)
	self.list = {}
	for _key,Value in pairs(_list) do
		table.insert(self.list,Value)
	end
	RankList.SORT_KEY = self.sortKey
	table.sort(self.list,RankList.sortFun)
	if table.getn(self.list) <= self.maxLenth then
		return
	end
	local tb = self.list
	self.list = {}
	for i=1,self.maxLenth do
		table.insert(self.list,tb[i])
	end
end

function RankList:getList()
	return self.list
end

function RankList:setList(_list)
	self.list = _list
end