#include "luathread.h"
#include "lua_module.h"
#include "Util.h"
#include "timeinterface.h"
#include "gdata.h"

namespace Au
{
	LuaThread::LuaThread()
	{

	}

	LuaThread::~LuaThread()
	{

	}

	bool LuaThread::run()
	{
		Au::LuaModuleSpace::LuaModule *tlm = NULL;
		tlm = Au::LuaModuleSpace::LuaModule::getSingletonPtr();
		while (1)
		{
			Au::GData::g_luamodule->HandleMsg();
			//tlm->HandleMsg();
			Au::Au_Sleep(10);
		}
		return true;
	}

	void LuaThread::OnShutdown()
	{

		
	}
}