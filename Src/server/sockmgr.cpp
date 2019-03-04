#include "sockmgr.h"
#include "config_struct.h"

initialiseSingleton(Au::SockMgr);

namespace Au
{

	SockMgr::SockMgr()
	{

	}

	SockMgr::~SockMgr()
	{

	}

	void SockMgr::RemoveSocket(unsigned int sockfd)
	{
		_lock_socks.Acquire();
		std::map<DATATYPE_SOCKFD, SMNode>::iterator iter = _socks.find(sockfd);
		if (_socks.end()!=iter)
		{
			iter->second.msg.DestroyAll();
			_socks.erase(iter);
		}
		_lock_socks.Release();
	}

	void SockMgr::InsertSocket(unsigned int sockfd, Socket *sock)
	{
		_lock_socks.Acquire();
		std::map<DATATYPE_SOCKFD, SMNode>::iterator iter = _socks.find(sockfd);
		
		if (_socks.end()!=iter)
		{
			iter->second.msg.DestroyAll();
			_socks.erase(iter);
		}
		SMNode smn;
		smn.sock =sock;
		_socks[sockfd] = smn;
		_lock_socks.Release();
	}

	void SockMgr::PushMsgToSock(unsigned int sockfd, void *data, int data_len)
	{
		_lock_socks.Acquire();
		if (_socks.end()== _socks.find(sockfd))
		{
			Log.outError("Please Check the sockfd:%u\n", sockfd);
		}
		else
		{
			_socks[sockfd].msg.PushMsg(data, sockfd, data_len);
		}
		_lock_socks.Release();
	}

	bool SockMgr::Send()
	{
		bool ret = true;
		_lock_socks.Acquire();
		std::map<unsigned int, SMNode>::iterator it_beg = _socks.begin();
		std::map<unsigned int, SMNode>::iterator it_end = _socks.end();
		
		while (it_beg!=it_end)
		{
			Socket *sock = NULL;
			sock = it_beg->second.sock;
			DoubleMsgQueue<ModuleMsg> *msg = &(it_beg->second.msg);
			ModuleMsg *smsg = NULL;
			while ((smsg=msg->GetMsg()))
			{
				if (sock && sock->IsConnected())
				{				
					if (!sock->Send((const uint8*)(smsg->param), smsg->msgLen))
						Log.outError("******************%s:%d send failured.\n",__FUNCTION__, __LINE__);
					
				}
				else 
				{
					it_beg->second.msg.DestroyAll();
					Log.outError("*******************%s:%d sock is null or not connected.\n", __FUNCTION__, __LINE__);
				}
				
			}
			++it_beg;
		}
		_lock_socks.Release();

		return ret;
	}

	int SockMgr::ValidateSocket(unsigned int sockfd, const char *accountid)
	{
		int ret = 0;
		_lock_socks.Acquire();
		if (_socks.end()!=_socks.find(sockfd))
		{
			Socket *s = NULL;
			s = _socks[sockfd].sock;
			if (NULL!=s)
				ret = s->validateSocket(accountid);


		}
		_lock_socks.Release();
		return ret;
	}

	unsigned int SockMgr::GetARandomSockfd()
	{
		unsigned int ret = AU_VALIDE_SOCKET_FD;
		int size = _socks.size();
		if (0==size)
			return ret;
		int randpos = rand()%size;
		std::map<DATATYPE_SOCKFD, SMNode>::iterator iter=_socks.begin();
		for (int i=0; i<randpos; ++i,++iter)
			;
		ret = iter->first;
		return ret;
	}

	int SockMgr::GetConnSocks()
	{
		int cnt = -1;
		_lock_socks.Acquire();
		cnt = _socks.size();
		_lock_socks.Release();
		return cnt;
	}

}//namespace Au

