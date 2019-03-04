#include <iostream>
#include "tolua++.h"
#include "tolua.h"
#include "msgpackage.h"
#include "netmsg_new.h"
#include "param_type_map.h"
#include "analytical_param.h"
#include "lua_engine.h"

using namespace std;
int tolua_All_open (lua_State* pState);
namespace Au
{
	
enum LuaEngineCode{
	lec_success = 0,
	lec_exception,
	lec_unkown,
	lec_no_function,
	lec_input_type,
	lec_output_type,
	lec_arg_error,
	lec_msg_param_error
};
char* _luaEngineMsg[] = {
	"work well done",
	"exception encountered",
	"unknown error",
	"no such function",
	"invalid input param type",
	"invalid output param type",
	"The Socket Function Arg Data Error",
	"Message parameter error."
};

//打印lua错误堆栈
int luaErrorHandler(lua_State *L) 
{
	lua_pop(L, 1);
	lua_getfield(L, LUA_GLOBALSINDEX, "debug");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		return 1;
	}
	lua_getfield(L, -1, "traceback");
	if (!lua_isfunction(L, -1)) {
		lua_pop(L, 2);
		return 1;
	}
	lua_pushvalue(L, 1);
	lua_pushinteger(L, 2);
	lua_call(L, 2, 1);
	return 1;
}

#define TRACE0_WARNING	Log.outLuaString
#define TRACE0_NORMAL	Log.outLuaString
#define TRACE0_ERROR	Log.outError
#define TRACE2_ERROR	Log.outError
#define TRACE1_ERROR	Log.outError

/** 运行错误追踪(信息）
@param   
@param   
@return  
*/
static int luaA_Trace(lua_State *L)
{
	int n = lua_gettop(L);  /* 参数个数 */
	int i;
	lua_getglobal(L, "tostring");
	for (i=1; i<=n; i++) {
		const char *s;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		s = lua_tostring(L, -1);  /* get result */
		if (s == NULL)
			return luaL_error(L, "`tostring' must return a string to `print'");
		if (i>1) TRACE0_NORMAL("\t");
		TRACE0_NORMAL(s);
		lua_pop(L, 1);  /* pop result */
	}
	TRACE0_NORMAL("\n");
	return 0;
}

/** 运行错误追踪(错误）
@param   
@param   
@return  
*/
static int luaA_Error (lua_State *L)
{
	int n = lua_gettop(L);  /* number of arguments */
	int i;
	lua_getglobal(L, "tostring");
	for (i=1; i<=n; i++) {
		const char *s;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		s = lua_tostring(L, -1);  /* get result */
		if (s == NULL)
			return luaL_error(L, "`tostring' must return a string to `print'");
		if (i>1) TRACE0_ERROR("\t");
		TRACE0_ERROR(s);
		lua_pop(L, 1);  /* pop result */
	}
	return 0;
}

/** 运行错误追踪(警告）
@param   
@param   
@return  
*/
static int luaA_Warning(lua_State *L)
{
	int n = lua_gettop(L);  /* number of arguments */
	int i;
	lua_getglobal(L, "tostring");
	for (i=1; i<=n; i++) {
		const char *s;
		lua_pushvalue(L, -1);  /* function to be called */
		lua_pushvalue(L, i);   /* value to print */
		lua_call(L, 1, 1);
		s = lua_tostring(L, -1);  /* get result */
		if (s == NULL)
			return luaL_error(L, "`tostring' must return a string to `print'");
		if (i>1) TRACE0_WARNING("\t");
		TRACE0_WARNING(s);
		lua_pop(L, 1);  /* pop result */
	}
	TRACE0_NORMAL("\n");
	return 0;
}

