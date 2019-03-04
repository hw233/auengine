#include "mysql_thread.h"
#include "mysql_module.h"
#include "modulemanager.h"
#include "gdata.h"

namespace Au
{
	MysqlThread::MysqlThread()
	{

	}

	MysqlThread::~MysqlThread()
	{

	}

	bool MysqlThread::run()
	{
		bool ret = true;
		while(1)
		{
			Au::GData::g_mysqlmodule->DoWork();
		}
		return ret;
	}

	void MysqlThread::OnShutdown()
	{

	}


}