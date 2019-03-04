#include <iostream>
#include "Log.h"
#include "launcher.h"

#include "Network/Network.h"
#include "Util.h"
#include "safe_tech.hpp"

#include "modulemanager.h"
#include "timeinterface.h"
#include "gdata.h"
#include "memcached_test.h"
#include "timer.h"
#include "Common.h"

bool  AnalyParam(int argc, char **argv);

int main(int argc, char** argv)
{
	if (!AnalyParam(argc, argv))
		return -1;
	
	//Memcached_Test();
	Au::Launcher *la = new Au::Launcher();
	if (!la->Init())
	{
		la->Shutdown();
		SAFE_RELEASE(la);
		Log.outError("%s:%d Launcher Init failured.\n", __FUNCTION__, __LINE__);
		return -1;
	}
	la->Start();

#if 1
	uint32 FLUSH_LOG_TIME = 10000;
	uint32 loopcounter = 0;
	uint32 last_time = now();
	uint32 diff = 0;
	uint32 start = 0;
	uint32 etime = 0;
	uint32 flushLogTime = now();
	int t_fore = now();
	int t_hind = 0;
	Au::LuaModuleSpace::LuaModule *tluamodule = NULL;
	tluamodule = Au::LuaModuleSpace::LuaModule::getSingletonPtr();

	while( !Au::GData::g_exit && NULL!=tluamodule)
	{
		t_hind = now();
		if ((t_hind-t_fore)>20)//20ºÁÃë
		{
			Au::TickTimer(t_hind-t_fore);
			t_fore = t_hind;
		}


		start = now();
		diff = start - last_time;
		if(! ((++loopcounter) % 10000) )
		{
			ThreadPool.ShowStats();
			ThreadPool.IntegrityCheck();
			sSocketMgr.ShowStatus();
		}
		UNIXTIME = time(NULL);
		sSocketGarbageCollector.Update();
		last_time = now();
		etime = last_time - start;
		if( 10 > etime )
		{
			Au::Au_Sleep( 10 - etime );
		}
		if (start - flushLogTime > FLUSH_LOG_TIME)
		{
			Log.flushLog();
			flushLogTime = start;
		}
	}

#endif 

	SAFE_RELEASE(la);
	return 0;
}

bool AnalyParam(int argc, char **argv)
{
	if (3!=argc)
		return false;
	Au::Launcher::s_globalconfigpath = std::string(argv[1]);
	Au::Launcher::s_nodename = std::string(argv[2]);
	Log.Init(5,argv[2]);
	return true;
}