/** 载入lua文件
@param   
@param   
@return  加载成功返回0
*/
static int luaA_LoadFile(lua_State *L, const char *filename)
{
	int status = -1;

	FILE* fp = fopen( filename, "rb" );
	if( fp )
	{
		fseek(fp, 0, SEEK_END);
		int nLength = ftell(fp);
		fseek(fp, 0, SEEK_SET);

		// 把文件读进内存
		char * pData = new char[nLength + 1]; pData[nLength] = 0;
		fread(pData, 1, nLength, fp);
		fclose(fp);
		status = luaL_loadbuffer(L, pData, nLength, pData);
		delete[] pData;
	}

	return status;
}

/** 载入lua
@param   
@param   
@return  
*/
static int luaA_DoFile(lua_State * L)
{
	size_t l;
	const char * sFileName = luaL_checklstring(L, 1, &l);
	if(sFileName != NULL )
	{
		luaA_LoadFile(L,sFileName);
		return 1;
	}

	return 0;
}

static int luaA_LoaderLua(lua_State *L)
{
	const char *name = luaL_gsub(L, luaL_checkstring(L, 1), ".", LUA_DIRSEP);
	char filename[256];
	sprintf(filename, "%s.luc", name);
	int status = luaA_LoadFile(L, filename);
	if (status != 0) {
		sprintf(filename, "%s.lua", name);
		status = luaA_LoadFile(L, filename);
	}
	if (status != 0) {
		luaL_error(L, "error loading module " LUA_QS " from file " LUA_QS ":\n\t%s",
			lua_tostring(L, 1), name, lua_tostring(L, -1));
	}
	return 1;
}

static int luaA_SetLoader(lua_State *L, lua_CFunction fn)
{
#ifndef FOR_TOOL
	lua_getglobal(L, LUA_LOADLIBNAME);
	if (lua_istable(L, -1)) {
		lua_getfield(L, -1, "loaders");
		if (lua_istable(L, -1)) {
			lua_pushcfunction(L, fn);
			//将fn 替换为loaders数组中的第二个函数，即 loader_lua函数为 fn。
			lua_rawseti(L, -2, 2); 
			return 0;
		}
	}
#endif
	return -1;
}

LuaEngine::LuaEngine(void): m_sLastErr(""),m_pLuaState(NULL),m_bFromPackLoadLua(true)
{
	/*m_pLuaState = NULL;
	m_bFromPackLoadLua = true;*/
}

LuaEngine::~LuaEngine(void)
{
	;
}

bool LuaEngine::Init()
{
	//Part Lua init
	bool bFromPackLoadLua = true;

	//是否从包里载入lua
	m_bFromPackLoadLua = bFromPackLoadLua;
	
	//初始化LUA库  
	m_pLuaState = lua_open();
	if(m_pLuaState == NULL)
	{
		return false;
	}

	//初始化所有的标准库
	luaL_openlibs(m_pLuaState);

	//替换缺省的Lua加载函数
	luaA_SetLoader(m_pLuaState, luaA_LoaderLua);

	//某游戏曾经有过此问题，堆栈太小，出现了频繁的当机
	lua_checkstack(m_pLuaState, 256);

	//初始化一些基本的api
	//替换掉了lua源码中的 luaB_dofile函数，一下类似，详见lua_register api 以及lbaselib.c 中的base_func[]
	lua_register(m_pLuaState, "dofile", luaA_DoFile);
	lua_register(m_pLuaState, "print", luaA_Trace);
	lua_register(m_pLuaState, "trace", luaA_Trace);
	lua_register(m_pLuaState, "error", luaA_Error);
	lua_register(m_pLuaState, "warning", luaA_Warning);

	//初始化Ｃ++导出接口
	tolua_All_open(m_pLuaState);

	return true;
}


bool LuaEngine::InitLuaMessageConfig(MessageConfigReader *mcr)
{
	_msgcfg = mcr;
	return true;
}

void LuaEngine::ShowMsgConfigInfo()
{
	_msgcfg->ShowAll();

}


bool LuaEngine::Destroy()
{
	if(m_pLuaState != NULL)
	{
		lua_close(m_pLuaState);
		m_pLuaState = NULL;
		return true;
	}
	return false;
}

