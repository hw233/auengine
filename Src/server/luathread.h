#ifndef _AUENGINE_SRC_AUENGINE_LUATHREAD_H_
#define _AUENGINE_SRC_AUENGINE_LUATHREAD_H_

#include "lua_engine.h"
#include "Network/Network.h"
#include "CThreads.h"

namespace Au
{

	//��ʹ��LuaModule �� LuaEngine �� ��Ϣ����
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