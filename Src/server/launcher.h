#ifndef _AUENGINE_SRC_AUENGINE_ENGINE_LAUNCHER_H_
#define _AUENGINE_SRC_AUENGINE_ENGINE_LAUNCHER_H_
#include <string>
#include "lua_module.h"

namespace Au
{
	
class Launcher
{
public:
	Launcher();
	virtual ~Launcher();

	virtual bool Init();

	virtual bool Start();

	virtual bool Shutdown();
	
	static std::string s_globalconfigpath;
	static std::string s_nodename;
	static Au::LuaModuleSpace::LuaModule *s_luamodule;
private:
	
};

}//namespace Au

#endif