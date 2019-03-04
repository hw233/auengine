require "resource.script.server.Base.Base"


--��������:	����
Queue = {}


-- �������ж���
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

-- ѹ����ж���
function Queue:push(value)
	table.insert( self.objTB, value )
end

--�������ж���
function Queue:pop()
	if self:empty() then
		return nil
	end
	return table.remove( self.objTB, 1 )
end

--ɾ������
function Queue:removeData(index)
	table.remove( self.objTB, index)
end

-- ���ص�һ������
function Queue:front()
	return self.objTB[1]
end

--���ݳ���
function Queue:size()
	return table.getn(self.objTB)
end

--��������
function Queue:getData(index)
	return self.objTB[index]
end


-- �����Ƿ�Ϊ��
function Queue:empty()
	return table.getn(self.objTB) == 0
end