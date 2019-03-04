require "resource.script.server.Base.Base"


--数据类型:	队列
Queue = {}


-- 创建队列对象
function Queue:New()
	local object = setmetatable({}, self)
	self.__index = self
	return object
end 

function Queue:Create()
	local _queue = createClass(Queue)
	_queue.objTB = {}
	return _queue
end

-- 压入队列对象
function Queue:push(value)
	table.insert( self.objTB, value )
end

--弹出队列对象
function Queue:pop()
	if self:empty() then
		return nil
	end
	return table.remove( self.objTB, 1 )
end

--删除对象
function Queue:removeData(index)
	table.remove( self.objTB, index)
end

-- 返回第一个对象
function Queue:front()
	return self.objTB[1]
end

--数据长度
function Queue:size()
	return table.getn(self.objTB)
end

--返回数据
function Queue:getData(index)
	return self.objTB[index]
end


-- 队列是否为空
function Queue:empty()
	return table.getn(self.objTB) == 0
end