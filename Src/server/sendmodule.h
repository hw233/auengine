#ifndef _AUENGINE_SRC_SERVER_SENDMODULE_H_
#define _AUENGINE_SRC_SERVER_SENDMODULE_H_
#include <vector>
#include "Common.h"
#include "CThreads.h"
#include "modulebase.h"
#include "sendthread.h"

namespace Au
{
	namespace SendModuleSpace
	{
		class SendModule:public ModuleBase
		{
		public:
			SendModule();
			~SendModule();
			bool Init();
			bool Destroy();
			bool Start();
		private:
			//Au::SocketsMgr _socks;
			std::vector<CThread*> _sendthreads;
		};//class SendModule
	}//namespace SendModuleSpace
}//namespace Au

#endif 