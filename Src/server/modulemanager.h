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
	
	//��ʼ��ģ����Ҫ����Դ
	bool Init();

	//ͨ��ID��ע��ģ��
	ModuleBase* RegisterModule(int module_id);

	//���������������,�ɻ�ȡ��ע��ģ���
	ModuleBase* operator[](int module_id);
	
	ModuleBase* GetModule(int module_id);
	//ͨ��ģ��ID������
	bool DestroyModule(int module_id);

	//ͨ��ģ���õ�ָ��������
	bool DestroyModule(ModuleBase *module);

	//��������ģ��
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
					//��ʼ��������ʧ�ܣ���Init�ɹ����ǲ�����Դ�ͷŵ���
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
	//���ÿ������캯���͸�ֵ����������ǵ�����ʡ�ԣ���Ϊֻ��newһ��
	ModuleManager(const ModuleManager &);
	void operator=(const ModuleManager &);
private:
	std::map<int, ModuleBase*> _modules;
};

}//end namespace Au.

#endif