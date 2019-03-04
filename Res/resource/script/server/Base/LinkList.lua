--LinkList.lua


LinkList = {}		--双向链表

LinkListNode = {}	--节点


--链表中的每一个节点
function LinkListNode:New()
	local object = setmetatable({},self)
	self.__index = self
	object.front = nil	--前一个节点
	object.back = nil	--后一个节点
	object.data = nil	--节点数据
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


--双向链表
function LinkList:New()
	local object = setmetatable({},self)
	self.__index = self
	return object
end


--初始化一个双向连接
function LinkList:Create()
	local _linkList = createClass(LinkList)
	_linkList.firstNode = LinkListNode:getNewNode()
	_linkList.endNode = LinkListNode:getNewNode()
	_linkList.firstNode.back = _linkList.endNode
	_linkList.endNode.front = _linkList.firstNode
	return _linkList
end


--往链表末尾插入一个节点
function LinkList:push(node)
	self.endNode.front.back = node
	node.front = self.endNode.front
	node.back = self.endNode
	self.endNode.front = node
end

--往链表最前面插入一个节点
function LinkList:pushFront(node)
	self.firstNode.back.front = node
	node.back = self.firstNode.back
	node.front = self.firstNode
	self.firstNode.back = node
end

--往链表上的某一个节点后面插入一个新结点
function LinkList:insertBackToNode(node1,node2)
	node2.back = node1.back
	node1.back.front = node2
	node2.front = node1
	node1.back = node2
end

--返回一个全新的节点
function LinkList:getNewNode()
	return LinkListNode:getNewNode()
end


--直接用 node2 替换 node1
function LinkList:replaceNode(node1,node2)
	node1.front.back = node2
	node2.front = node1.front
	
	node1.back.front = node2
	node2.back = node1.back
	
	node1:distroy()
	
end


--交换两个节点
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


