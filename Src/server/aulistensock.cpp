#include "aulistensock.h"
#include "netmsg_new.h"
#include "launcher.h"
#include "sockmgr.h"
#include "modulebase.h"
#include "modulemanager.h"
#include "servermap.h"
#include "config_module.h"
#include "msgpackager.h"
#include "gdata.h"

namespace Au
{
	AuListenSock::AuListenSock(SOCKET fd):BaseSocket(fd)
	{
		
	}

	AuListenSock::~AuListenSock()
	{

	}

	void AuListenSock::OnConnect()
	{

	}

	void AuListenSock::OnDisConnect()
	{

	}

	void AuListenSock::handleMessage(socketStreams *pData,int len,bool &bRight)
	{
		if (len < sizeof(ModuleMsg)-sizeof(long))
			bRight =  false;
		else
		{
			if (isSocketOK())
			{
				MsgHead *head = (MsgHead*)pData;
				head->playerID = (unsigned int )m_fd;
				if (MSG_ID_LOW_BOUND<=head->msgID &&MSG_ID_UP__BOUND>=head->msgID)
				{
					Au::GData::g_luamodule->PushMsg(pData, head->playerID, len);
				}
				if (head->msgID==1000)
					printf("%s:%d Got MsgId:1000\n", __FUNCTION__, __LINE__);
			}
			else
			{
				HandleValidate(pData, len, bRight);
			}
		}

	}

	void AuListenSock::HandleValidate(socketStreams *pData,int len,bool &bRight)
	{
		LoginMsg *msg = (LoginMsg *)pData;
		if (msg->msgLen != sizeof(LoginMsg))
		{
			bRight = false;
			return ;
		}
		memset(_accountid, 0, MAX_ACCOUNT_ID_SIZE);
		//printf("%s:%d msg->accountID:%s\n", __FUNCTION__, __LINE__, msg->accountID);
		strncpy(_accountid, msg->accountID, MAX_ACCOUNT_ID_SIZE);

		//printf("%s:%d _accountid:%s \n", __FUNCTION__, __LINE__, _accountid);
		char *p = NULL;
		p = (char *)pData;
		int32 key = -1;
		int keypos = sizeof(MsgHead)-sizeof(long);
		
		key = *((int32*)&(p[keypos]));
		if (key>0) //Player Msg
		{

			Au::SockMgr::getSingleton().InsertSocket((unsigned int)m_fd, this);
			//Send The Msg To Lua Script.
			MsgPackager tmp;
			//模拟验证模块发送102的消息
			tmp.MessageBegin((unsigned int)m_fd, 102);
			tmp.AddUint32((unsigned int)m_fd);
			tmp.AddString(_accountid);
			tmp.AddString(GetRemoteIP().c_str());
			tmp.AddUint8(1);//1 代码验证成功
			tmp.MessageEnd();
			Au::GData::g_luamodule->PushMsg(tmp.GetPackageData(), (unsigned int)m_fd, tmp.GetDataSize());
			Log.outString("Add Player Successed");
		}
		else if (key==0) //Server Msg
		{
			int server_key = atoi(msg->accountID);
			std::map<int, ServerSockNode>::iterator f_iter;
			f_iter = Au::ConfigManager::s_servermap.find(server_key);
			if (Au::ConfigManager::s_servermap.end()==f_iter)
			{
				Log.outError("Got the Illegal Key:%d\n",server_key);
				return ;
			}
			f_iter->second._sockfd = (unsigned int)m_fd;
			
			Au::SockMgr::getSingleton().InsertSocket((unsigned int)m_fd, this);

			MsgPackager tmp;
			tmp.MessageBegin((unsigned int)m_fd, 102);
			tmp.AddUint32((unsigned int)m_fd);
			tmp.AddString(_accountid);
			tmp.AddString(GetRemoteIP().c_str());
			tmp.AddUint8(1);
			tmp.MessageEnd();
			Au::GData::g_luamodule->PushMsg(tmp.GetPackageData(), (unsigned int)m_fd, tmp.GetDataSize());
			
			//Log.outString("this:%p Add SubServer Successed, the Key is :%u", this, key);
		}
		else  //Error
		{
			Log.outError("Illegal connection\n");
			return ;
		}
		
	}

	int AuListenSock::validateSocket(const char *accountid)
	{
		if (!IsConnected())
		{
			printf("%s:%d %s\n", __FUNCTION__, __LINE__, accountid);
			return 0;
		}
		
		if (0==strcmp((char *)_accountid, accountid))
		{
			//printf("%s:%d validate success.%s\n", __FUNCTION__, __LINE__, accountid);
			setSocketOK();
			return 1;
		}
		return 0;
	}

}//namespace Au