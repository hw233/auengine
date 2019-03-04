#include "launcher.h"
#include "modulemanager.h"
#include "Common.h"
#include "Network/Network.h"
#include "sendthread.h"
#include "config_module.h"
#include "sockmgr.h"
#include "gdata.h"
#include "tolua.h"
#include "testcase.h"

namespace Au
{
	
Launcher::Launcher()
{
	
}

Launcher::~Launcher()
{
	
}

bool Launcher::Init()
{
	bool ret = true;
	Au::GData::GDataInit();
	new Au::ModuleManager();
	new SocketMgr;
	new SockMgr;
	new SocketGarbageCollector;
	Au::GData::g_modulemanager = Au::ModuleManager::getSingletonPtr();
	if (NULL==Au::GData::g_modulemanager)
		return false;

	Au::ModuleManager::getSingleton().RegisterModule(CONFIG_MODULE);
	Au::ModuleManager::getSingleton().RegisterModule(SERVER_MAP);
	Au::ConfigManager *tcm = dynamic_cast<Au::ConfigManager*>(Au::ModuleManager::getSingleton()[CONFIG_MODULE]);
	if (NULL==tcm)
	{
		return false;
	}
	if (!tcm->LoadConfig(Au::Launcher::s_globalconfigpath.c_str()))
	{
		Log.outError("Load Config file error.\n");
		return false;
	}
	//0.Socket and ThreadPool should startup, first, because the lua script revoke the c/c++ interface,
	//it will use the threadpool and socketMgr
	
	sSocketMgr.SpawnWorkerThreads();
	ThreadPool.Startup();
	//1.Register LuaModule.
	Au::ModuleManager::getSingleton().RegisterModule(LUA_MODULE);
	if (NULL==Au::GData::g_luamodule)
	{
		Log.outError("Register Lua Module Failured.\n");
		this->Shutdown();
		return false;
	}
	//2.Init LuaModule
	Au::GData::g_luamodule->Init();
	Au::GData::g_luamodule->CreateThreads(1);
	Au::GData::g_luamodule->SetLuaMessageConfig(tcm->GetMessageConfig());
	Au::GData::g_luamodule->LoadAndRunLuaFile(tcm->GetLuaEngineInfo()._entrance_luafile.c_str());
	Au::GData::g_luamodule->RunLuaPublicFunction
		(
		tcm->GetLuaEngineInfo()._initenginefunc.c_str()
		);
	Au::GData::g_luamodule->RunLuaPublicFunction
		(
		tcm->GetLuaEngineInfo()._scriptinitfunc.c_str()
		);
	
	Au::GData::g_luamodule->Start();
	TestCase::TestOfVariPara();
	//3.Destroy Config Module
	Au::ModuleManager::getSingleton().DestroyModule(CONFIG_MODULE);
	Au::initRandSeek();
	return ret;
}

bool Launcher::Start()
{
	bool ret = true;

	ThreadPool.ExecuteTask(new SendThread());
	return ret;
}

bool Launcher::Shutdown()
{
	bool ret = true;

#ifdef WIN32
	

	sSocketMgr.ShutdownThreads();
#endif 
	sSocketMgr.CloseAll();
	ThreadPool.Shutdown();
	Au::ModuleManager::getSingleton().DestroyAll();
	return ret;
}

std::string Launcher::s_globalconfigpath = "";
std::string Launcher::s_nodename = "";

}//namespace Au