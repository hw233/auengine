#include "gameconsolethread.h"
#include "gdata.h"
#include "Log.h"

namespace Au
{
	namespace GameConsoleSpace
	{
	GameConsoleThread::GameConsoleThread()
	{

	}

	GameConsoleThread::~GameConsoleThread()
	{
	
	}

	bool GameConsoleThread::run()
	{
		bool ret = true;
		char cmd[80];
		while(THREADSTATE_TERMINATE!=GetThreadState())
		{
			memset(cmd, 0, 80);
			fgets(cmd, 80, stdin);
			size_t cnt = strlen(cmd);
			if( 0==strncmp( cmd, "exit", strlen("exit") ) )
			{
				GData::g_exit = true;
			}
			else if ( strncmp( cmd, "CPU", strlen("CPU")) == 0)
			{
				Log.outError("---PRINT CPU: %d    %d   %d  %d", Au::SysInfo::GetCPUCount(), Au::SysInfo::GetCPUUsage(), Au::SysInfo::GetRAMUsage(), Au::SysInfo::GetTickCount());
			}
			else
			{
				if (NULL!=Au::GData::g_luamodule)
				{
					Au::GData::g_luamodule->RunMemoryLua(cmd, cnt);
				}

			}
			Au_Sleep(100);
		}
		return ret;
	}

	void GameConsoleThread::OnShutdown()
	{
		Log.outString("GameConsoleThread ShutDown\n");
	}

	}

}//namesapce Au