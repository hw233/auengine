#include "modulemanager.h"
#include "modulebase.h"
#include "lua_module.h"
#include "config_module.h"
#include "robots.h"
#include "servermap.h"
#include "mysql_module.h"
#include "memcached_module.h"
#include "gameconsole.h"
#include "gdata.h"

initialiseSingleton(Au::ModuleManager);

namespace Au{
	
ModuleManager::ModuleManager()
{
	
}

bool ModuleManager::Init()
{
	return true;
}

ModuleBase* ModuleManager::RegisterModule(int module_id)
{
	ModuleBase *ret_module = NULL;
	if (module_id<=BEGIN_MODULE || module_id >= END_MODULE)
		return false;
	switch (module_id)
	{
	case LUA_MODULE:
	{
		ret_module = this->RegisterOne<LuaModuleSpace::LuaModule>(LUA_MODULE);
		Au::GData::g_luamodule = dynamic_cast<Au::LuaModuleSpace::LuaModule*>( Au::GData::g_modulemanager->GetModule(LUA_MODULE));
		break;
	}
	case CONFIG_MODULE:
	{
		ret_module = this->RegisterOne<Au::ConfigManager>(CONFIG_MODULE);
		Au::GData::g_configmodule = dynamic_cast<Au::ConfigManager*>( Au::GData::g_modulemanager->GetModule(CONFIG_MODULE));
		break;
	}
	case NETWORK_MODULE:
	{	
		break;
	}
	case ROBOTS_MODULE:
	{
		ret_module = this->RegisterOne<Au::RobotsSpace::Robots>(ROBOTS_MODULE);
		Au::GData::g_robotmodule = dynamic_cast<Au::RobotsSpace::Robots*>( Au::GData::g_modulemanager->GetModule(ROBOTS_MODULE));
		break;
	}
	case MYSQL_MODULE:
	{
		ret_module = this->RegisterOne<Au::MysqlModule>(MYSQL_MODULE);
		if (NULL==ret_module)
			Log.outError("Register Failured.\n");
		else
			Log.outError("Regiser successed.\n");
		Au::GData::g_mysqlmodule = dynamic_cast<Au::MysqlModule*>( Au::GData::g_modulemanager->GetModule(MYSQL_MODULE));
		break;
	}
	case MEMCACHED_MODULE:
	{
		ret_module = this->RegisterOne<Au::MemcachedModule>(MEMCACHED_MODULE);
		Au::GData::g_memcachedmodule = dynamic_cast<Au::MemcachedModule*>( Au::GData::g_modulemanager->GetModule(MEMCACHED_MODULE));
		break;
	}
	case SERVER_MAP:
	{
		ret_module = this->RegisterOne<Au::ServerMap>(SERVER_MAP);
		Au::GData::g_servermapmodule = dynamic_cast<Au::ServerMap*>( Au::GData::g_modulemanager->GetModule(SERVER_MAP));
		break;
	}
	case GAMECONSOLE_MODULE:
	{
		ret_module = this->RegisterOne<Au::GameConsoleSpace::GameConsole>(GAMECONSOLE_MODULE);
		Au::GData::g_gameconsolemodule = dynamic_cast<Au::GameConsoleSpace::GameConsole*>( Au::GData::g_modulemanager->GetModule(GAMECONSOLE_MODULE));
		break;
	}
	default:
	{
		ret_module = NULL;
	}

	}

	return ret_module;
}

ModuleBase* ModuleManager::operator[](int module_id)
{
	if (IsExist(module_id))
		return _modules[module_id];
	else
		return NULL;
}

ModuleBase* ModuleManager::GetModule(int module_id)
{
	if (IsExist(module_id))
		return _modules[module_id];
	else
		return NULL;
}

bool ModuleManager::DestroyModule(int module_id)
{
	if (BEGIN_MODULE>=module_id || END_MODULE<=module_id)
		return false;
	if (!IsExist(module_id))
		return false;

	if (!_modules[module_id]->Destroy())
		return false;
	else
	{
		delete _modules[module_id];
		_modules.erase(module_id);
	}	
	return true;
}

bool ModuleManager::DestroyModule(ModuleBase* module)
{
	//Check first,  the module pointer whther exist.
	std::map<int, ModuleBase *>::iterator it_beg = _modules.begin();
	std::map<int, ModuleBase *>::iterator it_end = _modules.end();
	while (it_beg!=it_end)
	{
		if (module==it_beg->second)
			break;
		++it_beg;
	}
	if (it_beg==it_end)
		return false;
	module->Destroy();
	delete module;
	module=NULL;
	_modules.erase(it_beg);
	return true;;
}

bool ModuleManager::DestroyAll()
{
	//逐个释放，考虑单个Destroy不成功的情况，单个模块不成功就退出，停止对其他模块的释放，
	//返回失败，后续行为由调用者去处理
	typedef std::map<int, ModuleBase*>::iterator map_iterator;
	for (map_iterator it=_modules.begin(); it!=_modules.end(); it = _modules.begin())
	{
		if (!it->second->Destroy())
			return false;
		delete it->second;
		_modules.erase(it);
	}
	return true;
}

ModuleManager::~ModuleManager()
{
	this->DestroyAll();
}

inline bool ModuleManager::IsRegister(int module_id)
{
	return IsExist(module_id);
}

inline bool ModuleManager::IsExist(int module_id)
{
	return (_modules.find(module_id)!=_modules.end());
}

}//end namespace Au
