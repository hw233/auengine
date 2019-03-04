--Base.lua
--�ж϶����Ƿ�Ϊ��
function isEmpty(obj)
	if obj == nil then
		return true
	end
	
	if type(obj) == "table" then
		return _G.next( obj ) == nil
	end
	return false
end

--���һ��Table��Ԫ�س���
function getTableLength(tb)
	if isEmpty(tb) then
		return 0
	end
	local n = 0
	for i,v in pairs(tb) do
		if v ~= nil then
			n = n + 1
		end
	end
	return n
end

local function search (k, plist)
	for i=1, table.getn(plist) do
		local v = plist[i][k] -- try 'i'-th superclass
		if v then
			return v
		end
	end
end

--������̳б�
function createClass (...)
	local classList = {}
	for i=1, table.getn(arg) do
		table.insert(classList,arg[i]:New())
	end
	local c = {}
	setmetatable(c, {__index = function (t, k)
		local v = search(k, classList)
		t[k] = v -- save for next access
		return v
	end})
	c.__index = c
	function c:new (o)
		o = o or {}
		setmetatable(o, c)
		return o
	end
	return c
end

function getNextTimeFromNow(nowTime,timesTb)
	local H1 = tonumber(timesTb[1])
	local M1 = tonumber(timesTb[2])
	local S1 = tonumber(timesTb[3])
	
	local H2 = tonumber(os.date("%H", nowTime))
	local M2 = tonumber(os.date("%M", nowTime))
	local S2 = tonumber(os.date("%S", nowTime))
	
	local ttime = (H1 - H2)*3600 + (M1 - M2)*60 + (S1 - S2) 
	
	if ttime < 0 then
		ttime = ttime + 24 * 3600
	end
	
	return nowTime + ttime
end

--����һ������
function createWeekTable()
	local tb = {}
	setmetatable(tb, {__mode = "v"})
	return tb
end

--���һ���ַ���
function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	local stringfind = string.find
	local stringsub = string.sub
	local stringlen = string.len
	
	while true do
		local nFindLastIndex = stringfind(szFullString, szSeparator, nFindStartIndex)
		if not nFindLastIndex then
			nSplitArray[nSplitIndex] = stringsub(szFullString, nFindStartIndex, stringlen(szFullString))
			break
		end
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
		if szSeparator == '%$' then  --�� $ ���Ų��
			nFindStartIndex = nFindLastIndex + stringlen(1)
		else
			nFindStartIndex = nFindLastIndex + stringlen(szSeparator)
		end
		nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

--����̨��ӡһ��Table
function printTB(tb)
	if isEmpty(tb) then
		print("there is no table")
		return
	end
	for k,v in pairs(tb) do
		print(k,v)
	end
end

--�ͷŶ���
function removeObject(obj)
	if isEmpty(tb) then
		return
	end
	if type(obj) == "table" then
		for k,v in pairs(tb) do
			obj[k] = nil
		end
		return
	end
	obj = nil
end

function table_has_Key(t,value)
	for i,v in pairs(t) do
		if value == v then
			return true
		end
	end
	return false
end

function findStr(str1,str2)
	if str1 == nil then
		return false
	end
	if str2 == nil then
		return false
	end
	if string.find(str1,str2) ==nil then
		return false
	else
		return true
	end
end

--���ַ�����������ִ������
function SplitStringToNumberTable(szFullString,szSeparator)
	local tableList = {}
	local tablegetn = table.getn
	local tableinsert = table.insert
		
	if szFullString ~=nil then
		szFullString =Split(szFullString,szSeparator)
		for i=1,tablegetn(szFullString) do
			tableinsert(tableList,tonumber(szFullString[i]))
		end
	end
	return tableList
end

--��һ���̶����ȵı��в���һ������
function InsertValueToMaxTable(tb,value,MaxNum)
	local tablelen = table.getn(tb)
	if tablelen >= MaxNum then
		table.remove(tb,1)
	end
	table.insert(tb,value)
end

--ֱ��ȡ��
function NumberToInt(numberValue)
	return math.floor(numberValue)
end

--��ȿ���
function deepcopy(object)    
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end  -- if        
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end  -- for        
		return setmetatable(new_table, getmetatable(object))    
	end  -- function _copy    
	return _copy(object)
end  -- function deepcopy


--����һ�������int �� seedA seedB
function AuRandom(seedA,seedB)
	if seedA == seedB then
		return seedA
	elseif seedA > seedB then
		return Au.auRand() % (seedA - seedB + 1 ) + seedB
	else
		return Au.auRand() % (seedB - seedA + 1 ) + seedA
	end
end

--����һ�����С�� �� seedA seedB
function AuRandomFloat(seedA,seedB)
	if seedA == seedB then
		return seedA
	elseif seedA > seedB then
		return Au.auRand() % (seedA - seedB + 0.001 ) + seedB
	else
		return Au.auRand() % (seedB - seedA + 0.001 ) + seedA
	end

