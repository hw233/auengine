#include "MsgPackage.h"
#include "Log.h"
#include <stack>


#if 0
void(*MSG_PACKAGE_END_FUNC)(int msgType,unsigned int playerID, void *pData, int len);


MsgPackage::MsgPackage(void)
{
	m_pData = NULL;
}

MsgPackage::~MsgPackage(void)
{
	m_pData = NULL;
}

void MsgPackage::messageBegin(unsigned int playerID, unsigned short msgID, unsigned char msgType, unsigned char msgFrom)
{
	memset( (void*)&m_netMsg, 0, sizeof(m_netMsg));

	NetMsg* pMsg = (NetMsg*)&m_netMsg;
	pMsg->msgFrom= msgFrom;
	pMsg->msgID = msgID;
	pMsg->msgType = msgType;
	pMsg->playerID = playerID;
	m_playerID = playerID;
	m_msgType = msgType;

	// 计算包大小
	m_size = sizeof(NetMsg) - sizeof(long);
	m_pData = (char*)&m_netMsg;
	m_pData += m_size;
}

void MsgPackage::messageEnd()
{
	if(m_size <= sizeof(NetMsg) - sizeof(long))
	{
		clear();
		return;
	}

	NetMsg* pMsg = (NetMsg*)&m_netMsg;

	if (m_size >= MAX_SEND_DATA_SIZE)
	{
		Log.outError( "Error Send Message ID: %d len is %d Max than %d",pMsg->msgID,m_size,MAX_SEND_DATA_SIZE);
		clear();
		return;
	}
	m_netMsg.msgLen = m_size;
	MSG_PACKAGE_END_FUNC(m_msgType,m_playerID,&m_netMsg,m_size);
	clear();
}

void* MsgPackage::getMsgPack()
{
	if(m_size == sizeof(NetMsg) - sizeof(long))
	{
		return NULL;
	}
	m_netMsg.msgLen = m_size;
	return &m_netMsg;
}

void MsgPackage::clear()
{
	m_size = 0;
}

int MsgPackage::getSize()
{
	return m_size;
}

int MsgPackage::getMsgID()
{
	NetMsg* pMsg = (NetMsg*)&m_netMsg;
	return pMsg->msgID;
}

template<class T>
void MsgPackage::addValue(T value)
{
	int size =sizeof(T);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((T*)m_pData) = value;
	m_pData += size;

}

void MsgPackage::addString(const char* value )
{
	if(m_size >= (MAX_SEND_DATA_SIZE - 100))
		return;

	int16 size = (int16)strlen( value );

	//字串大小
	*((int16*)m_pData) = size;
	m_size += sizeof(int16);
	m_pData += sizeof(int16);

	//字串
	memcpy( m_pData, value, size );
	m_size += size;
	m_pData += size;
}

void MsgPackage::addUint32( uint32 value )
{
	// 定位
	int size =sizeof(uint32);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((uint32*)m_pData) = value;
	m_pData += size;
}

void MsgPackage::addInt32( int32 value )
{
	// 定位
	int size =sizeof(int32);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((int32*)m_pData) = value;
	m_pData += size;
}

void MsgPackage::addUint16( uint16 value )
{
	// 定位
	int size =sizeof(uint16);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((uint16*)m_pData) = value;
	m_pData += size;
}

void MsgPackage::addInt16( int16 value )
{
	// 定位
	int size =sizeof(int16);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((int16*)m_pData) = value;
	m_pData += size;
}

void MsgPackage::addUint8( uint8 value )
{
	// 定位
	int size =sizeof(uint8);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((uint8*)m_pData) = value;
	m_pData += size;
}

void MsgPackage::addInt8( int8 value )
{
	// 定位
	int size =sizeof(int8);
	m_size += size;
	if(m_size >= MAX_SEND_DATA_SIZE)
		return;
	*((int8*)m_pData) = value;
	m_pData += size;
}

#if 0
namespace Au{

	//Lua脚本模块的发包模块.
	namespace LuaPack
	{
		std::stack<MsgPackage*> luaPackStack;
		MsgPackage* pLuaPack = NULL;
		void getLuaPack()
		{
			if (!pLuaPack)
			{
				pLuaPack = new MsgPackage;
				return;
			}
			if (pLuaPack->getSize() > 0)
			{
				luaPackStack.push(pLuaPack); //对未发数据包压栈
				pLuaPack = NULL;
				pLuaPack = new MsgPackage;   //分配一个新的数据包
			}
		}

		void releaseLuaPack()
		{
			if (!luaPackStack.empty())
			{
				delete pLuaPack; //销毁上一个数据包
				pLuaPack = NULL;
				pLuaPack = luaPackStack.top(); //获取栈顶数据包
				luaPackStack.pop();
				if (luaPackStack.size() > 10)
				{
					Log.outError("luaPackStack error ================= luaPackStack size %d\n",luaPackStack.size());
				}
				Log.outError("Please check is there any wrong with Message ID: %d\n",pLuaPack->getMsgID());
			}
		}

		void checkErrorLuaPack() //在处理一个Lua数据出错的时候,会清除掉Lua里的数据包
		{
			MsgPackage* pPack = NULL;
			while(!luaPackStack.empty())
			{

				pPack = luaPackStack.top(); //获取栈顶数据包
				delete pPack;				//销毁数据包
				pPack = NULL;
			}
			if(pLuaPack != NULL)
			{
				Log.outError("Send Message Error ID: %d\n",pLuaPack->getMsgID());
				pLuaPack->clear();	//清空这次需要发送的数据
			}
		}

	}//namespace LuaPack

	void messageToValidBegin( unsigned int playerID, unsigned short msgID)
	{
		LuaPack::getLuaPack();
		LuaPack::pLuaPack->messageBegin(playerID,msgID,MSG_TYPE_TO_Validate);
	}


	void messageToClientBegin( unsigned int playerID, unsigned short msgID )
	{
		LuaPack::getLuaPack();
		LuaPack::pLuaPack->messageBegin( playerID, msgID,MSG_TYPE_TO_CLIENT );
	}


	void checkErrorFromLuaEngine()
	{
		LuaPack::checkErrorLuaPack();
	}

	void messageEnd()
	{
		LuaPack::pLuaPack->messageEnd();
		LuaPack::releaseLuaPack();
	}

	void addUint32( uint32 value )
	{
		LuaPack::pLuaPack->addValue<uint32>( value );
	}

	void addInt32( int32 value )
	{
		LuaPack::pLuaPack->addValue<int32>( value );
	}

	void addUint16( uint16 value )
	{
		LuaPack::pLuaPack->addValue<uint16>( value );
	}

	void addInt16( int16 value )
	{
		LuaPack::pLuaPack->addValue<int16>( value );
	}

	void addUint8( uint8 value )
	{
		LuaPack::pLuaPack->addValue<uint8>( value );
	}

	void addInt8( int8 value )
	{
		LuaPack::pLuaPack->addValue<int8>( value );
	}

	void addBool( bool value )
	{
		LuaPack::pLuaPack->addValue<bool>( value );
	}

	void addFloat( float value )
	{
		LuaPack::pLuaPack->addValue<float>( value );
	}

	void addString(const char* value )
	{
		if (!value)
		{
			LuaPack::pLuaPack->addString("[errorString]");
		}
		else
			LuaPack::pLuaPack->addString( value );
	}



}
#endif 


#endif 
