--Deque.lua

--数据类型:	双向队列
Deque = {}

-- 创建双向队列对象
function Deque:New()
	local object = setmetatable({}, self)
	self.__index = self
	self.first = 0
	self.last = -1
	return object
end

function Deque:Create()
	local _deque = createClass(Deque)
	return _deque
end

--前置push
function Deque:pushFirst(value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

--后置push
function Deque:pushLast(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

--前置pop
function Deque:popFirst()
	local first = self.first
	if first > self.last then
		error("deque is empty")
		return nil
	end
	local value = self[first]
	self[first] = nil
	self.first = first + 1
	return value
end

--后置pop
function Deque:popLast()
	local last = self.last
	if self.first > last then
		error("deque is empty")
		return nil
	end
	local value = self[last]
	self[last] = nil
	self.last = last - 1
	return value
end