//执行lua函数
bool LuaEngine::RunLuaPublicFunction(const char* szFunName)
{
	return RunLuaFunction(szFunName);
}

bool LuaEngine::HandleLuaFun(unsigned int playerid, void *data, const int datasize)
{
	bool func_ret = true;
	int memory_beg = lua_gc(m_pLuaState, LUA_GCCOUNT, 0);
	int top_lua = lua_gettop(m_pLuaState);
	int res_lua = 0;

	if (!data)
		return false;
	//NetMsg* msg = (NetMsg*)data;
	MsgHead *msg = (MsgHead*)data;
	int param_cnt = 0;
	try
	{
	param_cnt = Au::AnalyticalParam::ReadParam(m_pLuaState, playerid, data, datasize, _msgcfg);
	if (-1==param_cnt)
	{
		m_sLastErr = _luaEngineMsg[lec_no_function];
		res_lua=lec_no_function;
	}
	else if (0==param_cnt)
	{
		m_sLastErr = _luaEngineMsg[lec_arg_error];
		Log.outError("%s  %u \n", _luaEngineMsg[lec_arg_error],msg->msgID );
		res_lua = lec_arg_error;
	}
	else
	{
		res_lua = this->callFunction(param_cnt);
		if (0!=res_lua)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
		int memory_end = lua_gc(m_pLuaState, LUA_GCCOUNT, 0);
		int memory_deleta = memory_end-memory_beg;
		if (100<memory_deleta)
		{
			Log.outError("New memory requested Value: %d,total Memory: %d, MessageID: %d",memory_deleta, memory_end, msg->msgID);
		}
	}
	}
	catch(...)
	{
		m_sLastErr = _luaEngineMsg[res_lua = lec_exception];
	}
	//恢复堆栈
	lua_settop(m_pLuaState, top_lua);
	if (0!=res_lua)
	{
		MsgConfig* msg_config=NULL;//
		msg_config = _msgcfg->GetMsgConfigFromMsgId(msg->msgID);
		if (NULL!=msg_config)
			Log.outError("[LuaEngine] call function %s(...) failed, reason is : \n %s", 
							msg_config->funcname.c_str(), m_sLastErr.c_str()); 
	}
	return (0==res_lua);
}


// 执行一个lua脚本
bool LuaEngine::LoadAndRunLuaFile(const char* szLuaFileName)
{
	if(szLuaFileName == NULL)
	{
		return false;
	}

	//Kirk merged m_bFromPackLoadLua=true/false case 
	//save stack top first
	int top = lua_gettop(m_pLuaState);
	int nResult = 0;
	try{
		nResult = m_bFromPackLoadLua?luaA_LoadFile(m_pLuaState, szLuaFileName):luaL_loadfile(m_pLuaState, szLuaFileName);
		if(nResult == 0)
		{
			nResult = lua_pcall(m_pLuaState, 0, 0, 0);
		}
		//If something goes wrong, try to find the reason
		if(nResult !=0 ){
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
	}catch(...){
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];
	}
	//whatever the case, try to restore the stack top
	lua_settop(m_pLuaState, top);
	if(nResult !=0 )
		TRACE2_ERROR("[LuaModule] load and execute file %s failed, because of %s", szLuaFileName, m_sLastErr.c_str());
	return (nResult == 0);
}

/** 执行一段内存里lua
@param   pLuaData : 载入的lua 数据
@param   nDataLen ：数据长度
@param   
@return  
@note     
@warning 
@retval buffer 
*/
bool LuaEngine::RunMemoryLua(char* pLuaData, int nDataLen)
{
	if(pLuaData == NULL || nDataLen <= 0)
	{
		return false;
	}

	//Kirk add the try/catch routine into the code 
	//save stack top			
	int top = lua_gettop(m_pLuaState);
	int nResult = 0;
	try{
		nResult = luaL_loadbuffer(m_pLuaState, pLuaData, nDataLen, pLuaData);
		if(nResult == 0)
		{
			nResult = lua_pcall(m_pLuaState, 0, 0, 0);
		}
		if(nResult != 0){
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
	}catch(...){
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];
	}
	//restore the stack top
	lua_settop(m_pLuaState, top);
	if(nResult !=0) 
		TRACE1_ERROR("[LuaModule] execute in memory lua block failed, because of %s", m_sLastErr.c_str());
	return (nResult == 0);
}

