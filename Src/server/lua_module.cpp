#include "Util.h"

#include "lua_module.h"
#include "msg_manager.h"
#include "packager_interface.h"

initialiseSingleton(Au::LuaModuleSpace::LuaModule);

namespace Au
{
	namespace LuaModuleSpace
	{
	LuaModule::LuaModule()
	{

	}

	LuaModule::~LuaModule()
	{
		
	}
	void LuaModule::SetLuaMessageConfig(MessageConfigReader *mcr)
	{
		_lua.InitLuaMessageConfig(mcr);
	}

	void LuaModule::ShowLuaConfigInfo()
	{
		_lua.ShowMsgConfigInfo();
	}

	bool LuaModule::Init()
	{
		if (!_lua.Init())
			return false;
		return true;
	}

	bool LuaModule::Start()
	{
		std::vector<CThread*>::iterator it_beg = _luathreads.begin();
		std::vector<CThread*>::iterator it_end = _luathreads.end();

		while (it_beg!=it_end)
		{
			ThreadPool.ExecuteTask(*it_beg);
			++it_beg;
		}
		return true;
	}

	bool LuaModule::Destroy()
	{
		if (!_lua.Destroy())
			return false;
		return true;
	}

	bool LuaModule::onTimer()
	{
		bool ret = true;
		return ret;
	}
	
	bool LuaModule::CreateThreads(int thread_nums)
	{
		bool ret = true;
		if (thread_nums<=0)
			return false;
		CThread *ct = NULL;
		for (int i=0; i<thread_nums; ++i)
		{
			ct = new LuaThread();
			_luathreads.push_back(ct);
		}
		return ret;
	}
	bool LuaModule::HandleLuaFun(unsigned int playerid, void *data, const int datasize)
	{
		bool ret = false;
		MsgHead *head = (MsgHead*)data;
		ret =  (_lua.HandleLuaFun(playerid, data, datasize));
		if(false==ret)
			Au::checkPackError();
		return ret;
	}

	void LuaModule::HandleMsg()
	{
		_lua_lock.Acquire();
		_lock_msg.Acquire();
		ModuleMsg *msg = this->GetMsg();
		if(NULL!=msg)
			this->HandleLuaFun(msg->playerID, msg->param, msg->msgLen);
		_lock_msg.Release();
		_lua_lock.Release();
	}

	bool LuaModule::LoadAndRunLuaFile(const char* szLuaFileName)
	{
		bool ret = false;
		_lua_lock.Acquire();
		ret =  _lua.LoadAndRunLuaFile(szLuaFileName);
		_lua_lock.Release();
		return ret;
	}
	
	bool LuaModule::RunLuaPublicFunction(const char* szFunName)
	{
		bool ret = false;
		_lua_lock.Acquire();
		ret = _lua.RunLuaPublicFunction(szFunName);
		_lua_lock.Release();
		return ret;
	}

	bool LuaModule::RunMemoryLua(char *luadata, int datalen)
	{
		bool ret = true;
		_lua_lock.Acquire();
		ret = _lua.RunMemoryLua(luadata, datalen);
		_lua_lock.Release();
		return ret;
	}

	bool LuaModule::RunLuaFunctionVariablePara(const char *funcname, const char *paraformat, ...)
	{
		bool ret = true;
		va_list vl;
		va_start(vl, paraformat);
		_lua_lock.Acquire();
		ret = _lua.RunLuaFunctionVariablePara(funcname, paraformat, vl);
		_lua_lock.Release();
		va_end(vl);
		return ret;
	}

	bool LuaModule::RunLuaFunctionVariableParaModule(const char *funcname, const char *paraformat, ...)
	{
		bool ret = true;
		va_list vl;
		_lua_lock.Acquire();
		va_start(vl, paraformat);
		ret = _lua.RunLuaFunctionVariableParaModule(funcname,paraformat, vl);
		va_end(vl);
		_lua_lock.Release();
		return ret;
	}
	void LuaModule::PushMsg(void *data, unsigned int playerid, int data_len, const MsgPriority mp)
	{
		_lock_msg.Acquire();
		_msg.PushMsg(data, playerid, data_len, mp);
		_lock_msg.Release();
	}

	ModuleMsg* LuaModule::GetMsg(const MsgPriority mp)
	{
		ModuleMsg *msg = NULL;
		msg = _msg.GetMsg(mp);
		return msg;
	}

	ModuleMsg* LuaModule::GetMsg()
	{
		ModuleMsg *msg = NULL;
		msg = _msg.GetMsg(PriorityUrgency);
		if (NULL==msg )
			msg = _msg.GetMsg(PriorityNormal);
		return msg;
	}
	
	}//namespace LuaModule
}//namesapce Au