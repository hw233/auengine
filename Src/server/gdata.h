#ifndef _AU_SRC_SERVER_GDATA_H_
#define _AU_SRC_SERVER_GDATA_H_
#include "modulemanager.h"
#include "memcached_module.h"
#include "lua_module.h"
#include "mysql_module.h"
#include "config_module.h"
#include "robots.h"
#include "servermap.h"
#include "gameconsole.h"
#include "monitor_module.h"

namespace Au
{
	namespace GData
	{
		extern Au::ModuleManager* g_modulemanager;
		//module
		extern Au::LuaModuleSpace::LuaModule *g_luamodule;
		extern Au::ConfigManager   *g_configmodule;
		extern Au::RobotsSpace::Robots   *g_robotmodule;
		extern Au::MysqlModule *g_mysqlmodule;
		extern Au::MemcachedModule *g_memcachedmodule;
		extern Au::ServerMap   *g_servermapmodule;
		extern Au::GameConsoleSpace::GameConsole  *g_gameconsolemodule;
		extern Au::MonitorModule *g_monitormodule;
		//end module
		extern bool g_exit;
		void GDataInit();
	}


}


#endif 