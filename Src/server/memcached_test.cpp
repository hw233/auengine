#include "memcached_test.h"
#include "MemCacheClient.h"
#ifdef WIN32
# include <winsock2.h>
# pragma comment(lib, "ws2_32.lib")
#endif
void Memcached_Test()
{
#ifdef WIN32
	WSADATA wsaData;
	int rc = WSAStartup(MAKEWORD(2,0), &wsaData);
	if (rc != 0) {
		printf("Failed to start winsock\n");
		return ;
	}
#endif

	MemCacheClient *client = new MemCacheClient;
	char server[1024]="127.0.0.1:11211";

	if (!client->AddServer(server))
		printf("Failed To add Server:%s \n",server);
	else
		printf("Add Server Successed.\n");

	MemCacheClient::MemRequest item;
	item.mKey = "TestSet4";
	item.mData.WriteBytes("Value3", sizeof("Value4"));
	if (1==client->Set(item))
		printf("Add successed.\n");
	else
		printf("Memcached Add Failured.\n");
	if (item.mResult==MCERR_OK)
		printf("Set Successed.\n");
	else
		printf("Set Failured.\n");
	#ifdef WIN32
		WSACleanup();
	#endif
}