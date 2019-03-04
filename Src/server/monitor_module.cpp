#include "monitor_module.h"
#include "auxiliary_kit.h"
#include <string>
#include <vector>
#include <algorithm>

namespace Au
{
    MonitorModule::MonitorModule()
    {
		_tickcnt = 0;
    }

    MonitorModule::~MonitorModule()
    {

    }

    bool MonitorModule::Init()
    {
        bool ret = true;
        return ret;
    }

    bool MonitorModule::Destory()
    {
        bool ret = true;
        return ret;

    }

    bool MonitorModule::Start()
    {
        bool ret = true;
        return ret;

    }

    bool MonitorModule::CreateThreads(int thread_nums)
    {
        bool ret = true;
        return ret;
    }

    void MonitorModule::Tick()
	{
		//_ticklock.Acquire();
		++_tickcnt;
		//_ticklock.Release();
	}
    
	void MonitorModule::DoWork()
	{
		int t_tickcnt = _tickcnt;
		int CHECK_TIME = 3*ONE_MINNUTE;
		if (t_tickcnt%ONE_TICK ==CHECK_TIME )
		{
			this->NodeCheck();
		}
	}

	bool MonitorModule::NodeCheck()
	{
		bool ret = true;
#ifdef WIN32
		std::string dst;
		char cmd[100] = "\0";
		sprintf(cmd, "wmic process where caption=\"%s\" get commandline /value", EXE_NAME_WINDOWS);
		Kit::ExecCmd(cmd, dst);
		std::vector<std::string> parameters;
		Kit::ObtainCaption(dst, parameters);

		std::vector<std::string> nodenames;
		Kit::ObtainFiled(parameters, 3, nodenames);
		std::vector<ModuleStatusNode>::iterator it_beg = _watched_modules.begin();
		std::vector<ModuleStatusNode>::iterator it_end = _watched_modules.end();
		while (it_beg!=it_end)
		{
			if (std::find(nodenames.begin(), nodenames.end(), it_beg->nodename)==nodenames.end())
			{
				it_beg->status = UNEXIST;

			}
			else
				it_beg->status = EXIST;
			++it_beg;
		}
		//Then  Restart It.
		//To Do

#else
			
#endif
		return ret;
	}


}//namespace Au
