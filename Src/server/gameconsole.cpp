#include "gameconsole.h"
#include "gameconsolethread.h"
#include "Log.h"

namespace Au
{
	namespace GameConsoleSpace
	{
	GameConsole::GameConsole()
	{

	}

	GameConsole::~GameConsole()
	{

	}

	bool GameConsole::CreateThreads(int thread_nums)
	{
		bool ret = true;
		if (thread_nums<=0)
			return false;
		CThread *ct = NULL;
		for (int i=0; i<thread_nums; ++i)
		{
			ct = new GameConsoleThread();
			_gameconsolethreads.push_back(ct);
		}
		return ret;
	}

	bool GameConsole::Init()
	{
		return true;
	}

	bool GameConsole::Start()
	{
		Log.outString("GameConsole Started.\n");
		std::vector<CThread *>::iterator it = _gameconsolethreads.begin();
		for (; _gameconsolethreads.end()!=it; ++it)
		{
			ThreadPool.ExecuteTask(*it);
		}
		return true;
	}

	bool GameConsole::Destroy()
	{
		return true;
	}

	}
}//namespace Au