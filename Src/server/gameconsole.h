#ifndef _AUENGINE_SRC_AUENGINE_GAMECONSOLE_H_
#define _AUENGINE_SRC_AUENGINE_GAMECONSOLE_H_

#include <vector>
#include "Common.h"
#include "CThreads.h"
#include "modulebase.h"
namespace Au
{
	namespace GameConsoleSpace
	{
	class GameConsole:public ModuleBase
	{
	public:
		GameConsole();
		~GameConsole();
		bool Init();
		bool CreateThreads(int n);
		bool Start();
		bool Destroy();
		

	private:
		Mutex _lock_robot;
		std::vector<CThread *> _gameconsolethreads;
	};
	}//namespace GameConsoleSpace


}//namespace Au


#endif