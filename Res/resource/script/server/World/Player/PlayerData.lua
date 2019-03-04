--PlayerData.lua
PlayerData = {}

function PlayerData:New()
	local object = setmetatable({},self)
	self.__index = self
	self.accountID = ""					--�˺�ID
	self.playerLevel = 1				--�ȼ�
	self.playerSex = 0					--�Ա�
	self.playerDiamond = 10000			--��ʯ
	self.playerCopper = 10000			--���
	self.playerRenKouTotal = 0			--�˿�����
	self.playerAllotRenKou = 0			--�ɷ����˿�
	self.playerStatus = 0               --���״̬(0-����״̬��1-̽��״̬)
    
    self.playerSystemState = 1			--��ҿ��Ź���
    self.playerPrimaryKey = 0			--���key(������ҽ���key)
    self.achievementPoint = 0 			--��ҳɾ͵�
    
    object.itemPropList = {}          	--�����б�
    object.itemEquipList = {}         	--װ���б�
    self.itemMaxNum = 100             	--�ֿ�ĸ�������
    
    object.buildList = {}				--�����б�
    object.taskList = {}				--�����б�
    object.heroList = {}				--����б�

    object.equitPropList = {}			--װ�����Լӳ�
    for __,propID in pairs(ItemEquipPropertyType) do
		object.equitPropList[propID] = 0
	end

	return object
end

--��ȡ���key
function PlayerData:getPrimaryKey()
	local primaryKey = self.playerPrimaryKey + 1
	self.playerPrimaryKey = primaryKey
	return primaryKey
end

--�������key
function PlayerData:setPrimaryKey(value)
	if self.playerPrimaryKey >= value then
		return
	end
	self.playerPrimaryKey = value
end