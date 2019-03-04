#include "basesocket.h"
#include "netmsg_new.h"
#include "version_info.h"
//#define SOCKET_DATA_MIN_SIZE 8 //is sizeof(MsgHead)-sizeof(long)

#define REAL_MSGHEAD_LEN (sizeof(MsgHead)-sizeof(long))

#define SOCKET_DATA_MIN_SIZE REAL_MSGHEAD_LEN
#define SOCKET_DATA_MAX_SIZE 500

BaseSocket::BaseSocket(SOCKET fd) : Socket( fd, MAX_BUFFER_SIZE, MAX_BUFFER_READ_SIZE )
{

}

BaseSocket::~BaseSocket(void)
{

}

void BaseSocket::OnConnect()
{
	Log.outString("IP: %s Port: %d onConnect", GetRemoteIP().c_str(), GetRemotePort() );

}

void BaseSocket::OnDisconnect()
{
	Log.outString("IP: %s Port: %d onDisconnect", GetRemoteIP().c_str(), GetRemotePort() );
}

void BaseSocket::OnRead()
{
	size_t size = readBuffer.GetSize();
	char* pBuff = 0;

	int buffSize;

	while( size >= SOCKET_DATA_MIN_SIZE )
	{
		
		pBuff = (char*)readBuffer.GetBufferStart();

		buffSize = *((unsigned short*)pBuff);
		
		if (buffSize <= SOCKET_DATA_MIN_SIZE || buffSize > SOCKET_DATA_MAX_SIZE)	//不合法数据包
		{
			readBuffer.Remove( readBuffer.GetSize() );
			Disconnect();
			return;
		}

		if( (int)size >= buffSize )
		{
			readBuffer.Read(this->msg,buffSize);
			bool bRight = true;
			handleMessage((socketStreams*)this->msg,buffSize,bRight);	//抛出数据包
			if (!bRight)
			{
				readBuffer.Remove( readBuffer.GetSize() );
				Disconnect();
				return;
			}
		}else
			break;
		size = readBuffer.GetSize();
	}

}
