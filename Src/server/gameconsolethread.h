#ifndef _AUENGINE_SRC_AUENGINE_GAMECONSOLETHREAD_H_
#define _AUENGINE_SRC_AUENGINE_GAMECONSOLETHREAD_H_
#include "Network/Network.h"
#include "CThreads.h"

namespace Au
{
	namespace GameConsoleSpace
	{
	class GameConsoleThread:public CThread
	{
	public:
		GameConsoleThread();
		~GameConsoleThread();
		bool run();
		void OnShutdown();
	};

	}//namesapce GameConsoleSpace
}//namespace Au

#endif 