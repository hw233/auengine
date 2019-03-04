#ifndef _MESSAGESENDER_H
#define _MESSAGESENDER_H
#if 0
#include "NetMsg.h"
#include "Common.h"

extern void(*MSG_PACKAGE_END_FUNC)(int msgType,unsigned int playerID, void *pData, int len);

class MsgPackage
{
public:
	MsgPackage(void);
	~MsgPackage(void);

	// �������ݰ� 
	// playerID Ϊ0ʱ��ֻ���ڷ������ͨ��
	void messageBegin(unsigned int playerID, unsigned short msgID, unsigned char msgType, unsigned char msgFrom = MSG_TYPE_FROM_ENGIN);

	// �������ݰ�
	void messageEnd();
	void* getMsgPack();

	void addUint32( uint32 value );
	void addInt32( int32 value );
	void addUint16( uint16 value );
	void addInt16( int16 value );
	void addUint8( uint8 value );
	void addInt8( int8 value );

	template<class T>
	void addValue(T value);
	void addString(const char* value );
	int getSize();
	int getMsgID();
	void clear();

private:
	NormalMsg		m_netMsg;
	int				m_size;
	unsigned int	m_playerID;
	int				m_msgType;
	char*			m_pData;
};


// �������ݰ� 
// id			��ϢID
// type			�����¼�: 5 ΪLua�ű���Ϣ
// playerID		���ͻ��˵����ID
//
#if 0
namespace Au{

	extern void messageToClientBegin( unsigned int playerID, unsigned short msgID);
	extern void messageToValidBegin( unsigned int playerID, unsigned short msgID);
	extern void checkErrorFromLuaEngine();
	// �������ݰ�
	extern void messageEnd();
	extern void addUint32( uint32 value );
	extern void addInt32( int32 value );
	extern void addUint16( uint16 value );
	extern void addInt16( int16 value );
	extern void addUint8( uint8 value );
	extern void addInt8( int8 value );
	extern void addBool( bool value );
	extern void addFloat( float value );
	extern void addString(const char* value );
}
#endif

#endif
#endif