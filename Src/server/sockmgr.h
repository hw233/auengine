#ifndef _AUENGINE_SRC_SERVER_SOCKMGR_H_
#define _AUENGINE_SRC_SERVER_SOCKMGR_H_
#include <map>
#include "Common.h"
#include "Network/Network.h"
#include "sockmsgnode.h"
#include "Singleton.h"

namespace Au
{

class SockMgr:public Singleton<SockMgr>
{
public:
	SockMgr();
	~SockMgr();
	void RemoveSocket(unsigned int sockfd);
	void InsertSocket(unsigned int sockfd, Socket *sock);
	void PushMsgToSock(unsigned int sockfd, void *data, int data_len);
	bool Send();

	int ValidateSocket(unsigned int sockid, const char *accountid);

	unsigned int GetARandomSockfd();

public:
	int GetConnSocks();
private:
	typedef unsigned int DATATYPE_SOCKFD;
	std::map<DATATYPE_SOCKFD, SMNode> _socks;
	Mutex _lock_socks;
	
};

}//namespace Au
#endif 