bool LuaEngine::RunLuaFunction(const char* szFunName )
{
	//Kirk refine the code
	if(!szFunName) return false;
	//save stack top
	int top = lua_gettop(m_pLuaState);

	int nResult = 0;
	try
	{
		lua_getglobal(m_pLuaState, szFunName);
		//Is it a function?
		if(!lua_isfunction(m_pLuaState, -1))
		{
			m_sLastErr = _luaEngineMsg[nResult = lec_no_function];
			goto RFEXIT;
		}

		// 调用执行
		nResult = lua_pcall(m_pLuaState, 0, 0, 0);
		if(nResult != 0)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
	}
	catch (...) {
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];
	}
RFEXIT:
	//restore stack top
	lua_settop(m_pLuaState, top);
	if(nResult != 0)
		TRACE2_ERROR("[LuaModule] call function %s(...) failed, reason is : %s", szFunName, m_sLastErr.c_str());        
	return (nResult == 0);
}

bool LuaEngine::RunLuaFunction(const char* szFunName, float v )
{
	//Kirk refine the code
	if(!szFunName) return false;
	//save stack top
	int top = lua_gettop(m_pLuaState);

	int nResult = 0;
	try
	{
		lua_getglobal(m_pLuaState, szFunName);
		//Is it a function?
		if(!lua_isfunction(m_pLuaState, -1))
		{
			m_sLastErr = _luaEngineMsg[nResult = lec_no_function];
			goto RFEXIT;
		}

		lua_pushnumber(m_pLuaState, v);

		// 调用执行
		nResult = lua_pcall(m_pLuaState, 1, 0, 0);
		if(nResult != 0)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
	}
	catch (...) {
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];
	}
RFEXIT:
	//restore stack top
	lua_settop(m_pLuaState, top);
	if(nResult != 0)
		TRACE2_ERROR("[LuaModule] call function %s(...) failed, reason is : %s", szFunName, m_sLastErr.c_str());        
	return (nResult == 0);
}

bool LuaEngine::RunLuaFunction(const char* szFunName, int v )
{
	//Kirk refine the code
	if(!szFunName) return false;
	//save stack top
	int top = lua_gettop(m_pLuaState);

	int nResult = 0;
	try
	{
		lua_getglobal(m_pLuaState, szFunName);
		//Is it a function?
		if(!lua_isfunction(m_pLuaState, -1))
		{
			m_sLastErr = _luaEngineMsg[nResult = lec_no_function];
			goto RFEXIT;
		}

		lua_pushinteger(m_pLuaState, v);

		// 调用执行
		nResult = lua_pcall(m_pLuaState, 1, 0, 0);
		if(nResult != 0)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
	}
	catch (...) {
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];
	}
RFEXIT:
	//restore stack top
	lua_settop(m_pLuaState, top);
	if(nResult != 0)
		TRACE2_ERROR("[LuaModule] call function %s(...) failed, reason is : %s", szFunName, m_sLastErr.c_str());        
	return (nResult == 0);
}

bool LuaEngine::RunLuaFunction(const char* szFunName, const char* str )
{
	//Kirk refine the code
	if(!szFunName) return false;
	//save stack top
	int top = lua_gettop(m_pLuaState);

	int nResult = 0;
	try
	{
		lua_getglobal(m_pLuaState, szFunName);
		//Is it a function?
		if(!lua_isfunction(m_pLuaState, -1))
		{
			m_sLastErr = _luaEngineMsg[nResult = lec_no_function];
			goto RFEXIT;
		}

		lua_pushstring(m_pLuaState, (char*)str);

		// 调用执行
		nResult = lua_pcall(m_pLuaState, 1, 0, 0);
		if(nResult != 0)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}
	}
	catch (...) {
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];
	}
