#ifndef _AUENGINE_SRC_AUENGINE_MODULEMANAGER_H_
#define _AUENGINE_SRC_AUENGINE_MODULEMANAGER_H_
#include <map>
#include "Common.h"
#include "Singleton.h"
#include "modulebase.h"
#define BEGIN_MODULE		0
#define LUA_MODULE			1		//lua module
#define CONFIG_MODULE		2		//
#define NETWORK_MODULE		3		// network module
#define ROBOTS_MODULE		4
#define MYSQL_MODULE		5
#define MEMCACHED_MODULE	6
#define SERVER_MAP			7
#define GAMECONSOLE_MODULE	8
#define END_MODULE			GAMECONSOLE_MODULE +1		//end module flag.


namespace Au
{
class ModuleManager:public Singleton< ModuleManager >
{
public:
	ModuleManager();
	~ModuleManager();
	
	//初始化模块需要的资源
	bool Init();

	//通过ID来注册模块
	ModuleBase* RegisterModule(int module_id);

	//重载中括号运算符,可获取已注册模块的
	ModuleBase* operator[](int module_id);
	
	ModuleBase* GetModule(int module_id);
	//通过模块ID来销毁
	bool DestroyModule(int module_id);

	//通过模块获得的指针来销毁
	bool DestroyModule(ModuleBase *module);

	//销毁所有模块
	bool DestroyAll();

	inline bool IsRegister(int module_id);

private:

	template<typename Type>
	ModuleBase* RegisterOne(int module_id)
	{
		ModuleBase *ret_module = NULL;
		if (!this->IsExist(module_id))//unregister.
		{
			ModuleBase *t_module = new Type();
			if (t_module)
			{
				if (t_module->Init())
				{
					_modules[module_id] = t_module;
					ret_module = t_module;
				}
				else
				{
					//初始化过程中失败，将Init成功的那部分资源释放掉。
					t_module->Destroy();
					delete t_module;
					t_module = NULL;
				}
			}
		}
		else // Registered.
		{
			ret_module = _modules[module_id];
		}
		return ret_module;
	}

	inline bool IsExist(int module_id);
	//禁用拷贝构造函数和赋值运算符，因是单例可省略，因为只能new一次
	ModuleManager(const ModuleManager &);
	void operator=(const ModuleManager &);
private:
	std::map<int, ModuleBase*> _modules;
};

}//end namespace Au.

#endif