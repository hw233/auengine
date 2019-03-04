#include "Log.h"
#include "memcached_module.h"
#include "memcached_thread.h"
#include "config_module.h"
#include "modulemanager.h"
#include "oper_member.h"

namespace Au
{
	MemcachedModule::MemcachedModule():_memcached_client(NULL)
	{

	}

	MemcachedModule::~MemcachedModule()
	{

	}

	bool MemcachedModule::Init()
	{
		bool ret = true;
		_memcached_client = new MemCacheClient();
		//To Do
		Au::ConfigManager *tcm_config = NULL;
		tcm_config = dynamic_cast<Au::ConfigManager*>(Au::ModuleManager::getSingletonPtr()->GetModule(CONFIG_MODULE));
		if (NULL==tcm_config)
			return false;
		MemcachedInfo *tmi = NULL;
		tmi = tcm_config->GetMemcachedInfo(Au::Launcher::s_nodename);
		if (NULL==tmi)
			return false;
		std::string tip;
		std::string tport;
		std::string tname;
		
		tip = tmi->_ip;
		tport = tmi->_port;
		tname = tmi->_name;
		std::string server_addr = tip+":"+tport;
		ret = this->AddServer(server_addr.c_str(), tname.c_str());
		if (ret)
			printf("%s:%d memcached Addserver successed.\n",__FUNCTION__, __LINE__);
		this->CreateThreads(1);
		return ret;
	}

	bool MemcachedModule::Destroy()
	{
		bool ret = true;

		return ret;

	}

	bool MemcachedModule::Start()
	{
		bool ret = true;	
		return ret;
	}

	bool MemcachedModule::CreateThreads(int thread_nums)
	{
		bool ret = true;
		return ret;
	}

	bool MemcachedModule::AddServer(const char *serveraddress, const char *servername, unsigned services /* = (unsigned)-1 */)
	{
		return _memcached_client->AddServer(serveraddress, servername, services);
	}

	void MemcachedModule::HandleOne(Oper &to)
	{
		switch (to.opertype)
		{
		case MEMCACHED_OPER_ADD:
			_memcached_client->Add(to.item);//ok
			break;
		case  MEMCACHED_OPER_SET:
			_memcached_client->Set(to.item);
			break;
		case MEMCACHED_OPER_REPLACE:
			_memcached_client->Replace(to.item);
			break;
		case MEMCACHED_OPER_APPEND:
			_memcached_client->Append(to.item);
			break;
		case MEMCACHED_OPER_PREPEND:
			_memcached_client->Prepend(to.item);
			break;
		case MEMCACHED_OPER_DEL:
			_memcached_client->Del(to.item);
			break;
		case MEMCACHED_OPER_INCREMENT:
			_memcached_client->Increment(to.item.mKey.c_str(), &(to.newvalue), to.diff);
			break;
		case MEMCACHED_OPER_DECREMENT:
			_memcached_client->Decrement(to.item.mKey.c_str(), &(to.newvalue), to.diff);
			break;
		default:
			Log.outError("Memcached Error Operator Command.\n");
		}
	}

	std::string MemcachedModule::Get(std::string key, int count)
	{
		string ret;
		char *p = NULL;
		MemCacheClient::MemRequest item;
		item.mKey = key;
		if (_memcached_client->Get(&item, count))
		{
			int datalen = item.mData.GetReadSize();
			p = new char[datalen];
			item.mData.ReadBytes((void *)p, datalen);
			ret.assign(p, datalen);
			delete []p;
		}	
		return ret;
	}
}//namespace Au