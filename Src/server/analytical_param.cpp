#include "analytical_param.h"
#include "Common.h"
#include "netmsg_new.h"
#include "param_type_map.h"
#include "Log.h"
#include <stdarg.h>
namespace Au
{
	namespace AnalyticalParam
	{

	
	int ReadParam(lua_State *L, unsigned int playerid, void *data, const int datasize,MessageConfigReader *msgcfg)
	{
		int para_cnt = 0;
		MsgHead *msg = (MsgHead *)data;
		MsgConfig *config = msgcfg->GetMsgConfigFromMsgId(msg->msgID);
		if (NULL==config)
			return para_cnt;
		lua_getglobal(L, config->funcname.c_str());
		if (!lua_isfunction(L, -1))
		{
			return -1;
		}
		lua_pushinteger(L, playerid);
		++para_cnt;

		std::vector<int> &types = config->parameters;
		char *data_head = (char *)data;
		int currentpos = sizeof(MsgHead)-sizeof(long);

		if (0<types.size() && types[0]==LUA_PARAM_TYPE_REPEAT)
		{
			int repeatcnt=0;
			if (currentpos+(int)sizeof(uint16)<=datasize)
			{
				repeatcnt = *((uint16*)&(data_head[currentpos]));
				if (repeatcnt<=0)
				{
					para_cnt = 0;
				}
				else
				{
					++para_cnt;
					currentpos += sizeof(uint16);
					lua_pushinteger(L, repeatcnt);
				}
			}

			for (int i=0; i<repeatcnt ; ++i)
			{
				for (unsigned int j=1; j<types.size(); ++j)
				{
					if (!ReadParamData(L, types[j], data_head, currentpos, datasize))
					{
						para_cnt = 0;
						//i = repeatcnt 与下一句的break结合，提前退出循环，减少判断
						i = repeatcnt;
						break;
					}
					else
						++para_cnt;
				}
			}
		}
		else
		{
			for (unsigned int i=0; i<types.size(); ++i)
			{
				if (!ReadParamData(L, types[i], data_head, currentpos, datasize))
				{
					para_cnt = 0;
					break;
				}
				else
					++para_cnt;
			}
		}
		return para_cnt;
	}

	bool ReadParamData(lua_State *L, const int datatype, char *data, int &currentpos, const int datasize)
	{
		bool ret = true;
		switch (datatype)
		{
		case LUA_PARAM_TYPE_UINT32:
			{
				if (!ReadParamTemplate<uint32>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_INT32:
			{
				if (!ReadParamTemplate<int32>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_UINT16:
			{
				if (!ReadParamTemplate<uint16>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_INT16:
			{
				if (!ReadParamTemplate<int16>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_UINT8:
			{
				if (!ReadParamTemplate<uint8>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_INT8:
			{
				if (!ReadParamTemplate<int8>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_BOOL:
			{
				if (!ReadParamTemplate<bool>(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_FLOAT:
			{
				if (!ReadParamFloat(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		case LUA_PARAM_TYPE_STRING:
			{
				if (!ReadParamString(L, data, currentpos, datasize))
					ret = false;
				break;
			}
		}

		return ret;
	}

	int AnalysisVariablePara(const char *format, int *arr, int arrlen)
	{
		bool ret = true;
		int cnt = 0;
		const char *pf = format;
		while(*pf && ret)
		{
			if ('%'==*pf && cnt<arrlen && ret)
			{
				pf++;
				switch (*pf)
				{
				case 'c'://char 
					arr[cnt++] = PARA_CHAR;
					break;
				case 'd'://int
					arr[cnt++] = PARA_INT;
					break;
				case 'f'://float
					arr[cnt++] = PARA_FLOAT;
					break;
				case 'l'://if *(++pf)=='f' double
					if(*(++pf)=='f')
						arr[cnt++]  = PARA_DOUBLE;
					else
						ret = false;
					break;
				case 'b'://bool
					arr[cnt++] = PARA_BOOL;
					break;
				case 's'://string
					arr[cnt++] = PARA_STRING;
					break;
				default:
					ret = false;
					Log.outError("Bad Argument.\n");
					break;
				}
				pf++;
			}
			else 
				ret = false;
		}

		if (ret)
			return cnt;
		else
			return -1;
		return 0;
	}

	bool PushValue(lua_State *L, int &nparams,const char *format, va_list vl)
	{
		nparams = 0;
		int paras[MAX_LUA_FUNC_PARA_NUM];
		bool flag = true;
		nparams = AnalyticalParam::AnalysisVariablePara(format, paras, MAX_LUA_FUNC_PARA_NUM);
		if (-1==nparams)
		{
			return false;
		}

		for (int i=0; i<nparams && flag; ++i)
		{
			switch (paras[i])
			{
				//
			case PARA_CHAR:
				{
					int ch = va_arg(vl, int);
					lua_pushinteger(L, ch);
					break;
				}
			case PARA_INT:
				{
					int num = va_arg(vl, int);
					lua_pushinteger(L, num);
					break;
				}
			case PARA_FLOAT:
				{
					//c语言并未提供 va_arg(vl, float),详见 <<C Traps and Pitfalls>>
					float fl = (float)(va_arg(vl, double));
					lua_pushnumber(L, fl*1.000000f);
					break;
				}
			case PARA_DOUBLE:
				{
					double db = (double)va_arg(vl, double);
					lua_pushnumber(L, db*1.000000f);
					break;
				}
			case PARA_BOOL:
				{
					int i = va_arg(vl, int);
					lua_pushinteger(L,i);
					break;
				}
			case PARA_STRING:
				{
					char *str = va_arg(vl, char*);
					lua_pushstring(L, str);
					break;
				}
			default:
				flag = false;
				break;
			}
		}
		return flag==true;
	}
	


	
	bool ReadParamFloat(lua_State *L, char *data, int &currentpos, int datasize)
	{
		if (currentpos+(int)sizeof(float)<=datasize)
		{
			int val = *((int *)(data[currentpos]));
			lua_pushnumber(L, val*0.001f);
			currentpos += sizeof(int);
			return true;
		}
		else
			return false;
		return false;
	}

	
	bool ReadParamString(lua_State *L, char *data, int &currentpos, int datasize)
	{
		if (currentpos+(int)sizeof(uint16)<=datasize)
		{
			uint16 count = *((uint16*)&(data[currentpos]));
			currentpos += sizeof(uint16);
			if (currentpos+(int)count<=datasize)
			{
				static char text[4096];
				memset(text, 0, 4096);
				memcpy(text, &(data[currentpos]), count );
				currentpos += count;
				lua_pushstring(L, (char *)text);
				return true;
			}
			else
				return false;
		}
		else
			return false;
		return false;
	}

}
}