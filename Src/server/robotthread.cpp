#include "robotthread.h"
#include <cstdlib>
#include "Util.h"
#include "Network/Network.h"

#include "connsocket.h"
#include "modulemanager.h"
#include "msg_manager.h"
#include "msg_manager.h"
#include "msgpackager.h"
#include "packager_interface.h"
#include "robots.h"
#include "gdata.h"
#include "sockmgr.h"

namespace Au
{
	namespace RobotsSpace
	{
		RobotThread::RobotThread()
		{
		
		}

		RobotThread::~RobotThread()
		{

		}

		bool RobotThread::run()
		{
			bool ret = true;
			if (NULL==Au::GData::g_robotmodule)
			{
				Log.outError("Has you registered Robot Module? \n");
				return false;
			}
			if (NULL==Au::GData::g_luamodule)
			{
				Log.outError("Lua Module hasn't registered.\n");
				return false;
			}
			while (1)
			{
				unsigned int sockfd = 0;
				//printf("%s:%d\n",__FUNCTION__, __LINE__);
				if (Au::GData::g_robotmodule->ObtainRandomSockfd(sockfd) && sockfd!=0)
				{
					/*
					MsgPackager tmp;
					tmp.MessageBegin(sockfd, TEST_MSG_ID);
					int32 a = rand()%100;
					int32 b = rand()%100;
					printf("^^^^^^^Request calc server calc the sum of a:%d and b:%d\n", a, b);
					tmp.AddInt32(a);
					tmp.AddInt32(b);
					tmp.MessageEnd();
					Au::SockMgr::getSingleton().PushMsgToSock(tmp.GetPlayerID(), tmp.GetPackageData(), tmp.GetDataSize());
					
					*/
					
					int tsfd = (int)sockfd;
					//printf("%s:%d sockfd:%u\n", __FUNCTION__, __LINE__, tsfd);
					Au::GData::g_luamodule->RunLuaFunctionVariableParaModule("RobotThreadCallFunc","%d", tsfd);
					Au::Au_Sleep(1000);
				}
			}
			return ret;
		}

		void RobotThread::OnShutdown()
		{

		}

	}//namespace RobotsSpace

}//namespace Au