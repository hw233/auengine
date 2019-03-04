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
		//����  bFromPackLoadLua : �Ƿ�Ҫ���ļ���������lua�ļ�,�������������lua������Ϳ������־Ϊflas
		virtual bool Init();

		virtual bool Destroy();

		bool InitLuaMessageConfig(MessageConfigReader *mcr);
		
		//���ز�ִ��һ��lua �ű��ļ���
		bool LoadAndRunLuaFile(const char* szLuaFileName);

		//����ȫ�ַ���
		bool RunLuaPublicFunction(const char* szFunName);

		bool HandleLuaFun(unsigned int playerid, void *data, const int datasize);

		virtual bool RunLuaFunction(const char* szFunName, const char* str );
		virtual bool RunLuaFunction(const char* szFunName );
		virtual bool RunLuaFunction(const char* szFunName, float v );
		virtual bool RunLuaFunction(const char* szFunName, int v );

		virtual bool RunLuaFunctionVariablePara(const char *funcname, const char *paraformat, ...);
		bool RunLuaFunctionVariableParaModule(const char *funcname, const char *paraformat, va_list vl);

		//ִ��һ���ڴ���lua����
		virtual bool RunMemoryLua(char* pLuaData, int nDataLen);

		void ShowMsgConfigInfo();
	private:

		
		//ȡ��������͵�lua����
		virtual const char*	 GetLastError(void);

		//��ȡlong����luaȫ�ֱ���
		virtual long getLongGlobalVar(char* szVarName) ;

		int	callFunction(uint32 nParams);

	private:
		//lua��׼
		lua_State *m_pLuaState;

		//�Ƿ�Ӱ�������lua
		bool m_bFromPackLoadLua;

		//�������һ�εĴ�����Ϣ
		std::string	m_sLastErr;

		MessageConfigReader *_msgcfg;
	};
}//namespace Au

#endif