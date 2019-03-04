--LinkList.lua


LinkList = {}		--˫������

LinkListNode = {}	--�ڵ�


--�����е�ÿһ���ڵ�
function LinkListNode:New()
	local object = setmetatable({},self)
	self.__index = self
	object.front = nil	--ǰһ���ڵ�
	object.back = nil	--��һ���ڵ�
	object.data = nil	--�ڵ�����
	return object
end

function LinkListNode:distroy()
	self.front = nil
	self.back = nil
	self.data = nil
end

function LinkListNode:noData()
	if isEmpty(self.data) then
		return true
	end
	return false
end


function LinkListNode:getNewNode()
	local node = createClass(LinkListNode)
	return node
end


--˫������
function LinkList:New()
	local object = setmetatable({},self)
	self.__index = self
	return object
end


--��ʼ��һ��˫������
function LinkList:Create()
	local _linkList = createClass(LinkList)
	_linkList.firstNode = LinkListNode:getNewNode()
	_linkList.endNode = LinkListNode:getNewNode()
	_linkList.firstNode.back = _linkList.endNode
	_linkList.endNode.front = _linkList.firstNode
	return _linkList
end


--������ĩβ����һ���ڵ�
function LinkList:push(node)
	self.endNode.front.back = node
	node.front = self.endNode.front
	node.back = self.endNode
	self.endNode.front = node
end

--��������ǰ�����һ���ڵ�
function LinkList:pushFront(node)
	self.firstNode.back.front = node
	node.back = self.firstNode.back
	node.front = self.firstNode
	self.firstNode.back = node
end

--�������ϵ�ĳһ���ڵ�������һ���½��
function LinkList:insertBackToNode(node1,node2)
	node2.back = node1.back
	node1.back.front = node2
	node2.front = node1
	node1.back = node2
end

--����һ��ȫ�µĽڵ�
function LinkList:getNewNode()
	return LinkListNode:getNewNode()
end


--ֱ���� node2 �滻 node1
function LinkList:replaceNode(node1,node2)
	node1.front.back = node2
	node2.front = node1.front
	
	node1.back.front = node2
	node2.back = node1.back
	
	node1:distroy()
	
end


--���������ڵ�
function LinkList:exChange(node1,node2)
	
	local tempNode = node1.front
	
	node1.front.back = node2
	node2.front.back = node1
	node1.front = node2.front
	node2.front = tempNode
	
	node1.back.front =node2
	node2.back.front = node1
	tempNode = node1.back
	
	node1.back = node2.back
	node2.back = tempNode
end


