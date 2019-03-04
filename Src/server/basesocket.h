#pragma once

#ifndef _BASESOCKET_H
#define _BASESOCKET_H
#include "Network/Network.h"
//#include "netmsg.h"
#include "netmsg_new.h"

class BaseSocket : public Socket
{
public:
	BaseSocket( SOCKET fd );
	~BaseSocket(void);

	// Called when data is received.
	virtual void OnRead();

	// Called when a connection is first successfully established.
	virtual void OnConnect();

	// Called when the socket is disconnected from the client (either forcibly or by the connection dropping)
	virtual void OnDisconnect();
private:
	char msg[MAX_BUFFER_SIZE];

protected:
	
	virtual void handleMessage(socketStreams *pData,int len,bool &bRight){}

};


#endif  //_BASESOCKET_H