RFEXIT:
	//restore stack top
	lua_settop(m_pLuaState, top);
	if(nResult != 0)
		TRACE2_ERROR("[LuaModule] call function %s(...) failed, reason is : %s", szFunName, m_sLastErr.c_str());        
	return (nResult == 0);
}

bool LuaEngine::RunLuaFunctionVariablePara(const char *funcname, const char *paraformat, ...)
{
	if (NULL==funcname)
		return false;
	int top = lua_gettop(m_pLuaState);
	int nResult = 0;
	try
	{
		lua_getglobal(m_pLuaState, funcname);
		if (!lua_isfunction(m_pLuaState, -1))
		{
			m_sLastErr = _luaEngineMsg[nResult = lec_no_function];
			goto RFEXIT;
		}
		//analysis parameter.
		int nparams=0;
		va_list vl;
		va_start(vl, paraformat);
		if (!AnalyticalParam::PushValue(m_pLuaState, nparams, paraformat, vl))
		{
			va_end(vl);
			goto RFEXIT;
		}
		va_end(vl);
		//to do.

		nResult = lua_pcall(m_pLuaState, nparams, 0, 0);
		if(nResult != 0)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}

	}
	catch (...)
	{
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];

	}
RFEXIT:
	lua_settop(m_pLuaState, top);
	if(nResult != 0)
		TRACE2_ERROR("[LuaModule] call function %s(...) failed, reason is : %s", funcname, m_sLastErr.c_str());        
	return (nResult == 0);
}

bool LuaEngine::RunLuaFunctionVariableParaModule(const char *funcname, const char *paraformat, va_list vl)
{
	bool ret = true;
	if (NULL==funcname)
		return false;
	int top = lua_gettop(m_pLuaState);
	int nResult = 0;
	try
	{
		lua_getglobal(m_pLuaState, funcname);
		if (!lua_isfunction(m_pLuaState, -1))
		{
			m_sLastErr = _luaEngineMsg[nResult = lec_no_function];
			goto RFEXIT;
		}
		//analysis parameter.
		int nparams=0;
		if (!AnalyticalParam::PushValue(m_pLuaState, nparams, paraformat, vl))
		{
			goto RFEXIT;
		}
	
		nResult = lua_pcall(m_pLuaState, nparams, 0, 0);
		if(nResult != 0)
		{
			const char* pszErrInfor = lua_tostring(m_pLuaState, -1);
			m_sLastErr = pszErrInfor? pszErrInfor : _luaEngineMsg[lec_unkown];
		}

	}
	catch (...)
	{
		m_sLastErr = _luaEngineMsg[nResult = lec_exception];

	}
RFEXIT:
	lua_settop(m_pLuaState, top);
	if(nResult != 0)
		TRACE2_ERROR("[LuaModule] call function %s(...) failed, reason is : %s", funcname, m_sLastErr.c_str());        
	return (nResult == 0);
	return ret;
}

int LuaEngine::callFunction(uint32 nParams)
{

	int result = 0;

	int size0 = lua_gettop(m_pLuaState);

	int error_index = lua_gettop(m_pLuaState) - nParams;
	lua_pushcfunction(m_pLuaState, luaErrorHandler);
	//将luaErrorHandler函数放到要执行的函数下面。
	lua_insert(m_pLuaState, error_index);
	result = lua_pcall(m_pLuaState, nParams, 1, error_index);
	lua_remove(m_pLuaState, error_index);

	if((lua_gettop(m_pLuaState) + (int)nParams  + 1) != size0){

	}

	return result;
}

const char* LuaEngine::GetLastError(void)
{
	return m_sLastErr.c_str();
}

long LuaEngine::getLongGlobalVar(char* szVarName) 
{
	lua_getglobal(m_pLuaState, szVarName);
	return (long) lua_tonumber(m_pLuaState, -1);
}

}//end namespace Au