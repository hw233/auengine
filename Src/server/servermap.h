#ifndef _AUENGINE_SRC_SERVER_SERVERMAP_H_
#define _AUENGINE_SRC_SERVER_SERVERMAP_H_
#include <map>
#include "modulebase.h"

namespace Au
{
	class ServerMap:public ModuleBase
	{
	public:
		ServerMap();
		~ServerMap();
		bool Init();
		bool Destroy();
		bool Start();
		bool ObtainSockFd(int rand_key, unsigned int &res);
		bool Insert(int rand_key, unsigned int sockfd);
		bool IsExist(int rand_key);
	private:
		//key: rand_key, value: sockfd
		std::map<int, unsigned int> _server;
	};
}

#endif 