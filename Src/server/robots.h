#ifndef _AUENGINE_SRC_AUENGINE_ROBOTS_H_
#define _AUENGINE_SRC_AUENGINE_ROBOTS_H_
#include <vector>
#include "Common.h"
#include "Singleton.h"
#include "CThreads.h"
#include "connsocket.h"
#include "modulebase.h"


namespace Au
{
	namespace RobotsSpace
	{
		class Robots: public ModuleBase
		{
		public:
			Robots();
			~Robots();
			bool Init();
			bool Destroy();
			bool Start();
			bool CreateThreads(int n);

			bool ObtainRandomSockfd(unsigned int &res);
		private:
			Mutex _lock_robot;
			//std::vector<unsigned int> _robots;//save all the sockfd
			std::vector<CThread *> _robotthreads;
		};

	}
}

#endif 