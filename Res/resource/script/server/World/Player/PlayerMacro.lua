--PlayerMacro.lua
--Player��ȫ�ֺ�
require "resource.script.server.Config.Player.FUNCTIONCFG"

local PlayerMacro = {}
PlayerMacro.NOTERM 			= 0		--������
PlayerMacro.COMPLETETASK 	= 1		--��������
PlayerMacro.PLAYERLEVEL	 	= 2		--����ȼ�
PlayerMacro.BUILD 			= 3		--����
PlayerMacro.SPACE			= 4		--��������ID
PlayerMacro.GETITEM			= 5		--�����Ʒ
PlayerMacro.BIGMAP			= 6		--�󸱱�ID
PlayerMacro.OPENSYS			= 7		--����ģ��


PLAYER_PROP_TYPE = {}
PLAYER_PROP_TYPE.PLAYERLEVEL = 1
PLAYER_PROP_TYPE.PLAYEREXP = 2
PLAYER_PROP_TYPE.PLAYERDIAMOND = 3
PLAYER_PROP_TYPE.PLAYERCOPPER = 4
--PLAYER_PROP_TYPE.PLAYERWOOD = 5
--PLAYER_PROP_TYPE.PLAYERFUR = 6
--PLAYER_PROP_TYPE.PLAYERMEAT = 7
--PLAYER_PROP_TYPE.PLAYERBONFIRESTATE = 9
PLAYER_PROP_TYPE.PLAYERBEARLOAD = 10
PLAYER_PROP_TYPE.PLAYERRENKOUTOTAL = 11
PLAYER_PROP_TYPE.PLAYERTALENTPOINT = 12--�ɾ͵�
--PLAYER_PROP_TYPE.ROLELOGINDAYS = 14
PLAYER_PROP_TYPE.PLAYERSYSTEMSTATE = 15	--���ŵ�ϵͳ����

LOG_BACK_TYPE = {}
LOG_BACK_TYPE.LOG_SUCCESS = 1		--��¼�ɹ�
LOG_BACK_TYPE.LOG_CREATE_PLAYER = 2	--�������
LOG_BACK_TYPE.LOG_PLAYER_EXIEST = 3	--����Ѵ���
LOG_BACK_TYPE.LOG_PLAYER_OTHER = 4	--����ڱ𴦵�¼
LOG_BACK_TYPE.LOG_GAME_SHUT = 5		--��Ϸ��ά��
LOG_BACK_TYPE.LOG_GAME_FULL = 6		--��Ϸ��������
LOG_BACK_TYPE.LOG_MAX_ONLINE = 7	--���������Ѵ�����

FUNCTION_ID_TYPE = {}
FUNCTION_ID_TYPE.GOLD = 11          --������
FUNCTION_ID_TYPE.BUILD = 12         --���칦��
FUNCTION_ID_TYPE.WAREHOUSE = 13     --�ֿ⹦��
FUNCTION_ID_TYPE.PEOPLE = 14        --�˿ڷ��书��
FUNCTION_ID_TYPE.ADVENTURES = 15    --ð���߹���
FUNCTION_ID_TYPE.EXPLORE = 16       --̽�չ���
FUNCTION_ID_TYPE.SHOP = 17          --�̵깦��
FUNCTION_ID_TYPE.MAKE = 18          --���칦��
FUNCTION_ID_TYPE.EVENT = 19         --�¼�����
FUNCTION_ID_TYPE.TALENT = 20        --�츳����
FUNCTION_ID_TYPE.ACHIEVEMENT = 21   --�ɾ͹���


PLAYERSTATUS = {}
PLAYERSTATUS.INNERCITY = 0			--����
PLAYERSTATUS.EXPLORE = 1			--̽��

--��ȡ��������
function PlayerMacro:readFunctionCfg(functionID)
	local ID  = "FUNCTIONID_"..functionID
	return FUNCTIONCFG[ID]
end

return {PlayerMacro = PlayerMacro}