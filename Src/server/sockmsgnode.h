#ifndef _AUENGINE_SRC_SERVER_SOCKMSGNODE_H_
#define _AUENGINE_SRC_SERVER_SOCKMSGNODE_H_
#include "Common.h"
#include "Network/Network.h"
#include "doublemsgqueue.h"
#include "netmsg_new.h"

typedef struct SockMsgNode
{
	SockMsgNode():sock(NULL)
	{
	}
	Socket *sock;
	DoubleMsgQueue<ModuleMsg> msg;
}SMNode;

#endif