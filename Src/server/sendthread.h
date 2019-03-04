#ifndef _AUENGINE_SRC_AUENGINE_SENDTHREAD_H_
#define _AUENGINE_SRC_AUENGINE_SENDTHREAD_H_
#include "Common.h"
#include "CThreads.h"

namespace Au
{
	class SendThread:public CThread
	{
	public:
		SendThread();
		~SendThread();
		bool run();
	};

}//namespace 

#endif 