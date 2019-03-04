#ifndef _AUENGINE_SRC_AUENGINE_LUATHREAD_H_
#define _AUENGINE_SRC_AUENGINE_LUATHREAD_H_

#include "lua_engine.h"
#include "Network/Network.h"
#include "CThreads.h"

namespace Au
{

	//会使用LuaModule 的 LuaEngine 和 消息队列
class LuaThread: public CThread
{
public:
	LuaThread();
	~LuaThread();
	bool run();
	void OnShutdown();

};

}//namspace Au

#endif