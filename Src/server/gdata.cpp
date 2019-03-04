#include "gdata.h"

namespace Au
{
	namespace GData
	{
		Au::ModuleManager *g_modulemanager;
		
		Au::LuaModuleSpace::LuaModule *g_luamodule;
		Au::ConfigManager   *g_configmodule;
		Au::RobotsSpace::Robots   *g_robotmodule;
		Au::MysqlModule *g_mysqlmodule;
		Au::MemcachedModule *g_memcachedmodule;
		Au::ServerMap   *g_servermapmodule;
		Au::GameConsoleSpace::GameConsole  *g_gameconsolemodule;
		Au::MonitorModule *g_monitormodule;
		bool g_exit; 
		void GDataInit()
		{
			g_modulemanager = NULL;
			g_luamodule = NULL;
			g_configmodule = NULL;
			g_robotmodule = NULL;
			g_mysqlmodule = NULL;
			g_memcachedmodule = NULL;
			g_servermapmodule = NULL;
			g_gameconsolemodule = NULL;
			g_monitormodule = NULL;
			g_exit = false;
		}
	}
}