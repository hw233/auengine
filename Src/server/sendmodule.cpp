#include "sendmodule.h"

namespace Au
{
	namespace SendModuleSpace
	{
		SendModule::SendModule()
		{

		}

		SendModule::~SendModule()
		{

		}

		bool SendModule::Init()
		{
			bool ret = true;
			return ret;
		}

		bool SendModule::Start()
		{
			std::vector<CThread*>::const_iterator it_beg = _sendthreads.begin();
			std::vector<CThread*>::const_iterator it_end = _sendthreads.end();

			while (it_beg!=it_end)
			{
				ThreadPool.ExecuteTask(*it_beg);
				++it_beg;
			}
	
			return true;
		}

		bool SendModule::Destroy()
		{
			bool ret = true;
			return ret;			
		}

	}//namespace SendModuleSpace
}//namespace Au