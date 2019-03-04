#ifndef _AU_SRC_SERVER_MONITOR_THREAD_H_
#define _AU_SRC_SERVER_MONITOR_THREAD_H_
#include "Threading/Threading.h"
#include "Network/Network.h"
#include "CThreads.h"
namespace Au
{
	class MonitorThread:public CThread
	{
	public:
		MonitorThread();
		~MonitorThread();
		bool run();
		void OnShutdown();

	};//class MonitorThread
}//namespace Au

#endif 