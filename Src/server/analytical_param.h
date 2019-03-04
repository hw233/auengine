#ifndef _AUENGINE_SRC_AUENGINE_ANALYTICAL_PARAM_H_
#define _AUENGINE_SRC_AUENGINE_ANALYTICAL_PARAM_H_
#include <stdlib.h>
#include <string>

#include "messageconfig_reader.h"
extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}
#include "Common.h"

#define MAX_LUA_FUNC_PARA_NUM	60//LUA函数最多60个参数
#define PARA_CHAR	1
#define PARA_INT	2
#define PARA_FLOAT	3
#define PARA_DOUBLE 4
#define PARA_BOOL	5
#define PARA_STRING	6


namespace Au
{
namespace AnalyticalParam
{
//public:
	//返回-1，指定的脚本函数不存在，返回0参数错误，返回大于零的值，表示正确读取参数的个数
	int ReadParam(lua_State *L, unsigned int playid, void *data, const int datasize, MessageConfigReader *msgcfg);

	//从data中读取执行Lua脚本函数需要的实参,成功调用 currpos的值会改变
	bool ReadParamData(lua_State *L, const int datatype, char *data, int &currpos, const int datasize);

	
	int  AnalysisVariablePara(const char *format, int *resarr, int arrlen);

	bool PushValue(lua_State *L, int &nparams, const char *paraformat, va_list vl);

	template<typename Type>
	bool ReadParamTemplate(lua_State *L,char *data, int &currentpos, int datasize);
	bool ReadParamFloat(lua_State *L, char *data, int &currentpos, int datasize);
	bool ReadParamString(lua_State *L, char *data, int &currentpos, int datasize);
}

template<typename Type>
bool AnalyticalParam::ReadParamTemplate(lua_State *L,char *data, int &currentpos, int datasize)
{
	if (currentpos+(int)sizeof(Type)<=datasize)
	{
		Type val = *((Type*)&(data[currentpos]));
		lua_pushinteger(L, val);
		currentpos += sizeof(Type);
		return true;
	}
	else
		return false;
	return false;
}

}//namespace Au



#endif