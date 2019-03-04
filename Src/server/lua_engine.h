#ifndef _AUENGINE_SRC_AUENGINE_LUAENGINE_H_
#define _AUENGINE_SRC_AUENGINE_LUAENGINE_H_

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include <string>
#include "Network/Network.h"
#include "messageconfig_reader.h"

namespace Au
{
	class LuaEngine
	{
	public:
		LuaEngine(void);
		~LuaEngine(void);
		//创建  bFromPackLoadLua : 是否要从文件包里载入lua文件,如果服务器不将lua打包，就可以设标志为flas
		virtual bool Init();

		virtual bool Destroy();

		bool InitLuaMessageConfig(MessageConfigReader *mcr);
		
		//加载并执行一个lua 脚本文件。
		bool LoadAndRunLuaFile(const char* szLuaFileName);

		//运行全局方法
		bool RunLuaPublicFunction(const char* szFunName);

		bool HandleLuaFun(unsigned int playerid, void *data, const int datasize);

		virtual bool RunLuaFunction(const char* szFunName, const char* str );
		virtual bool RunLuaFunction(const char* szFunName );
		virtual bool RunLuaFunction(const char* szFunName, float v );
		virtual bool RunLuaFunction(const char* szFunName, int v );

		virtual bool RunLuaFunctionVariablePara(const char *funcname, const char *paraformat, ...);
		bool RunLuaFunctionVariableParaModule(const char *funcname, const char *paraformat, va_list vl);

		//执行一段内存里lua代码
		virtual bool RunMemoryLua(char* pLuaData, int nDataLen);

		void ShowMsgConfigInfo();
	private:

		
		//取得最近发送的lua错误
		virtual const char*	 GetLastError(void);

		//获取long类型lua全局变量
		virtual long getLongGlobalVar(char* szVarName) ;

		int	callFunction(uint32 nParams);

	private:
		//lua标准
		lua_State *m_pLuaState;

		//是否从包里载入lua
		bool m_bFromPackLoadLua;

		//保存最后一次的错误信息
		std::string	m_sLastErr;

		MessageConfigReader *_msgcfg;
	};
}//namespace Au

#endif