#include "sendthread.h"

#include "Network/Network.h"
#include "basesocket.h"
#include "netmsg_new.h"
#include "doublemsgqueue.h"
#include "sockmgr.h"

namespace Au
{

	SendThread::SendThread()
	{

	}
	
	SendThread::~SendThread()
	{

	}

	bool SendThread::run()
	{
		Au::SockMgr* tsm = Au::SockMgr::getSingletonPtr();
		while(NULL!=tsm)
		{
			tsm->Send();
			Au::Au_Sleep( 100 );
		}
		
		return false;
	}

}//namespace Au