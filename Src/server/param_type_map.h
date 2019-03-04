#ifndef _AUENGINE_SRC_AUENGINE_PARAM_TYPE_MAP_H_
#define _AUENGINE_SRC_AUENGINE_PARAM_TYPE_MAP_H_

//这里不使用负数是为了后面宏利用这些数字产生一些宏，使用负数的时候负号会导致失败

#define		LUA_PARAM_TYPE_ERROR		0
#define		LUA_PARAM_TYPE_BEG			1
#define		LUA_PARAM_TYPE_REPEAT		2
#define		LUA_PARAM_TYPE_UINT32		3
#define		LUA_PARAM_TYPE_INT32		4
#define		LUA_PARAM_TYPE_UINT16		5
#define		LUA_PARAM_TYPE_INT16		6
#define		LUA_PARAM_TYPE_UINT8		7
#define		LUA_PARAM_TYPE_INT8			8
#define		LUA_PARAM_TYPE_BOOL			9
#define		LUA_PARAM_TYPE_FLOAT		10
#define		LUA_PARAM_TYPE_STRING		11
#define		LUA_PARAM_TYPE_END			12

#endif 