#ifndef _AUENGINE_SRC_SERVER_SERVERCOMMON_CONFIG_STRUCT_H_
#define _AUENGINE_SRC_SERVER_SERVERCOMMON_CONFIG_STRUCT_H_
#ifdef WIN32 
#include "basesocket.h"
#endif
#ifdef WIN32
#define AU_VALIDE_SOCKET_FD INVALID_SOCKET
#else
#define AU_VALIDE_SOCKET_FD -1
#endif

#define GLOBAL_CONFIG_PATH						"./Au.xml"

#define CHUNK_1									"Server"
#define CHUNK_2									"CalcServer"
#define CHUNK_3									"Robot"


#define LUA_INFO								"LuaInfo"
#define LUAENGINE_ENTRANCELUAFILE_NODE			"EntranceLuaFile"
#define LUAENGINE_INITENGINEFUNC_NODE			"InitEngineFunc"
#define LUAENGINE_MESSAGECONFIGFILEPATH_NODE	"MessageConfigFilePath"
#define LUAENGINE_SCRIPTINITFUNC_NODE			"ScriptInitFunc" 

#define NETWORK_INFO							"NetWorkInfo"
#define NETWORK_KEY								"key"
#define NETWORK_TYPE							"type"
#define NETWORK_IP								"ip"
#define NETWORK_PORT							"port"

#define MEMCACHED_INFO							"MemcachedInfo"
#define MEMCACHED_TYPE							"type"
#define MEMCACHED_NAME                          "name"
#define MEMCACHED_IP                            "ip"
#define MEMCACHED_PORT                          "port"

#define MYSQL_INFO                              "MysqlInfo"
#define MYSQL_HOSTNAME                          "Hostname"
#define MYSQL_USERNAME                          "Username"
#define MYSQL_PASSWORD							"Password"
#define MYSQL_NAME								"Name"
#define MYSQL_PORT								"Port"

typedef struct LuaEngineInfo
{
	std::string _msgconfigfilepath;
	std::string _entrance_luafile;
	std::string _scriptinitfunc;
	std::string _initenginefunc;
}LuaEngineInfo;

typedef struct NetworkInfo
{
	std::string _key;
	std::string _type;
	std::string _ip;
	std::string _port;
}NetworkInfo;

typedef struct MemcachedInfo
{
	std::string _type;
	std::string _name;
	std::string _ip;
	std::string _port;
}MemcachedInfo;

typedef struct MysqlInfo
{
	std::string _hostname;
	std::string _username;
	std::string _password;
	std::string _name;
	std::string _port;
}MysqlInfo;

typedef struct ChunkInfo
{
	LuaEngineInfo _luainfo;
	NetworkInfo   _networkinfo;
	MemcachedInfo _memcachedinfo;
	MysqlInfo     _mysqlinfo;
}ChunkInfo;


//服务器名：Server ,Key 与 sockfd的映射。
typedef struct ServerSockNode
{
	ServerSockNode()
	{
#ifdef WIN32
		_sockfd = AU_VALIDE_SOCKET_FD;
#else
		_sockfd = AU_VALIDE_SOCKET_FD;
#endif 
	}
	std::string _servername;
	unsigned int _sockfd ;
}ServerSockNode;

#endif