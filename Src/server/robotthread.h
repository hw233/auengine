#ifndef _AUENGINE_SRC_AUENGINE_ROBOTTHREAD_H_
#define _AUENGINE_SRC_AUENGINE_ROBOTTHREAD_H_
#include "Network/Network.h"
#include "CThreads.h"

namespace Au
{

	namespace RobotsSpace
	{
		class RobotThread:public CThread
		{
		public:
			RobotThread();
			~RobotThread();
			bool run();
			void OnShutdown();
		};

	}//namespace RobotsSpace

}//namespace Au

#endif 