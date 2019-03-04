#include "connsocket.h"
#include "launcher.h"
#include "netmsg_new.h"
#include "sockmgr.h"
#include "gdata.h"

namespace Au
{


	ConnSocket::ConnSocket(SOCKET fd):BaseSocket(fd)
	{
		SocketOps::Nonblocking(fd);
	}

	ConnSocket::~ConnSocket()
	{

	}

	void ConnSocket::OnConnect()
	{

	}

	void ConnSocket::OnDisconnect()
	{

	}

	void ConnSocket::handleMessage(socketStreams *pData,int len, bool &bRight)
	{
		if (len < sizeof(MsgHead)-sizeof(long))
		{
			bRight = false;
		}
		{
			//如果收到的消息ID是 MSG_ID_PLAYER_LOGON_SUCCESS， 说明连接服务器成功，这个时候才把ConnSocket的信息加入到SockMgr中。
			MsgHead *head = (MsgHead *)pData;
			head->playerID = (unsigned int)m_fd;
			if (MSG_ID_PLAYER_LOGON_SUCCESS==head->msgID)
			{
				printf("%s:%d Get the login success msg.\n",__FUNCTION__, __LINE__ );
				Au::SockMgr::getSingleton().InsertSocket((unsigned int)m_fd, this);
				setSocketOK();
				bRight = true;
			}
			else if (MSG_ID_LOW_BOUND<=head->msgID && MSG_ID_UP__BOUND>=head->msgID && isSocketOK()) 
			{
				Au::GData::g_luamodule->PushMsg(pData, head->playerID, len);
			}
			else 
				bRight = false;
			if (!bRight)
			{
				Log.outError("Error Socket Package's Received from IP: %s Port: %d ",GetRemoteIP().c_str(), GetRemotePort());
			}
		}

	}

}//namespace Au
