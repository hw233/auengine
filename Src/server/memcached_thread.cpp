#include "memcached_thread.h"
#include "memcached_module.h"
#include "modulemanager.h"

namespace Au
{
	MemcachedThread::MemcachedThread()
	{

	}

	MemcachedThread::~MemcachedThread()
	{

	}

	bool MemcachedThread::run()
	{
		//printf("%s:%d \n", __FUNCTION__, __LINE__);
		bool ret = true;
		Au::MemcachedModule *tmm = NULL;
		tmm = dynamic_cast<Au::MemcachedModule*>(Au::ModuleManager::getSingletonPtr()->GetModule(MEMCACHED_MODULE));
		while(NULL!=tmm)
		{
			//printf("%s:%d \n", __FUNCTION__, __LINE__);
			//tmm->Handle();
		}

		return ret;
	}

	void MemcachedThread::OnShutdown()
	{

	}




}