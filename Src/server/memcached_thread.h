#ifndef _AU_SRC_SERVER_MEMCACHED_THREAD_H_
#define _AU_SRC_SERVER_MEMCACHED_THREAD_H_
#include "Network/Network.h"
#include "CThreads.h"

namespace Au
{
	class MemcachedThread:public CThread
	{
	public:
		MemcachedThread();
		~MemcachedThread();
		bool run();
		void OnShutdown();
	private:
	};


}

#endif 
