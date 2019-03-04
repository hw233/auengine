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

#define MAX_LUA_FUNC_PARA_NUM	60//LUA�������60������
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
	//����-1��ָ���Ľű����������ڣ�����0�������󣬷��ش������ֵ����ʾ��ȷ��ȡ�����ĸ���
	int ReadParam(lua_State *L, unsigned int playid, void *data, const int datasize, MessageConfigReader *msgcfg);

	//��data�ж�ȡִ��Lua�ű�������Ҫ��ʵ��,�ɹ����� currpos��ֵ��ı�
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