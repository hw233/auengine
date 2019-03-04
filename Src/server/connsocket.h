#ifndef _AUENGINE_SRC_AUENGINE_CLIENTSOCKET_H_
#define _AUENGINE_SRC_AUENGINE_CLIENTSOCKET_H_

#include "basesocket.h"
#include "netmsg_new.h"
#include <vector>

namespace Au
{
	//different from Au::Server g_clients,
	
	class  ConnSocket:public BaseSocket
	{
	public:
		ConnSocket(SOCKET fd);
		~ConnSocket();
		virtual void OnDisconnect();

		virtual void OnConnect();

	protected:
		virtual void handleMessage(void *pData,int len, bool &bRight);

	private:

	};


}//namespace Au

#endif 