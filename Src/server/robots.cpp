#include <cstdlib>
#include "robots.h"
#include "connsocket.h"
#include "safe_tech.hpp"
#include "robotthread.h"
#include "sockmgr.h"
#include "config_struct.h"

namespace Au
{
	namespace RobotsSpace
	{
		Robots::Robots()
		{
			
		}


		bool Robots::ObtainRandomSockfd(unsigned int &res)
		{
			bool ret = true;
			res = Au::SockMgr::getSingletonPtr()->GetARandomSockfd();
			if (AU_VALIDE_SOCKET_FD==res)
				ret = false;
			return ret;
		}

		bool Robots::Init()
		{
			CThread *tct = NULL;
			for (int i=0;i<1; ++i)
			{
				tct=new RobotThread();
				_robotthreads.push_back(tct);
			}
			return true;
		}

		bool Robots::Start()
		{
			std::vector<CThread *>::iterator it = _robotthreads.begin();

			for ( ; _robotthreads.end()!=it; ++it)
			{
				printf("%s:%d \n", __FUNCTION__, __LINE__);
				ThreadPool.ExecuteTask(*it);
			}return true;
		}

		bool Robots::CreateThreads(int thread_nums)
		{
			if (thread_nums<=0)
				return false;
			CThread *ct = NULL;
			for (int i=0; i<thread_nums; ++i)
			{
				ct = new RobotThread();
				_robotthreads.push_back(ct);
			}
			return true;
		}


		bool Robots::Destroy()
		{
			return true;
		}
		
		Robots::~Robots()
		{

		}
	}

}//namespace Au