#include "gdata.h"
#include "monitor_thread.h"

namespace Au
{
	MonitorThread::MonitorThread()
	{

	}

	MonitorThread::~MonitorThread()
	{

	}

	bool MonitorThread::run()
	{
		bool ret = true;
		if (!Au::GData::g_monitormodule)
			return false;
		while(1)
		{
			Au::GData::g_monitormodule->DoWork();//	if ()
		}

		return ret;
	}

	void MonitorThread::OnShutdown()
	{
		return ;
	}
}