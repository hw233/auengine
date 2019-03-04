#ifndef _AUENGINE_SRC_SERVER_AULISTENSOCK_H_
#define _AUENGINE_SRC_SERVER_AULISTENSOCK_H_
#include "basesocket.h"
#include "netmsg_new.h"
namespace Au
{
	class AuListenSock:public BaseSocket
	{
	public:
		AuListenSock(SOCKET fd);
		~AuListenSock();
		//derived
		virtual void OnConnect();
		virtual void OnDisConnect();
		virtual void handleMessage(socketStreams *pData,int len,bool &bRight);

		void HandleValidate( socketStreams *pData,int len,bool &bRight);

		virtual int validateSocket(const char *accountid);

		//bool AnalySock(void *data, unsigned short data_len);
	private:
		char _accountid[MAX_ACCOUNT_ID_SIZE];
	};

}//namespace Au

#endif 