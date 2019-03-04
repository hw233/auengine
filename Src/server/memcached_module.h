#ifndef _AU_SRC_SERVER_MEMCACHED_MODULE_H_
#define _AU_SRC_SERVER_MEMCACHED_MODULE_H_
#include <queue>
#include <vector>
#include "Network/Network.h"
#include "CThreads.h"
#include "modulebase.h"
#include "MemCacheClient.h"
#include "oper_member.h"

namespace Au
{
	class MemcachedModule:public ModuleBase
	{
	public:
		MemcachedModule();
		~MemcachedModule();
		bool Init();
		bool Destroy();
		bool Start();
		bool CreateThreads(int thread_nums);

	public:
		bool AddServer(const char *serveraddress, const char *servername, unsigned services = (unsigned)-1);
		std::string Get(std::string key, int count);
		void HandleOne(Oper &to);
		
	public:

		MemCacheClient *_memcached_client;

	};


}

#endif 