#ifndef AU_SRC_SERVER_MYSQL_THREAD_H
#define AU_SRC_SERVER_MYSQL_THREAD_H
#include "Network/Network.h"
#include "CThreads.h"

namespace Au
{
	class MysqlThread:public CThread
	{
	public:
		MysqlThread();
		~MysqlThread();
		bool run();
		void OnShutdown();
	private:
	};

}


#endif 