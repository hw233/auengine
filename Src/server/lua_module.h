#ifndef _AUENGINE_SRC_AUENGINE_LUA_MODULE_H_
#define _AUENGINE_SRC_AUENGINE_LUA_MODULE_H_
#include <vector>
#include "lua_engine.h"
#include "Network/Network.h"
#include "CThreads.h"

#include "comm_lua_module.h"
#include "netmsg_new.h"
#include "message_queue.h"
#include "doublemsgqueue.h"
#include "msg_manager.h"
#include "messageconfig_reader.h"
#include "modulebase.h"
#include "luathread.h"
//Rules: 所有其他模块要调用 LuaEngine引擎进行处理的部分，都是通过LuaModule进行调用，
//		LuaModule提供LuaEngine处理的接口，都需要加锁进行处理。因为LuaEngine只有一个，
//		多个线程访问会进行竞争。

namespace Au
{
	
	namespace LuaModuleSpace
	{
	class LuaModule: public ModuleBase, public Singleton<LuaModule>
	{
	public:
		LuaModule();
		~LuaModule();
		bool Init();
		bool Start();
		bool Destroy();
		bool CreateThreads(int n);
		bool onTimer();

	public:
		void PushMsg(void *data, unsigned int playerid, int data_len, const MsgPriority mp=PriorityNormal);
		
		//Part of lua engine
		bool HandleLuaFun(unsigned int playerid, void *data, const int datasize);
		//The follow thread function used _lua, but didn't used the lock, because
		//they should revoke before LuaThread(s) start.
		void SetLuaMessageConfig(MessageConfigReader *mcr);
		bool LoadAndRunLuaFile(const char* szLuaFileName);
		bool RunLuaPublicFunction(const char* szFunName);
		void HandleMsg();
		//For Test
		bool RunMemoryLua(char *luadata, int datalen);
		bool RunLuaFunctionVariablePara(const char *funcname, const char *paraformat, ...);
		bool RunLuaFunctionVariableParaModule(const char *funcname, const char *paraformat, ...);
		
	public:
		void ShowLuaConfigInfo();
	private:
		ModuleMsg* GetMsg(const MsgPriority mp);
		//Get The PriorityUrgency Msg first, if is NULL, then get the NormalMsg
		ModuleMsg* GetMsg();

		//All the _luathreads used the same LuaEngine, so ,all the revoke operator should be locked.
		Mutex _lua_lock;
		
		LuaEngine _lua;

		std::vector<CThread *> _luathreads;
		
		Mutex _lock_msg;
		DoubleMsgQueue<ModuleMsg> _msg;
	};
	}//namespace LuaModule
}//namespace Au
#endif 