end

--��1��num�з��� lenth ������

function AuRandomLengthNum(lenth,num)
	local tDict = {}
	local RandomTB = {}
	local tablegetn = table.getn
	local tableinsert = table.insert
	local tableremove = table.remove
	
	if lenth >= num then
		for i=1,num do
			tableinsert(RandomTB,i)
		end
	else
		for i=1,num do
			tableinsert(tDict,i)
		end
		while tablegetn(RandomTB) < lenth do
			_len = tablegetn(tDict)
			index = Au.auRand() % _len + 1
			tableinsert(RandomTB, tableremove(tDict, index))
		end
	end
	return RandomTB
end

--��ȡLUA������
function LuaClock()
	return math.ceil(os.clock()*1000)
end

--��ӡ������λ��
function PrintError(...)
	local errorType = ""
	for i = 1,table.getn(arg) do
		errorType = errorType..arg[i]..","
	end
	error("Error Occur Arg:"..errorType.."\n"..debug.traceback())
end

--�������
function InsertByAscOrder(tb,object,propType)
	local tablegetn = table.getn
	local tableinsert = table.insert
	
	if object[propType] == nil then
		return
	end
	if tablegetn(tb) == 0 then
		tableinsert(tb,object)
		return
	end
	if object[propType] >= tb[tablegetn(tb)][propType] then
		tableinsert(tb,object)
		return
	end
	for i = 1, tablegetn(tb) do
		if object[propType]<=tb[i][propType] then
			tableinsert(tb,i,object)
			return
		end
	end
end

--��ĳ��table�в���count�����ظ��������
function selectNumber(count,temp)
	local tablegetn = table.getn
	local tableinsert = table.insert
	local tableremove = table.remove
	local selected={}
	local lenth = table.getn(temp)
	local index = 0
	if lenth <= count then
		return temp
	end
	while tablegetn(selected) < count do
		lenth = tablegetn(temp)
		index = Au.auRand() % lenth + 1
		tableinsert(selected, tableremove(temp, index))
	end
	return selected
end


--���������key��������,�����������
function sortedpairs(t,comparator)
	local sortedKeys = {};
	table.foreach(t, function(k,v) table.insert(sortedKeys,k) end);
	table.sort(sortedKeys,comparator);
	local returnTB = {}
	for i = 1,table.getn(sortedKeys) do
		table.insert(returnTB,t[sortedKeys[i]])
	end
	return returnTB
end

--��ȡ���ʱ�����ʱ���(������ͬһ���ʱ���)
function getIntervalTimeFromPoint(nowTime,endTime)
	local timesTb = Split(endTime,":")
	local H1 = tonumber(os.date("%H", nowTime))
	local M1 = tonumber(os.date("%M", nowTime))
	local S1 = tonumber(os.date("%S", nowTime))

	local H2 = tonumber(timesTb[1])
	local M2 = tonumber(timesTb[2])
	local S2 = tonumber(timesTb[3])
	
	local ttime = (H2 - H1)*3600 + (M2 - M1)*60 + (S2 - S1)
	if ttime < 0 then
		ttime = ttime + 24 * 3600
	end
	return ttime
end

local function packDBTable(t)
	local str = "{"
	for i, v in pairs(t) do
		str = string.format("%s[%s]=%s,", str, packDBValue(i), packDBValue(v))
	end
	return str.."}"
end

--������ݿ�ĳ��ֵ
function unpackDBValue(pValue)
	if not pValue or type(pValue) ~= "string" then
		return {}
	end
	local str = string.format("local value=%s;return value", pValue)
	return loadstring(str)()
end

--������ݿ�ĳ��ֵ
function packDBValue(value)
	local dataType = type(value)
	if dataType == "number" or dataType == "boolean" then
		return tostring(value)
	elseif dataType == "string" then
		local svalue = string.gsub(value, "[\"\\]", "\\%1")
		return string.format("\"%s\"", svalue)		
	elseif dataType == "table" then
		return packDBTable(value)
	else
		print("���������������"..dataType)
		return false
	end
end

--����һ��ֻ����table
function readOnly(t)
	local proxy = {}
	local mt = {	--����Ԫ��
		__index = t,--����ʱ����
		__newindex = function (t, k, v)--����ʱ����
			error("attempt to update a read-only table", 2)
		end
	}
	setmetatable(proxy, mt)
	return proxy
end

--luaռ���ڴ�
function luaMem()
	luaRecoveMem()
	local c1 = collectgarbage("count")
	return c1
end

--lua�����ڴ�
function luaRecoveMem()
	collectgarbage("collect")
	collectgarbage("collect")
end

--������
--a = makeCount() b = makeCount() print(a())--1 print(b())--1
function makeCounter()
	local count = 0
	function _count()
		count = count + 1
		return count
	end
	return _count
end